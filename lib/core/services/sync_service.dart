import '../../data/datasources/local/hive_service.dart';
import '../../data/datasources/remote/supabase_service.dart';

class SyncService {
  static Future<void> syncOrders() async {
    final box = HiveService.getOrderBox();

    for (final item in box.values) {
      await SupabaseService.upsertOrder(Map<String, dynamic>.from(item));
    }
  }

  static Future<void> syncUsers() async {
    final box = HiveService.getUserBox();

    for (final item in box.values) {
      await SupabaseService.upsertUser(Map<String, dynamic>.from(item));
    }
  }

  static Future<void> syncMenu() async {
    final menu = await SupabaseService.getMenu();

    final box = HiveService.getMenuBox();

    await box.clear();

    for (var m in menu) {
      await box.add(m);
    }
  }

  static Future<void> syncTables() async {
    final tables = await SupabaseService.getTables();

    final box = HiveService.getTableBox();

    await box.clear();

    for (var t in tables) {
      await box.add(t);
    }
  }
}
