import '../../models/order_model.dart';
import 'supabase_service.dart';

class OrderRemoteDataSource {
  Future<void> createOrder(OrderModel order) async {
    await SupabaseService.upsertOrder(order.toJson());
  }

  Future<void> updateOrder(OrderModel order) async {
    await SupabaseService.upsertOrder(order.toJson());
  }

  Future<List<OrderModel>> getOrdersByUser(String userId) async {
    final orders = await SupabaseService.getOrdersByUser(userId);
    return orders.map(OrderModel.fromJson).toList();
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    await SupabaseService.updateOrderStatus(orderId: orderId, status: status);
  }

  Stream<OrderModel?> watchActiveOrder(String userId) {
    return SupabaseService.watchOrdersByUser(userId).map((rows) {
      final active =
          rows.where((r) => r['status'] != 'paid' && r['status'] != 'completed');
      if (active.isEmpty) return null;
      return OrderModel.fromJson(active.first);
    });
  }

  Future<void> insertCashRequest(Map<String, dynamic> data) async {
    await SupabaseService.insertCashRequest(data);
  }

  Stream<List<Map<String, dynamic>>> watchCashRequests(String tableId) {
    return SupabaseService.watchCashRequests(tableId);
  }

  Stream<List<Map<String, dynamic>>> watchAllOrders() {
    return SupabaseService.watchAllOrders();
  }

  Stream<List<Map<String, dynamic>>> watchActiveOrders() {
    const active = {'pending', 'accepted', 'preparing', 'ready'};
    return SupabaseService.watchAllOrders().map((rows) {
      final filtered = rows
          .where((r) => active.contains(r['status']?.toString()))
          .toList()
        ..sort((a, b) {
          final ca =
              DateTime.tryParse(a['created_at'] as String? ?? '') ?? DateTime(0);
          final cb =
              DateTime.tryParse(b['created_at'] as String? ?? '') ?? DateTime(0);
          return ca.compareTo(cb);
        });
      return filtered;
    });
  }
}
