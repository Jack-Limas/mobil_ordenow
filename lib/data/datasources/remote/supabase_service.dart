import '../../../core/config/supabase_config.dart';
import '../../../core/utils/constants.dart';

class SupabaseService {
  static final client = SupabaseConfig.client;

  // ---------- USER ----------

  static Future<void> upsertUser(Map<String, dynamic> data) async {
    await client.from(SupabaseTables.user).upsert(data);
  }

  static Future<List<Map<String, dynamic>>> getUsers() async {
    final res = await client.from(SupabaseTables.user).select();
    return List<Map<String, dynamic>>.from(res);
  }

  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final res = await client
        .from(SupabaseTables.user)
        .select()
        .eq('email', email)
        .maybeSingle();

    if (res == null) {
      return null;
    }

    return Map<String, dynamic>.from(res);
  }

  // ---------- MENU ----------

  static Future<List<Map<String, dynamic>>> getMenu() async {
    final res = await client.from(SupabaseTables.menu).select();
    return List<Map<String, dynamic>>.from(res);
  }

  // ---------- ORDER ----------

  static Future<void> upsertOrder(Map<String, dynamic> data) async {
    await client.from(SupabaseTables.order).upsert(data);
  }

  static Future<List<Map<String, dynamic>>> getOrders() async {
    final res = await client.from(SupabaseTables.order).select();
    return List<Map<String, dynamic>>.from(res);
  }

  static Future<List<Map<String, dynamic>>> getOrdersByUser(
    String userId,
  ) async {
    final res =
        await client.from(SupabaseTables.order).select().eq('user_id', userId);
    return List<Map<String, dynamic>>.from(res);
  }

  // ---------- TABLE ----------

  static Future<List<Map<String, dynamic>>> getTables() async {
    final res = await client.from(SupabaseTables.table).select();
    return List<Map<String, dynamic>>.from(res);
  }
}
