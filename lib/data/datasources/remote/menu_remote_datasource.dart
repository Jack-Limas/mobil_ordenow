import '../../models/menu_model.dart';
import 'supabase_service.dart';

class MenuRemoteDataSource {
  Future<List<MenuModel>> getMenu() async {
    final menu = await SupabaseService.getMenu();
    return menu.map(MenuModel.fromJson).toList();
  }

  Future<void> createMenuItem(Map<String, dynamic> data) async {
    await SupabaseService.createMenuItem(data);
  }

  Future<void> updateMenuItem(String id, Map<String, dynamic> data) async {
    await SupabaseService.updateMenuItem(id, data);
  }

  Future<void> deleteMenuItem(String id) async {
    await SupabaseService.deleteMenuItem(id);
  }
}
