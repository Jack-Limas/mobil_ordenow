import '../../domain/entities/order.dart';

class OrderModel extends Order {
  OrderModel({
    required super.id,
    required super.userId,
    required super.tableId,
    required super.items,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    required super.paid,
    required super.paymentMethod,
    required super.totalAmount,
    required super.notes,
    required super.synced,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      tableId: json['table_id'] as String,
      items: List<String>.from(json['items'] ?? const []),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.parse(json['created_at'] as String),
      paid: json['paid'] as bool? ?? false,
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String? ?? '',
      synced: json['synced'] as bool? ?? true,
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
      "updated_at": updatedAt.toIso8601String(),
      "paid": paid,
      "payment_method": paymentMethod,
      "total_amount": totalAmount,
      "notes": notes,
      "synced": synced,
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
      updatedAt: order.updatedAt,
      paid: order.paid,
      paymentMethod: order.paymentMethod,
      totalAmount: order.totalAmount,
      notes: order.notes,
      synced: order.synced,
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
      updatedAt: updatedAt,
      paid: paid,
      paymentMethod: paymentMethod,
      totalAmount: totalAmount,
      notes: notes,
      synced: synced,
    );
  }
}
