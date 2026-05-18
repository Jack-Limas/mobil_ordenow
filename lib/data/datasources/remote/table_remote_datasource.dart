import '../../models/table_model.dart';
import 'supabase_service.dart';

class TableRemoteDataSource {
  Future<List<TableModel>> getTables() async {
    final tables = await SupabaseService.getTables();
    return tables.map(TableModel.fromJson).toList();
  }

  Stream<List<TableModel>> watchTables() {
    return SupabaseService.watchTables().map(
      (tables) => tables.map(TableModel.fromJson).toList(),
    );
  }

  Future<void> reserveTable(String tableId) {
    return SupabaseService.updateTableStatus(
      tableId: tableId,
      occupied: true,
      needsPayment: false,
    );
  }

  Future<void> releaseTable(String tableId) {
    return SupabaseService.updateTableStatus(
      tableId: tableId,
      occupied: false,
      needsPayment: false,
    );
  }
}
