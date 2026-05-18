import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/app_copy.dart';
import '../../core/utils/constants.dart';
import '../providers/app_demo_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/app_utility_toggles.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isProcessing = false;
  bool _paid = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _simulateCardPayment(BuildContext context) async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    context.read<OrderProvider>().markAsPaid(paymentMethod: 'card');
    setState(() {
      _isProcessing = false;
      _paid = true;
    });
  }

  void _requestCashDesk(BuildContext context) {
    context.read<OrderProvider>().requestCashDesk();
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>();
    final flow = context.read<AppDemoProvider>();
    final auth = context.read<AuthProvider>();
    final copy = AppCopy.of(context);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF171717);
    final surfaceColor =
        isDarkMode ? const Color(0xFF1C1C1E) : const Color(0xFFF4F4F5);
    final mutedColor =
        isDarkMode ? const Color(0xFFC9C2BE) : const Color(0xFF625B56);

    final isPaidNow = _paid || order.isPaid;
    final isCashRequested =
        order.selectedTable?.needsPayment == true && !order.isPaid;

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
                            'PAGO',
                            style: TextStyle(
                              color: Color(0xFFFFB48E),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.6,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            copy.isSpanish ? 'Tu cuenta' : 'Your bill',
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
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
                  children: [
                    if (isPaidNow)
                      _ReceiptCard(
                        order: order,
                        textColor: textColor,
                        surfaceColor: surfaceColor,
                        mutedColor: mutedColor,
                        userName: auth.currentUser?.fullName ?? '',
                        onFinish: () {
                          order.clearDemoState();
                          flow.backToWelcome();
                        },
                        copy: copy,
                      )
                    else if (isCashRequested)
                      _CashWaitCard(
                        tableNumber: order.selectedTable?.number,
                        textColor: textColor,
                        surfaceColor: surfaceColor,
                        copy: copy,
                      )
                    else ...[
                      _OrderSummaryCard(
                        order: order,
                        textColor: textColor,
                        surfaceColor: surfaceColor,
                        mutedColor: mutedColor,
                        copy: copy,
                      ),
                      const SizedBox(height: 18),
                      _PaymentMethodTabs(
                        selectedMethod: order.paymentMethod,
                        onChanged: (m) => order.setPaymentMethod(m),
                        textColor: textColor,
                        surfaceColor: surfaceColor,
                        mutedColor: mutedColor,
                        copy: copy,
                      ),
                      const SizedBox(height: 18),
                      if (order.paymentMethod == 'card')
                        _CardForm(
                          cardNumberController: _cardNumberController,
                          cardNameController: _cardNameController,
                          expiryController: _expiryController,
                          cvvController: _cvvController,
                          textColor: textColor,
                          surfaceColor: surfaceColor,
                          copy: copy,
                        )
                      else
                        _NequiForm(
                          textColor: textColor,
                          surfaceColor: surfaceColor,
                          copy: copy,
                        ),
                      const SizedBox(height: 24),
                      if (order.paymentMethod == 'cash')
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _requestCashDesk(context),
                            icon: const Icon(Icons.point_of_sale_rounded),
                            label: Text(
                              copy.isSpanish
                                  ? 'Solicitar pago en caja'
                                  : 'Request cash payment',
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _isProcessing
                                ? null
                                : () => _simulateCardPayment(context),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6F22),
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            icon: _isProcessing
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.lock_rounded),
                            label: Text(
                              _isProcessing
                                  ? (copy.isSpanish
                                      ? 'Procesando...'
                                      : 'Processing...')
                                  : (copy.isSpanish
                                      ? 'Pagar ahora'
                                      : 'Pay now'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                    ],
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

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({
    required this.order,
    required this.textColor,
    required this.surfaceColor,
    required this.mutedColor,
    required this.copy,
  });

  final OrderProvider order;
  final Color textColor;
  final Color surfaceColor;
  final Color mutedColor;
  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            copy.isSpanish ? 'Resumen del pedido' : 'Order summary',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ...order.orderedItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    _formatCop(item.price),
                    style: TextStyle(color: mutedColor),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 24),
          Row(
            children: [
              Text(
                copy.isSpanish ? 'Total' : 'Total',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                _formatCop(order.activeOrder?.totalAmount ?? order.cartTotal),
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

class _PaymentMethodTabs extends StatelessWidget {
  const _PaymentMethodTabs({
    required this.selectedMethod,
    required this.onChanged,
    required this.textColor,
    required this.surfaceColor,
    required this.mutedColor,
    required this.copy,
  });

  final String selectedMethod;
  final ValueChanged<String> onChanged;
  final Color textColor;
  final Color surfaceColor;
  final Color mutedColor;
  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MethodTab(
          label: copy.isSpanish ? 'Tarjeta' : 'Card',
          icon: Icons.credit_card_rounded,
          isSelected: selectedMethod == 'card',
          onTap: () => onChanged('card'),
          textColor: textColor,
          surfaceColor: surfaceColor,
        ),
        const SizedBox(width: 12),
        _MethodTab(
          label: 'Nequi',
          icon: Icons.phone_android_rounded,
          isSelected: selectedMethod == 'nequi',
          onTap: () => onChanged('nequi'),
          textColor: textColor,
          surfaceColor: surfaceColor,
        ),
        const SizedBox(width: 12),
        _MethodTab(
          label: copy.isSpanish ? 'Efectivo' : 'Cash',
          icon: Icons.payments_rounded,
          isSelected: selectedMethod == 'cash',
          onTap: () => onChanged('cash'),
          textColor: textColor,
          surfaceColor: surfaceColor,
        ),
      ],
    );
  }
}

class _MethodTab extends StatelessWidget {
  const _MethodTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.textColor,
    required this.surfaceColor,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color textColor;
  final Color surfaceColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFF6F22).withValues(alpha: 0.15)
                : surfaceColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFFF6F22)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFFFF6F22) : textColor,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFFFF6F22) : textColor,
                  fontSize: 12,
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

