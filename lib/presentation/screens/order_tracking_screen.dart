import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/app_copy.dart';
import '../../core/utils/constants.dart';
import '../providers/app_demo_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/app_utility_toggles.dart';
import '../widgets/order_progress.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>();
    final flow = context.read<AppDemoProvider>();
    final copy = AppCopy.of(context);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF171717);
    final surfaceColor = isDarkMode ? const Color(0xFF1C1C1E) : const Color(0xFFF4F4F5);
    final mutedColor =
        isDarkMode ? const Color(0xFFC9C2BE) : const Color(0xFF625B56);

    final isReady = order.currentOrderStatus == OrderStatuses.ready ||
        order.currentOrderStatus == OrderStatuses.delivered ||
        order.currentOrderStatus == OrderStatuses.completed;

    return Scaffold(
      body: Container(
        color: backgroundColor,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SEGUIMIENTO',
                            style: TextStyle(
                              color: Color(0xFFFFB48E),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.6,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            copy.isSpanish ? 'Tu pedido' : 'Your order',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const AppUtilityToggles(),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 22),
                  children: [
                    _StatusHeroCard(
                      status: order.currentOrderStatus,
                      tableNumber: order.selectedTable?.number,
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                copy.isSpanish
                                    ? 'Estado en vivo'
                                    : 'Live status',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF188A31)
                                      .withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  '● LIVE',
                                  style: TextStyle(
                                    color: Color(0xFF62D26F),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          OrderProgress(currentStep: order.orderStepIndex),
                          if (order.activeOrder != null) ...[
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: order.advanceKitchenStatus,
                              icon: const Icon(Icons.skip_next_rounded),
                              label: Text(copy.isSpanish
                                  ? 'Simular avance'
                                  : 'Simulate advance'),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (order.orderedItems.isNotEmpty) ...[
                      Text(
                        copy.isSpanish ? 'Detalle del pedido' : 'Order detail',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...order.orderedItems.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF6F22)
                                        .withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.restaurant_rounded,
                                    color: Color(0xFFFF6F22),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatCop(item.price),
                                  style: const TextStyle(
                                    color: Color(0xFFFFB48E),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    _ActionButtons(
                      isReady: isReady,
                      mutedColor: mutedColor,
                      copy: copy,
                      onAddMore: () =>
                          flow.setCustomerScreen(CustomerScreen.aiConcierge),
                      onPay: () =>
                          flow.setCustomerScreen(CustomerScreen.checkout),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusHeroCard extends StatelessWidget {
  const _StatusHeroCard({
    required this.status,
    required this.tableNumber,
    required this.isDarkMode,
  });

  final String status;
  final int? tableNumber;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(status);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: config.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(config.icon, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  config.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            config.subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          if (tableNumber != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Mesa #$tableNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  _StatusConfig _statusConfig(String status) {
    switch (status) {
      case OrderStatuses.preparing:
        return _StatusConfig(
          gradientColors: const [Color(0xFF1565C0), Color(0xFF0D47A1)],
          icon: Icons.soup_kitchen_rounded,
          label: 'Preparando tu pedido...',
          subtitle: 'El chef está trabajando en tus platos. Pronto estará listo.',
        );
      case OrderStatuses.ready:
      case OrderStatuses.delivered:
        return _StatusConfig(
          gradientColors: const [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          icon: Icons.check_circle_rounded,
          label: '¡Listo para recoger!',
          subtitle: 'Tu pedido está listo. Dirígete a la barra o espera al mesero.',
        );
      case OrderStatuses.completed:
        return _StatusConfig(
          gradientColors: const [Color(0xFF4A148C), Color(0xFF6A1B9A)],
          icon: Icons.celebration_rounded,
          label: '¡Pedido completado!',
          subtitle: 'Gracias por visitar OrdeNow. ¡Buen provecho!',
        );
      default:
        return _StatusConfig(
          gradientColors: const [Color(0xFFF57F17), Color(0xFFE65100)],
          icon: Icons.hourglass_top_rounded,
          label: 'Pedido recibido',
          subtitle: 'Tu orden ha sido registrada. El chef la tomará en breve.',
        );
    }
  }
}

class _StatusConfig {
  const _StatusConfig({
    required this.gradientColors,
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  final List<Color> gradientColors;
  final IconData icon;
  final String label;
  final String subtitle;
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.isReady,
    required this.mutedColor,
    required this.copy,
    required this.onAddMore,
    required this.onPay,
  });

  final bool isReady;
  final Color mutedColor;
  final AppCopy copy;
  final VoidCallback onAddMore;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onAddMore,
            icon: const Icon(Icons.add_rounded),
            label: Text(
              copy.isSpanish ? 'Agregar algo más' : 'Add something else',
            ),
          ),
        ),
        if (isReady) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onPay,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF6F22),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.payment_rounded),
              label: Text(
                copy.isSpanish ? 'Ver cuenta y pagar' : 'See bill and pay',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

String _formatCop(double value) {
  final intVal = value.toInt();
  return '\$${intVal.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
}
