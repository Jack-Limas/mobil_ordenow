import '../entities/user.dart';
import '../repositories/user_repository.dart';

class UpdateUserProfile {
  UpdateUserProfile(this._repository);

  final UserRepository _repository;

  Future<User> call(User user) {
    return _repository.updateProfile(user);
  }
}
