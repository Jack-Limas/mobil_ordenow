import '../../domain/entities/table.dart';

class TableModel extends TableEntity {
  TableModel({
    required super.id,
    required super.number,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'],
      number: json['number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "number": number,
    };
  }
}