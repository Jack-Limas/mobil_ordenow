import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../core/services/ai_service.dart';
import '../../domain/entities/menu.dart';
import 'order_provider.dart';

class DemoAiMessage {
  const DemoAiMessage({
    required this.text,
    required this.isUser,
    this.isConfirmation = false,
    this.isVoice = false,
  });

  final String text;
  final bool isUser;
  final bool isConfirmation;
  final bool isVoice;
}

class AiProvider extends ChangeNotifier {
  AiProvider({required OrderProvider orderProvider})
      : _orderProvider = orderProvider {
    _initTts();
  }

  final AiService _aiService = AiService();
  final FlutterTts _tts = FlutterTts();
  OrderProvider _orderProvider;

  final List<DemoAiMessage> _messages = [];
  final List<ChatMessage> _history = [];

  bool _isSpeaking = false;
  bool _ttsEnabled = true;
  bool _isLoading = false;
  bool _pendingConfirmation = false;
  bool _shouldNavigateToPayment = false;
  AiActionData? _pendingOrderData;
  String? _currentUserId;

  List<DemoAiMessage> get messages => List.unmodifiable(_messages);
  bool get isSpeaking => _isSpeaking;
  bool get ttsEnabled => _ttsEnabled;
  bool get isLoading => _isLoading;
  bool get pendingConfirmation => _pendingConfirmation;
  bool get shouldNavigateToPayment => _shouldNavigateToPayment;

  void updateOrderProvider(OrderProvider orderProvider) {
    _orderProvider = orderProvider;
  }

  void setCurrentUser(String? userId) {
    _currentUserId = userId;
  }

  void clearNavigationFlag() {
    _shouldNavigateToPayment = false;
  }

  void _initTts() {
    _tts
      ..setStartHandler(() {
        _isSpeaking = true;
        notifyListeners();
      })
      ..setCompletionHandler(() {
        _isSpeaking = false;
        notifyListeners();
      })
      ..setErrorHandler((_) {
        _isSpeaking = false;
        notifyListeners();
      })
      ..setLanguage('es-CO')
      ..setSpeechRate(0.5)
      ..setVolume(1.0);
  }

  void toggleTts() {
    _ttsEnabled = !_ttsEnabled;
    if (!_ttsEnabled) _tts.stop();
    notifyListeners();
  }

  void resetConversation() {
    _tts.stop();
    _messages.clear();
    _history.clear();
    _pendingConfirmation = false;
    _pendingOrderData = null;
    _currentUserId = null;
    _messages.add(const DemoAiMessage(
      text:
          'De vuelta. Cuéntame tus antojos, alergias, o si prefieres algo rápido, premium o refrescante.',
      isUser: false,
    ));
    notifyListeners();
  }

  Future<void> confirmPendingOrder() async {
    _pendingConfirmation = false;
    notifyListeners();
    if (_pendingOrderData != null) {
      await _executeAction('create_order', _pendingOrderData!);
      _pendingOrderData = null;
    }
  }

  void cancelPendingOrder() {
    _pendingConfirmation = false;
    _pendingOrderData = null;
    _messages.add(const DemoAiMessage(
      text: 'Pedido cancelado. ¿En qué más te puedo ayudar?',
      isUser: false,
    ));
    notifyListeners();
  }

  Future<void> sendGreeting({
    String? userName,
    required List<Menu> recommendedMenu,
    int? tableNumber,
    List<String> allergies = const [],
    String diningPreferences = '',
    List<String> orderHistory = const [],
  }) async {
    if (_messages.isNotEmpty || _isLoading) return;

    final name = userName?.trim() ?? '';
    final isReturning = orderHistory.isNotEmpty;
    final hasAllergies = allergies.isNotEmpty;
    final hasPreferences = diningPreferences.trim().isNotEmpty;

    final buffer = StringBuffer();
    if (name.isNotEmpty) {
      buffer.write('Saluda a $name por su nombre y preséntate brevemente como el asistente virtual de OrdeNow.');
    } else {
      buffer.write('Saluda al cliente y preséntate brevemente como el asistente virtual de OrdeNow.');
    }
    if (isReturning) {
      buffer.write(' Es un cliente recurrente — puedes hacer referencia a visitas anteriores si es natural.');
    } else {
      buffer.write(' Es su primera visita — no menciones visitas ni pedidos anteriores que no existen.');
    }
    if (hasAllergies) {
      buffer.write(' YA sabes que tiene alergia a: ${allergies.join(", ")}. NO le preguntes por sus alergias; simplemente tenlas presentes.');
    }
    if (hasPreferences) {
      buffer.write(' Sus preferencias registradas son: $diningPreferences. No le preguntes qué prefiere.');
    }
    buffer.write(' Ofrécete a ayudarle a explorar el menú o hacer su pedido.');
    final greetingPrompt = buffer.toString();

    await _callAi(
      prompt: greetingPrompt,
      recommendedMenu: recommendedMenu,
      cartItems: const [],
      tableNumber: tableNumber,
      orderStatus: '',
      allergies: allergies,
      diningPreferences: diningPreferences,
      orderHistory: orderHistory,
      isGreeting: true,
    );
  }

