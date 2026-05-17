import '../entities/user.dart';

abstract class UserRepository {
  Future<User?> login(String email, String password);

  Future<User> register(User user);

  Future<User?> getCurrentUser();

  Future<void> saveLocal(User user);

  Future<void> logout();
}
