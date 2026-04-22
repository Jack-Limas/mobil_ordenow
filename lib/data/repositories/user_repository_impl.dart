import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  @override
  Future<User?> getCurrentUser() async {
    return _localDataSource.getCurrentUser();
  }

  @override
  Future<User?> login(String email, String password) async {
    try {
      final remoteUser = await _remoteDataSource.login(email, password);
      if (remoteUser != null) {
        await _localDataSource.saveUser(remoteUser);
        return remoteUser;
      }
    } catch (_) {
      // Falls back to local authentication below.
    }

    final localUser = await _localDataSource.findUserByEmail(email);
    if (localUser == null || localUser.password != password) {
      return null;
    }

    await _localDataSource.saveUser(localUser);
    return localUser;
  }

  @override
  Future<void> logout() async {
    await _localDataSource.logout();
  }

  @override
  Future<void> register(User user) async {
    final model = UserModel.fromEntity(user);

    await _localDataSource.saveUser(model);

    try {
      await _remoteDataSource.register(model);
    } catch (_) {
      // The local copy remains available for offline mode.
    }
  }

  @override
  Future<void> saveLocal(User user) async {
    await _localDataSource.saveUser(UserModel.fromEntity(user));
  }
}
