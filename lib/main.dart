import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/config/app_dependencies.dart';
import 'core/config/app_bootstrap.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/admin_dashboard_provider.dart';
import 'presentation/providers/menu_management_provider.dart';
import 'presentation/providers/orders_kds_provider.dart';
import 'presentation/providers/ai_provider.dart';
import 'presentation/providers/app_demo_provider.dart';
import 'presentation/providers/app_settings_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/order_provider.dart';
import 'presentation/providers/table_provider.dart';
import 'presentation/screens/app_shell_screen.dart';

Future<void> main() async {
  // 1. Asegura que los canales nativos de Flutter estén listos
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 2. Inicializa Supabase, Hive y las configuraciones base de la app
    await AppBootstrap.initialize();
  } catch (e) {
    debugPrint("⚠️ Advertencia en Bootstrap: $e");
    // Esto evita que la app se muera si 'seedTablesIfEmpty' falla por aserción
  }

  // 3. Carga el contenedor de dependencias funcionales
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
        // El AppSettingsProvider cargará idioma y tema desde Hive de inmediato
        ChangeNotifierProvider(
          create: (_) => AppSettingsProvider()..loadPreferences(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            loginUser: dependencies.loginUser,
            registerUser: dependencies.registerUser,
            getCurrentUser: dependencies.getCurrentUser,
            logoutUser: dependencies.logoutUser,
            updateUserProfile: dependencies.updateUserProfile,
          )..loadCurrentUser(),
        ),
        ChangeNotifierProvider(create: (_) => AppDemoProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(
          create: (_) => TableProvider(
            getTables: dependencies.getTables,
            watchTables: dependencies.watchTables,
            reserveTable: dependencies.reserveTable,
            getSelectedTable: dependencies.getSelectedTable,
          )..initialize(),
        ),
        ChangeNotifierProvider(create: (_) => AiProvider()),
        ChangeNotifierProvider(create: (_) => AdminDashboardProvider()),
        ChangeNotifierProvider(create: (_) => OrdersKdsProvider()),
        ChangeNotifierProvider(create: (_) => MenuManagementProvider()),
      ],
      child: Consumer<AppSettingsProvider>(
        builder: (context, settingsProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'OrdeNow',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsProvider.themeMode, // Sincronizado en tiempo real
            locale: settingsProvider.locale,       // Sincronizado en tiempo real
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