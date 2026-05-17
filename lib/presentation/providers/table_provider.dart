import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/entities/table.dart';
import '../../domain/usecases/get_selected_table.dart';
import '../../domain/usecases/get_tables.dart';
import '../../domain/usecases/reserve_table.dart';
import '../../domain/usecases/watch_tables.dart';

class TableProvider extends ChangeNotifier {
  TableProvider({
    required GetTables getTables,
    required WatchTables watchTables,
    required ReserveTable reserveTable,
    required GetSelectedTable getSelectedTable,
  })  : _getTables = getTables,
        _watchTables = watchTables,
        _reserveTable = reserveTable,
        _getSelectedTable = getSelectedTable;

  final GetTables _getTables;
  final WatchTables _watchTables;
  final ReserveTable _reserveTable;
  final GetSelectedTable _getSelectedTable;

  StreamSubscription<List<TableEntity>>? _tableSubscription;
  List<TableEntity> _tables = const [];
  String? _selectedTableId;
  bool _isLoading = false;
  bool _isReserving = false;
  String? _errorMessage;

  List<TableEntity> get tables => List.unmodifiable(_tables);
  String? get selectedTableId => _selectedTableId;
  bool get isLoading => _isLoading;
  bool get isReserving => _isReserving;
  String? get errorMessage => _errorMessage;
  bool get hasTables => _tables.isNotEmpty;

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

  Future<void> initialize() async {
    await _restoreSelectedTable();
    await loadTables();
    _subscribeToTables();
  }

  Future<void> loadTables() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tables = await _getTables();
    } catch (_) {
      _errorMessage = 'Unable to load tables.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> reserve(TableEntity table) async {
    if (!table.isSelectable) {
      _errorMessage = 'This table is not available.';
      notifyListeners();
      return false;
    }

    _isReserving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _reserveTable(table.id);
      _selectedTableId = table.id;
      return true;
    } catch (_) {
      _errorMessage = 'Unable to reserve this table.';
      return false;
    } finally {
      _isReserving = false;
      notifyListeners();
    }
  }

  bool choose(TableEntity table) {
    if (!table.isSelectable) {
      _errorMessage = 'This table is not available.';
      notifyListeners();
      return false;
    }

    _selectedTableId = table.id;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _restoreSelectedTable() async {
    final selected = await _getSelectedTable();
    _selectedTableId = selected?.id;
  }

  void _subscribeToTables() {
    _tableSubscription?.cancel();
    _tableSubscription = _watchTables().listen(
      (tables) {
        _tables = tables;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (_) {
        _errorMessage = 'Realtime table updates are unavailable.';
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _tableSubscription?.cancel();
    super.dispose();
  }
}
