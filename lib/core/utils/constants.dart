import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFF6F22);
  static const Color secondary = Color(0xFFE53935);
  static const Color error = Color(0xFFD32F2F);

  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF4F4F5);
  static const Color lightOnSurface = Color(0xFF171717);

  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF1C1C1E);
  static const Color darkOnSurface = Color(0xFFF7F7F8);
}

class AppStrings {
  static const String appName = 'Ordenow';
  static const String appTagline = 'Order faster, clearly, and without waiting.';
}

class HiveBoxes {
  static const String settings = 'settings_box';
  static const String user = 'user_box';
  static const String order = 'order_box';
  static const String menu = 'menu_box';
  static const String table = 'table_box';
}

class HiveKeys {
  static const String themeMode = 'theme_mode';
  static const String languageCode = 'language_code';
  static const String currentUserId = 'current_user_id';
  static const String selectedTableId = 'selected_table_id';
  static const String orderHistory = 'order_history_';
}

class SupabaseTables {
  static const String user = 'users';
  static const String menu = 'menu_items';
  static const String order = 'orders';
  static const String table = 'restaurant_tables';
  static const String cashRequest = 'cash_requests';
}

class OrderStatuses {
  static const String pending = 'pending';
  static const String accepted = 'accepted';
  static const String preparing = 'preparing';
  static const String ready = 'ready';
  static const String delivered = 'delivered';
  static const String completed = 'completed';
}