  Future<void> sendMessage({
    required String prompt,
    required List<Menu> recommendedMenu,
    required List<Menu> cartItems,
    required int? tableNumber,
    required String orderStatus,
    List<String> allergies = const [],
    String diningPreferences = '',
    List<String> orderHistory = const [],
    bool isVoice = false,
  }) async {
    final trimmed = prompt.trim();
    if (trimmed.isEmpty || _isLoading) return;

    _messages.add(DemoAiMessage(text: trimmed, isUser: true, isVoice: isVoice));
    notifyListeners();

    await _callAi(
      prompt: trimmed,
      recommendedMenu: recommendedMenu,
      cartItems: cartItems,
      tableNumber: tableNumber,
      orderStatus: orderStatus,
      allergies: allergies,
      diningPreferences: diningPreferences,
      orderHistory: orderHistory,
    );
  }

  Future<void> _callAi({
    required String prompt,
    required List<Menu> recommendedMenu,
    required List<Menu> cartItems,
    required int? tableNumber,
    required String orderStatus,
    required List<String> allergies,
    required String diningPreferences,
    List<String> orderHistory = const [],
    bool isGreeting = false,
  }) async {
    _isLoading = true;
    notifyListeners();

    final aiResponse = await _aiService.generateConciergeReply(
      prompt: prompt,
      conversationHistory: List.from(_history),
      recommendedMenu: recommendedMenu,
      cartItems: cartItems,
      tableNumber: tableNumber,
      orderStatus: orderStatus,
      allergies: allergies,
      diningPreferences: diningPreferences,
      hasActiveOrder: _orderProvider.hasActiveOrder,
      orderHistory: orderHistory,
    );

    _history.add(ChatMessage(role: 'user', content: prompt));
    _history.add(ChatMessage(role: 'assistant', content: aiResponse.reply));

    if (_history.length > 8) {
      _history.removeRange(0, _history.length - 8);
    }

    final isConfirmation = aiResponse.action == 'confirm_order';
    _messages.add(DemoAiMessage(
      text: aiResponse.reply,
      isUser: false,
      isConfirmation: isConfirmation,
    ));

    if (aiResponse.action != 'none' && !isConfirmation) {
      await _executeAction(aiResponse.action, aiResponse.actionData);
    } else if (isConfirmation && aiResponse.actionData != null) {
      _pendingConfirmation = true;
      _pendingOrderData = aiResponse.actionData;
    }

    _isLoading = false;
    notifyListeners();

    if (_ttsEnabled) await _tts.speak(aiResponse.reply);
  }

  Future<void> _executeAction(String action, AiActionData? data) async {
    switch (action) {
      case 'add_to_cart':
        if (data != null) {
          for (final item in data.items) {
            _orderProvider.addItemById(id: item.id, quantity: item.quantity);
          }
        }

      case 'update_order':
        if (data != null) {
          if (_orderProvider.hasActiveOrder) {
            // Active order exists → append directly to it in Supabase
            await _orderProvider.appendItemsToActiveOrder(items: data.items);
            _messages.add(const DemoAiMessage(
              text: '¡Listo! Agregué los platos a tu pedido en curso.',
              isUser: false,
            ));
            notifyListeners();
          } else {
            // No active order yet → just add to local cart
            for (final item in data.items) {
              _orderProvider.addItemById(id: item.id, quantity: item.quantity);
            }
          }
        }

      case 'create_order':
        if (data != null && _currentUserId != null) {
          if (_orderProvider.hasActiveOrder) {
            // Guard: an order is already in flight — never create a second one.
            // Append the new items to the existing order instead.
            await _orderProvider.appendItemsToActiveOrder(items: data.items);
            _messages.add(const DemoAiMessage(
              text:
                  '¡Listo! Agregué los nuevos platos a tu pedido en curso. '
                  'El equipo de cocina ya los tiene.',
              isUser: false,
            ));
          } else {
            await _orderProvider.createOrderFromAi(
              items: data.items,
              total: data.total ?? 0,
              userId: _currentUserId!,
            );
            _messages.add(const DemoAiMessage(
              text:
                  '¡Tu pedido está en camino a la cocina! Te aviso cuando esté listo.',
              isUser: false,
            ));
          }
          notifyListeners();
        }

      case 'go_to_payment':
        _shouldNavigateToPayment = true;
        notifyListeners();
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
