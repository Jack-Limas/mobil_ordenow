import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ordenow/core/theme/app_theme.dart';
import 'package:ordenow/presentation/providers/app_settings_provider.dart';
import 'package:ordenow/presentation/screens/app_shell_screen.dart';

void main() {
  testWidgets('shows OrdeNow app shell', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppSettingsProvider(),
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
