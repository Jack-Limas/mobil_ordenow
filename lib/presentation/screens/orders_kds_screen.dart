import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/admin_dashboard_provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/orders_kds_provider.dart';

class OrdersKdsScreen extends StatelessWidget {
  const OrdersKdsScreen({super.key, this.showBackButton = true});

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final kds = context.watch<OrdersKdsProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: kds.pendingCash.isNotEmpty
          ? _CashFab(request: kds.pendingCash.first)
          : null,
      body: Column(
        children: [
          _KdsAppBar(showBackButton: showBackButton),
          if (kds.pendingCash.isNotEmpty)
            _CashAlertBanner(request: kds.pendingCash.first),
          Expanded(
            child: kds.activeOrders.isEmpty
                ? const _EmptyKds()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    children: [
                      _SectionHeader(count: kds.activeCount),
                      const SizedBox(height: 16),
                      for (var i = 0; i < kds.activeOrders.length; i++) ...[
                        _OrderCard(
                          order: kds.activeOrders[i],
                          turn: i + 1,
                          kds: kds,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _KdsAppBar extends StatelessWidget {
  const _KdsAppBar({required this.showBackButton});

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    return SafeArea(
      bottom: false,
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.fromLTRB(4, 8, 16, 12),
        child: Row(
          children: [
            if (showBackButton)
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              )
            else
              const SizedBox(width: 12),
            const Icon(
              Icons.restaurant_menu_rounded,
              color: Color(0xFFFF6F22),
              size: 22,
            ),
            const SizedBox(width: 6),
            const Text(
              'OrdeNow',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => settings.toggleLanguage(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  settings.isSpanish ? 'ES' : 'EN',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: settings.cycleThemeMode,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  settings.themeMode == ThemeMode.light
                      ? Icons.light_mode_rounded
                      : settings.themeMode == ThemeMode.system
                      ? Icons.settings_brightness_rounded
                      : Icons.dark_mode_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CashAlertBanner extends StatelessWidget {
  const _CashAlertBanner({required this.request});

  final KdsCashRequest request;

  @override
  Widget build(BuildContext context) {
    final kds = context.read<OrdersKdsProvider>();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x20FF6F22),
        border: Border.all(color: const Color(0xFFFF6F22)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text('💳', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pago Efectivo Pendiente',
                  style: TextStyle(
                    color: Color(0xFFFF6F22),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${kds.tableLabel(request.tableId)} solicita cierre de cuenta',
                  style: const TextStyle(
                    color: Color(0xFFFF6F22),
                    fontSize: 12,
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Gestión de Comandas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6F22),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count Activos',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderCard extends StatefulWidget {
  const _OrderCard({
    required this.order,
    required this.turn,
    required this.kds,
  });

  final KdsActiveOrder order;
  final int turn;
  final OrdersKdsProvider kds;

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  String? _lastRefreshedId;

  @override
  void didUpdateWidget(_OrderCard old) {
    super.didUpdateWidget(old);
    _maybeRefreshPayment();
  }

  @override
  void initState() {
    super.initState();
    _maybeRefreshPayment();
  }

  void _maybeRefreshPayment() {
    final o = widget.order;
    if (o.status == 'ready' && !o.paid && _lastRefreshedId != o.id) {
      _lastRefreshedId = o.id;
      Future.microtask(() => widget.kds.refreshPaymentStatus(o.id));
    }
  }

  KdsActiveOrder get order => widget.order;
  int get turn => widget.turn;
  OrdersKdsProvider get kds => widget.kds;

  String _elapsed() {
    final diff = DateTime.now().difference(order.createdAt);
    if (diff.inMinutes < 1) return 'Recién llegada';
    return 'Hace ${diff.inMinutes} min';
  }

  String _formatCop(double v) {
    final s = v.toStringAsFixed(0);
    return '\$${s.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    if (order.status == 'ready') return _buildDetailCard(context);

    final isPrep = order.status == 'preparing';
    final statusLabel = isPrep ? 'Preparando' : 'Recibido';
    final statusColor = isPrep
        ? const Color(0xFFFF6F22)
        : const Color(0xFFFFB800);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                kds.tableLabel(order.tableId),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _StatusPill(label: statusLabel, color: statusColor),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _elapsed(),
            style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < order.itemIds.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Text(
                    '${i + 1}.',
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      kds.itemName(order.itemIds[i]),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          if (order.notes.isNotEmpty) ...[
            const SizedBox(height: 4),
            _NoteChip(text: order.notes),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: isPrep
                ? _ReadyButton(
                    onTap: () =>
                        kds.markReady(order.id, kds.tableLabel(order.tableId)),
                  )
                : _StartButton(onTap: () => kds.startPreparation(order.id)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context) {
    final label = kds.tableLabel(order.tableId);
    final now = DateTime.now();
    final service = order.totalAmount * 0.10;
    final total = order.totalAmount + service;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF6F22).withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF2C2C2E))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Detalle de Comanda $label',
                    style: const TextStyle(
                      color: Color(0xFFFF6F22),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _TurnBadge(turn: turn),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(
              children: [
                Text(
                  _dateLabel(now),
                  style: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D2E0D),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Abierta',
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: [
                for (final id in order.itemIds)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            kds.itemName(id),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Divider(color: Color(0xFF2C2C2E), height: 24),
                _BillRow(
                  label: 'Subtotal',
                  value: _formatCop(order.totalAmount),
                ),
                const SizedBox(height: 6),
                _BillRow(label: 'Servicio (10%)', value: _formatCop(service)),
                const SizedBox(height: 6),
                _BillRow(label: 'Total', value: _formatCop(total), bold: true),
                const SizedBox(height: 14),
                if (!order.paid)
                  _PaymentPendingBanner(
                    order: order,
                    onRefresh: () => kds.refreshPaymentStatus(order.id),
                  ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: order.paid
                        ? () {
                            kds.releaseTable(
                              orderId: order.id,
                              tableId: order.tableId,
                            );
                            context
                                .read<AdminDashboardProvider>()
                                .releaseTable(order.tableId);
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6F22),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF3A3A3C),
                      disabledForegroundColor: const Color(0xFF636366),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(
                      order.paid
                          ? Icons.event_available_rounded
                          : Icons.lock_outline_rounded,
                      size: 18,
                    ),
                    label: Text(
                      order.paid
                          ? 'Cerrar pedido y liberar mesa'
                          : 'Esperando confirmación de pago',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _dateLabel(DateTime dt) {
    const months = [
      '',
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month]} ${dt.day}, $h:$m';
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 5),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TurnBadge extends StatelessWidget {
  const _TurnBadge({required this.turn});

  final int turn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6F22).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'TURNO ${turn.toString().padLeft(2, '0')}',
        style: const TextStyle(
          color: Color(0xFFFF6F22),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  const _BillRow({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: bold ? Colors.white : const Color(0xFF8E8E93),
      fontSize: bold ? 15 : 13,
      fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
    );
    return Row(
      children: [
        Text(label, style: style),
        const Spacer(),
        Text(value, style: style),
      ],
    );
  }
}

class _NoteChip extends StatelessWidget {
  const _NoteChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF6F22),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: const Text('🍳', style: TextStyle(fontSize: 16)),
      label: const Text(
        'Comenzar Preparación',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    );
  }
}

class _ReadyButton extends StatelessWidget {
  const _ReadyButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1A3A1A),
        foregroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
      label: const Text(
        'Notificar: Listo para servir',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    );
  }
}

class _PaymentPendingBanner extends StatelessWidget {
  const _PaymentPendingBanner({required this.order, required this.onRefresh});

  final KdsActiveOrder order;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final isCash = order.paymentMethod == 'cash';
    final message = isCash
        ? 'Pago en efectivo solicitado. Confírmalo con el botón naranja (💳).'
        : 'Pago digital pendiente. Toca "Verificar" para comprobar.';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF48484A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: Color(0xFF8E8E93), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
          if (!isCash) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRefresh,
              child: const Text(
                'Verificar',
                style: TextStyle(
                  color: Color(0xFFFF6F22),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
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
          Icon(Icons.soup_kitchen_rounded, color: Color(0xFF2C2C2E), size: 72),
          SizedBox(height: 20),
          Text(
            'Sin órdenes activas',
            style: TextStyle(
              color: Color(0xFF48484A),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Las nuevas comandas aparecerán aquí\nen tiempo real.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF3A3A3C), height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _CashFab extends StatelessWidget {
  const _CashFab({required this.request});

  final KdsCashRequest request;

  String _formatCop(double v) {
    final s = v.toStringAsFixed(0);
    return '\$${s.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showDialog(context),
      backgroundColor: const Color(0xFFFF6F22),
      child: const Icon(
        Icons.attach_money_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  void _showDialog(BuildContext context) {
    final kds = context.read<OrdersKdsProvider>();
    final label = kds.tableLabel(request.tableId);
    final amount = request.amount > 0
        ? _formatCop(request.amount)
        : _formatCop(kds.orderTotalForTable(request.tableId));

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Confirmar Pago en Efectivo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          '¿Confirmar pago en efectivo de $label por $amount?',
          style: const TextStyle(color: Color(0xFF8E8E93)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF8E8E93)),
            ),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await kds.confirmCashPayment(
                requestId: request.id,
                tableId: request.tableId,
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF6F22),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
