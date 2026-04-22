import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/config/app_bootstrap.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/app_settings_provider.dart';
import 'presentation/screens/app_shell_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBootstrap.initialize();

  runApp(const OrdeNowApp());
}

class OrdeNowApp extends StatelessWidget {
  const OrdeNowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppSettingsProvider()..loadPreferences(),
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