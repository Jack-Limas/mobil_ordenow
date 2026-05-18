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

  static Future<Map<String, dynamic>?> getUserById(String id) async {
    final res = await client
        .from(SupabaseTables.user)
        .select()
        .eq('id', id)
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

  static Stream<List<Map<String, dynamic>>> watchOrdersByUser(String userId) {
    return client
        .from(SupabaseTables.order)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((rows) => rows.map(Map<String, dynamic>.from).toList());
  }

  // ---------- TABLE ----------

  static Future<List<Map<String, dynamic>>> getTables() async {
    final res = await client.from(SupabaseTables.table).select();
    return List<Map<String, dynamic>>.from(res);
  }

  static Stream<List<Map<String, dynamic>>> watchTables() {
    return client
        .from(SupabaseTables.table)
        .stream(primaryKey: ['id'])
        .order('number')
        .map((rows) => rows.map(Map<String, dynamic>.from).toList());
  }

  static Future<void> updateTableStatus({
    required String tableId,
    required bool occupied,
    required bool needsPayment,
  }) async {
    await client.from(SupabaseTables.table).update({
      'occupied': occupied,
      'needs_payment': needsPayment,
    }).eq('id', tableId);
  }
}
