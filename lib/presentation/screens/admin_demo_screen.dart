import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ai_provider.dart';
import '../providers/app_demo_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/demo_section_card.dart';
import '../widgets/order_progress.dart';

class AdminDemoScreen extends StatelessWidget {
  const AdminDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>();
    final ai = context.read<AiProvider>();
    final demo = context.read<AppDemoProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF120F0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Admin + KDS Demo',
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
              title: 'Operations Snapshot',
              subtitle:
                  'This dashboard simulates the restaurant back office: kitchen progress, occupied tables and cashier follow-up.',
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF7DDB7A).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'Admin Demo',
                  style: TextStyle(
                    color: Color(0xFF9AE198),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _AdminStatCard(
                      label: 'Occupied Tables',
                      value: '${order.occupiedTables.length}',
                      icon: Icons.table_bar_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AdminStatCard(
                      label: 'Cash Pending',
                      value: '${order.pendingPaymentTables.length}',
                      icon: Icons.payments_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AdminStatCard(
                      label: 'Kitchen Stage',
                      value: order.currentOrderStatus.toUpperCase(),
                      icon: Icons.soup_kitchen_rounded,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DemoSectionCard(
              title: 'Tables Panel',
              subtitle:
                  'Overview of every table in the restaurant and its current service condition.',
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.tables.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 128,
                ),
                itemBuilder: (context, index) {
                  final table = order.tables[index];
                  final isCurrent = table.id == order.selectedTableId;
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? const Color(0xFFFF6B00).withValues(alpha: 0.18)
                          : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isCurrent
                            ? const Color(0xFFFF8C4D)
                            : Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Table ${table.number}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          table.occupied ? 'Occupied' : 'Available',
                          style: TextStyle(
                            color: table.occupied
                                ? const Color(0xFFFFB38D)
                                : const Color(0xFF9AE198),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          table.needsPayment
                              ? 'Awaiting cashier'
                              : 'Service flowing',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            DemoSectionCard(
              title: 'Kitchen Display System',
              subtitle:
                  'Chefs move the order across stages and the customer app reacts in real time.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (order.activeOrder == null)
                    const Text(
                      'No active order yet. Open the customer demo, select a table and place an order to feed the KDS.',
                      style: TextStyle(color: Colors.white70),
                    )
                  else ...[
                    Row(
                      children: [
                        Expanded(
                          child: _KdsCard(
                            title: 'Current Table',
                            value:
                                'Table ${order.selectedTable?.number ?? '-'}',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _KdsCard(
                            title: 'Ticket Total',
                            value:
                                '\$${order.activeOrder!.totalAmount.toStringAsFixed(0)}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OrderProgress(currentStep: order.orderStepIndex),
                    const SizedBox(height: 16),
                    const Text(
                      'Items on ticket',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...order.orderedItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            item.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.icon(
                          onPressed: order.advanceKitchenStatus,
                          icon:
                              const Icon(Icons.keyboard_double_arrow_right_rounded),
                          label: const Text('Advance Kitchen Status'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            order.requestCashDesk();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Cash desk request sent to cashier queue.'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.receipt_long_rounded),
                          label: const Text('Flag Cash Payment'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            DemoSectionCard(
              title: 'Cashier Queue',
              subtitle:
                  'Tables requesting cash payment appear here so the front desk can close the bill.',
              child: Column(
                children: [
                  if (order.pendingPaymentTables.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Text(
                        'No tables pending payment right now.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  else
                    ...order.pendingPaymentTables.map(
                      (table) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B00).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color:
                                  const Color(0xFFFF6B00).withValues(alpha: 0.16),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Table ${table.number}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Customer is ready to pay in cash.',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                              FilledButton(
                                onPressed: () {
                                  order.markAsPaid(paymentMethod: 'cash');
                                },
                                child: const Text('Close Bill'),
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
        ),
      ),
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  const _AdminStatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFFFB088)),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _KdsCard extends StatelessWidget {
  const _KdsCard({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
