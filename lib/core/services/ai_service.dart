import 'package:flutter/foundation.dart';

import '../../core/config/supabase_config.dart';
import '../../domain/entities/menu.dart';

class ChatMessage {
  const ChatMessage({required this.role, required this.content});
  final String role; // 'user' | 'assistant'
  final String content;
  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

class AiCartItem {
  const AiCartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });

  final String id;
  final String name;
  final double price;
  final int quantity;

  factory AiCartItem.fromJson(Map<String, dynamic> json) => AiCartItem(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0,
    quantity: json['quantity'] as int? ?? 1,
  );
}

class AiActionData {
  const AiActionData({
    this.items = const [],
    this.total,
    this.orderSummary,
  });

  final List<AiCartItem> items;
  final double? total;
  final String? orderSummary;

  factory AiActionData.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return AiActionData(
      items: rawItems
          .map((e) => AiCartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toDouble(),
      orderSummary: json['order_summary'] as String?,
    );
  }
}

class AiResponse {
  const AiResponse({
    required this.reply,
    this.action = 'none',
    this.actionData,
  });

  final String reply;
  final String action; // 'none' | 'add_to_cart' | 'confirm_order' | 'create_order' | 'go_to_payment' | 'update_order'
  final AiActionData? actionData;
}

class AiService {
  Future<AiResponse> generateConciergeReply({
    required String prompt,
    required List<ChatMessage> conversationHistory,
    required List<Menu> recommendedMenu,
    required List<Menu> cartItems,
    required int? tableNumber,
    required String orderStatus,
    List<String> allergies = const [],
    String diningPreferences = '',
    bool hasActiveOrder = false,
  }) async {
    try {
      final response = await SupabaseConfig.client.functions.invoke(
        'ordenow-ai-concierge',
        body: {
          'prompt': prompt,
          'conversation_history':
              conversationHistory.map((m) => m.toJson()).toList(),
          'table_number': tableNumber,
          'order_status': orderStatus,
          'has_active_order': hasActiveOrder,
          'allergies': allergies,
          'dining_preferences': diningPreferences,
          'cart_items': cartItems.map((item) => item.name).toList(),
          'menu': recommendedMenu.map(_menuToPayload).toList(),
          'recommended_menu': recommendedMenu.map(_menuToPayload).toList(),
        },
      );

      final data = response.data;
      if (data is Map) {
        final reply = data['reply'] as String? ?? '';
        final action = data['action'] as String? ?? 'none';
        final rawActionData = data['action_data'];
        AiActionData? actionData;
        if (rawActionData is Map<String, dynamic>) {
          actionData = AiActionData.fromJson(rawActionData);
        }
        return AiResponse(reply: reply, action: action, actionData: actionData);
      }
    } catch (e) {
      debugPrint('AiService error: $e');
    }

    final fallbackReply = _buildFallbackReply(
      prompt: prompt,
      recommendedMenu: recommendedMenu,
      cartItems: cartItems,
      tableNumber: tableNumber,
      orderStatus: orderStatus,
      allergies: allergies,
    );
    return AiResponse(reply: fallbackReply);
  }

  Map<String, dynamic> _menuToPayload(Menu item) => {
    'id': item.id,
    'name': item.name,
    'description': item.description,
    'price': item.price,
    'category': item.category,
    'available': item.available,
    'recommended': item.recommended,
    'tags': item.tags,
    'image_url': item.imageUrl,
  };

  String _buildFallbackReply({
    required String prompt,
    required List<Menu> recommendedMenu,
    required List<Menu> cartItems,
    required int? tableNumber,
    required String orderStatus,
    List<String> allergies = const [],
  }) {
    final normalized = prompt.toLowerCase();
    final availableMenu = recommendedMenu.where((item) => item.available).toList();
    final matched = _findMenuMatches(normalized, availableMenu, allergies);

    if (matched.isNotEmpty) {
      final picks = matched.take(3).map((item) {
        final price = item.price
            .toInt()
            .toString()
            .replaceAllMapped(
              RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
              (match) => '${match[1]}.',
            );
        return '${item.name} por \$$price';
      }).join(', ');
      return 'Para ese antojo te recomiendo: $picks. '
          'Dime si quieres agregar alguno al pedido.';
    }

    if (allergies.isNotEmpty &&
        (normalized.contains('alerg') || normalized.contains('puedo'))) {
      final safe = availableMenu
          .where(
            (m) => !m.tags.any(
              (t) => allergies.any(
                (a) => t.toLowerCase().contains(a.toLowerCase()),
              ),
            ),
          )
          .take(2)
          .map((m) => m.name)
          .join(' y ');
      return 'Tengo en cuenta tu alergia a: ${allergies.join(', ')}. '
          'Te recomiendo: ${safe.isNotEmpty ? safe : "consulta el menú con nosotros"}.';
    }

    if (normalized.contains('bebida') || normalized.contains('tomar')) {
      final drinks = availableMenu
          .where(
            (item) =>
                item.category.toLowerCase().contains('beb') ||
                item.tags.any((tag) => tag.toLowerCase().contains('bebida')),
          )
          .take(2)
          .map((item) => item.name)
          .join(' o ');
      return drinks.isNotEmpty
          ? 'Para beber, te recomiendo $drinks.'
          : 'Puedo sugerirte un plato mientras buscamos bebidas disponibles.';
    }

    if (cartItems.isNotEmpty) {
      final names = cartItems.map((item) => item.name).join(', ');
      return 'Tu carrito tiene: $names. ¿Agregamos algo más o quieres confirmar el pedido?';
    }

    final picks = availableMenu.take(2).map((item) => item.name).join(' y ');
    return 'Te recomiendo $picks. Dime si prefieres algo ligero, premium o vegetariano.';
  }

  List<Menu> _findMenuMatches(
    String normalizedPrompt,
    List<Menu> menu,
    List<String> allergies,
  ) {
    const stopWords = {
      'quiero', 'tengo', 'ganas', 'antojo', 'algo', 'con', 'de', 'del',
      'la', 'el', 'los', 'las', 'un', 'una', 'recomienda', 'recomiendame',
      'plato', 'platos', 'comer', 'para', 'por', 'favor',
    };

    final terms = normalizedPrompt
        .replaceAll(RegExp(r'[^a-z0-9áéíóúñü\s]'), ' ')
        .split(RegExp(r'\s+'))
        .map((t) => t.trim())
        .where((t) => t.length > 2 && !stopWords.contains(t))
        .toSet();

    if (terms.isEmpty) return const [];

    final allergyTerms = allergies.map((a) => a.toLowerCase()).toList();
    final scored = <({Menu item, int score})>[];

    for (final item in menu) {
      final searchable =
          [item.name, item.description, item.category, ...item.tags]
              .join(' ')
              .toLowerCase();

      if (allergyTerms.any(searchable.contains)) continue;

      var score = 0;
      for (final term in terms) {
        if (searchable.contains(term)) {
          score += item.tags.any((tag) => tag.toLowerCase().contains(term))
              ? 3
              : 1;
        }
      }

      if (item.recommended && score > 0) score += 1;
      if (score > 0) scored.add((item: item, score: score));
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.map((e) => e.item).toList();
  }
}
