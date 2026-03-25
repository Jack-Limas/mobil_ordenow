class Order {
  final String id;
  final String userId;
  final String tableId;
  final List<String> items;
  final String status;
  final DateTime createdAt;
  final bool paid;

  Order({
    required this.id,
    required this.userId,
    required this.tableId,
    required this.items,
    required this.status,
    required this.createdAt,
    required this.paid,
  });
}