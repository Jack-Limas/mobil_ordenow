class Menu {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final bool available;
  final bool recommended;
  final List<String> tags;

  Menu({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.available,
    required this.recommended,
    required this.tags,
  });
}
