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
  bool _isLoading = false;

  final List<DemoAiMessage> _messages = [];

  List<DemoAiMessage> get messages => List.unmodifiable(_messages);
  bool get isSpeaking => _isSpeaking;
  bool get ttsEnabled => _ttsEnabled;
  bool get isLoading => _isLoading;

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

  Future<void> sendGreeting({
    String? userName,
    required List<Menu> recommendedMenu,
    int? tableNumber,
    List<String> allergies = const [],
    String diningPreferences = '',
  }) async {
    if (_messages.isNotEmpty || _isLoading) return;

    final name = userName?.trim() ?? '';
    final greetingPrompt = name.isNotEmpty
        ? 'Saluda a $name por su nombre y preséntate brevemente como el asistente virtual de OrdeNow. Ofrécete a ayudarle a explorar el menú o hacer su pedido.'
        : 'Saluda al cliente y preséntate brevemente como el asistente virtual de OrdeNow. Ofrécete a ayudarle a explorar el menú o hacer su pedido.';

    _isLoading = true;
    notifyListeners();

    final reply = await _aiService.generateConciergeReply(
      prompt: greetingPrompt,
      recommendedMenu: recommendedMenu,
      cartItems: const [],
      tableNumber: tableNumber,
      orderStatus: '',
      allergies: allergies,
      diningPreferences: diningPreferences,
    );

    _messages.add(DemoAiMessage(text: reply, isUser: false));
    _isLoading = false;
    notifyListeners();

    if (_ttsEnabled) {
      await _tts.speak(reply);
    }
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
    if (trimmedPrompt.isEmpty || _isLoading) return;

    _messages.add(DemoAiMessage(text: trimmedPrompt, isUser: true));
    _isLoading = true;
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
    _isLoading = false;
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
