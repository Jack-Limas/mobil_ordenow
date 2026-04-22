import '../../models/menu_model.dart';
import 'hive_service.dart';

class MenuLocalDataSource {
  Future<void> saveMenu(List<MenuModel> menu) async {
    final box = HiveService.getMenuBox();
    await box.clear();

    for (final item in menu) {
      await box.put(item.id, item.toJson());
    }
  }

  Future<List<MenuModel>> getMenu() async {
    return HiveService.getMenuBox().values
        .whereType<Map>()
        .map((item) => MenuModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
