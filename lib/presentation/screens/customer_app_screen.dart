import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/app_copy.dart';
import '../../domain/entities/menu.dart';
import '../providers/ai_provider.dart';
import '../providers/app_demo_provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/connectivity_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/ai_chat_box.dart';
import '../widgets/ai_message_bubble.dart';
import '../widgets/app_utility_toggles.dart';
import '../widgets/offline_banner.dart';
import 'client_profile_screen.dart';
import 'menu_catalog_screen.dart';
import 'order_tracking_screen.dart';
import 'payment_screen.dart';

class CustomerAppScreen extends StatelessWidget {
  const CustomerAppScreen({super.key});

  static const Map<String, String> _menuImages = {
    'menu-1': 'lib/assets/images/saffron_infused_sea_scallops.png',
    'menu-2': 'lib/assets/images/midnight_pasta.png',
    'menu-3': 'lib/assets/images/smoked_ribeye.png',
    'menu-4': 'lib/assets/images/artisan_harvest_bowl.png',
    'menu-5': 'lib/assets/images/background_bienvenida.png',
    'menu-6': 'lib/assets/images/background_bienvenida.png',
  };

  static const List<String> _customerLabels = [
    'IA',
    'Menú',
    'Pedidos',
    'Historial',
    'Perfil',
  ];

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<AppDemoProvider>();
    final palette = _CustomerPalette.of(context);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: IndexedStack(
                index: flow.customerScreen.index,
                children: const [
                  _MenuCatalogView(),
                  _SmartCartView(),
                  _AiConciergeView(),
                  _CheckoutView(),
                  OrderTrackingScreen(),
                  _HistoryView(),
                  _CustomerProfileView(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _CustomerBottomBar(
        selectedIndex: _navigationIndex(flow.customerScreen),
        highlightedLabel: _highlightedLabel(flow.customerScreen),
        onTap: (index) {
          switch (index) {
            case 0:
              flow.setCustomerScreen(CustomerScreen.aiConcierge);
            case 1:
              flow.setCustomerScreen(CustomerScreen.menu);
            case 2:
              flow.setCustomerScreen(CustomerScreen.tracking);
            case 3:
              flow.setCustomerScreen(CustomerScreen.history);
            case 4:
              flow.setCustomerScreen(CustomerScreen.profile);
          }
        },
      ),
    );
  }

  static String imageFor(String menuId) {
    return _menuImages[menuId] ?? 'lib/assets/images/background_bienvenida.png';
  }

  int _navigationIndex(CustomerScreen screen) {
    switch (screen) {
      case CustomerScreen.aiConcierge:
        return 0;
      case CustomerScreen.menu:
      case CustomerScreen.cart:
      case CustomerScreen.checkout:
        return 1;
      case CustomerScreen.tracking:
        return 2;
      case CustomerScreen.history:
        return 3;
      case CustomerScreen.profile:
        return 4;
    }
  }

  String _highlightedLabel(CustomerScreen screen) {
    return _customerLabels[_navigationIndex(screen)];
  }
}

class _MenuCatalogView extends StatelessWidget {
  const _MenuCatalogView();

  @override
  Widget build(BuildContext context) => const MenuCatalogScreen();
}

class _SmartCartView extends StatelessWidget {
  const _SmartCartView();

