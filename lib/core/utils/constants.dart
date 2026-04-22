import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFF6B00);
  static const Color secondary = Color(0xFFE53935);
  static const Color error = Color(0xFFD32F2F);

  static const Color lightBackground = Color(0xFFFFF7F2);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF221B17);

  static const Color darkBackground = Color(0xFF18110D);
  static const Color darkSurface = Color(0xFF2A211C);
  static const Color darkOnSurface = Color(0xFFF9EDE5);
}

class AppStrings {
  static const String appName = 'OrdeNow';
  static const String appTagline = 'Pide rapido, claro y sin filas.';
}

class HiveBoxes {
  static const String settings = 'settings_box';
}

class HiveKeys {
  static const String themeMode = 'theme_mode';
  static const String languageCode = 'language_code';
}
