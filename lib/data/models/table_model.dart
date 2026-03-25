import '../../domain/entities/table.dart';

class TableModel extends TableEntity {
  TableModel({
    required super.id,
    required super.number,
    required super.occupied,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'],
      number: json['number'],
      occupied: json['occupied'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "number": number,
      "occupied": occupied,
    };
  }

  factory TableModel.fromEntity(TableEntity table) {
    return TableModel(
      id: table.id,
      number: table.number,
      occupied: table.occupied,
    );
  }

  TableEntity toEntity() {
    return TableEntity(
      id: id,
      number: number,
      occupied: occupied,
    );
  }
}