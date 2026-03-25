import '../../domain/entities/menu.dart';

class MenuModel extends Menu {
  MenuModel({
    required super.id,
    required super.name,
    required super.price,
    required super.category,
    required super.available,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      category: json['category'],
      available: json['available'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "price": price,
      "category": category,
      "available": available,
    };
  }

  factory MenuModel.fromEntity(Menu menu) {
    return MenuModel(
      id: menu.id,
      name: menu.name,
      price: menu.price,
      category: menu.category,
      available: menu.available,
    );
  }

  Menu toEntity() {
    return Menu(
      id: id,
      name: name,
      price: price,
      category: category,
      available: available,
    );
  }
}