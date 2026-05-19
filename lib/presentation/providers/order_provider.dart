import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/constants.dart';
import '../../data/datasources/remote/supabase_service.dart';
import '../../data/models/menu_model.dart';
import '../../data/models/order_model.dart';
import '../../domain/entities/menu.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/table.dart';

class CartLineItem {
  const CartLineItem({required this.menu, required this.quantity});

  final Menu menu;
  final int quantity;

  double get total => menu.price * quantity;
}

class OrderProvider extends ChangeNotifier {
  final Uuid _uuid = const Uuid();
  StreamSubscription<List<Map<String, dynamic>>>? _menuSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _activeOrderSubscription;

  List<Menu> _menu = [];

  final List<TableEntity> _tables = List.generate(
    8,
    (index) => TableEntity(
      id: 'table-${index + 1}',
      number: index + 1,
      occupied: index == 1 || index == 4,
      needsPayment: index == 4,
    ),
  );

  String? _selectedTableId;
  final List<String> _cartMenuIds = [];
  Order? _activeOrder;
  String _paymentMethod = 'card';
  String _diningPreferences = '';

  OrderProvider() {
    _loadRemoteMenu();
    _subscribeToMenu();
  }

  List<Menu> get menu => List.unmodifiable(_menu);
  List<TableEntity> get tables => List.unmodifiable(_tables);
  String? get selectedTableId => _selectedTableId;
  Order? get activeOrder => _activeOrder;
  String get paymentMethod => _paymentMethod;
  String get diningPreferences => _diningPreferences;

  List<Menu> get recommendedMenu =>
      _menu.where((item) => item.recommended).toList();

  List<Menu> get cartItems => _cartMenuIds
      .map((id) => _menu.firstWhere((item) => item.id == id))
      .toList();

  double get cartTotal =>
      cartItems.fold(0, (total, item) => total + item.price);

  double get serviceFee => 0;

  double get checkoutTotal => cartTotal + serviceFee;

  bool get hasActiveOrder => _activeOrder != null;
  bool get hasSelectedTable => _selectedTableId != null;
  bool get isPaid => _activeOrder?.paid ?? false;

  String get currentOrderStatus =>
      _activeOrder?.status ?? OrderStatuses.pending;

  int get orderStepIndex {
    switch (_activeOrder?.status) {
      case OrderStatuses.accepted:
        return 1;
      case OrderStatuses.preparing:
        return 2;
      case OrderStatuses.ready:
        return 3;
      case OrderStatuses.delivered:
      case OrderStatuses.completed:
        return 4;
      default:
        return 0;
    }
  }

  // 0=Recibido, 1=Cocinando, 2=Reparto, 3=Entregado
  int get trackingStep {
    switch (_activeOrder?.status) {
      case OrderStatuses.preparing:
        return 1;
      case OrderStatuses.ready:
        return 2;
      case OrderStatuses.delivered:
      case OrderStatuses.completed:
        return 3;
      default:
        return 0;
    }
  }

  List<TableEntity> get pendingPaymentTables =>
      _tables.where((table) => table.needsPayment).toList();

  List<TableEntity> get occupiedTables =>
      _tables.where((table) => table.occupied).toList();

  List<CartLineItem> get cartLineItems {
    final quantities = <String, int>{};
    for (final id in _cartMenuIds) {
      quantities.update(id, (value) => value + 1, ifAbsent: () => 1);
    }

    return quantities.entries.map((entry) {
      final menuItem = _menu.firstWhere((item) => item.id == entry.key);
      return CartLineItem(menu: menuItem, quantity: entry.value);
    }).toList();
  }

  void selectTable(String tableId) {
    _selectedTableId = tableId;
    notifyListeners();
  }

  void selectTableEntity(TableEntity table) {
    final index = _tables.indexWhere((item) => item.id == table.id);
    if (index == -1) {
      _tables.add(table);
    } else {
      _tables[index] = table;
    }

    _selectedTableId = table.id;
    notifyListeners();
  }

