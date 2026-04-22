import '../../core/config/supabase_config.dart';
import '../../domain/entities/menu.dart';

class AiService {
  Future<String> generateConciergeReply({
    required String prompt,
    required List<Menu> recommendedMenu,
    required List<Menu> cartItems,
    required int? tableNumber,
    required String orderStatus,
  }) async {
    try {
      final response = await SupabaseConfig.client.functions.invoke(
        'ordenow-ai-concierge',
        body: {
          'prompt': prompt,
          'table_number': tableNumber,
          'order_status': orderStatus,
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
      // Falls back to a local mock reply while the edge function is unavailable.
    }

    return _buildFallbackReply(
      prompt: prompt,
      recommendedMenu: recommendedMenu,
      cartItems: cartItems,
      tableNumber: tableNumber,
      orderStatus: orderStatus,
    );
  }

  String _buildFallbackReply({
    required String prompt,
    required List<Menu> recommendedMenu,
    required List<Menu> cartItems,
    required int? tableNumber,
    required String orderStatus,
  }) {
    final normalized = prompt.toLowerCase();

    if (normalized.contains('allergy') || normalized.contains('alerg')) {
      return 'I noted the allergy context. I would prioritize lighter and safer '
          'recommendations like Artisan Harvest Bowl and Lychee Ginger Fizz.';
    }

    if (normalized.contains('drink') || normalized.contains('bebida')) {
      return 'A fresh pairing would be Lychee Ginger Fizz, while a premium '
          'pairing would be Cacao Old Fashioned.';
    }

    if (normalized.contains('status') || normalized.contains('estado')) {
      return 'Your current order status is $orderStatus for table ${tableNumber ?? '-'}';
    }

    if (cartItems.isNotEmpty) {
      final names = cartItems.map((item) => item.name).join(', ');
      return 'Your current cart includes $names. I can now help confirm sides, '
          'drinks, or payment method.';
    }

    final picks = recommendedMenu.take(2).map((item) => item.name).join(' and ');
    return 'For this visit I recommend $picks. Tell me if you want something '
        'comforting, premium, light, or allergy-aware.';
  }
}
