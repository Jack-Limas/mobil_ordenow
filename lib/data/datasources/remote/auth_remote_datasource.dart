import '../../models/user_model.dart';
import 'supabase_service.dart';

class AuthRemoteDataSource {
  Future<void> register(UserModel user) async {
    await SupabaseService.upsertUser(user.toJson());
  }

  Future<UserModel?> login(String email, String password) async {
    final rawUser = await SupabaseService.getUserByEmail(email);
    if (rawUser == null) {
      return null;
    }

    final user = UserModel.fromJson(rawUser);
    if (user.password != password) {
      return null;
    }

    return user;
  }
}
