import '../repositories/user_repository.dart';

class LogoutUser {
  LogoutUser(this._repository);

  final UserRepository _repository;

  Future<void> call() {
    return _repository.logout();
  }
}
