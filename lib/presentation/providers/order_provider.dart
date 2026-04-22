import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/constants.dart';
import '../../domain/entities/menu.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/table.dart';

class OrderProvider extends ChangeNotifier {
  final Uuid _uuid = const Uuid();

  final List<Menu> _menu = [
    Menu(
      id: 'menu-1',
      name: 'Saffron Sea Scallops',
      description: 'Silky scallops with saffron butter and citrus pearls.',
      price: 68000,
      category: 'Main',
      available: true,
      recommended: true,
      tags: const ['seafood', 'light', 'chef pick'],
    ),
    Menu(
      id: 'menu-2',
      name: 'Midnight Pasta',
      description: 'Black garlic cream pasta with mushrooms and parmesan.',
      price: 52000,
      category: 'Main',
      available: true,
      recommended: true,
      tags: const ['vegetarian', 'comfort'],
    ),
    Menu(
      id: 'menu-3',
      name: 'Smoked Ribeye',
      description: 'Charcoal ribeye with roasted potato and demi-glace.',
      price: 78000,
      category: 'Signature',
      available: true,
      recommended: true,
      tags: const ['beef', 'premium'],
    ),
    Menu(
      id: 'menu-4',
      name: 'Artisan Harvest Bowl',
      description: 'Warm quinoa, greens, avocado, mango and house dressing.',
      price: 44000,
      category: 'Healthy',
      available: true,
      recommended: false,
      tags: const ['healthy', 'gluten free'],
    ),
    Menu(
      id: 'menu-5',
      name: 'Lychee Ginger Fizz',
      description: 'Sparkling lychee drink with ginger and mint.',
      price: 18000,
      category: 'Drink',
      available: true,
      recommended: true,
      tags: const ['drink', 'fresh'],
    ),
    Menu(
      id: 'menu-6',
      name: 'Cacao Old Fashioned',
      description: 'Dark cacao twist on a classic old fashioned.',
      price: 26000,
      category: 'Drink',
      available: true,
      recommended: false,
      tags: const ['drink', 'cocktail'],
    ),
  ];

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

  List<Menu> get menu => List.unmodifiable(_menu);
  List<TableEntity> get tables => List.unmodifiable(_tables);
  String? get selectedTableId => _selectedTableId;
  Order? get activeOrder => _activeOrder;
  String get paymentMethod => _paymentMethod;

  List<Menu> get recommendedMenu =>
      _menu.where((item) => item.recommended).toList();

  List<Menu> get cartItems => _cartMenuIds
      .map((id) => _menu.firstWhere((item) => item.id == id))
      .toList();

  double get cartTotal =>
      cartItems.fold(0, (total, item) => total + item.price);

  bool get hasActiveOrder => _activeOrder != null;
  bool get hasSelectedTable => _selectedTableId != null;
  bool get isPaid => _activeOrder?.paid ?? false;

  String get currentOrderStatus => _activeOrder?.status ?? OrderStatuses.pending;

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

  List<TableEntity> get pendingPaymentTables =>
      _tables.where((table) => table.needsPayment).toList();

  List<TableEntity> get occupiedTables =>
      _tables.where((table) => table.occupied).toList();

  void selectTable(String tableId) {
    _selectedTableId = tableId;
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

  void setPaymentMethod(String value) {
    _paymentMethod = value;
    notifyListeners();
  }

  void placeDemoOrder({
    required String userId,
    String notes = '',
  }) {
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
    notifyListeners();
  }

  void requestCashDesk() {
    _updateTableState(occupied: true, needsPayment: true);
    notifyListeners();
  }

  void clearDemoState() {
    _selectedTableId = null;
    _cartMenuIds.clear();
    _activeOrder = null;
    _paymentMethod = 'card';

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

    return _tables.firstWhere((table) => table.id == _selectedTableId);
  }

  List<Menu> get orderedItems {
    if (_activeOrder == null) {
      return const [];
    }

    return _activeOrder!.items
        .map((id) => _menu.firstWhere((item) => item.id == id))
        .toList();
  }

  void _updateTableState({
    required bool occupied,
    required bool needsPayment,
  }) {
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
  }
}
