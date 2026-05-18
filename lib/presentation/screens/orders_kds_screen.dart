import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/constants.dart';
import '../providers/order_provider.dart';

class OrdersKdsScreen extends StatelessWidget {
  const OrdersKdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _KdsHeader(),
            Expanded(
              child: order.activeOrder == null
                  ? const _EmptyKds()
                  : _KdsBoard(order: order),
            ),
          ],
        ),
      ),
    );
  }
}

class _KdsHeader extends StatelessWidget {
  const _KdsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF1C1C1E), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6F22).withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'KDS',
              style: TextStyle(
                color: Color(0xFFFF6F22),
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Kitchen Display',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF188A31).withValues(alpha: 0.18),
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
    );
  }
}

class _EmptyKds extends StatelessWidget {
  const _EmptyKds();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.soup_kitchen_rounded,
            color: Color(0xFF2C2C2E),
            size: 72,
          ),
          SizedBox(height: 20),
          Text(
            'Sin órdenes activas',
            style: TextStyle(
              color: Color(0xFF48484A),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Las nuevas comandas aparecerán aquí\nen tiempo real.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF3A3A3C),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _KdsBoard extends StatelessWidget {
  const _KdsBoard({required this.order});

  final OrderProvider order;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _StatusSectionHeader(
          label: 'PENDIENTE',
          count: order.currentOrderStatus == OrderStatuses.pending ||
                  order.currentOrderStatus == OrderStatuses.accepted
              ? 1
              : 0,
          accent: const Color(0xFFF0B63E),
        ),
        const SizedBox(height: 10),
        if (order.currentOrderStatus == OrderStatuses.pending ||
            order.currentOrderStatus == OrderStatuses.accepted)
          _KdsOrderCard(
            order: order,
            accent: const Color(0xFFF0B63E),
            actionLabel: 'Iniciar preparación',
            onAction: order.advanceKitchenStatus,
          ),
        const SizedBox(height: 20),
        _StatusSectionHeader(
          label: 'EN PREPARACIÓN',
          count: order.currentOrderStatus == OrderStatuses.preparing ? 1 : 0,
          accent: const Color(0xFF5E9FFF),
        ),
        const SizedBox(height: 10),
        if (order.currentOrderStatus == OrderStatuses.preparing)
          _KdsOrderCard(
            order: order,
            accent: const Color(0xFF5E9FFF),
            actionLabel: 'Marcar como listo',
            onAction: order.advanceKitchenStatus,
          ),
        const SizedBox(height: 20),
        _StatusSectionHeader(
          label: 'LISTO PARA ENTREGAR',
          count: order.currentOrderStatus == OrderStatuses.ready ||
                  order.currentOrderStatus == OrderStatuses.delivered
              ? 1
              : 0,
          accent: const Color(0xFF62D26F),
        ),
        const SizedBox(height: 10),
        if (order.currentOrderStatus == OrderStatuses.ready ||
            order.currentOrderStatus == OrderStatuses.delivered)
          _KdsOrderCard(
            order: order,
            accent: const Color(0xFF62D26F),
            actionLabel: 'Confirmar entrega',
            onAction: order.advanceKitchenStatus,
          ),
      ],
    );
  }
}

class _StatusSectionHeader extends StatelessWidget {
  const _StatusSectionHeader({
    required this.label,
    required this.count,
    required this.accent,
  });

  final String label;
  final int count;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: count > 0 ? accent : const Color(0xFF2C2C2E),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: count > 0 ? accent : const Color(0xFF48484A),
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
        const Spacer(),
        if (count > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

class _KdsOrderCard extends StatelessWidget {
  const _KdsOrderCard({
    required this.order,
    required this.accent,
    required this.actionLabel,
    required this.onAction,
  });

  final OrderProvider order;
  final Color accent;
  final String actionLabel;
  final VoidCallback onAction;

  String _elapsedLabel() {
    final created = order.activeOrder?.createdAt;
    if (created == null) return '';
    final diff = DateTime.now().difference(created);
    if (diff.inMinutes < 1) return 'Recién llegada';
    return 'Hace ${diff.inMinutes} min';
  }

  @override
  Widget build(BuildContext context) {
    final activeOrder = order.activeOrder!;
    final items = order.orderedItems;
    final table = order.selectedTable;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accent.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  table != null ? 'Mesa ${table.number}' : 'Mesa —',
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '#${activeOrder.id.substring(0, 6).toUpperCase()}',
                style: const TextStyle(
                  color: Color(0xFF8C8C8E),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                _elapsedLabel(),
                style: const TextStyle(
                  color: Color(0xFF636366),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFF1C1C1E), height: 1),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.category.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF636366),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (activeOrder.notes?.isNotEmpty == true) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1A18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.note_rounded,
                      color: Color(0xFFF0B63E), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      activeOrder.notes!,
                      style: const TextStyle(
                        color: Color(0xFFD4B896),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.check_rounded, size: 18),
              label: Text(
                actionLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
