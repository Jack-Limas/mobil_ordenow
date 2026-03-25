import '../entities/order.dart';

abstract class OrderRepository {
  Future<void> createOrder(Order order);

  Future<void> updateOrder(Order order);

  Future<Order?> getActiveOrder(String userId);

  Future<List<Order>> getOrdersByUser(String userId);

  Future<void> saveLocal(Order order);

  Future<void> syncOrders();
}