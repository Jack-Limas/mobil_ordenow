import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ordenow/core/theme/app_theme.dart';
import 'package:ordenow/presentation/providers/app_settings_provider.dart';
import 'package:ordenow/presentation/providers/auth_provider.dart';
import 'package:ordenow/presentation/screens/app_shell_screen.dart';
import 'package:ordenow/domain/usecases/get_current_user.dart';
import 'package:ordenow/domain/usecases/login_user.dart';
import 'package:ordenow/domain/usecases/logout_user.dart';
import 'package:ordenow/domain/usecases/register_user.dart';
import 'package:ordenow/domain/repositories/user_repository.dart';
import 'package:ordenow/domain/entities/user.dart';

void main() {
  testWidgets('shows OrdeNow app shell', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
          ChangeNotifierProvider(
            create: (_) => AuthProvider(
              loginUser: LoginUser(_FakeUserRepository()),
              registerUser: RegisterUser(_FakeUserRepository()),
              getCurrentUser: GetCurrentUser(_FakeUserRepository()),
              logoutUser: LogoutUser(_FakeUserRepository()),
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const AppShellScreen(),
        ),
      ),
    );

    expect(find.text('OrdeNow'), findsOneWidget);
    expect(find.text('Configuracion inicial'), findsOneWidget);
  });
}

class _FakeUserRepository implements UserRepository {
  @override
  Future<User?> getCurrentUser() async => null;

  @override
  Future<User?> login(String email, String password) async => null;

  @override
  Future<void> logout() async {}

  @override
  Future<void> register(User user) async {}

  @override
  Future<void> saveLocal(User user) async {}
}
