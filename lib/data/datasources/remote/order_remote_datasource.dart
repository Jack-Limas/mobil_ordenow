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
}
