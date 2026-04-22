import '../../core/services/sync_service.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/local/order_local_datasource.dart';
import '../datasources/remote/order_remote_datasource.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({
    required OrderRemoteDataSource remoteDataSource,
    required OrderLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final OrderRemoteDataSource _remoteDataSource;
  final OrderLocalDataSource _localDataSource;

  @override
  Future<void> createOrder(Order order) async {
    final model = OrderModel.fromEntity(order);
    await _localDataSource.saveOrder(model);

    try {
      await _remoteDataSource.createOrder(model);
    } catch (_) {
      // The order stays stored locally until sync runs.
    }
  }

  @override
  Future<Order?> getActiveOrder(String userId) async {
    return _localDataSource.getActiveOrder(userId);
  }

  @override
  Future<List<Order>> getOrdersByUser(String userId) async {
    try {
      final remoteOrders = await _remoteDataSource.getOrdersByUser(userId);
      for (final order in remoteOrders) {
        await _localDataSource.saveOrder(order);
      }
      return remoteOrders;
    } catch (_) {
      return _localDataSource.getOrdersByUser(userId);
    }
  }

  @override
  Future<void> saveLocal(Order order) async {
    await _localDataSource.saveOrder(OrderModel.fromEntity(order));
  }

  @override
  Future<void> syncOrders() async {
    await SyncService.syncOrders();
  }

  @override
  Future<void> updateOrder(Order order) async {
    final model = OrderModel.fromEntity(order);
    await _localDataSource.saveOrder(model);

    try {
      await _remoteDataSource.updateOrder(model);
    } catch (_) {
      // Local state remains as source of truth while offline.
    }
  }
}
