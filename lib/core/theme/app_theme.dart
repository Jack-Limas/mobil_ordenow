import 'package:flutter/material.dart';

class AppTheme {
  static const Color orange = Color(0xFFFF6F22);
  static const Color darkBg = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF1C1C1E);
  static const Color darkSurface2 = Color(0xFF2C2C2E);
  static const Color lightBg = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF2F2F7);
  static const Color lightSurface2 = Color(0xFFE5E5EA);

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        useMaterial3: false,
        scaffoldBackgroundColor: darkBg,
        cardColor: darkSurface,
        canvasColor: darkBg,
        colorScheme: const ColorScheme.dark(
          primary: orange,
          secondary: orange,
          surface: darkSurface,
          background: darkBg,
          onBackground: Colors.white,
          onSurface: Colors.white,
          onPrimary: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: darkBg,
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: darkBg,
          selectedItemColor: orange,
          unselectedItemColor: Color(0xFF8E8E93),
          type: BottomNavigationBarType.fixed,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: darkSurface2,
          labelStyle: const TextStyle(color: Colors.white),
          side: BorderSide.none,
        ),
        dividerColor: darkSurface2,
        iconTheme: const IconThemeData(color: Colors.white),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Color(0xFF8E8E93)),
          titleLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(color: Colors.white),
          labelMedium: TextStyle(color: Color(0xFF8E8E93)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkSurface,
          hintStyle: const TextStyle(color: Color(0xFF8E8E93)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: orange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          ),
        ),
      );

  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        useMaterial3: false,
        scaffoldBackgroundColor: lightBg,
        cardColor: lightSurface,
        canvasColor: lightBg,
        colorScheme: const ColorScheme.light(
          primary: orange,
          secondary: orange,
          surface: lightSurface,
          background: lightBg,
          onBackground: Color(0xFF000000),
          onSurface: Color(0xFF000000),
          onPrimary: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: lightBg,
          foregroundColor: Color(0xFF000000),
          iconTheme: IconThemeData(color: Color(0xFF000000)),
          titleTextStyle: TextStyle(
            color: Color(0xFF000000),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: lightBg,
          selectedItemColor: orange,
          unselectedItemColor: Color(0xFF8E8E93),
          type: BottomNavigationBarType.fixed,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: lightSurface2,
          labelStyle: const TextStyle(color: Color(0xFF000000)),
          side: BorderSide.none,
        ),
        dividerColor: lightSurface2,
        iconTheme: const IconThemeData(color: Color(0xFF000000)),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF000000)),
          bodyMedium: TextStyle(color: Color(0xFF6C6C70)),
          titleLarge: TextStyle(
            color: Color(0xFF000000),
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(color: Color(0xFF000000)),
          labelMedium: TextStyle(color: Color(0xFF6C6C70)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: lightSurface,
          hintStyle: const TextStyle(color: Color(0xFF8E8E93)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: orange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          ),
        ),
      );
}
