import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/datasources/remote/supabase_service.dart';
import '../../data/models/table_model.dart';
import '../../domain/entities/table.dart';

class DashPopularDish {
  final String menuId;
  final String name;
  final int sales;

  const DashPopularDish({
    required this.menuId,
    required this.name,
    required this.sales,
  });
}

class DashRecentOrder {
  final String shortId;
  final String label;
  final String status;
  final double total;

  const DashRecentOrder({
    required this.shortId,
    required this.label,
    required this.status,
    required this.total,
  });
}

class AdminDashboardProvider extends ChangeNotifier {
  StreamSubscription<List<Map<String, dynamic>>>? _ordersSub;
  StreamSubscription<List<Map<String, dynamic>>>? _tablesSub;

  List<TableEntity> _tables = const [];
  List<Map<String, dynamic>> _orders = const [];

  List<TableEntity> get tables => List.unmodifiable(_tables);
  bool get showActive => true;
  List<DashPopularDish> get popularDishes => const [];
  List<double> get salesSparkline => const [];
  List<double> get flowBars => const [];
  List<TableEntity> get occupiedTables =>
      _tables.where((t) => t.occupied || t.needsPayment).toList()
        ..sort((a, b) => a.number.compareTo(b.number));

  int get activeOrders {
    final now = DateTime.now();
    return _orders.where((o) {
      if (!_isActiveOrder(o)) return false;
      final created = DateTime.tryParse(o['created_at']?.toString() ?? '');
      if (created == null) return false;
      return created.year == now.year &&
          created.month == now.month &&
          created.day == now.day;
    }).length;
  }

  double get salesToday {
    final now = DateTime.now();
    return _orders
        .where((order) {
          final created = DateTime.tryParse(
            order['created_at']?.toString() ?? '',
          );
          final isToday =
              created != null &&
              created.year == now.year &&
              created.month == now.month &&
              created.day == now.day;
          return isToday &&
              (order['paid'] == true ||
                  order['status'] == 'completed' ||
                  order['status'] == 'paid');
        })
        .fold(
          0.0,
          (total, order) =>
              total + ((order['total_amount'] as num?)?.toDouble() ?? 0),
        );
  }

  double get avgTicket {
    final paid = _orders.where((order) {
      return order['paid'] == true ||
          order['status'] == 'completed' ||
          order['status'] == 'paid';
    }).toList();
    if (paid.isEmpty) return 0;
    final total = paid.fold(
      0.0,
      (sum, order) => sum + ((order['total_amount'] as num?)?.toDouble() ?? 0),
    );
    return total / paid.length;
  }

  List<DashRecentOrder> get recentOrders => _orders.take(12).map((order) {
    final id = order['id']?.toString() ?? '';
    final short = id.isEmpty
        ? '#---'
        : '#${id.substring(0, id.length < 4 ? id.length : 4).toUpperCase()}';
    final table = tableForId(order['table_id']?.toString() ?? '');
    return DashRecentOrder(
      shortId: short,
      label: table == null ? 'Mesa sin asignar' : 'Mesa ${table.number}',
      status: order['status']?.toString() ?? 'pending',
      total: (order['total_amount'] as num?)?.toDouble() ?? 0,
    );
  }).toList();

  AdminDashboardProvider() {
    _loadInitialData();
    _initStreams();
  }

  TableEntity? tableForId(String tableId) {
    for (final table in _tables) {
      if (table.id == tableId) return table;
    }
    return null;
  }

  Map<String, dynamic>? activeOrderForTable(String tableId) {
    for (final order in _orders) {
      if (order['table_id'] == tableId && _isActiveOrder(order)) {
        return order;
      }
    }
    return null;
  }

  Future<void> releaseTable(String tableId) async {
    final activeOrder = activeOrderForTable(tableId);

    // Optimistic update: mark table as free immediately.
    _tables = _tables.map((t) {
      if (t.id == tableId) return t.copyWith(occupied: false, needsPayment: false);
      return t;
    }).toList();
    notifyListeners();

    // Each operation in its own try-catch so one failure doesn't block the other.
    if (activeOrder != null) {
      try {
        await SupabaseService.updateOrderStatus(
          orderId: activeOrder['id'] as String,
          status: 'completed',
        );
      } catch (_) {}
    }

    try {
      await SupabaseService.updateTableStatus(
        tableId: tableId,
        occupied: false,
        needsPayment: false,
      );
    } catch (_) {}
  }

  void setTab({required bool showActive}) {}

  Future<void> _loadInitialData() async {
    try {
      final rows = await SupabaseService.getTables();
      _tables = rows.map(TableModel.fromJson).toList();
      notifyListeners();
    } catch (_) {}

    try {
      _orders = await SupabaseService.getOrders();
      notifyListeners();
    } catch (_) {}
  }

  void _initStreams() {
    try {
      _tablesSub = SupabaseService.watchTables().listen((rows) {
        _tables = rows.map(TableModel.fromJson).toList();
        notifyListeners();
      }, onError: (_) {});

      _ordersSub = SupabaseService.watchAllOrders().listen((rows) {
        _orders = rows;
        notifyListeners();
      }, onError: (_) {});
    } catch (_) {}
  }

  bool _isActiveOrder(Map<String, dynamic> order) {
    const active = {'pending', 'accepted', 'preparing', 'ready', 'delivered'};
    return active.contains(order['status']?.toString());
  }

  @override
  void dispose() {
    _ordersSub?.cancel();
    _tablesSub?.cancel();
    super.dispose();
  }
}
