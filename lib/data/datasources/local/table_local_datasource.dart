import '../../../core/utils/constants.dart';
import '../../models/table_model.dart';
import 'hive_service.dart';

class TableLocalDataSource {
  Future<void> saveTables(List<TableModel> tables) async {
    final box = HiveService.getTableBox();
    await box.clear();

    for (final table in tables) {
      await box.put(table.id, table.toJson());
    }
  }

  Future<List<TableModel>> getTables() async {
    return HiveService.getTableBox().values
        .whereType<Map>()
        .map((item) => TableModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> saveSelectedTableId(String tableId) async {
    await HiveService.settingsBox.put(HiveKeys.selectedTableId, tableId);
  }

  Future<TableModel?> getSelectedTable() async {
    final tableId =
        HiveService.settingsBox.get(HiveKeys.selectedTableId) as String?;

    if (tableId == null || tableId.isEmpty) {
      return null;
    }

    final raw = HiveService.getTableBox().get(tableId);
    if (raw is! Map) {
      return null;
    }

    return TableModel.fromJson(Map<String, dynamic>.from(raw));
  }
}
