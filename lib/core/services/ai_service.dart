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
          'recommended_menu': recommendedMenu
              .map(
                (item) => {
                  'name': item.name,
                  'description': item.description,
                  'price': item.price,
                  'tags': item.tags,
                },
              )
              .toList(),
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

  String _buildFallbackReply({
    required String prompt,
    required List<Menu> recommendedMenu,
    required List<Menu> cartItems,
    required int? tableNumber,
    required String orderStatus,
    List<String> allergies = const [],
  }) {
    final normalized = prompt.toLowerCase();

    if (allergies.isNotEmpty &&
        (normalized.contains('allergy') ||
            normalized.contains('alerg') ||
            normalized.contains('puedo') ||
            normalized.contains('can i'))) {
      final safe = recommendedMenu
          .where((m) => !m.tags.any((t) => allergies
              .any((a) => t.toLowerCase().contains(a.toLowerCase()))))
          .take(2)
          .map((m) => m.name)
          .join(' y ');
      final allergyList = allergies.join(', ');
      return 'Tengo en cuenta tu alergia a: $allergyList. '
          'Te recomiendo con seguridad: ${safe.isNotEmpty ? safe : "Artisan Harvest Bowl"}.';
    }

    if (normalized.contains('drink') || normalized.contains('bebida')) {
      return 'Para beber, te recomiendo Lychee Ginger Fizz (refrescante) '
          'o Cacao Old Fashioned (premium).';
    }

    if (normalized.contains('status') || normalized.contains('estado')) {
      return 'Tu pedido en mesa ${tableNumber ?? '-'} está: $orderStatus.';
    }

    if (normalized.contains('menu') || normalized.contains('platos')) {
      final picks = recommendedMenu.take(3).map((m) => m.name).join(', ');
      return 'Hoy destacamos: $picks. ¿Quieres más detalles de alguno?';
    }

    if (cartItems.isNotEmpty) {
      final names = cartItems.map((item) => item.name).join(', ');
      return 'Tu carrito tiene: $names. '
          '¿Agregamos algo más, bebidas o ajustamos el pedido?';
    }

    final picks =
        recommendedMenu.take(2).map((item) => item.name).join(' y ');
    return 'Para este momento te recomiendo $picks. '
        'Dime si prefieres algo ligero, premium, vegetariano o sin alergenos.';
  }
}
