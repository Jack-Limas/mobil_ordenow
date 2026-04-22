import '../../domain/entities/menu.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasources/local/menu_local_datasource.dart';
import '../datasources/remote/menu_remote_datasource.dart';
import '../models/menu_model.dart';

class MenuRepositoryImpl implements MenuRepository {
  MenuRepositoryImpl({
    required MenuRemoteDataSource remoteDataSource,
    required MenuLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final MenuRemoteDataSource _remoteDataSource;
  final MenuLocalDataSource _localDataSource;

  @override
  Future<List<Menu>> getMenu() async {
    try {
      final remoteMenu = await _remoteDataSource.getMenu();
      await _localDataSource.saveMenu(remoteMenu);
      return remoteMenu;
    } catch (_) {
      return _localDataSource.getMenu();
    }
  }

  @override
  Future<void> saveLocal(List<Menu> menu) async {
    final models = menu.map(MenuModel.fromEntity).toList();
    await _localDataSource.saveMenu(models);
  }

  @override
  Future<void> syncMenu() async {
    final remoteMenu = await _remoteDataSource.getMenu();
    await _localDataSource.saveMenu(remoteMenu);
  }
}
