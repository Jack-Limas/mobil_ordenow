import '../entities/table.dart';

abstract class TableRepository {
  Future<List<TableEntity>> getTables();

  Future<void> selectTable(String tableId);

  Future<TableEntity?> getSelectedTable();
}