class Order {
  final String id;
  final String userId;
  final String tableId;
  final List<String> items;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool paid;
  final String paymentMethod;
  final double totalAmount;
  final String notes;
  final bool synced;

  Order({
    required this.id,
    required this.userId,
    required this.tableId,
    required this.items,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.paid,
    required this.paymentMethod,
    required this.totalAmount,
    required this.notes,
    required this.synced,
  });
}
