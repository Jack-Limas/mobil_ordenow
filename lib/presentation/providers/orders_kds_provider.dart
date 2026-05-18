import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/services/notification_service.dart';
import '../../data/datasources/remote/order_remote_datasource.dart';
import '../../data/datasources/remote/supabase_service.dart';

class KdsActiveOrder {
  final String id;
  final String tableId;
  final List<String> itemIds;
  final String status;
  final double totalAmount;
  final DateTime createdAt;
  final String notes;

  const KdsActiveOrder({
    required this.id,
    required this.tableId,
    required this.itemIds,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.notes,
  });
}

class KdsCashRequest {
  final String id;
  final String tableId;
  final double amount;

  const KdsCashRequest({
    required this.id,
    required this.tableId,
    required this.amount,
  });
}

class OrdersKdsProvider extends ChangeNotifier {
  final _ds = OrderRemoteDataSource();
  StreamSubscription? _ordersSub;
  StreamSubscription? _cashSub;

  List<KdsActiveOrder> _activeOrders = [];
  List<KdsCashRequest> _pendingCash = [];
  Map<String, String> _menuNames = {};
  Map<String, int> _tableNumbers = {};

  List<KdsActiveOrder> get activeOrders => List.unmodifiable(_activeOrders);
  List<KdsCashRequest> get pendingCash => List.unmodifiable(_pendingCash);
  int get activeCount => _activeOrders.length;

  String itemName(String id) => _menuNames[id] ?? id;

  String tableLabel(String tableId) {
    final num = _tableNumbers[tableId];
    return num != null ? 'Mesa $num' : 'Mesa —';
  }

  double orderTotalForTable(String tableId) {
    for (final o in _activeOrders) {
      if (o.tableId == tableId) return o.totalAmount;
    }
    return 0;
  }

  OrdersKdsProvider() {
    _loadLookups();
    _initStreams();
  }

  Future<void> _loadLookups() async {
    try {
      final menuRows = await SupabaseService.getMenu();
      _menuNames = {
        for (final r in menuRows) r['id'] as String: r['name'] as String,
      };
    } catch (_) {}
    try {
      final tableRows = await SupabaseService.getTables();
      _tableNumbers = {
        for (final r in tableRows)
          r['id'] as String: (r['number'] as num).toInt(),
      };
    } catch (_) {}
    notifyListeners();
  }

  void _initStreams() {
    try {
      _ordersSub = _ds.watchActiveOrders().listen(
        (rows) {
          _activeOrders = rows.map((r) {
            return KdsActiveOrder(
              id: r['id'] as String,
              tableId: r['table_id'] as String,
              itemIds: List<String>.from(r['items'] ?? const []),
              status: r['status'] as String,
              totalAmount: (r['total_amount'] as num?)?.toDouble() ?? 0,
              createdAt:
                  DateTime.tryParse(r['created_at'] as String? ?? '') ??
                  DateTime.now(),
              notes: r['notes'] as String? ?? '',
            );
          }).toList();
          notifyListeners();
        },
        onError: (_) {},
      );
      _cashSub = _ds.watchAllPendingCashRequests().listen(
        (rows) {
          _pendingCash = rows.map((r) {
            return KdsCashRequest(
              id: r['id'] as String,
              tableId: r['table_id'] as String,
              amount: (r['amount'] as num?)?.toDouble() ?? 0,
            );
          }).toList();
          notifyListeners();
        },
        onError: (_) {},
      );
    } catch (_) {}
  }

  Future<void> startPreparation(String orderId) async {
    try {
      await _ds.updateOrderStatus(orderId: orderId, status: 'preparing');
    } catch (_) {}
  }

  Future<void> markReady(String orderId, String label) async {
    try {
      await _ds.updateOrderStatus(orderId: orderId, status: 'ready');
      await NotificationService.notifyOrderReady(
        tableLabel: label,
        orderId: orderId,
      );
    } catch (_) {}
  }

  Future<void> confirmCashPayment({
    required String requestId,
    required String tableId,
  }) async {
    try {
      KdsActiveOrder? order;
      for (final o in _activeOrders) {
        if (o.tableId == tableId) {
          order = o;
          break;
        }
      }
      await _ds.updateCashRequestStatus(
        requestId: requestId,
        status: 'confirmed',
      );
      if (order != null) {
        await _ds.updateOrderStatus(orderId: order.id, status: 'paid');
      }
      await SupabaseService.updateTableStatus(
        tableId: tableId,
        occupied: false,
        needsPayment: false,
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _ordersSub?.cancel();
    _cashSub?.cancel();
    super.dispose();
  }
}
