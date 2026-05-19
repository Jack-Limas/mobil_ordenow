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
    final res = await client.from(SupabaseTables.menu).select().order('name');
    return List<Map<String, dynamic>>.from(res);
  }

  static Stream<List<Map<String, dynamic>>> watchMenu() {
    return client
        .from(SupabaseTables.menu)
        .stream(primaryKey: ['id'])
        .order('name')
        .map((rows) => rows.map(Map<String, dynamic>.from).toList());
  }

  static Future<void> createMenuItem(Map<String, dynamic> data) async {
    await client.from(SupabaseTables.menu).insert(data);
  }

  static Future<void> updateMenuItem(
    String id,
    Map<String, dynamic> data,
  ) async {
    await client.from(SupabaseTables.menu).update(data).eq('id', id);
  }

  static Future<void> deleteMenuItem(String id) async {
    await client.from(SupabaseTables.menu).delete().eq('id', id);
  }

  // ---------- ORDER ----------

  static Future<void> upsertOrder(Map<String, dynamic> data) async {
    await client.from(SupabaseTables.order).upsert(data);
  }

  static Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    await client
        .from(SupabaseTables.order)
        .update({
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', orderId);
  }

  static Future<void> updateOrderPayment({
    required String orderId,
    required bool paid,
    required String paymentMethod,
    String? status,
  }) async {
    await client
        .from(SupabaseTables.order)
        .update({
          'paid': paid,
          'payment_method': paymentMethod,
          if (status != null) 'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', orderId);
  }

  static Future<List<Map<String, dynamic>>> getOrders() async {
    final res = await client.from(SupabaseTables.order).select();
    return List<Map<String, dynamic>>.from(res);
  }

  static Future<List<Map<String, dynamic>>> getOrdersByUser(
    String userId,
  ) async {
    final res = await client
        .from(SupabaseTables.order)
        .select()
        .eq('user_id', userId);
    return List<Map<String, dynamic>>.from(res);
  }

  static Stream<List<Map<String, dynamic>>> watchOrdersByUser(String userId) {
    return client
        .from(SupabaseTables.order)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((rows) => rows.map(Map<String, dynamic>.from).toList());
  }

  static Stream<List<Map<String, dynamic>>> watchAllOrders() {
    return client
        .from(SupabaseTables.order)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((rows) => rows.map(Map<String, dynamic>.from).toList());
  }

  // ---------- CASH REQUESTS ----------

  static Future<void> insertCashRequest(Map<String, dynamic> data) async {
    await client.from(SupabaseTables.cashRequest).insert(data);
  }

  static Stream<List<Map<String, dynamic>>> watchCashRequests(String tableId) {
    return client
        .from(SupabaseTables.cashRequest)
        .stream(primaryKey: ['id'])
        .eq('table_id', tableId)
        .map((rows) => rows.map(Map<String, dynamic>.from).toList());
  }

  static Stream<List<Map<String, dynamic>>> watchAllCashRequests() {
    return client
        .from(SupabaseTables.cashRequest)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((rows) => rows.map(Map<String, dynamic>.from).toList());
  }

  static Future<void> updateCashRequestStatus({
    required String requestId,
    required String status,
  }) async {
    await client
        .from(SupabaseTables.cashRequest)
        .update({
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', requestId);
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
    await client
        .from(SupabaseTables.table)
        .update({'occupied': occupied, 'needs_payment': needsPayment})
        .eq('id', tableId);
  }
}
