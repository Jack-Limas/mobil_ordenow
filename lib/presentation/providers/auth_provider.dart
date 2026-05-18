import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/update_user_profile.dart';

enum AuthState { idle, loading, authenticated, unauthenticated, error }

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
  AuthState _state = AuthState.idle;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == AuthState.loading;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get hasCompletedProfile =>
      _currentUser != null && _currentUser!.fullName.isNotEmpty;
  String get userRole => _currentUser?.role ?? 'client';
  bool get isAdmin => userRole == 'admin';
  bool get isClient => userRole == 'client';

  Future<void> loadCurrentUser() async {
    _setState(AuthState.loading);

    try {
      _currentUser = await _getCurrentUser();
      _errorMessage = null;
      _setState(
        _currentUser != null ? AuthState.authenticated : AuthState.unauthenticated,
      );
    } catch (_) {
      _errorMessage = 'Unable to restore the current session.';
      _setState(AuthState.error);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setState(AuthState.loading);

    try {
      final user = await _loginUser(
        email: email.trim(),
        password: password.trim(),
      );

      if (user == null) {
        _errorMessage = 'Invalid email or password.';
        _setState(AuthState.error);
        return false;
      }

      _currentUser = user;
      _errorMessage = null;
      _setState(AuthState.authenticated);
      return true;
    } catch (_) {
      _errorMessage = 'The login process failed.';
      _setState(AuthState.error);
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    String role = 'client',
  }) async {
    _setState(AuthState.loading);

    try {
      final user = User(
        id: _uuid.v4(),
        email: email.trim().toLowerCase(),
        fullName: fullName.trim(),
        password: password.trim(),
        role: role,
        allergies: const [],
        preferences: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _currentUser = await _registerUser(user);
      _errorMessage = null;
      _setState(AuthState.authenticated);
      return true;
    } catch (_) {
      _errorMessage = 'The register process failed.';
      _setState(AuthState.error);
      return false;
    }
  }

  Future<void> logout() async {
    _setState(AuthState.loading);

    try {
      await _logoutUser();
      _currentUser = null;
      _errorMessage = null;
      _setState(AuthState.unauthenticated);
    } catch (_) {
      _errorMessage = 'Unable to close the session.';
      _setState(AuthState.error);
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

    _setState(AuthState.loading);

    try {
      _currentUser = await _updateUserProfile(
        user.copyWith(
          allergies: allergies,
          preferences: preferences,
          updatedAt: DateTime.now(),
        ),
      );
      _errorMessage = null;
      _setState(AuthState.authenticated);
      return true;
    } catch (_) {
      _errorMessage = 'Unable to update the initial profile.';
      _setState(AuthState.error);
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _setState(
        _currentUser != null ? AuthState.authenticated : AuthState.unauthenticated,
      );
    }
  }

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }
}
