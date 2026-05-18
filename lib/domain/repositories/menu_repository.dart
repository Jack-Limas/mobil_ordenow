import '../entities/menu.dart';

abstract class MenuRepository {
  Future<List<Menu>> getMenu();

  Future<void> saveLocal(List<Menu> menu);

  Future<void> syncMenu();

  Future<void> createMenuItem(Map<String, dynamic> data);

  Future<void> updateMenuItem(String id, Map<String, dynamic> data);

  Future<void> deleteMenuItem(String id);
}