import '../entities/user.dart';
import '../repositories/user_repository.dart';

class GetCurrentUser {
  GetCurrentUser(this._repository);

  final UserRepository _repository;

  Future<User?> call() {
    return _repository.getCurrentUser();
  }
}
