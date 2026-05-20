import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/app_copy.dart';
import '../../domain/entities/menu.dart';
import '../providers/app_demo_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isDigital = true;
  bool _isProcessing = false;
  bool _isCashRequested = false;

  Future<void> _finalizeDigital() async {
    final order = context.read<OrderProvider>();
    final auth = context.read<AuthProvider>();
    final flow = context.read<AppDemoProvider>();

    if (order.cartLineItems.isEmpty && !order.hasActiveOrder) return;

    setState(() => _isProcessing = true);

    if (!order.hasSelectedTable) {
      order.selectTable(order.tables.first.id);
    }

    if (!order.hasActiveOrder) {
      order.placeDemoOrder(
        userId: auth.currentUser?.id ?? 'demo-user',
        notes: '',
      );
    }

    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    order.finalizeDigitalPayment();
    setState(() => _isProcessing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Pago confirmado! Tu pedido sigue en camino.'),
        backgroundColor: Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    // The order is still active — go back to tracking, not history.
    // clearDemoState is NOT called here; the admin releases the table when done.
    flow.setCustomerScreen(CustomerScreen.tracking);
  }

  void _requestCash() {
    final order = context.read<OrderProvider>();
    final auth = context.read<AuthProvider>();

    if (!order.hasSelectedTable) {
      order.selectTable(order.tables.first.id);
    }

    if (!order.hasActiveOrder) {
      order.placeDemoOrder(
        userId: auth.currentUser?.id ?? 'demo-user',
        notes: '',
      );
    }

    order.requestCashPayment();
    setState(() => _isCashRequested = true);
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>();
    final flow = context.read<AppDemoProvider>();

    final subtotal = order.activeOrder?.totalAmount ?? order.checkoutTotal;
    final tax = subtotal * 0.08;
    final grandTotal = subtotal + tax;

    return Column(
      children: [
        _PaymentAppBar(
          onBack: () => flow.setCustomerScreen(
            order.hasActiveOrder ? CustomerScreen.tracking : CustomerScreen.cart,
          ),
        ),
        Expanded(
          child: _isCashRequested
              ? _CashWaitState(tableNumber: order.selectedTable?.number)
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    _TotalCard(
                      total: grandTotal,
                      tableNumber: order.selectedTable?.number,
                    ),
                    const SizedBox(height: 16),
                    _MethodSelector(
                      isDigital: _isDigital,
                      onChanged: (v) => setState(() => _isDigital = v),
                    ),
                    if (!_isDigital) ...[
                      const SizedBox(height: 14),
                      const _CashAlert(),
                    ],
                    const SizedBox(height: 16),
                    _ComandaDigital(
                      order: order,
                      subtotal: subtotal,
                      tax: tax,
                      grandTotal: grandTotal,
                    ),
                    const SizedBox(height: 24),
                    _FinalizeButton(
                      isDigital: _isDigital,
                      isProcessing: _isProcessing,
                      canFinalize:
                          order.cartLineItems.isNotEmpty || order.hasActiveOrder,
                      onTap: () =>
                          _isDigital ? _finalizeDigital() : _requestCash(),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _PaymentAppBar extends StatelessWidget {
  const _PaymentAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                AppCopy.of(context).paymentTitle.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.total, this.tableNumber});

  final double total;
  final int? tableNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B1F0E), Color(0xFF1C1C1E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppCopy.of(context).paymentTotal.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFFFF6F22),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _formatCop(total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          if (tableNumber != null) ...[
            const SizedBox(height: 8),
            Text(
              'Mesa #$tableNumber',
              style: const TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MethodSelector extends StatelessWidget {
  const _MethodSelector({required this.isDigital, required this.onChanged});

  final bool isDigital;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MethodPill(
          label: 'Digital',
          icon: Icons.credit_card_rounded,
          isSelected: isDigital,
          onTap: () => onChanged(true),
        ),
        const SizedBox(width: 12),
        _MethodPill(
          label: 'Efectivo',
          icon: Icons.payments_rounded,
          isSelected: !isDigital,
          onTap: () => onChanged(false),
        ),
      ],
    );
  }
}

class _MethodPill extends StatelessWidget {
  const _MethodPill({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFF6F22).withValues(alpha: 0.15)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFFF6F22)
                  : Theme.of(context).dividerColor,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? const Color(0xFFFF6F22)
                    : const Color(0xFF8E8E93),
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFFFF6F22)
                      : const Color(0xFF8E8E93),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CashAlert extends StatelessWidget {
  const _CashAlert();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6F22).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF6F22).withValues(alpha: 0.4),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFFFF6F22), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Al pagar en efectivo, un cajero vendrá a tu mesa para procesar el cobro.',
              style: TextStyle(
                color: Color(0xFFFF6F22),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComandaDigital extends StatelessWidget {
  const _ComandaDigital({
    required this.order,
    required this.subtotal,
    required this.tax,
    required this.grandTotal,
  });

  final OrderProvider order;
  final double subtotal;
  final double tax;
  final double grandTotal;

  List<MapEntry<Menu, int>> _deduped() {
    final items =
        order.hasActiveOrder ? order.orderedItems : order.cartItems;
    final counts = <String, int>{};
    final menuMap = <String, Menu>{};
    for (final item in items) {
      counts.update(item.id, (v) => v + 1, ifAbsent: () => 1);
      menuMap[item.id] = item;
    }
    return counts.entries
        .map((e) => MapEntry(menuMap[e.key]!, e.value))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _deduped();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'COMANDA DIGITAL',
            style: TextStyle(
              color: Color(0xFFFF6F22),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.qr_code_2_rounded,
                    size: 96,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                const SizedBox(height: 8),
                if (order.activeOrder != null)
                  Text(
                    'Pedido #${order.activeOrder!.id.substring(0, 8).toUpperCase()}',
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: Theme.of(context).dividerColor, height: 1),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Item',
                  style: TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'Cant',
                style: TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 16),
              SizedBox(
                width: 80,
                child: Text(
                  'Total',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      entry.key.name,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '×${entry.value}',
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 80,
                    child: Text(
                      _formatCop(entry.key.price * entry.value),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(color: Theme.of(context).dividerColor, height: 24),
          _SummaryRow(label: 'Subtotal', value: _formatCop(subtotal)),
          const SizedBox(height: 6),
          _SummaryRow(label: 'Impuesto (8%)', value: _formatCop(tax)),
          Divider(color: Theme.of(context).dividerColor, height: 24),
          Row(
            children: [
              Text(
                'TOTAL',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Text(
                _formatCop(grandTotal),
                style: const TextStyle(
                  color: Color(0xFFFF6F22),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FinalizeButton extends StatelessWidget {
  const _FinalizeButton({
    required this.isDigital,
    required this.isProcessing,
    required this.canFinalize,
    required this.onTap,
  });

  final bool isDigital;
  final bool isProcessing;
  final bool canFinalize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: (canFinalize && !isProcessing) ? onTap : null,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFFF6F22),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF3A3A3C),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: isProcessing
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isDigital
                        ? Icons.payment_rounded
                        : Icons.point_of_sale_rounded,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isDigital
                        ? 'Pagar y Finalizar Visita'
                        : 'Solicitar Cajero',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _CashWaitState extends StatelessWidget {
  const _CashWaitState({this.tableNumber});

  final int? tableNumber;

  @override
  Widget build(BuildContext context) {
    final flow = context.read<AppDemoProvider>();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6F22).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.point_of_sale_rounded,
                color: Color(0xFFFF6F22),
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '¡Cajero en camino!',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              tableNumber != null
                  ? 'Tu mesa #$tableNumber ha sido notificada. Un cajero se acercará pronto para procesar tu pago.'
                  : 'Tu mesa ha sido notificada. Un cajero se acercará pronto.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 15,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Color(0xFFFF6F22)),
            const SizedBox(height: 32),
            TextButton.icon(
              onPressed: () =>
                  flow.setCustomerScreen(CustomerScreen.tracking),
              icon: const Icon(Icons.receipt_long_outlined,
                  color: Color(0xFFFF6F22)),
              label: const Text(
                'Ver seguimiento del pedido',
                style: TextStyle(color: Color(0xFFFF6F22)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatCop(double value) {
  final intVal = value.toInt();
  return '\$${intVal.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
}