  @override
  Widget build(BuildContext context) {
    final palette = _CustomerPalette.of(context);
    final copy = AppCopy.of(context);
    final order = context.watch<OrderProvider>();
    final flow = context.read<AppDemoProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CustomerHeader(
            title: 'OrdeNow',
            leading: const CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage(
                'lib/assets/images/smoked_ribeye.png',
              ),
            ),
            trailing: const _InlineUtilityButtons(),
          ),
          const SizedBox(height: 18),
          Text(
            copy.isSpanish ? 'TU SELECCION' : 'YOUR SELECTION',
            style: const TextStyle(
              color: Color(0xFFE3B6A1),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            copy.isSpanish ? 'Carrito Inteligente' : 'Smart Cart',
            style: TextStyle(
              color: palette.primaryText,
              fontSize: 40,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 18),
          if (order.cartLineItems.isEmpty)
            _EmptyStateCard(
              title: copy.isSpanish
                  ? 'Tu carrito esta vacio'
                  : 'Your cart is empty',
              subtitle: copy.isSpanish
                  ? 'Agrega platos desde el menu para construir tu pedido y desbloquear maridajes de IA.'
                  : 'Add dishes from the menu to build your order and unlock AI pairings.',
              actionLabel: copy.isSpanish ? 'Ver Menu' : 'Browse Menu',
              onTap: () => flow.setCustomerScreen(CustomerScreen.menu),
            )
          else
            ...order.cartLineItems.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: _CartLineCard(line: line),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                _SummaryRow(
                  label: copy.isSpanish ? 'Subtotal' : 'Subtotal',
                  value: _formatPrice(order.cartTotal),
                ),
                const SizedBox(height: 10),
                _SummaryRow(
                  label: copy.isSpanish ? 'Tarifa de servicio' : 'Delivery Fee',
                  value: copy.isSpanish ? 'GRATIS' : 'FREE',
                  valueColor: Color(0xFF7EDB7A),
                ),
                const Divider(height: 30, color: Color(0x33FFFFFF)),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            copy.isSpanish ? 'TOTAL' : 'TOTAL AMOUNT',
                            style: const TextStyle(
                              color: Color(0xFFB7A39A),
                              fontSize: 12,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _formatPrice(order.checkoutTotal),
                            style: const TextStyle(
                              color: Color(0xFFFFC0A5),
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 168,
                      child: FilledButton(
                        onPressed: order.cartLineItems.isEmpty
                            ? null
                            : () => flow.setCustomerScreen(
                                CustomerScreen.checkout,
                              ),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8B4A),
                          foregroundColor: const Color(0xFF2D1200),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                        child: Text(
                          copy.isSpanish ? 'PAGAR' : 'CHECKOUT',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AiConciergeView extends StatefulWidget {
  const _AiConciergeView();

  @override
  State<_AiConciergeView> createState() => _AiConciergeViewState();
}

class _AiConciergeViewState extends State<_AiConciergeView> {
  bool _isListening = false;
  final ScrollController _scrollController = ScrollController();
  AiProvider? _aiProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _aiProvider = context.read<AiProvider>();
        _aiProvider!.addListener(_onAiChanged);
        _triggerGreeting();
      }
    });
  }

  void _onAiChanged() {
    if (!mounted) return;
    final ai = _aiProvider;
    if (ai != null && ai.shouldNavigateToPayment) {
      ai.clearNavigationFlag();
      context.read<AppDemoProvider>().setCustomerScreen(CustomerScreen.checkout);
    }
  }

  Future<void> _triggerGreeting() async {
    final auth = context.read<AuthProvider>();
    final order = context.read<OrderProvider>();
    final ai = context.read<AiProvider>();
    ai.setCurrentUser(auth.currentUser?.id); // always set before the guard
    if (ai.messages.isNotEmpty || ai.isLoading) return;
    await ai.sendGreeting(
      userName: auth.currentUser?.fullName,
      recommendedMenu: order.menu,
      tableNumber: order.selectedTable?.number,
      allergies: auth.currentUser?.allergies ?? [],
      diningPreferences: order.diningPreferences,
      orderHistory: order.historyItemNames,
    );
    _scrollToBottom();
  }

  @override
  void dispose() {
    _aiProvider?.removeListener(_onAiChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendPrompt(String prompt) async {
    final order = context.read<OrderProvider>();
    final auth = context.read<AuthProvider>();
    final ai = context.read<AiProvider>();
    ai.setCurrentUser(auth.currentUser?.id);
    await ai.sendMessage(
      prompt: prompt,
      recommendedMenu: order.menu,
      cartItems: order.cartItems,
      tableNumber: order.selectedTable?.number,
      orderStatus: order.currentOrderStatus,
      allergies: auth.currentUser?.allergies ?? [],
      diningPreferences: order.diningPreferences,
      orderHistory: order.historyItemNames,
    );
    _scrollToBottom();
  }

  Future<void> _sendVoicePrompt(String prompt) async {
    final order = context.read<OrderProvider>();
    final auth = context.read<AuthProvider>();
    final ai = context.read<AiProvider>();
    ai.setCurrentUser(auth.currentUser?.id);
    await ai.sendMessage(
      prompt: prompt,
      recommendedMenu: order.menu,
      cartItems: order.cartItems,
      tableNumber: order.selectedTable?.number,
      orderStatus: order.currentOrderStatus,
      allergies: auth.currentUser?.allergies ?? [],
      diningPreferences: order.diningPreferences,
      orderHistory: order.historyItemNames,
      isVoice: true,
    );
    _scrollToBottom();
  }

  String _initials(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return '?';
    final parts = fullName.trim().split(' ');
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final ai = context.watch<AiProvider>();
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<AppSettingsProvider>();
    final initials = _initials(auth.currentUser?.fullName);

    return Column(
      children: [
        // App bar
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6F22),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.restaurant_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'OrdeNow',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              const AppUtilityToggles(),
            ],
          ),
        ),
        // Messages list
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            itemCount: ai.messages.length + (ai.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == ai.messages.length) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 14),
                  child: _TypingIndicator(),
                );
              }
              final msg = ai.messages[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: AiMessageBubble(
                  text: msg.text,
                  isUser: msg.isUser,
                  userInitials: initials,
                  isVoice: msg.isVoice,
                ),
              );
            },
          ),
        ),
        // Confirm / cancel buttons shown when AI requests order confirmation
        Consumer<AiProvider>(
          builder: (context, ai, _) {
            if (!ai.pendingConfirmation) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: ai.cancelPendingOrder,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: ai.confirmPendingOrder,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6F22),
                      ),
                      child: const Text('Confirmar pedido'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        // Animated orb — visible when mic is active
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            child: _isListening ? const _OrbSection() : const SizedBox.shrink(),
          ),
        ),
        // Quick suggestion chips — hide when offline
        if (context.watch<ConnectivityProvider>().isOnline)
          _QuickChips(onSend: _sendPrompt),
        const SizedBox(height: 8),
        // Input bar — replaced by offline notice when disconnected
        if (context.watch<ConnectivityProvider>().isOnline)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: AiChatBox(
              hintText: settings.isSpanish
                  ? 'Escribe aquí...'
                  : 'Type here...',
              onSend: _sendPrompt,
              onVoiceSend: _sendVoicePrompt,
              isLoading: ai.isLoading,
              onListeningChanged: (v) => setState(() => _isListening = v),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    color: Color(0xFF636366),
                    size: 18,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'La IA no está disponible sin conexión. '
                      'Explora el menú para hacer tu pedido.',
                      style: TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _cycleTheme(AppSettingsProvider settings) async {
    switch (settings.themeMode) {
      case ThemeMode.system:
        await settings.updateThemeMode(ThemeMode.dark);
      case ThemeMode.dark:
        await settings.updateThemeMode(ThemeMode.light);
      case ThemeMode.light:
        await settings.updateThemeMode(ThemeMode.system);
    }
  }
}