  void setDiningPreferences(String value) {
    _diningPreferences = value;
    notifyListeners();
  }

  void addItemToCart(String menuId) {
    _cartMenuIds.add(menuId);
    notifyListeners();
  }

  void removeItemFromCart(String menuId) {
    _cartMenuIds.remove(menuId);
    notifyListeners();
  }

  void decrementItemQuantity(String menuId) {
    final index = _cartMenuIds.indexOf(menuId);
    if (index == -1) {
      return;
    }

    _cartMenuIds.removeAt(index);
    notifyListeners();
  }

  void setPaymentMethod(String value) {
    _paymentMethod = value;
    notifyListeners();
  }

  void placeDemoOrder({required String userId, String notes = ''}) {
    if (_selectedTableId == null || _cartMenuIds.isEmpty) {
      return;
    }

    final now = DateTime.now();
    _activeOrder = Order(
      id: _uuid.v4(),
      userId: userId,
      tableId: _selectedTableId!,
      items: List<String>.from(_cartMenuIds),
      status: OrderStatuses.accepted,
      createdAt: now,
      updatedAt: now,
      paid: false,
      paymentMethod: _paymentMethod,
      totalAmount: cartTotal,
      notes: notes,
      synced: false,
    );

    _cartMenuIds.clear();
    _updateTableState(occupied: true, needsPayment: false);
    notifyListeners();

    _syncActiveOrder();
    _subscribeToActiveOrder(userId);
  }

  void advanceKitchenStatus() {
    if (_activeOrder == null) {
      return;
    }

    final nextStatus = switch (_activeOrder!.status) {
      OrderStatuses.accepted => OrderStatuses.preparing,
      OrderStatuses.preparing => OrderStatuses.ready,
      OrderStatuses.ready => OrderStatuses.delivered,
      OrderStatuses.delivered => OrderStatuses.completed,
      _ => _activeOrder!.status,
    };

    _activeOrder = Order(
      id: _activeOrder!.id,
      userId: _activeOrder!.userId,
      tableId: _activeOrder!.tableId,
      items: _activeOrder!.items,
      status: nextStatus,
      createdAt: _activeOrder!.createdAt,
      updatedAt: DateTime.now(),
      paid: _activeOrder!.paid,
      paymentMethod: _activeOrder!.paymentMethod,
      totalAmount: _activeOrder!.totalAmount,
      notes: _activeOrder!.notes,
      synced: _activeOrder!.synced,
    );

    _syncActiveOrder();
    notifyListeners();
  }

  void markAsPaid({String? paymentMethod}) {
    if (_activeOrder == null) {
      return;
    }

    _activeOrder = Order(
      id: _activeOrder!.id,
      userId: _activeOrder!.userId,
      tableId: _activeOrder!.tableId,
      items: _activeOrder!.items,
      status: _activeOrder!.status,
      createdAt: _activeOrder!.createdAt,
      updatedAt: DateTime.now(),
      paid: true,
      paymentMethod: paymentMethod ?? _activeOrder!.paymentMethod,
      totalAmount: _activeOrder!.totalAmount,
      notes: _activeOrder!.notes,
      synced: _activeOrder!.synced,
    );

    _updateTableState(occupied: true, needsPayment: false);
    _syncActiveOrder();
    _syncPaymentState(
      paid: true,
      paymentMethod: paymentMethod ?? _activeOrder!.paymentMethod,
    );
    notifyListeners();
  }

  void requestCashDesk() {
    _updateTableState(occupied: true, needsPayment: true);
    _syncActiveOrder();
    _syncCashRequest();
    notifyListeners();
  }

  void finalizeDigitalPayment() {
    markAsPaid(paymentMethod: 'digital');
  }

  void requestCashPayment() {
    requestCashDesk();
  }

