import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/app_copy.dart';
import '../../domain/entities/menu.dart';
import '../providers/ai_provider.dart';
import '../providers/app_demo_provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/ai_message_bubble.dart';
import '../widgets/order_progress.dart';

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
    'Discover',
    'Orders',
    'AI Concierge',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<AppDemoProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF120F0D),
      body: SafeArea(
        child: IndexedStack(
          index: flow.customerScreen.index,
          children: const [
            _MenuCatalogView(),
            _SmartCartView(),
            _AiConciergeView(),
            _CheckoutView(),
            _TrackingView(),
            _CustomerProfileView(),
          ],
        ),
      ),
      bottomNavigationBar: _CustomerBottomBar(
        selectedIndex: _navigationIndex(flow.customerScreen),
        highlightedLabel: _highlightedLabel(flow.customerScreen),
        onTap: (index) {
          switch (index) {
            case 0:
              flow.setCustomerScreen(CustomerScreen.menu);
            case 1:
              flow.setCustomerScreen(CustomerScreen.cart);
            case 2:
              flow.setCustomerScreen(CustomerScreen.aiConcierge);
            case 3:
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
      case CustomerScreen.menu:
        return 0;
      case CustomerScreen.cart:
      case CustomerScreen.checkout:
      case CustomerScreen.tracking:
        return 1;
      case CustomerScreen.aiConcierge:
        return 2;
      case CustomerScreen.profile:
        return 3;
    }
  }

  String _highlightedLabel(CustomerScreen screen) {
    switch (screen) {
      case CustomerScreen.checkout:
        return 'Checkout';
      case CustomerScreen.tracking:
        return 'Orders';
      default:
        return _customerLabels[_navigationIndex(screen)];
    }
  }
}

class _MenuCatalogView extends StatefulWidget {
  const _MenuCatalogView();

  @override
  State<_MenuCatalogView> createState() => _MenuCatalogViewState();
}

class _MenuCatalogViewState extends State<_MenuCatalogView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All Dishes';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>();
    final flow = context.read<AppDemoProvider>();
    final categories = <String>[
      'All Dishes',
      ...order.menu.map((item) => item.category).toSet(),
    ];
    final search = _searchController.text.trim().toLowerCase();
    final filteredMenu = order.menu.where((item) {
      final matchesCategory = _selectedCategory == 'All Dishes' ||
          item.category == _selectedCategory;
      final matchesSearch = search.isEmpty ||
          item.name.toLowerCase().contains(search) ||
          item.description.toLowerCase().contains(search);
      return matchesCategory && matchesSearch;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CustomerHeader(
            title: 'OrdeNow',
            leading: const CircleAvatar(
              radius: 18,
              backgroundImage:
                  AssetImage('lib/assets/images/background_bienvenida.png'),
            ),
            trailing: IconButton(
              onPressed: () => flow.setCustomerScreen(CustomerScreen.cart),
              icon: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2522),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFBCA1)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'What are you craving today?',
                      hintStyle: TextStyle(color: Color(0xFF8E827A)),
                    ),
                  ),
                ),
                const Icon(Icons.search_rounded, color: Color(0xFFB8ADA5)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == _selectedCategory;
                return ChoiceChip(
                  selected: isSelected,
                  label: Text(category),
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                );
              },
              separatorBuilder: (_, index) => const SizedBox(width: 10),
              itemCount: categories.length,
            ),
          ),
          const SizedBox(height: 20),
          if (filteredMenu.isNotEmpty)
            _FeaturedDishCard(menu: filteredMenu.first),
          const SizedBox(height: 18),
          ...filteredMenu.skip(1).map(
            (menu) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: _MenuListCard(
                menu: menu,
                onAdd: () => order.addItemToCart(menu.id),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const _AllergyAwarenessCard(),
        ],
      ),
    );
  }
}

class _SmartCartView extends StatelessWidget {
  const _SmartCartView();

