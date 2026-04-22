import '../../models/order_model.dart';
import 'hive_service.dart';

class OrderLocalDataSource {
  Future<void> saveOrder(OrderModel order) async {
    await HiveService.getOrderBox().put(order.id, order.toJson());
  }

  Future<List<OrderModel>> getOrders() async {
    return HiveService.getOrderBox().values
        .whereType<Map>()
        .map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<OrderModel>> getOrdersByUser(String userId) async {
    final orders = await getOrders();
    return orders.where((order) => order.userId == userId).toList();
  }

  Future<OrderModel?> getActiveOrder(String userId) async {
    final orders = await getOrdersByUser(userId);

    for (final order in orders.reversed) {
      if (!order.paid) {
        return order;
      }
    }

    return null;
  }
}
