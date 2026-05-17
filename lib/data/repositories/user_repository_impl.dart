import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

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
    if (localUser == null ||
        localUser.password.isEmpty ||
        localUser.password != password) {
      return null;
    }

    await _localDataSource.saveUser(localUser);
    return localUser;
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {
      // Hive still owns the local session cleanup for offline-safe logout.
    }

    await _localDataSource.logout();
  }

  @override
  Future<User> register(User user) async {
    final model = UserModel.fromEntity(user);

    try {
      final remoteUser = await _remoteDataSource.register(model);
      await _localDataSource.saveUser(remoteUser);
      return remoteUser;
    } on supabase.AuthException { // <--- AQUÍ SE CORRIGIÓ: Se le agregó 'supabase.'
      rethrow;
    } catch (_) {
      await _localDataSource.saveUser(model);
      return model;
    }
  }

  @override
  Future<void> saveLocal(User user) async {
    await _localDataSource.saveUser(UserModel.fromEntity(user));
  }

  @override
  Future<User> updateProfile(User user) async {
    final model = UserModel.fromEntity(user);

    try {
      final remoteUser = await _remoteDataSource.updateProfile(model);
      await _localDataSource.saveUser(remoteUser);
      return remoteUser;
    } catch (_) {
      await _localDataSource.saveUser(model);
      return model;
    }
  }
}