import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ai_provider.dart';
import '../providers/app_demo_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/ai_message_bubble.dart';
import '../widgets/demo_section_card.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/order_progress.dart';

class CustomerDemoScreen extends StatefulWidget {
  const CustomerDemoScreen({super.key});

  @override
  State<CustomerDemoScreen> createState() => _CustomerDemoScreenState();
}

class _CustomerDemoScreenState extends State<CustomerDemoScreen> {
  final TextEditingController _chatController = TextEditingController();

  static const _menuImages = {
    'menu-1': 'lib/assets/images/saffron_infused_sea_scallops.png',
    'menu-2': 'lib/assets/images/midnight_pasta.png',
    'menu-3': 'lib/assets/images/smoked_ribeye.png',
    'menu-4': 'lib/assets/images/artisan_harvest_bowl.png',
    'menu-5': 'lib/assets/images/background_bienvenida.png',
    'menu-6': 'lib/assets/images/background_bienvenida.png',
  };

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final order = context.watch<OrderProvider>();
    final ai = context.watch<AiProvider>();
    final demo = context.read<AppDemoProvider>();

    final userName = auth.currentUser?.fullName ?? 'Demo Guest';
    final table = order.selectedTable;

    return Scaffold(
      backgroundColor: const Color(0xFF120F0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Customer Demo',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          TextButton(
            onPressed: () {
              order.clearDemoState();
              ai.resetConversation();
              demo.backToWelcome();
            },
            child: const Text('Exit Demo'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            DemoSectionCard(
              title: 'Welcome, $userName',
              subtitle:
                  'This simulated journey lets you test table selection, AI ordering, live kitchen updates and payment.',
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B00).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'User Demo',
                  style: TextStyle(
                    color: Color(0xFFFFB088),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _InfoChip(
                    icon: Icons.table_restaurant_rounded,
                    label: table == null
                        ? 'No table selected'
                        : 'Table ${table.number} selected',
                  ),
                  _InfoChip(
                    icon: Icons.restaurant_menu_rounded,
                    label: '${order.cartItems.length} items in cart',
                  ),
                  _InfoChip(
                    icon: Icons.payments_rounded,
                    label: order.hasActiveOrder
                        ? order.isPaid
                            ? 'Paid'
                            : 'Pending payment'
                        : 'No active order',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DemoSectionCard(
              title: 'Table Selection',
              subtitle:
                  'The customer chooses the physical table number before starting the conversation.',
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: order.tables.map((tableItem) {
                  final isSelected = tableItem.id == order.selectedTableId;
                  return ChoiceChip(
                    selected: isSelected,
                    label: Text('Table ${tableItem.number}'),
                    onSelected: (_) => order.selectTable(tableItem.id),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            DemoSectionCard(
              title: 'AI Concierge',
              subtitle:
                  'This mock assistant reacts to cravings, allergies, drinks, order status and cart context.',
              child: Column(
                children: [
                  Container(
                    constraints: const BoxConstraints(maxHeight: 320),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: ai.messages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final message = ai.messages[index];
                        return AiMessageBubble(
                          text: message.text,
                          isUser: message.isUser,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'I want something premium',
                      'Any light options for allergies?',
                      'Suggest a drink',
                      'What is my order status?',
                    ].map((prompt) {
                      return ActionChip(
                        label: Text(prompt),
                        onPressed: () {
                          ai.sendMessage(
                            prompt: prompt,
                            recommendedMenu: order.recommendedMenu,
                            cartItems: order.cartItems,
                            tableNumber: table?.number,
                            orderStatus: order.currentOrderStatus,
                          );
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _chatController,
                          decoration: const InputDecoration(
                            hintText: 'Talk to the AI demo...',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        onPressed: () {
                          ai.sendMessage(
                            prompt: _chatController.text,
                            recommendedMenu: order.recommendedMenu,
                            cartItems: order.cartItems,
                            tableNumber: table?.number,
                            orderStatus: order.currentOrderStatus,
                          );
                          _chatController.clear();
                        },
                        child: const Text('Send'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DemoSectionCard(
              title: 'Recommended Menu',
              subtitle:
                  'A mix of signature dishes and drinks that the AI can recommend and the guest can add instantly.',
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.menu.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 320,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final item = order.menu[index];
                  return MenuItemCard(
                    menu: item,
                    imagePath:
                        _menuImages[item.id] ?? 'lib/assets/images/background_bienvenida.png',
                    onAdd: () => order.addItemToCart(item.id),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            DemoSectionCard(
              title: 'Current Cart',
              subtitle:
                  'Review items, payment method and place the simulated order to the KDS.',
              trailing: Text(
                '\$${order.cartTotal.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Color(0xFFFFC1A1),
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: Column(
                children: [
                  if (order.cartItems.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Text(
                        'The cart is empty. Add dishes from the menu to simulate the order flow.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  else
                    ...order.cartItems.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${item.price.toStringAsFixed(0)} COP',
                                      style: const TextStyle(
                                        color: Color(0xFFFFB792),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => order.removeItemFromCart(item.id),
                                icon: const Icon(Icons.close_rounded),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 12),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'card',
                        label: Text('Card'),
                        icon: Icon(Icons.credit_card_rounded),
                      ),
                      ButtonSegment(
                        value: 'cash',
                        label: Text('Cash'),
                        icon: Icon(Icons.payments_rounded),
                      ),
                    ],
                    selected: {order.paymentMethod},
                    onSelectionChanged: (value) {
                      order.setPaymentMethod(value.first);
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: !order.hasSelectedTable || order.cartItems.isEmpty
                          ? null
                          : () {
                              order.placeDemoOrder(
                                userId: auth.currentUser?.id ?? 'demo-customer',
                                notes: 'No peanuts, medium spice, sparkling water.',
                              );
                            },
                      child: const Text('Send Order To Kitchen'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DemoSectionCard(
              title: 'Live Order Tracking',
              subtitle:
                  'This mirrors the guest experience while the admin kitchen screen updates the order.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OrderProgress(currentStep: order.orderStepIndex),
                  const SizedBox(height: 16),
                  Text(
                    'Status: ${order.currentOrderStatus.toUpperCase()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (order.activeOrder != null) ...[
                    ...order.orderedItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '- ${item.name}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        OutlinedButton.icon(
                          onPressed: order.advanceKitchenStatus,
                          icon: const Icon(Icons.local_fire_department_rounded),
                          label: const Text('Advance Demo Status'),
                        ),
                        OutlinedButton.icon(
                          onPressed: order.requestCashDesk,
                          icon: const Icon(Icons.point_of_sale_rounded),
                          label: const Text('Request Cash Desk'),
                        ),
                      ],
                    ),
                  ] else
                    const Text(
                      'No active order yet. Place one from the cart to start the timeline.',
                      style: TextStyle(color: Colors.white70),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DemoSectionCard(
              title: 'Payment',
              subtitle:
                  'Simulate the final step. Card pays instantly, cash flags the table for the admin cashier.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.isPaid
                        ? 'Payment completed with ${order.activeOrder?.paymentMethod ?? order.paymentMethod}.'
                        : 'Payment pending. Choose how the guest will close the bill.',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton(
                        onPressed: order.activeOrder == null
                            ? null
                            : () => order.markAsPaid(paymentMethod: 'card'),
                        child: const Text('Simulate Card Payment'),
                      ),
                      OutlinedButton(
                        onPressed: order.activeOrder == null
                            ? null
                            : () {
                                order.requestCashDesk();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Table flagged for cash payment on admin side.',
                                    ),
                                  ),
                                );
                              },
                        child: const Text('Pay In Cash'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFFFB088)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
