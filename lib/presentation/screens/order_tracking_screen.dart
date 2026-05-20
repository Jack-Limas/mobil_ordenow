import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/app_copy.dart';
import '../../core/utils/constants.dart';
import '../../domain/entities/menu.dart';
import '../providers/app_demo_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/app_utility_toggles.dart';
import '../widgets/order_progress.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  static const _images = <String, String>{
    'menu-1': 'lib/assets/images/saffron_infused_sea_scallops.png',
    'menu-2': 'lib/assets/images/midnight_pasta.png',
    'menu-3': 'lib/assets/images/smoked_ribeye.png',
    'menu-4': 'lib/assets/images/artisan_harvest_bowl.png',
    'menu-5': 'lib/assets/images/background_bienvenida.png',
    'menu-6': 'lib/assets/images/background_bienvenida.png',
  };

  static String imageFor(String id) =>
      _images[id] ?? 'lib/assets/images/background_bienvenida.png';

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>();
    final flow = context.read<AppDemoProvider>();

    return Column(
      children: [
        const _TrackingAppBar(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _TrackingCard(order: order),
              const SizedBox(height: 20),
              if (order.orderedItems.isNotEmpty) ...[
                _SelectionSection(order: order),
                const SizedBox(height: 24),
              ],
              if (order.hasActiveOrder && !order.isPaid) ...[
                _PayNowCard(
                  total: order.activeOrder!.totalAmount,
                  onPay: () =>
                      flow.setCustomerScreen(CustomerScreen.checkout),
                ),
                const SizedBox(height: 24),
              ],
              _ExploreMenuSection(
                menu: order.menu,
                onExplore: () =>
                    flow.setCustomerScreen(CustomerScreen.menu),
                onAiOrder: () =>
                    flow.setCustomerScreen(CustomerScreen.aiConcierge),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── App bar ────────────────────────────────────────────────────────────────

class _TrackingAppBar extends StatelessWidget {
  const _TrackingAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

// ─── Tracking card ───────────────────────────────────────────────────────────

class _TrackingCard extends StatelessWidget {
  const _TrackingCard({required this.order});

  final OrderProvider order;

  ({Color color, String label}) _badge(String status) {
    switch (status) {
      case OrderStatuses.preparing:
        return (color: const Color(0xFFFF6F22), label: 'En Cocina');
      case OrderStatuses.ready:
        return (color: const Color(0xFF62D26F), label: 'Listo');
      case OrderStatuses.delivered:
      case OrderStatuses.completed:
        return (color: const Color(0xFF5E9FFF), label: 'Entregado');
      default:
        return (color: const Color(0xFFF0B63E), label: 'Recibido');
    }
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    final activeOrder = order.activeOrder;
    final status = order.currentOrderStatus;
    final badge = _badge(status);
    final orderId = activeOrder != null
        ? '#${activeOrder.id.substring(0, 4).toUpperCase()}'
        : '#—';
    final timeStr = activeOrder != null
        ? 'Iniciado a las ${_formatTime(activeOrder.createdAt)}'
        : copy.trackingActiveOrder;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      copy.trackingTitle.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pedido $orderId',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeStr,
                      style: const TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: badge.color,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      badge.label,
                      style: TextStyle(
                        color: badge.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          OrderProgress(currentStep: order.trackingStep),
        ],
      ),
    );
  }
}

// ─── Tu Selección ────────────────────────────────────────────────────────────

class _SelectionSection extends StatelessWidget {
  const _SelectionSection({required this.order});

  final OrderProvider order;

  @override
  Widget build(BuildContext context) {
    final items = order.orderedItems;
    final unique = _deduped(items);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.content_cut_rounded,
                color: Color(0xFFFF6F22), size: 18),
            const SizedBox(width: 8),
            Text(
              'Tu Selección',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              '${items.length} artículo${items.length == 1 ? '' : 's'}',
              style: const TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...unique.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SelectionItem(menu: entry.key, qty: entry.value),
            )),
      ],
    );
  }

  List<MapEntry<Menu, int>> _deduped(List<Menu> items) {
    final counts = <String, int>{};
    final seen = <String, Menu>{};
    for (final m in items) {
      counts.update(m.id, (v) => v + 1, ifAbsent: () => 1);
      seen.putIfAbsent(m.id, () => m);
    }
    return counts.entries
        .map((e) => MapEntry(seen[e.key]!, e.value))
        .toList();
  }
}

class _SelectionItem extends StatelessWidget {
  const _SelectionItem({required this.menu, required this.qty});

