import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/config/app_dependencies.dart';
import 'core/config/app_bootstrap.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/ai_provider.dart';
import 'presentation/providers/app_demo_provider.dart';
import 'presentation/providers/app_settings_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/order_provider.dart';
import 'presentation/screens/app_shell_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBootstrap.initialize();
  final dependencies = AppDependencies();

  runApp(OrdeNowApp(dependencies: dependencies));
}

class OrdeNowApp extends StatelessWidget {
  const OrdeNowApp({
    super.key,
    required this.dependencies,
  });

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppSettingsProvider()..loadPreferences(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            loginUser: dependencies.loginUser,
            registerUser: dependencies.registerUser,
            getCurrentUser: dependencies.getCurrentUser,
            logoutUser: dependencies.logoutUser,
          )..loadCurrentUser(),
        ),
        ChangeNotifierProvider(create: (_) => AppDemoProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => AiProvider()),
      ],
      child: Consumer<AppSettingsProvider>(
        builder: (context, settingsProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'OrdeNow',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsProvider.themeMode,
            locale: settingsProvider.locale,
            supportedLocales: const [
              Locale('es'),
              Locale('en'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const AppShellScreen(),
          );
        },
      ),
    );
  }
}
