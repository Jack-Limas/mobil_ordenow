import '../../domain/entities/menu.dart';

class MenuModel extends Menu {
  MenuModel({
    required super.id,
    required super.name,
    required super.price,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id'],
      name: json['name'],
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "price": price,
    };
  }
}