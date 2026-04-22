import '../../../core/utils/constants.dart';
import '../../models/user_model.dart';
import 'hive_service.dart';

class AuthLocalDataSource {
  Future<void> saveUser(UserModel user) async {
    await HiveService.getUserBox().put(user.id, user.toJson());
    await HiveService.settingsBox.put(HiveKeys.currentUserId, user.id);
  }

  Future<UserModel?> getCurrentUser() async {
    final currentUserId =
        HiveService.settingsBox.get(HiveKeys.currentUserId) as String?;

    if (currentUserId == null || currentUserId.isEmpty) {
      return null;
    }

    final raw = HiveService.getUserBox().get(currentUserId);
    if (raw is! Map) {
      return null;
    }

    return UserModel.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<UserModel?> findUserByEmail(String email) async {
    final users = HiveService.getUserBox().values
        .whereType<Map>()
        .map((item) => UserModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    for (final user in users) {
      if (user.email.toLowerCase() == email.toLowerCase()) {
        return user;
      }
    }

    return null;
  }

  Future<void> logout() async {
    await HiveService.settingsBox.delete(HiveKeys.currentUserId);
  }
}
