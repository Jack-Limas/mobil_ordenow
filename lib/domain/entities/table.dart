class TableEntity {
  final String id;
  final int number;
  final bool occupied;
  final bool needsPayment;

  TableEntity({
    required this.id,
    required this.number,
    required this.occupied,
    required this.needsPayment,
  });
}
