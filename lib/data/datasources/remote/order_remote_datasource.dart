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
}
