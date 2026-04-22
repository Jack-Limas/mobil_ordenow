import '../../models/menu_model.dart';
import 'supabase_service.dart';

class MenuRemoteDataSource {
  Future<List<MenuModel>> getMenu() async {
    final menu = await SupabaseService.getMenu();
    return menu.map(MenuModel.fromJson).toList();
  }
}