class _CardForm extends StatelessWidget {
  const _CardForm({
    required this.cardNumberController,
    required this.cardNameController,
    required this.expiryController,
    required this.cvvController,
    required this.textColor,
    required this.surfaceColor,
    required this.copy,
  });

  final TextEditingController cardNumberController;
  final TextEditingController cardNameController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;
  final Color textColor;
  final Color surfaceColor;
  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            copy.isSpanish ? 'Datos de la tarjeta' : 'Card details',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: cardNumberController,
            keyboardType: TextInputType.number,
            maxLength: 19,
            decoration: InputDecoration(
              counterText: '',
              labelText: copy.isSpanish ? 'Número de tarjeta' : 'Card number',
              hintText: '1234 5678 9012 3456',
              prefixIcon: const Icon(Icons.credit_card_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: cardNameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: copy.isSpanish ? 'Nombre en la tarjeta' : 'Name on card',
              hintText: copy.isSpanish ? 'JUAN GARCIA' : 'JOHN DOE',
              prefixIcon: const Icon(Icons.person_rounded),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: expiryController,
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  decoration: const InputDecoration(
                    counterText: '',
                    labelText: 'MM/AA',
                    hintText: '12/28',
                    prefixIcon: Icon(Icons.calendar_today_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: cvvController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                  decoration: const InputDecoration(
                    counterText: '',
                    labelText: 'CVV',
                    hintText: '•••',
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NequiForm extends StatelessWidget {
  const _NequiForm({
    required this.textColor,
    required this.surfaceColor,
    required this.copy,
  });

  final Color textColor;
  final Color surfaceColor;
  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF6C00F5).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.phone_android_rounded,
              color: Color(0xFF8B3CF7),
              size: 40,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            copy.isSpanish
                ? 'Pagar con Nequi'
                : 'Pay with Nequi',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            copy.isSpanish
                ? 'Abre tu app Nequi y escanea el QR para completar el pago de forma segura.'
                : 'Open your Nequi app and scan the QR code to complete the payment securely.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.qr_code_2_rounded,
              size: 120,
              color: Color(0xFF6C00F5),
            ),
          ),
        ],
      ),
    );
  }
}

class _CashWaitCard extends StatelessWidget {
  const _CashWaitCard({
    required this.tableNumber,
    required this.textColor,
    required this.surfaceColor,
    required this.copy,
  });

  final int? tableNumber;
  final Color textColor;
  final Color surfaceColor;
  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.point_of_sale_rounded,
            color: Colors.white,
            size: 52,
          ),
          const SizedBox(height: 18),
          const Text(
            '¡Dirígete a la caja!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            copy.isSpanish
                ? 'Tu mesa ha sido marcada para pago en efectivo. Un cajero se acercará pronto.'
                : 'Your table has been flagged for cash payment. A cashier will come shortly.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          if (tableNumber != null) ...[
            const SizedBox(height: 20),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Mesa #$tableNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({
    required this.order,
    required this.textColor,
    required this.surfaceColor,
    required this.mutedColor,
    required this.userName,
    required this.onFinish,
    required this.copy,
  });

  final OrderProvider order;
  final Color textColor;
  final Color surfaceColor;
  final Color mutedColor;
  final String userName;
  final VoidCallback onFinish;
  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                copy.isSpanish ? '¡Pago exitoso!' : 'Payment successful!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                copy.isSpanish
                    ? 'Gracias por tu visita, $userName.\n¡Buen provecho!'
                    : 'Thank you for your visit, $userName.\nEnjoy your meal!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _formatCop(
                    order.activeOrder?.totalAmount ?? order.cartTotal),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                order.activeOrder?.paymentMethod?.toUpperCase() ?? 'CARD',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
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
              Text(
                copy.isSpanish ? 'Recibo' : 'Receipt',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              ...order.orderedItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: TextStyle(color: textColor),
                        ),
                      ),
                      Text(
                        _formatCop(item.price),
                        style: TextStyle(color: mutedColor),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 20),
              Row(
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatCop(
                        order.activeOrder?.totalAmount ?? order.cartTotal),
                    style: const TextStyle(
                      color: Color(0xFFFF6F22),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onFinish,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF6F22),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: const Icon(Icons.home_rounded),
            label: Text(
              copy.isSpanish ? 'Volver al inicio' : 'Back to home',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _formatCop(double value) {
  final intVal = value.toInt();
  return '\$${intVal.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
}
