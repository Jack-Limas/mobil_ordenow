import 'package:flutter/material.dart';

import '../../domain/entities/menu.dart';

class DemoAiMessage {
  const DemoAiMessage({
    required this.text,
    required this.isUser,
  });

  final String text;
  final bool isUser;
}

class AiProvider extends ChangeNotifier {
  final List<DemoAiMessage> _messages = const [
    DemoAiMessage(
      text:
          'Welcome to Ordenow. I can recommend dishes, drinks, allergy-safe options, and help you place your order.',
      isUser: false,
    ),
  ].toList();

  List<DemoAiMessage> get messages => List.unmodifiable(_messages);

  void resetConversation() {
    _messages
      ..clear()
      ..add(
        const DemoAiMessage(
          text:
              'Welcome back. Tell me your cravings, allergies, or if you want something quick, premium, or refreshing.',
          isUser: false,
        ),
      );
    notifyListeners();
  }

  void sendMessage({
    required String prompt,
    required List<Menu> recommendedMenu,
    required List<Menu> cartItems,
    required int? tableNumber,
    required String orderStatus,
  }) {
    final trimmedPrompt = prompt.trim();
    if (trimmedPrompt.isEmpty) {
      return;
    }

    _messages.add(DemoAiMessage(text: trimmedPrompt, isUser: true));
    _messages.add(
      DemoAiMessage(
        text: _buildAssistantReply(
          prompt: trimmedPrompt,
          recommendedMenu: recommendedMenu,
          cartItems: cartItems,
          tableNumber: tableNumber,
          orderStatus: orderStatus,
        ),
        isUser: false,
      ),
    );
    notifyListeners();
  }

  String _buildAssistantReply({
    required String prompt,
    required List<Menu> recommendedMenu,
    required List<Menu> cartItems,
    required int? tableNumber,
    required String orderStatus,
  }) {
    final normalized = prompt.toLowerCase();

    if (normalized.contains('allergy') || normalized.contains('allerg')) {
      return 'I noted your allergy concern. For this demo I recommend the '
          'Artisan Harvest Bowl and Lychee Ginger Fizz because they feel lighter '
          'and easier to adapt.';
    }

    if (normalized.contains('drink') || normalized.contains('beverage')) {
      return 'For drinks, I suggest the Lychee Ginger Fizz for something fresh '
          'or the Cacao Old Fashioned for a richer pairing.';
    }

    if (normalized.contains('status') || normalized.contains('order')) {
      return 'Your current order status is $orderStatus. '
          'Table ${tableNumber ?? '-'} remains linked to this session.';
    }

    if (normalized.contains('quick') || normalized.contains('fast')) {
      return 'For a faster kitchen turnaround I recommend Midnight Pasta plus '
          'Lychee Ginger Fizz.';
    }

    if (normalized.contains('premium') || normalized.contains('special')) {
      return 'For a premium experience, go with Smoked Ribeye and finish with '
          'a Cacao Old Fashioned.';
    }

    if (cartItems.isNotEmpty) {
      final names = cartItems.map((item) => item.name).join(', ');
      return 'Your cart currently includes $names. If you want, I can also '
          'suggest a drink pairing or mark the order as ready to confirm.';
    }

    final picks = recommendedMenu.take(2).map((item) => item.name).join(' and ');
    return 'Based on this demo profile, I recommend $picks. '
        'Tell me if you want something light, comforting, or chef signature.';
  }
}
