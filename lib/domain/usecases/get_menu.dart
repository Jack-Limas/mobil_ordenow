import '../entities/menu.dart';
import '../repositories/menu_repository.dart';

class GetMenu {
  GetMenu(this._repository);

  final MenuRepository _repository;

  Future<List<Menu>> call() {
    return _repository.getMenu();
  }
}
