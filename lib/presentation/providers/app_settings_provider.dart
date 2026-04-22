import 'package:flutter/material.dart';

import '../../core/utils/constants.dart';
import '../../data/datasources/local/hive_service.dart';

class AppSettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('es');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  Future<void> loadPreferences() async {
    final settingsBox = HiveService.settingsBox;
    final savedTheme = settingsBox.get(HiveKeys.themeMode) as String?;
    final savedLanguageCode =
        settingsBox.get(HiveKeys.languageCode) as String?;

    if (savedTheme != null) {
      _themeMode = _themeModeFromValue(savedTheme);
    }

    if (savedLanguageCode != null && savedLanguageCode.isNotEmpty) {
      _locale = Locale(savedLanguageCode);
    }

    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    await HiveService.settingsBox.put(
      HiveKeys.themeMode,
      themeMode.name,
    );
    notifyListeners();
  }

  Future<void> updateLanguage(String languageCode) async {
    _locale = Locale(languageCode);
    await HiveService.settingsBox.put(HiveKeys.languageCode, languageCode);
    notifyListeners();
  }

  ThemeMode _themeModeFromValue(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