  @override
  Widget build(BuildContext context) {
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
              backgroundImage:
                  AssetImage('lib/assets/images/smoked_ribeye.png'),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF342F2B),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.translate_rounded),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF342F2B),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.dark_mode_outlined),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'YOUR SELECTION',
            style: TextStyle(
              color: Color(0xFFE3B6A1),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Smart Cart',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 18),
          if (order.cartLineItems.isEmpty)
            _EmptyStateCard(
              title: 'Your cart is empty',
              subtitle:
                  'Add dishes from the menu to build your order and unlock AI pairings.',
              actionLabel: 'Browse Menu',
              onTap: () => flow.setCustomerScreen(CustomerScreen.menu),
            )
          else
            ...order.cartLineItems.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: _CartLineCard(line: line),
              ),
            ),
          const SizedBox(height: 8),
          const Text(
            "SOMMELIER'S PAIRINGS",
            style: TextStyle(
              color: Color(0xFFEAB8A1),
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 210,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _PairingCard(
                  title: 'Amber Craft Ale',
                  subtitle: 'Pairs with burger',
                  price: 7500,
                  imagePath: 'lib/assets/images/background_bienvenida.png',
                  onAdd: () => order.addItemToCart('menu-5'),
                ),
                const SizedBox(width: 14),
                _PairingCard(
                  title: 'Blood Orange Fizz',
                  subtitle: 'Refreshing',
                  price: 5000,
                  imagePath: 'lib/assets/images/background_bienvenida.png',
                  onAdd: () => order.addItemToCart('menu-5'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2522),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                _SummaryRow(
                  label: 'Subtotal',
                  value: _formatPrice(order.cartTotal),
                ),
                const SizedBox(height: 10),
                const _SummaryRow(
                  label: 'Delivery Fee',
                  value: 'FREE',
                  valueColor: Color(0xFF7EDB7A),
                ),
                const Divider(height: 30, color: Color(0x33FFFFFF)),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOTAL AMOUNT',
                            style: TextStyle(
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
                            : () => flow.setCustomerScreen(CustomerScreen.checkout),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8B4A),
                          foregroundColor: const Color(0xFF2D1200),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                        child: const Text(
                          'CHECKOUT',
                          style: TextStyle(fontWeight: FontWeight.w800),
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
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendPrompt(BuildContext context, String prompt) async {
    final order = context.read<OrderProvider>();
    final ai = context.read<AiProvider>();
    await ai.sendMessage(
      prompt: prompt,
      recommendedMenu: order.recommendedMenu,
      cartItems: order.cartItems,
      tableNumber: order.selectedTable?.number,
      orderStatus: order.currentOrderStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ai = context.watch<AiProvider>();
    final flow = context.read<AppDemoProvider>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage:
                    AssetImage('lib/assets/images/background_bienvenida.png'),
              ),
              const SizedBox(width: 12),
              const Text(
                'OrdeNow',
                style: TextStyle(
                  color: Color(0xFFFF6B00),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2B2927),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.language_rounded, size: 16),
                    SizedBox(width: 6),
                    Text('EN'),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => flow.setCustomerScreen(CustomerScreen.cart),
                icon: const Icon(Icons.shopping_bag_outlined),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Your ',
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: 'Sensory',
                  style: TextStyle(color: Color(0xFFFF6B00)),
                ),
                TextSpan(
                  text: '\nSommelier.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w300,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Curating the perfect flavors for your mood.\nWhat are you craving today?',
            style: TextStyle(
              color: Color(0xFFD9C1B7),
              fontSize: 16,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ListView(
              children: [
                ...ai.messages.map(
                  (message) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: AiMessageBubble(
                      text: message.text,
                      isUser: message.isUser,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'lib/assets/images/midnight_pasta.png',
                        height: 185,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.72),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Wild Mushroom & Truffle\nLinguine',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              _Tag(text: "CHEF'S CHOICE", color: Color(0xFF1F8D3A)),
                              SizedBox(width: 8),
                              _Tag(text: 'PREMIUM', color: Color(0xFF7C5A2B)),
                              Spacer(),
                              Text(
                                '\$34',
                                style: TextStyle(
                                  color: Color(0xFFFF6B00),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B2927),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Describe a flavor or mood...',
                            hintStyle: TextStyle(color: Color(0xFF7F746D)),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          final prompt = _controller.text;
                          _controller.clear();
                          _sendPrompt(context, prompt);
                        },
                        icon: const Icon(
                          Icons.send_outlined,
                          color: Color(0xFFFFBBA0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFA167), Color(0xFFFF6B00)],
                  ),
                ),
                child: const Icon(Icons.mic_rounded, color: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CheckoutView extends StatelessWidget {
  const _CheckoutView();

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>();
    final auth = context.watch<AuthProvider>();
    final flow = context.read<AppDemoProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CustomerHeader(
            title: 'OrdeNow',
            leading: IconButton(
              onPressed: () => flow.setCustomerScreen(CustomerScreen.cart),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            trailing: const CircleAvatar(
              radius: 18,
              backgroundImage:
                  AssetImage('lib/assets/images/smoked_ribeye.png'),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFF3B261F), Color(0xFF231F1D)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Finalize Order',
                  style: TextStyle(
                    color: Color(0xFFFFBCA1),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Selected: Tasting Menu for Two',
                  style: TextStyle(color: Color(0xFFB6A198)),
                ),
                const SizedBox(height: 20),
                Text(
                  _formatPrice(order.checkoutTotal),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _PaymentMethodCard(
                  selected: order.paymentMethod == 'card',
                  label: 'Card / Wallet',
                  icon: Icons.credit_card_rounded,
                  onTap: () => order.setPaymentMethod('card'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _PaymentMethodCard(
                  selected: order.paymentMethod == 'cash',
                  label: 'Cash',
                  icon: Icons.payments_outlined,
                  onTap: () => order.setPaymentMethod('cash'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _CheckoutField(label: 'CARDHOLDER NAME', hint: 'ALEXANDER SOMMELIER'),
          const SizedBox(height: 16),
          const _CheckoutField(label: 'CARD NUMBER', hint: '**** **** **** 8829'),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: _CheckoutField(label: 'EXPIRY DATE', hint: 'MM/YY'),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _CheckoutField(label: 'CVV', hint: '***'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'OR PAY WITH',
            style: TextStyle(
              color: Color(0xFFAF9E96),
              fontSize: 12,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFF381C2B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF6B3451)),
            ),
            child: const Row(
              children: [
                Icon(Icons.account_balance_wallet_rounded,
                    color: Color(0xFFFF72B0)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Nequi Digital Wallet',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2A28),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payments_rounded, color: Color(0xFF7EDB7A)),
                SizedBox(width: 10),
                Text(
                  'Pay in Cash',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1C1A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Selecting "Pay in Cash" will immediately notify the restaurant administrator.',
              style: TextStyle(color: Color(0xFFAF9E96), height: 1.5),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: order.cartLineItems.isEmpty
                  ? null
                  : () {
                      if (!order.hasSelectedTable) {
                        order.selectTable(order.tables.first.id);
                      }

                      if (!order.hasActiveOrder) {
                        order.placeDemoOrder(
                          userId: auth.currentUser?.id ?? 'customer-preview',
                          notes: 'Created from checkout flow.',
                        );
                      }

                      if (order.paymentMethod == 'card') {
                        order.markAsPaid(paymentMethod: 'card');
                      } else {
                        order.requestCashDesk();
                      }

                      flow.setCustomerScreen(CustomerScreen.tracking);
                    },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF8B4A),
                foregroundColor: const Color(0xFF2D1200),
                padding: const EdgeInsets.symmetric(vertical: 24),
              ),
              child: const Text(
                'CONFIRM PAYMENT',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingView extends StatelessWidget {
  const _TrackingView();

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>();
    final flow = context.read<AppDemoProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CustomerHeader(
            title: 'OrdeNow',
            leading: const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.black,
              child: Icon(Icons.person_outline, color: Colors.white70),
            ),
            trailing: IconButton(
              onPressed: () => flow.setCustomerScreen(CustomerScreen.cart),
              icon: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
          const SizedBox(height: 28),
          Container(
            height: 275,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              image: const DecorationImage(
                image: AssetImage('lib/assets/images/background_bienvenida.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.85),
                    Colors.transparent,
                  ],
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _Tag(text: 'ORDER #8821', color: Color(0xFF188A31)),
                    SizedBox(height: 14),
                    Text(
                      'Preparing your\nSignature\nCourse',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        height: 1.1,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Estimated arrival at your table: 12 mins',
                      style: TextStyle(
                        color: Color(0xFFD5C8C1),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2E2B28),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      'Live Status',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Spacer(),
                    Text(
                      'LIVE KITCHEN FEED',
                      style: TextStyle(
                        color: Color(0xFF84D975),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                OrderProgress(currentStep: order.orderStepIndex),
                const SizedBox(height: 16),
                if (order.activeOrder != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: order.advanceKitchenStatus,
                      child: const Text('Advance Status'),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1D1B1A),
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Column(
              children: [
                Icon(Icons.qr_code_2_rounded, size: 120, color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Digital Receipt',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Scan to pay or split the bill with your party',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFB5A59D)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2B2927),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Concierge',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Need to add another drink? Allergies? Just ask me anything about your current order.',
                  style: TextStyle(color: Color(0xFFD9C1B7), height: 1.5),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () => flow.setCustomerScreen(CustomerScreen.aiConcierge),
                  child: const Text('Talk to AI'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Order Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ...order.orderedItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _OrderDetailRow(menu: item),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerProfileView extends StatelessWidget {
  const _CustomerProfileView();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<AppSettingsProvider>();
    final flow = context.read<AppDemoProvider>();
    final order = context.watch<OrderProvider>();
    final copy = AppCopy.of(context);
    final user = auth.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CustomerHeader(
            title: 'OrdeNow',
            leading: const CircleAvatar(
              radius: 18,
              child: Icon(Icons.person),
            ),
            trailing: IconButton(
              onPressed: () => flow.setCustomerScreen(CustomerScreen.cart),
              icon: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 260,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              image: const DecorationImage(
                image: AssetImage('lib/assets/images/background_bienvenida.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.82),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        color: const Color(0xFF181A23),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0x334E6484)),
                      ),
                      child: const Icon(Icons.badge_rounded,
                          size: 52, color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.fullName ?? 'Julian Rossi',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'julian.rossi@aesthetic.com',
                      style: const TextStyle(
                        color: Color(0xFFE6B6A1),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1C1A),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Allergy\nPreferences',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                _PreferenceTile(
                  title: 'Gluten-Free',
                  value: true,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 12),
                _PreferenceTile(
                  title: 'Egg Allergy',
                  value: false,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 12),
                _PreferenceTile(
                  title: 'Shellfish',
                  value: true,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 12),
                _PreferenceTile(
                  title: 'Peanuts',
                  value: false,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4C2D22),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x66B56E4E)),
                  ),
                  child: const Text(
                    'Our AI Concierge will automatically flag any dishes containing these ingredients across all menus.',
                    style: TextStyle(
                      color: Color(0xFFFFD0BB),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1C1A),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      'Recent Orders',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Spacer(),
                    Text(
                      'View All',
                      style: TextStyle(color: Color(0xFFE5B49D)),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ...order.orderedItems.take(2).map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _RecentOrderTile(menu: item),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1C1A),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'App Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'LANGUAGE',
                  style: TextStyle(
                    color: Color(0xFF8C7E76),
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2B29),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SegmentButton(
                          label: 'English',
                          selected: !copy.isSpanish,
                          onTap: () => settings.updateLanguage('en'),
                        ),
                      ),
                      Expanded(
                        child: _SegmentButton(
                          label: 'Spanish',
                          selected: copy.isSpanish,
                          onTap: () => settings.updateLanguage('es'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'DISPLAY THEME',
                  style: TextStyle(
                    color: Color(0xFF8C7E76),
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _ThemeOption(
                        label: 'Dark',
                        icon: Icons.dark_mode_outlined,
                        selected: settings.themeMode == ThemeMode.dark,
                        onTap: () => settings.updateThemeMode(ThemeMode.dark),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ThemeOption(
                        label: 'Light',
                        icon: Icons.light_mode_outlined,
                        selected: settings.themeMode == ThemeMode.light,
                        onTap: () => settings.updateThemeMode(ThemeMode.light),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ThemeOption(
                        label: 'System',
                        icon: Icons.settings_brightness_outlined,
                        selected: settings.themeMode == ThemeMode.system,
                        onTap: () => settings.updateThemeMode(ThemeMode.system),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF281E21),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.logout_rounded, color: Color(0xFFE4B6A1)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Sign Out\nWe'll save your palate settings for next time.",
                          style: TextStyle(color: Colors.white70, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 126,
                child: FilledButton(
                  onPressed: () async {
                    await auth.logout();
                    flow.backToWelcome();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFA10014),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  child: const Text('Log out'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
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
          style: const TextStyle(
            color: Color(0xFFFF6B00),
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
    const icons = [
      Icons.explore_outlined,
      Icons.receipt_long_outlined,
      Icons.auto_awesome_outlined,
      Icons.person_outline_rounded,
    ];
    const labels = ['Discover', 'Orders', 'AI Concierge', 'Profile'];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF171413),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x22FFFFFF)),
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

class _FeaturedDishCard extends StatelessWidget {
  const _FeaturedDishCard({
    required this.menu,
  });

  final Menu menu;

  @override
  Widget build(BuildContext context) {
    final order = context.read<OrderProvider>();

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Image.asset(
            CustomerAppScreen.imageFor(menu.id),
            height: 260,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.82),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CHEF SIGNATURE',
                style: TextStyle(
                  color: Color(0xFF8FD37B),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.7,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                menu.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    _formatPrice(menu.price),
                    style: const TextStyle(
                      color: Color(0xFFFFC3A5),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => order.addItemToCart(menu.id),
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuListCard extends StatelessWidget {
  const _MenuListCard({
    required this.menu,
    required this.onAdd,
  });

  final Menu menu;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF191716),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: Image.asset(
              CustomerAppScreen.imageFor(menu.id),
              height: 210,
              width: double.infinity,
              fit: BoxFit.cover,
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
                        menu.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      _formatPrice(menu.price),
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
                  menu.description,
                  style: const TextStyle(
                    color: Color(0xFFB8ABA3),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ...menu.tags.take(2).map(
                      (tag) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _MiniIconTag(tag: tag),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: onAdd,
                      child: const Text('DETAILS'),
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

class _MiniIconTag extends StatelessWidget {
  const _MiniIconTag({
    required this.tag,
  });

  final String tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2C2B26),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Center(
        child: Text(
          tag.characters.first.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFFE5B9A2),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _AllergyAwarenessCard extends StatelessWidget {
  const _AllergyAwarenessCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2927),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ALLERGY AWARENESS',
            style: TextStyle(
              color: Color(0xFF8BD270),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Informed Dining',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Each of our creations is meticulously documented. Select any dish to view its molecular ingredient breakdown.',
            style: TextStyle(
              color: Color(0xFFD7C5BC),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _Tag(text: 'Nut Free Options', color: Color(0xFF43341B)),
              _Tag(text: 'Plant-Based Focus', color: Color(0xFF213722)),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'lib/assets/images/background_bienvenida.png',
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartLineCard extends StatelessWidget {
  const _CartLineCard({
    required this.line,
  });

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
            child: Image.asset(
              CustomerAppScreen.imageFor(line.menu.id),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
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

class _PairingCard extends StatelessWidget {
  const _PairingCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.imagePath,
    required this.onAdd,
  });

  final String title;
  final String subtitle;
  final double price;
  final String imagePath;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 185,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF23201E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              imagePath,
              height: 110,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF8BD270),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                _formatPrice(price),
                style: const TextStyle(
                  color: Color(0xFFFFC0A5),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: onAdd,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6B00),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.black),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.selected,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF261A13) : const Color(0xFF2E2B29),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFFFF6B00) : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFFFBFA3)),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutField extends StatelessWidget {
  const _CheckoutField({
    required this.label,
    required this.hint,
  });

  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFAF9E96),
            fontSize: 12,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF34312E),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            hint,
            style: const TextStyle(color: Color(0xFF7D746F)),
          ),
        ),
      ],
    );
  }
}

class _OrderDetailRow extends StatelessWidget {
  const _OrderDetailRow({
    required this.menu,
  });

  final Menu menu;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            CustomerAppScreen.imageFor(menu.id),
            width: 82,
            height: 82,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                menu.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                menu.description,
                style: const TextStyle(color: Color(0xFFB7A39A), height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          _formatPrice(menu.price),
          style: const TextStyle(
            color: Color(0xFFEAB8A1),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  const _PreferenceTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF2F2C29),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.spa_outlined, color: Color(0xFFC9AEA0)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF72DB6E),
          ),
        ],
      ),
    );
  }
}

class _RecentOrderTile extends StatelessWidget {
  const _RecentOrderTile({
    required this.menu,
  });

  final Menu menu;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset(
            CustomerAppScreen.imageFor(menu.id),
            width: 52,
            height: 52,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                menu.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Delivered',
                style: TextStyle(
                  color: const Color(0xFF7EDB7A).withValues(alpha: 0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Text(
          _formatPrice(menu.price),
          style: const TextStyle(color: Color(0xFFCFAF9F)),
        ),
      ],
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4B433E) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? const Color(0xFFFFC0A5) : const Color(0xFF9D8F87),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2B2320) : const Color(0xFF2F2C29),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFFE5B39C) : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: selected
                    ? const Color(0xFFE5B39C)
                    : const Color(0xFF90827A)),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? const Color(0xFFE5B39C)
                    : const Color(0xFF90827A),
              ),
            ),
          ],
        ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1A18),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
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
          FilledButton(
            onPressed: onTap,
            child: Text(actionLabel),
          ),
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

class _Tag extends StatelessWidget {
  const _Tag({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

String _formatPrice(double value) {
  return '\$${value.toStringAsFixed(2)}';
}
