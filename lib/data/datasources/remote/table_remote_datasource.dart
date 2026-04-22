import '../../models/table_model.dart';
import 'supabase_service.dart';

class TableRemoteDataSource {
  Future<List<TableModel>> getTables() async {
    final tables = await SupabaseService.getTables();
    return tables.map(TableModel.fromJson).toList();
  }
}
