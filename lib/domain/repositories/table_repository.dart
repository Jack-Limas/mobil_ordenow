import '../entities/table.dart';

abstract class TableRepository {
  Future<List<TableEntity>> getTables();

  Stream<List<TableEntity>> watchTables();

  Future<void> selectTable(String tableId);

  Future<void> reserveTable(String tableId);

  Future<TableEntity?> getSelectedTable();
}