  void clearDemoState() {
    _selectedTableId = null;
    _cartMenuIds.clear();
    _activeOrder = null;
    _activeOrderSubscription?.cancel();
    _activeOrderSubscription = null;
    _paymentMethod = 'card';
    _diningPreferences = '';

    for (var i = 0; i < _tables.length; i++) {
      _tables[i] = TableEntity(
        id: _tables[i].id,
        number: _tables[i].number,
        occupied: i == 1 || i == 4,
        needsPayment: i == 4,
      );
    }

    notifyListeners();
  }

  TableEntity? get selectedTable {
    if (_selectedTableId == null) {
      return null;
    }

    for (final table in _tables) {
      if (table.id == _selectedTableId) {
        return table;
      }
    }

    return null;
  }

  List<Menu> get orderedItems {
    if (_activeOrder == null) {
      return const [];
    }

    return _activeOrder!.items
        .map((id) => _menu.firstWhere((item) => item.id == id))
        .toList();
  }

  void _updateTableState({required bool occupied, required bool needsPayment}) {
    if (_selectedTableId == null) {
      return;
    }

    final index = _tables.indexWhere((table) => table.id == _selectedTableId);
    if (index == -1) {
      return;
    }

    final current = _tables[index];
    _tables[index] = TableEntity(
      id: current.id,
      number: current.number,
      occupied: occupied,
      needsPayment: needsPayment,
    );

    _syncTableState(current.id, occupied: occupied, needsPayment: needsPayment);
  }

  Future<void> _loadRemoteMenu() async {
    try {
      final rows = await SupabaseService.getMenu();
      _applyRemoteMenu(rows);
    } catch (_) {
      // Demo menu remains available when Supabase is not reachable.
    }
  }

  void _subscribeToMenu() {
    try {
      _menuSubscription = SupabaseService.watchMenu().listen(
        _applyRemoteMenu,
        onError: (_) {},
      );
    } catch (_) {}
  }

  void _applyRemoteMenu(List<Map<String, dynamic>> rows) {
    _menu = rows.map(MenuModel.fromJson).toList();
    _cartMenuIds.removeWhere((id) => !_menu.any((item) => item.id == id));
    notifyListeners();
  }

  void _subscribeToActiveOrder(String userId) {
    _activeOrderSubscription?.cancel();
    try {
      _activeOrderSubscription = SupabaseService.watchOrdersByUser(userId)
          .listen((rows) {
            if (_activeOrder == null) {
              return;
            }

            Map<String, dynamic>? row;
            for (final item in rows) {
              if (item['id'] == _activeOrder!.id) {
                row = item;
                break;
              }
            }

            if (row == null) {
              return;
            }

            _activeOrder = OrderModel.fromJson(row);
            notifyListeners();
          }, onError: (_) {});
    } catch (_) {}
  }

  Future<void> _syncActiveOrder() async {
    final order = _activeOrder;
    if (order == null) {
      return;
    }

    try {
      await SupabaseService.upsertOrder(OrderModel.fromEntity(order).toJson());
    } catch (_) {
      // Local state keeps the customer flow usable if the network is down.
    }
  }

  Future<void> _syncPaymentState({
    required bool paid,
    required String paymentMethod,
  }) async {
    final order = _activeOrder;
    if (order == null) {
      return;
    }

    try {
      await SupabaseService.updateOrderPayment(
        orderId: order.id,
        paid: paid,
        paymentMethod: paymentMethod,
      );
    } catch (_) {}
  }

  Future<void> _syncCashRequest() async {
    final order = _activeOrder;
    if (order == null) {
      return;
    }

    try {
      await SupabaseService.insertCashRequest({
        'id': _uuid.v4(),
        'order_id': order.id,
        'table_id': order.tableId,
        'amount': order.totalAmount,
        'method': 'cash',
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  Future<void> _syncTableState(
    String tableId, {
    required bool occupied,
    required bool needsPayment,
  }) async {
    try {
      await SupabaseService.updateTableStatus(
        tableId: tableId,
        occupied: occupied,
        needsPayment: needsPayment,
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _menuSubscription?.cancel();
    _activeOrderSubscription?.cancel();
    super.dispose();
  }
}
