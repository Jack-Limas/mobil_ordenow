import 'package:flutter/material.dart';

import '../../core/services/ai_service.dart';
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
  final AiService _aiService = AiService();
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

  Future<void> sendMessage({
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
    notifyListeners();

    final reply = await _aiService.generateConciergeReply(
      prompt: trimmedPrompt,
      recommendedMenu: recommendedMenu,
      cartItems: cartItems,
      tableNumber: tableNumber,
      orderStatus: orderStatus,
    );

    _messages.add(DemoAiMessage(text: reply, isUser: false));
    notifyListeners();
  }
}
