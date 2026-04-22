import '../../domain/entities/menu.dart';

class MenuModel extends Menu {
  MenuModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.category,
    required super.available,
    required super.recommended,
    required super.tags,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String? ?? 'main',
      available: json['available'] as bool? ?? true,
      recommended: json['recommended'] as bool? ?? false,
      tags: List<String>.from(json['tags'] ?? const []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "price": price,
      "category": category,
      "available": available,
      "recommended": recommended,
      "tags": tags,
    };
  }

  factory MenuModel.fromEntity(Menu menu) {
    return MenuModel(
      id: menu.id,
      name: menu.name,
      description: menu.description,
      price: menu.price,
      category: menu.category,
      available: menu.available,
      recommended: menu.recommended,
      tags: menu.tags,
    );
  }

  Menu toEntity() {
    return Menu(
      id: id,
      name: name,
      description: description,
      price: price,
      category: category,
      available: available,
      recommended: recommended,
      tags: tags,
    );
  }
}
