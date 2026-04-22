import '../entities/user.dart';
import '../repositories/user_repository.dart';

class LoginUser {
  LoginUser(this._repository);

  final UserRepository _repository;

  Future<User?> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email, password);
  }
}
