import '../../domain/entities/order.dart';

class OrderModel extends Order {
  OrderModel({
    required super.id,
    required super.userId,
    required super.tableId,
    required super.items,
    required super.status,
    required super.createdAt,
    required super.paid,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      userId: json['user_id'],
      tableId: json['table_id'],
      items: List<String>.from(json['items']),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      paid: json['paid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user_id": userId,
      "table_id": tableId,
      "items": items,
      "status": status,
      "created_at": createdAt.toIso8601String(),
      "paid": paid,
    };
  }

  factory OrderModel.fromEntity(Order order) {
    return OrderModel(
      id: order.id,
      userId: order.userId,
      tableId: order.tableId,
      items: order.items,
      status: order.status,
      createdAt: order.createdAt,
      paid: order.paid,
    );
  }

  Order toEntity() {
    return Order(
      id: id,
      userId: userId,
      tableId: tableId,
      items: items,
      status: status,
      createdAt: createdAt,
      paid: paid,
    );
  }
}