class _OrbSection extends StatelessWidget {
  const _OrbSection();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF6F22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6F22).withValues(alpha: 0.55),
                  blurRadius: 50,
                  spreadRadius: 12,
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 52,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'ESCUCHANDO TUS ANTOJOS...',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: Color(0xFFFF6F22),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: const SizedBox(
            width: 36,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFFF6F22),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickChips extends StatelessWidget {
  const _QuickChips({required this.onSend});

  final ValueChanged<String> onSend;

  static const List<(IconData, String)> _chips = [
    (Icons.eco_outlined, 'Recomiéndame algo saludable'),
    (Icons.whatshot_outlined, 'Quiero algo con mucho sabor'),
    (Icons.local_cafe_outlined, 'Una bebida refrescante'),
    (Icons.star_outline_rounded, 'El plato especial del chef'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (icon, label) = _chips[index];
          return GestureDetector(
            onTap: () => onSend(label),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: const Color(0xFF62D26F), size: 13),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CheckoutView extends StatelessWidget {
  const _CheckoutView();

  @override
  Widget build(BuildContext context) => const PaymentScreen();
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>();
    final items = order.historyItems;

    return Column(
      children: [
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6F22),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.restaurant_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'OrdeNow',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              const AppUtilityToggles(),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const _EmptyHistory()
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  children: [
                    Text(
                      AppCopy.of(context).historyTitle,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              _HistoryItemThumbnail(item: item),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      item.category,
                                      style: const TextStyle(
                                        color: Color(0xFF8E8E93),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                _formatPrice(item.price),
                                style: const TextStyle(
                                  color: Color(0xFFFF6F22),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, color: Color(0xFF3A3A3C), size: 64),
          SizedBox(height: 16),
          Text(
            'Sin historial',
            style: TextStyle(
              color: Color(0xFF636366),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tus pedidos anteriores\naparecerán aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF3A3A3C)),
          ),
        ],
      ),
    );
  }
}

class _CustomerProfileView extends StatelessWidget {
  const _CustomerProfileView();

  @override
  Widget build(BuildContext context) => const ClientProfileScreen();
}

class _CustomerHeader extends StatelessWidget {
  const _CustomerHeader({
    required this.title,
    required this.leading,
    required this.trailing,
  });

  final String title;
  final Widget leading;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        leading,
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            color: const Color(0xFFFF6B00),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        trailing,
      ],
    );
  }
}

