import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/update_user_profile.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required LoginUser loginUser,
    required RegisterUser registerUser,
    required GetCurrentUser getCurrentUser,
    required LogoutUser logoutUser,
    required UpdateUserProfile updateUserProfile,
  })  : _loginUser = loginUser,
        _registerUser = registerUser,
        _getCurrentUser = getCurrentUser,
        _logoutUser = logoutUser,
        _updateUserProfile = updateUserProfile;

  final LoginUser _loginUser;
  final RegisterUser _registerUser;
  final GetCurrentUser _getCurrentUser;
  final LogoutUser _logoutUser;
  final UpdateUserProfile _updateUserProfile;
  final Uuid _uuid = const Uuid();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  Future<void> loadCurrentUser() async {
    _setLoading(true);

    try {
      _currentUser = await _getCurrentUser();
      _errorMessage = null;
    } catch (_) {
      _errorMessage = 'Unable to restore the current session.';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      final user = await _loginUser(
        email: email.trim(),
        password: password.trim(),
      );

      if (user == null) {
        _errorMessage = 'Invalid email or password.';
        return false;
      }

      _currentUser = user;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'The login process failed.';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      final normalizedEmail = email.trim().toLowerCase();
      final normalizedName = fullName.trim();
      final normalizedPassword = password.trim();

      final user = User(
        id: _uuid.v4(),
        email: normalizedEmail,
        fullName: normalizedName,
        password: normalizedPassword,
        allergies: const [],
        preferences: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _currentUser = await _registerUser(user);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'The register process failed.';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);

    try {
      await _logoutUser();
      _currentUser = null;
      _errorMessage = null;
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Unable to close the session.';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateInitialProfile({
    required List<String> allergies,
    required List<String> preferences,
  }) async {
    final user = _currentUser;
    if (user == null) {
      _errorMessage = 'No active user session.';
      notifyListeners();
      return false;
    }

    _setLoading(true);

    try {
      _currentUser = await _updateUserProfile(
        user.copyWith(
          allergies: allergies,
          preferences: preferences,
          updatedAt: DateTime.now(),
        ),
      );
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Unable to update the initial profile.';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
