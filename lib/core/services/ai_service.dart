import '../../core/config/supabase_config.dart';
import '../../domain/entities/menu.dart';

class AiService {
  Future<String> generateConciergeReply({
    required String prompt,
    required List<Menu> recommendedMenu,
    required List<Menu> cartItems,
    required int? tableNumber,
    required String orderStatus,
    List<String> allergies = const [],
    String diningPreferences = '',
  }) async {
    try {
      final response = await SupabaseConfig.client.functions.invoke(
        'ordenow-ai-concierge',
        body: {
          'prompt': prompt,
          'table_number': tableNumber,
          'order_status': orderStatus,
          'allergies': allergies,
          'dining_preferences': diningPreferences,
          'cart_items': cartItems.map((item) => item.name).toList(),
          'menu': recommendedMenu.map(_menuToPayload).toList(),
          'recommended_menu': recommendedMenu.map(_menuToPayload).toList(),
        },
      );

      final data = response.data;
      if (data is Map && data['reply'] is String) {
        return data['reply'] as String;
      }
    } catch (_) {
      // Falls back to a local reply while the edge function is unavailable.
    }

    return _buildFallbackReply(
      prompt: prompt,
      recommendedMenu: recommendedMenu,
      cartItems: cartItems,
      tableNumber: tableNumber,
      orderStatus: orderStatus,
      allergies: allergies,
    );
  }

  Map<String, dynamic> _menuToPayload(Menu item) {
    return {
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
  }

  String _buildFallbackReply({
    required String prompt,
    required List<Menu> recommendedMenu,
    required List<Menu> cartItems,
    required int? tableNumber,
    required String orderStatus,
    List<String> allergies = const [],
  }) {
    final normalized = prompt.toLowerCase();
    final availableMenu = recommendedMenu
        .where((item) => item.available)
        .toList();
    final matched = _findMenuMatches(normalized, availableMenu, allergies);

    if (matched.isNotEmpty) {
      final picks = matched
          .take(3)
          .map((item) {
            final price = item.price.toInt().toString().replaceAllMapped(
              RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
              (match) => '${match[1]}.',
            );
            return '${item.name} por \$$price';
          })
          .join(', ');

      return 'Para ese antojo te recomiendo: $picks. '
          'Los elegi porque coinciden con ingredientes, descripcion o tags del menu. '
          'Si quieres, te ayudo a agregar uno al pedido.';
    }

    if (allergies.isNotEmpty &&
        (normalized.contains('allergy') ||
            normalized.contains('alerg') ||
            normalized.contains('puedo') ||
            normalized.contains('can i'))) {
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
      final allergyList = allergies.join(', ');
      return 'Tengo en cuenta tu alergia a: $allergyList. '
          'Te recomiendo con seguridad: ${safe.isNotEmpty ? safe : "una opcion disponible del menu"}';
    }

    if (normalized.contains('drink') || normalized.contains('bebida')) {
      final drinks = availableMenu
          .where(
            (item) =>
                item.category.toLowerCase().contains('beb') ||
                item.category.toLowerCase().contains('drink') ||
                item.tags.any((tag) => tag.toLowerCase().contains('drink')),
          )
          .take(2)
          .map((item) => item.name)
          .join(' o ');
      return drinks.isNotEmpty
          ? 'Para beber, te recomiendo $drinks.'
          : 'No veo bebidas disponibles ahora mismo, pero puedo sugerirte un plato.';
    }

    if (normalized.contains('status') || normalized.contains('estado')) {
      return 'Tu pedido en mesa ${tableNumber ?? '-'} esta: $orderStatus.';
    }

    if (normalized.contains('menu') || normalized.contains('platos')) {
      final picks = availableMenu.take(3).map((m) => m.name).join(', ');
      return 'Hoy destacamos: $picks. Quieres mas detalles de alguno?';
    }

    if (cartItems.isNotEmpty) {
      final names = cartItems.map((item) => item.name).join(', ');
      return 'Tu carrito tiene: $names. '
          'Agregamos algo mas, bebidas o ajustamos el pedido?';
    }

    final picks = availableMenu.take(2).map((item) => item.name).join(' y ');
    return 'Para este momento te recomiendo $picks. '
        'Dime si prefieres algo ligero, premium, vegetariano o sin alergenos.';
  }

  List<Menu> _findMenuMatches(
    String normalizedPrompt,
    List<Menu> menu,
    List<String> allergies,
  ) {
    final stopWords = {
      'quiero',
      'tengo',
      'ganas',
      'antojo',
      'algo',
      'con',
      'de',
      'del',
      'la',
      'el',
      'los',
      'las',
      'un',
      'una',
      'recomienda',
      'recomiendame',
      'plato',
      'platos',
      'comer',
      'para',
      'por',
      'favor',
    };

    final terms = normalizedPrompt
        .replaceAll(RegExp(r'[^a-z0-9áéíóúñü\s]'), ' ')
        .split(RegExp(r'\s+'))
        .map((term) => term.trim())
        .where((term) => term.length > 2 && !stopWords.contains(term))
        .toSet();

    if (terms.isEmpty) {
      return const [];
    }

    final allergyTerms = allergies.map((item) => item.toLowerCase()).toList();
    final scored = <({Menu item, int score})>[];

    for (final item in menu) {
      final searchable = [
        item.name,
        item.description,
        item.category,
        ...item.tags,
      ].join(' ').toLowerCase();

      if (allergyTerms.any(searchable.contains)) {
        continue;
      }

      var score = 0;
      for (final term in terms) {
        if (searchable.contains(term)) {
          score += item.tags.any((tag) => tag.toLowerCase().contains(term))
              ? 3
              : 1;
        }
      }

      if (item.recommended && score > 0) {
        score += 1;
      }

      if (score > 0) {
        scored.add((item: item, score: score));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.map((entry) => entry.item).toList();
  }
}
