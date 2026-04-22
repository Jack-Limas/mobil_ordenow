import '../../../core/config/supabase_config.dart';

class SupabaseService {
  static final client = SupabaseConfig.client;

  // ---------- USER ----------

  static Future insertUser(Map<String, dynamic> data) async {
    await client.from('user').insert(data);
  }

  static Future<List<Map<String, dynamic>>> getUsers() async {
    final res = await client.from('user').select();
    return List<Map<String, dynamic>>.from(res);
  }

  // ---------- MENU ----------

  static Future<List<Map<String, dynamic>>> getMenu() async {
    final res = await client.from('menu').select();
    return List<Map<String, dynamic>>.from(res);
  }

  // ---------- ORDER ----------

  static Future insertOrder(Map<String, dynamic> data) async {
    await client.from('order').insert(data);
  }

  static Future<List<Map<String, dynamic>>> getOrders() async {
    final res = await client.from('order').select();
    return List<Map<String, dynamic>>.from(res);
  }

  // ---------- TABLE ----------

  static Future<List<Map<String, dynamic>>> getTables() async {
    final res = await client.from('table').select();
    return List<Map<String, dynamic>>.from(res);
  }
}