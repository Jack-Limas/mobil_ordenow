import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../data/datasources/remote/menu_remote_datasource.dart';
import '../../domain/entities/menu.dart';

class MenuManagementProvider extends ChangeNotifier {
  final _ds = MenuRemoteDataSource();
  final _uuid = const Uuid();

  List<Menu> _menu = [];
  bool _loading = false;
  final String _aiSuggestion =
      '¿Qué tal si añadimos \'Sinfonía de Bosque\'? Las palabras '
      '\'Terroir, recalibrar y silenciar\' aumentan el valor percibido '
      'del plato en un 15%.';

  List<Menu> get menu => List.unmodifiable(_menu);
  bool get loading => _loading;
  String get aiSuggestion => _aiSuggestion;

  MenuManagementProvider() {
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    _loading = true;
    notifyListeners();
    try {
      _menu = await _ds.getMenu();
    } catch (_) {}
    _loading = false;
    notifyListeners();
  }

  Future<void> refresh() => _loadMenu();

  Future<void> createMenuItem({
    required String name,
    required double price,
    required String category,
    required String description,
    required String ingredients,
    required String imageUrl,
  }) async {
    try {
      final tags = ingredients.isNotEmpty
          ? ingredients
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList()
          : <String>[];
      await _ds.createMenuItem({
        'id': _uuid.v4(),
        'name': name,
        'price': price,
        'category': category,
        'description': description,
        'image_url': imageUrl,
        'available': true,
        'recommended': false,
        'tags': tags,
      });
      await _loadMenu();
    } catch (_) {}
  }

  Future<void> updateMenuItem({
    required String id,
    required String name,
    required double price,
    required String category,
    required String description,
    required String imageUrl,
  }) async {
    try {
      await _ds.updateMenuItem(id, {
        'name': name,
        'price': price,
        'category': category,
        'description': description,
        'image_url': imageUrl,
      });
      await _loadMenu();
    } catch (_) {}
  }

  Future<void> deleteMenuItem(String id) async {
    try {
      await _ds.deleteMenuItem(id);
      await _loadMenu();
    } catch (_) {}
  }
}