class _InlineUtilityButtons extends StatelessWidget {
  const _InlineUtilityButtons({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final palette = _CustomerPalette.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _UtilityAction(
          onTap: settings.toggleLanguage,
          background: palette.surface,
          width: compact ? 40 : 74,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.translate_rounded, size: 18),
              if (!compact) ...[
                const SizedBox(width: 6),
                Text(
                  settings.isSpanish ? 'ES' : 'EN',
                  style: TextStyle(
                    color: palette.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 10),
        _UtilityAction(
          onTap: () => _cycleThemeMode(settings),
          background: palette.surface,
          child: Icon(
            settings.themeMode == ThemeMode.light
                ? Icons.light_mode_rounded
                : settings.themeMode == ThemeMode.system
                ? Icons.settings_brightness_rounded
                : Icons.dark_mode_outlined,
            size: 18,
          ),
        ),
      ],
    );
  }

  Future<void> _cycleThemeMode(AppSettingsProvider settings) async {
    switch (settings.themeMode) {
      case ThemeMode.system:
        await settings.updateThemeMode(ThemeMode.dark);
      case ThemeMode.dark:
        await settings.updateThemeMode(ThemeMode.light);
      case ThemeMode.light:
        await settings.updateThemeMode(ThemeMode.system);
    }
  }
}

class _UtilityAction extends StatelessWidget {
  const _UtilityAction({
    required this.onTap,
    required this.child,
    required this.background,
    this.width,
  });

  final Future<void> Function()? onTap;
  final Widget child;
  final Color background;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final palette = _CustomerPalette.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: width ?? 40,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: palette.outline),
        ),
        alignment: Alignment.center,
        child: IconTheme(
          data: IconThemeData(color: palette.primaryText),
          child: child,
        ),
      ),
    );
  }
}

class _CustomerPalette {
  const _CustomerPalette({
    required this.background,
    required this.surface,
    required this.surfaceStrong,
    required this.primaryText,
    required this.mutedText,
    required this.navBackground,
    required this.outline,
  });

  final Color background;
  final Color surface;
  final Color surfaceStrong;
  final Color primaryText;
  final Color mutedText;
  final Color navBackground;
  final Color outline;