  final Menu menu;
  final int qty;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _TrackingItemImage(menu: menu),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  qty > 1 ? '${menu.name} ×$qty' : menu.name,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  menu.description,
                  style: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _formatCop(menu.price * qty),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Explora el Menú ─────────────────────────────────────────────────────────

class _ExploreMenuSection extends StatelessWidget {
  const _ExploreMenuSection({
    required this.menu,
    required this.onExplore,
    required this.onAiOrder,
  });

  final List<Menu> menu;
  final VoidCallback onExplore;
  final VoidCallback onAiOrder;

  @override
  Widget build(BuildContext context) {
    if (menu.isEmpty) return const SizedBox.shrink();
    final featured = menu.first;
    final rest = menu.skip(1).take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppCopy.of(context).trackingExplore,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onExplore,
              child: Text(
                '${AppCopy.of(context).trackingViewOnly} ›',
                style: const TextStyle(
                  color: Color(0xFFFF6F22),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _LargeMenuCard(
            menu: featured, onExplore: onExplore, onAiOrder: onAiOrder),
        if (rest.length >= 2) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SmallMenuCard(
                    menu: rest[0], onAction: onExplore, actionLabel: 'Explorar'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SmallMenuCard(
                    menu: rest[1], onAction: onAiOrder, actionLabel: '✦ IA Order'),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _LargeMenuCard extends StatelessWidget {
  const _LargeMenuCard({
    required this.menu,
    required this.onExplore,
    required this.onAiOrder,
  });

  final Menu menu;
  final VoidCallback onExplore;
  final VoidCallback onAiOrder;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          _TrackingMenuImage(menu: menu, height: 180),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6F22),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          menu.category.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        menu.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onAiOrder,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '✦ IA Order',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallMenuCard extends StatelessWidget {
  const _SmallMenuCard({
    required this.menu,
    required this.onAction,
    required this.actionLabel,
  });

  final Menu menu;
  final VoidCallback onAction;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          _TrackingMenuImage(menu: menu, height: 140),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menu.category,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onAction,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      actionLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── image helpers ───────────────────────────────────────────────────────────

class _TrackingItemImage extends StatelessWidget {
  const _TrackingItemImage({required this.menu});
  final Menu menu;

  @override
  Widget build(BuildContext context) {
    final url = menu.imageUrl.trim();
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (ctx, _, __) => _placeholder(ctx),
      );
    }
    return Image.asset(
      OrderTrackingScreen.imageFor(menu.id),
      width: 64,
      height: 64,
      fit: BoxFit.cover,
      errorBuilder: (ctx, _, __) => _placeholder(ctx),
    );
  }

  Widget _placeholder(BuildContext ctx) => Container(
        width: 64,
        height: 64,
        color: Theme.of(ctx).colorScheme.surface,
        child: Icon(
          Icons.restaurant_rounded,
          color: Theme.of(ctx).dividerColor,
          size: 28,
        ),
      );
}

class _TrackingMenuImage extends StatelessWidget {
  const _TrackingMenuImage({required this.menu, required this.height});
  final Menu menu;
  final double height;

  @override
  Widget build(BuildContext context) {
    final url = menu.imageUrl.trim();
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (ctx, _, __) => _fallback(ctx),
      );
    }
    return Image.asset(
      OrderTrackingScreen.imageFor(menu.id),
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (ctx, _, __) => _fallback(ctx),
    );
  }

  Widget _fallback(BuildContext ctx) => Container(
        height: height,
        color: Theme.of(ctx).cardColor,
        child: Icon(
          Icons.restaurant_rounded,
          color: Theme.of(ctx).dividerColor,
          size: 48,
        ),
      );
}

// ─── Pay Now Card ────────────────────────────────────────────────────────────

class _PayNowCard extends StatelessWidget {
  const _PayNowCard({required this.total, required this.onPay});

  final double total;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF6F22).withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                  Icons.payment_rounded, color: Color(0xFFFF6F22), size: 18),
              const SizedBox(width: 8),
              Text(
                'Pago',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Total: ${_formatCop(total)}',
            style: const TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Puedes pagar ahora o esperar a recibir tu pedido.',
            style: TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onPay,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF6F22),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.payment_rounded, size: 18),
              label: const Text(
                'Pagar Pedido',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── helpers ─────────────────────────────────────────────────────────────────

String _formatCop(double value) {
  final intVal = value.toInt();
  return '\$${intVal.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
}
