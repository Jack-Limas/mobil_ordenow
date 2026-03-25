import '../entities/menu.dart';

abstract class MenuRepository {
  Future<List<Menu>> getMenu();

  Future<void> saveLocal(List<Menu> menu);

  Future<void> syncMenu();
}