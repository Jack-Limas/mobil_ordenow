import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/datasources/remote/order_remote_datasource.dart';

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
  static const _demoSparkline = <double>[
    1800000,
    1650000,
    2100000,
    1950000,
    2200000,
    2450000,
  ];
  static const _demoFlowBars = <double>[8, 12, 15, 10, 17, 14];

  static const _demoPopular = <DashPopularDish>[
    DashPopularDish(
        menuId: 'menu-4', name: 'Ensalada de Dragón Exótico', sales: 42),
    DashPopularDish(
        menuId: 'menu-3', name: 'Corte Prime Chimichurri', sales: 31),
    DashPopularDish(
        menuId: 'menu-2', name: 'Burger Nean Orgánico', sales: 19),
  ];

  static const _demoRecent = <DashRecentOrder>[
    DashRecentOrder(
        shortId: '#M21',
        label: 'Mesa 12 (Toronja)',
        status: 'preparing',
        total: 84200),
    DashRecentOrder(
        shortId: '#M20',
        label: 'Juan Delgado',
        status: 'delivered',
        total: 72100),
    DashRecentOrder(
        shortId: '#M19',
        label: 'Mesa 7 (Mandarina)',
        status: 'preparing',
        total: 52500),
    DashRecentOrder(
        shortId: '#M18',
        label: 'Carlos Rivera',
        status: 'ready',
        total: 91300),
  ];

  double _salesToday = 2450000;
  int _activeOrders = 12;
  double _avgTicket = 42500;
  bool _showActive = true;
  List<DashPopularDish> _popular = List.from(_demoPopular);
  List<DashRecentOrder> _recent = List.from(_demoRecent);

  StreamSubscription<List<Map<String, dynamic>>>? _sub;

  double get salesToday => _salesToday;
  int get activeOrders => _activeOrders;
  double get avgTicket => _avgTicket;
  bool get showActive => _showActive;
  List<DashPopularDish> get popularDishes => List.unmodifiable(_popular);
  List<DashRecentOrder> get recentOrders => List.unmodifiable(_recent);
  List<double> get salesSparkline => _demoSparkline;
  List<double> get flowBars => _demoFlowBars;

  AdminDashboardProvider() {
    _initStreams();
  }

  void _initStreams() {
    try {
      _sub = OrderRemoteDataSource()
          .watchAllOrders()
          .listen(_processOrders, onError: (_) {});
    } catch (_) {}
  }

  void _processOrders(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return;
    final today = DateTime.now();

    final paidRows = rows.where((r) {
      final created = DateTime.tryParse(r['created_at']?.toString() ?? '');
      final isToday = created != null &&
          created.year == today.year &&
          created.month == today.month &&
          created.day == today.day;
      return isToday &&
          (r['status'] == 'completed' || r['status'] == 'paid');
    }).toList();

    const activeStatuses = {'accepted', 'preparing', 'ready'};
    final activeRows = rows
        .where((r) => activeStatuses.contains(r['status']?.toString()))
        .toList();

    _salesToday = paidRows.fold(
        0.0, (s, r) => s + ((r['total_amount'] as num?)?.toDouble() ?? 0));
    _activeOrders = activeRows.length;
    _avgTicket = paidRows.isEmpty ? 0 : _salesToday / paidRows.length;

    _recent = rows.take(20).map((r) {
      final id = r['id']?.toString() ?? '';
      final shortId =
          '#M${id.substring(0, id.length.clamp(0, 2)).toUpperCase()}';
      return DashRecentOrder(
        shortId: shortId,
        label: 'Mesa ${r['table_id'] ?? '-'}',
        status: r['status']?.toString() ?? 'pending',
        total: (r['total_amount'] as num?)?.toDouble() ?? 0,
      );
    }).toList();

    notifyListeners();
  }

  void setTab({required bool showActive}) {
    _showActive = showActive;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
