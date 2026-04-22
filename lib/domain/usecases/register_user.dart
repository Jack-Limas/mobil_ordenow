import '../entities/user.dart';
import '../repositories/user_repository.dart';

class RegisterUser {
  RegisterUser(this._repository);

  final UserRepository _repository;

  Future<void> call(User user) {
    return _repository.register(user);
  }
}
