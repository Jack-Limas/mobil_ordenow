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

  bool get isSelectable => !occupied && !needsPayment;

  String get statusKey {
    if (needsPayment) {
      return 'payment_pending';
    }

    if (occupied) {
      return 'occupied';
    }

    return 'available';
  }

  TableEntity copyWith({
    String? id,
    int? number,
    bool? occupied,
    bool? needsPayment,
  }) {
    return TableEntity(
      id: id ?? this.id,
      number: number ?? this.number,
      occupied: occupied ?? this.occupied,
      needsPayment: needsPayment ?? this.needsPayment,
    );
  }
}