  static _CustomerPalette of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return isDark
        ? const _CustomerPalette(
            background: Color(0xFF120F0D),
            surface: Color(0xFF2A2522),
            surfaceStrong: Color(0xFF1D1A18),
            primaryText: Colors.white,
            mutedText: Color(0xFFB8ADA5),
            navBackground: Color(0xFF171413),
            outline: Color(0x22FFFFFF),
          )
        : const _CustomerPalette(
            background: Color(0xFFF7EEE7),
            surface: Color(0xFFFFFFFF),
            surfaceStrong: Color(0xFFF1E3D8),
            primaryText: Color(0xFF2A1C16),
            mutedText: Color(0xFF7B685E),
            navBackground: Color(0xFFF6E8DD),
            outline: Color(0x22A0694B),
          );
  }
}

class _CustomerBottomBar extends StatelessWidget {
  const _CustomerBottomBar({
    required this.selectedIndex,
    required this.highlightedLabel,
    required this.onTap,
  });

  final int selectedIndex;
  final String highlightedLabel;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final palette = _CustomerPalette.of(context);
    const icons = [
      Icons.auto_awesome_outlined,
      Icons.restaurant_menu_outlined,
      Icons.receipt_long_outlined,
      Icons.history_outlined,
      Icons.person_outline_rounded,
    ];
    const labels = ['IA', 'Menú', 'Pedidos', 'Historial', 'Perfil'];

    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: palette.navBackground,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(labels.length, (index) {
          final isSelected = index == selectedIndex;
          final displayLabel = isSelected ? highlightedLabel : labels[index];

          return GestureDetector(
            onTap: () => onTap(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF3A2517)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icons[index],
                    color: isSelected
                        ? const Color(0xFFFF7B1A)
                        : const Color(0xFF98908A),
                    size: 20,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    displayLabel.toUpperCase(),
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFFFF7B1A)
                          : const Color(0xFF98908A),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _CartLineCard extends StatelessWidget {
  const _CartLineCard({required this.line});

  final CartLineItem line;

  @override
  Widget build(BuildContext context) {
    final order = context.read<OrderProvider>();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1D1A18),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: _CartLineImage(
              imagePath: line.menu.imageUrl.isNotEmpty
                  ? line.menu.imageUrl
                  : CustomerAppScreen.imageFor(line.menu.id),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        line.menu.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      _formatPrice(line.total),
                      style: const TextStyle(
                        color: Color(0xFFEAB8A1),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  line.menu.description,
                  style: const TextStyle(color: Color(0xFFC4B3AA), height: 1.4),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF34312E),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () =>
                                order.decrementItemQuantity(line.menu.id),
                            icon: const Icon(Icons.remove),
                          ),
                          Text(
                            '${line.quantity}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          IconButton(
                            onPressed: () => order.addItemToCart(line.menu.id),
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => order.addItemToCart(line.menu.id),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('MODIFY'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartLineImage extends StatelessWidget {
  const _CartLineImage({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final path = imagePath.trim();
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _CartImagePlaceholder(),
      );
    }

    return Image.asset(
      path,
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _CartImagePlaceholder(),
    );
  }
}

class _CartImagePlaceholder extends StatelessWidget {
  const _CartImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      color: Theme.of(context).colorScheme.surface,
      child: Icon(
        Icons.restaurant_rounded,
        color: Theme.of(context).dividerColor,
        size: 44,
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = _CustomerPalette.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: palette.primaryText,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFFB7A39A), height: 1.5),
          ),
          const SizedBox(height: 18),
          FilledButton(onPressed: onTap, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFFDCC5BA),
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFFB8A59B), fontSize: 16),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _HistoryItemThumbnail extends StatelessWidget {
  const _HistoryItemThumbnail({required this.item});

  final Menu item;

  @override
  Widget build(BuildContext context) {
    final url = item.imageUrl.trim();
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          url,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const _HistoryThumbFallback(),
        ),
      );
    }
    final assetPath = url.isNotEmpty
        ? url
        : CustomerAppScreen.imageFor(item.id);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        assetPath,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _HistoryThumbFallback(),
      ),
    );
  }
}

class _HistoryThumbFallback extends StatelessWidget {
  const _HistoryThumbFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFFF6F22).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.restaurant_rounded, color: Color(0xFFFF6F22)),
    );
  }
}

String _formatPrice(double value) {
  final intVal = value.toInt();
  final formatted = intVal.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
  return '\$$formatted';
}
