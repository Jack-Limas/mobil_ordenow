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
  final bool paid;
  final String paymentMethod;

  const KdsActiveOrder({
    required this.id,
    required this.tableId,
    required this.itemIds,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.notes,
    this.paid = false,
    this.paymentMethod = '',
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
      _ordersSub = _ds.watchActiveOrders().listen((rows) {
        _activeOrders =
            rows.map((r) {
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
                paid: (r['paid'] as bool?) ?? false,
                paymentMethod: r['payment_method'] as String? ?? '',
              );
            }).toList()..sort((a, b) {
              final tableA = _tableNumbers[a.tableId] ?? 9999;
              final tableB = _tableNumbers[b.tableId] ?? 9999;
              final byTable = tableA.compareTo(tableB);
              if (byTable != 0) return byTable;
              return a.createdAt.compareTo(b.createdAt);
            });
        notifyListeners();
      }, onError: (_) {});
      _cashSub = _ds.watchAllPendingCashRequests().listen((rows) {
        _pendingCash = rows.map((r) {
          return KdsCashRequest(
            id: r['id'] as String,
            tableId: r['table_id'] as String,
            amount: (r['amount'] as num?)?.toDouble() ?? 0,
          );
        }).toList();
        notifyListeners();
      }, onError: (_) {});
    } catch (_) {}
  }

  Future<void> refreshPaymentStatus(String orderId) async {
    try {
      final rows = await SupabaseService.getOrders();
      Map<String, dynamic>? row;
      for (final r in rows) {
        if (r['id'] == orderId) {
          row = r;
          break;
        }
      }
      if (row == null) return;
      final paid = (row['paid'] as bool?) ?? false;
      final method = row['payment_method'] as String? ?? '';
      _activeOrders = _activeOrders.map((o) {
        if (o.id != orderId) return o;
        return KdsActiveOrder(
          id: o.id,
          tableId: o.tableId,
          itemIds: o.itemIds,
          status: o.status,
          totalAmount: o.totalAmount,
          createdAt: o.createdAt,
          notes: o.notes,
          paid: paid,
          paymentMethod: method,
        );
      }).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> startPreparation(String orderId) async {
    _updateLocalStatus(orderId, 'preparing');
    try {
      await _ds.updateOrderStatus(orderId: orderId, status: 'preparing');
    } catch (_) {}
  }

  Future<void> markReady(String orderId, String label) async {
    _updateLocalStatus(orderId, 'ready');
    try {
      await _ds.updateOrderStatus(orderId: orderId, status: 'ready');
      await NotificationService.notifyOrderReady(
        tableLabel: label,
        orderId: orderId,
      );
    } catch (_) {}
  }

  void _updateLocalStatus(String orderId, String status) {
    _activeOrders = _activeOrders.map((o) {
      if (o.id != orderId) return o;
      return KdsActiveOrder(
        id: o.id,
        tableId: o.tableId,
        itemIds: o.itemIds,
        status: status,
        totalAmount: o.totalAmount,
        createdAt: o.createdAt,
        notes: o.notes,
        paid: o.paid,
        paymentMethod: o.paymentMethod,
      );
    }).toList();
    notifyListeners();
  }

  Future<void> confirmCashPayment({
    required String requestId,
    required String tableId,
  }) async {
    KdsActiveOrder? order;
    for (final o in _activeOrders) {
      if (o.tableId == tableId) {
        order = o;
        break;
      }
    }
    if (order != null) {
      _activeOrders = _activeOrders.where((o) => o.id != order!.id).toList();
    }
    _pendingCash = _pendingCash.where((c) => c.id != requestId).toList();
    notifyListeners();
    try {
      await _ds.updateCashRequestStatus(
        requestId: requestId,
        status: 'confirmed',
      );
      if (order != null) {
        await _ds.updateOrderStatus(orderId: order.id, status: 'completed');
      }
      await SupabaseService.updateTableStatus(
        tableId: tableId,
        occupied: false,
        needsPayment: false,
      );
    } catch (_) {}
  }

  Future<void> releaseTable({
    required String orderId,
    required String tableId,
  }) async {
    _activeOrders = _activeOrders.where((o) => o.id != orderId).toList();
    notifyListeners();
    try {
      await _ds.updateOrderStatus(orderId: orderId, status: 'completed');
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
