import '../../domain/entities/table.dart';

class TableModel extends TableEntity {
  TableModel({
    required super.id,
    required super.number,
    required super.occupied,
    required super.needsPayment,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'] as String,
      number: json['number'] as int,
      occupied: json['occupied'] as bool? ?? false,
      needsPayment: json['needs_payment'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "number": number,
      "occupied": occupied,
      "needs_payment": needsPayment,
    };
  }

  factory TableModel.fromEntity(TableEntity table) {
    return TableModel(
      id: table.id,
      number: table.number,
      occupied: table.occupied,
      needsPayment: table.needsPayment,
    );
  }

  TableEntity toEntity() {
    return TableEntity(
      id: id,
      number: number,
      occupied: occupied,
      needsPayment: needsPayment,
    );
  }
}
