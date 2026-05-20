import '../../data/datasources/local/hive_service.dart';
import '../../data/datasources/remote/supabase_service.dart';

class SyncService {
  /// Pushes only orders that were saved offline (synced == false) to Supabase.
  /// Called automatically when connectivity is restored.
  static Future<void> syncUnsyncedOrders() async {
    final box = HiveService.getOrderBox();
    for (final key in box.keys.toList()) {
      final raw = box.get(key);
      if (raw == null) continue;
      final data = Map<String, dynamic>.from(raw as Map);
      if (data['synced'] == true) continue;
      try {
        final payload = Map<String, dynamic>.from(data)..remove('synced');
        await SupabaseService.upsertOrder(payload);
        data['synced'] = true;
        await box.put(key, data);
      } catch (_) {}
    }
  }

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
