import '../../models/user_model.dart';
import 'supabase_service.dart';

class AuthRemoteDataSource {
  Future<UserModel> register(UserModel user) async {
    final response = await SupabaseService.client.auth.signUp(
      email: user.email,
      password: user.password,
      data: {'full_name': user.fullName, 'role': user.role},
    );

    final authUser = response.user;
    if (authUser == null) {
      throw StateError('Supabase did not return a registered user.');
    }

    final registeredUser = UserModel.fromEntity(user.copyWith(id: authUser.id));
    final profileUser = UserModel.fromEntity(
      registeredUser.copyWith(password: ''),
    );
    await SupabaseService.upsertUser(profileUser.toJson());

    return registeredUser;
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await SupabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final authUser = response.user;

      if (authUser == null) {
        return null;
      }

      final rawUser =
          await SupabaseService.getUserById(authUser.id) ??
          await SupabaseService.getUserByEmail(email);

      final roleFromMeta =
          authUser.userMetadata?['role'] as String? ?? 'client';

      if (rawUser != null) {
        final model = UserModel.fromJson(rawUser);
        if (model.role == 'client' && roleFromMeta != 'client') {
          return UserModel.fromEntity(model.copyWith(role: roleFromMeta));
        }
        return model;
      }

      return UserModel(
        id: authUser.id,
        email: authUser.email ?? email,
        fullName: authUser.userMetadata?['full_name'] as String? ?? '',
        password: '',
        role: roleFromMeta,
        allergies: const [],
        preferences: const [],
        createdAt: DateTime.tryParse(authUser.createdAt) ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (_) {
      final rawUser = await SupabaseService.getUserByEmail(email);
      if (rawUser == null) {
        return null;
      }

      final model = UserModel.fromJson(rawUser);
      if (model.password != password) {
        return null;
      }

      return model;
    }
  }

  Future<void> logout() async {
    await SupabaseService.client.auth.signOut();
  }

  Future<UserModel> updateProfile(UserModel user) async {
    await SupabaseService.updateUserProfile(user.id, {
      'full_name': user.fullName,
      'allergies': user.allergies,
      'preferences': user.preferences,
      'updated_at': user.updatedAt.toIso8601String(),
    });
    return user;
  }
}
