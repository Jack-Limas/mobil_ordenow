import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
  final FlutterTts _tts = FlutterTts();

  bool _isSpeaking = false;
  bool _ttsEnabled = true;

  final List<DemoAiMessage> _messages = const [
    DemoAiMessage(
      text:
          'Bienvenido a OrdeNow. Puedo recomendarte platos, bebidas, opciones sin alergenos y ayudarte a hacer tu pedido.',
      isUser: false,
    ),
  ].toList();

  List<DemoAiMessage> get messages => List.unmodifiable(_messages);
  bool get isSpeaking => _isSpeaking;
  bool get ttsEnabled => _ttsEnabled;

  AiProvider() {
    _initTts();
  }

  void _initTts() {
    _tts.setStartHandler(() {
      _isSpeaking = true;
      notifyListeners();
    });
    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });
    _tts.setErrorHandler((_) {
      _isSpeaking = false;
      notifyListeners();
    });
    _tts.setLanguage('es-CO');
    _tts.setSpeechRate(0.5);
    _tts.setVolume(1.0);
  }

  void toggleTts() {
    _ttsEnabled = !_ttsEnabled;
    if (!_ttsEnabled) _tts.stop();
    notifyListeners();
  }

  void resetConversation() {
    _tts.stop();
    _messages
      ..clear()
      ..add(
        const DemoAiMessage(
          text:
              'De vuelta. Cuéntame tus antojos, alergias, o si prefieres algo rápido, premium o refrescante.',
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
    List<String> allergies = const [],
    String diningPreferences = '',
  }) async {
    final trimmedPrompt = prompt.trim();
    if (trimmedPrompt.isEmpty) return;

    _messages.add(DemoAiMessage(text: trimmedPrompt, isUser: true));
    notifyListeners();

    final reply = await _aiService.generateConciergeReply(
      prompt: trimmedPrompt,
      recommendedMenu: recommendedMenu,
      cartItems: cartItems,
      tableNumber: tableNumber,
      orderStatus: orderStatus,
      allergies: allergies,
      diningPreferences: diningPreferences,
    );

    _messages.add(DemoAiMessage(text: reply, isUser: false));
    notifyListeners();

    if (_ttsEnabled) {
      await _tts.speak(reply);
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
