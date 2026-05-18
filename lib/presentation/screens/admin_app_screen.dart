import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/admin_dashboard_provider.dart';
import '../providers/app_demo_provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/order_provider.dart';
import 'menu_management_screen.dart';
import 'orders_kds_screen.dart';

String _formatCop(double value) {
  final intVal = value.toInt();
  return '\$${intVal.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
}

class AdminAppScreen extends StatelessWidget {
  const AdminAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<AppDemoProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: IndexedStack(
          index: flow.adminScreen.index,
          children: const [
            _AdminDashboardView(),
            _AdminMenuManagementView(),
            _AdminOrderManagementView(),
            _AdminProfileView(),
          ],
        ),
      ),
      bottomNavigationBar: _AdminBottomBar(
        selectedIndex: flow.adminScreen.index,
        onTap: (index) => flow.setAdminScreen(AdminScreen.values[index]),
      ),
      floatingActionButton: flow.adminScreen == AdminScreen.dashboard
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const OrdersKdsScreen()),
              ),
              backgroundColor: const Color(0xFFFF6F22),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

class _AdminDashboardView extends StatelessWidget {
  const _AdminDashboardView();

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<AdminDashboardProvider>();
    final settings = context.watch<AppSettingsProvider>();

    return Column(
      children: [
        _DashboardAppBar(settings: settings),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumen del Día',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _todaySubtitle(),
                  style: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                _SalesCard(dash: dash),
                const SizedBox(height: 12),
                _ActiveOrdersCard(dash: dash),
                const SizedBox(height: 12),
                _AvgTicketCard(dash: dash),
                const SizedBox(height: 24),
                _PopularDishesSection(dash: dash),
                const SizedBox(height: 24),
                _OrderFlowSection(dash: dash),
                const SizedBox(height: 24),
                _RecentOrdersSection(dash: dash),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _todaySubtitle() {
    final now = DateTime.now();
    const weekdays = [
      'Lunes', 'Martes', 'Miércoles', 'Jueves',
      'Viernes', 'Sábado', 'Domingo'
    ];
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${weekdays[now.weekday - 1]}, ${now.day} de ${months[now.month - 1]} • Tiempo Real';
  }
}

class _DashboardAppBar extends StatelessWidget {
  const _DashboardAppBar({required this.settings});

  final AppSettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
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
          const Text(
            'OrdeNow',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: settings.toggleLanguage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
        ],
      ),
    );
  }
}

class _SalesCard extends StatelessWidget {
  const _SalesCard({required this.dash});

  final AdminDashboardProvider dash;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text(
                      'VENTAS DEL DÍA',
                      style: TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.show_chart_rounded,
                        color: Color(0xFF8E8E93), size: 18),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _formatCop(dash.salesToday),
                  style: const TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(Icons.arrow_upward_rounded,
                        color: Color(0xFF4CAF50), size: 14),
                    SizedBox(width: 4),
                    Text(
                      '+11.5% vs ayer',
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: CustomPaint(
                painter: _SparklinePainter(
                  data: dash.salesSparkline,
                  color: const Color(0xFF4CAF50),
                ),
                size: const Size(double.infinity, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveOrdersCard extends StatelessWidget {
  const _ActiveOrdersCard({required this.dash});

  final AdminDashboardProvider dash;

  @override
  Widget build(BuildContext context) {
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
            children: const [
              Text(
                'PEDIDOS ACTIVOS',
                style: TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              Spacer(),
              Icon(Icons.list_alt_rounded, color: Color(0xFF8E8E93), size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${dash.activeOrders}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Row(
            children: [
              Icon(Icons.timer_outlined, color: Color(0xFF8E8E93), size: 14),
              SizedBox(width: 4),
              Text(
                'Promedio 26 min',
                style: TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AvgTicketCard extends StatelessWidget {
  const _AvgTicketCard({required this.dash});

  final AdminDashboardProvider dash;

  @override
  Widget build(BuildContext context) {
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
            children: const [
              Text(
                'TICKET PROMEDIO',
                style: TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              Spacer(),
              Icon(Icons.receipt_long_rounded,
                  color: Color(0xFF8E8E93), size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatCop(dash.avgTicket),
            style: const TextStyle(
              color: Color(0xFFFF6F22),
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '12 Comandas/hora',
            style: TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  const _SparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final max = data.reduce((a, b) => a > b ? a : b);
    final min = data.reduce((a, b) => a < b ? a : b);
    final range = (max - min) == 0 ? 1.0 : max - min;

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.3),
          color.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final linePath = Path();
    final fillPath = Path();

    for (var i = 0; i < data.length; i++) {
      final x = i / (data.length - 1) * size.width;
      final y =
          (1 - (data[i] - min) / range) * (size.height * 0.8) +
          size.height * 0.1;
      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.data != data || old.color != color;
}

class _PopularDishesSection extends StatelessWidget {
  const _PopularDishesSection({required this.dash});

  final AdminDashboardProvider dash;

  static const _menuImages = <String, String>{
    'menu-1': 'lib/assets/images/saffron_infused_sea_scallops.png',
    'menu-2': 'lib/assets/images/midnight_pasta.png',
    'menu-3': 'lib/assets/images/smoked_ribeye.png',
    'menu-4': 'lib/assets/images/artisan_harvest_bowl.png',
  };

  @override
  Widget build(BuildContext context) {
    final dishes = dash.popularDishes;
    final maxSales = dishes.isEmpty
        ? 1
        : dishes.map((d) => d.sales).reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        Row(
          children: const [
            Text(
              'Platos Populares',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Spacer(),
            Text(
              'Ver todo',
              style: TextStyle(
                color: Color(0xFFFF6F22),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              for (var i = 0; i < dishes.length; i++) ...[
                _DishRow(
                  dish: dishes[i],
                  imagePath: _menuImages[dishes[i].menuId] ??
                      'lib/assets/images/background_bienvenida.png',
                  fraction: maxSales == 0 ? 0 : dishes[i].sales / maxSales,
                ),
                if (i < dishes.length - 1)
                  const Divider(
                      height: 1,
                      color: Color(0xFF2C2C2E),
                      indent: 16,
                      endIndent: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DishRow extends StatelessWidget {
  const _DishRow({
    required this.dish,
    required this.imagePath,
    required this.fraction,
  });

  final DashPopularDish dish;
  final String imagePath;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              imagePath,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.restaurant_rounded,
                    color: Color(0xFF3A3A3C), size: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dish.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Container(
                          height: 4,
                          width: constraints.maxWidth,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2E),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Container(
                          height: 4,
                          width: constraints.maxWidth * fraction,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6F22),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${dish.sales}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                'Ventas',
                style: TextStyle(color: Color(0xFF8E8E93), fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderFlowSection extends StatelessWidget {
  const _OrderFlowSection({required this.dash});

  final AdminDashboardProvider dash;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Flujo de Pedidos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Últimas 6 horas',
          style: TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 80,
                child: CustomPaint(
                  painter: _BarChartPainter(
                    values: dash.flowBars,
                    color: const Color(0xFFFF6F22),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['7h', '8h', '9h', '10h', '11h', '12h']
                    .map((l) => Text(l,
                        style: const TextStyle(
                            color: Color(0xFF8E8E93), fontSize: 10)))
                    .toList(),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D2E0D),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded,
                          color: Color(0xFF4CAF50), size: 15),
                      SizedBox(width: 6),
                      Text(
                        'Eficiencia de Cocina  94%',
                        style: TextStyle(
                          color: Color(0xFF4CAF50),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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

class _BarChartPainter extends CustomPainter {
  final List<double> values;
  final Color color;

  const _BarChartPainter({required this.values, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final max = values.reduce((a, b) => a > b ? a : b);
    if (max == 0) return;
    final barW = size.width / values.length;
    final gap = barW * 0.35;
    final paint = Paint()..color = color;

    for (var i = 0; i < values.length; i++) {
      final x = i * barW + gap / 2;
      final barH = values[i] / max * size.height * 0.9;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height - barH, barW - gap, barH),
          const Radius.circular(4),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) =>
      old.values != values || old.color != color;
}

class _RecentOrdersSection extends StatelessWidget {
  const _RecentOrdersSection({required this.dash});

  final AdminDashboardProvider dash;

  @override
  Widget build(BuildContext context) {
    const activeStatuses = {'accepted', 'preparing', 'ready'};
    final orders = dash.showActive
        ? dash.recentOrders
            .where((o) => activeStatuses.contains(o.status))
            .toList()
        : dash.recentOrders
            .where((o) =>
                o.status == 'delivered' || o.status == 'completed')
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Pedidos Recientes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            _TabPill(
              label: 'Activos',
              isSelected: dash.showActive,
              onTap: () => context
                  .read<AdminDashboardProvider>()
                  .setTab(showActive: true),
            ),
            const SizedBox(width: 8),
            _TabPill(
              label: 'Historial',
              isSelected: !dash.showActive,
              onTap: () => context
                  .read<AdminDashboardProvider>()
                  .setTab(showActive: false),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                child: Row(
                  children: const [
                    SizedBox(
                      width: 44,
                      child: Text('ID',
                          style: TextStyle(
                              color: Color(0xFF8E8E93),
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                    Expanded(
                        child: Text('Mesa/Cliente',
                            style: TextStyle(
                                color: Color(0xFF8E8E93),
                                fontSize: 11,
                                fontWeight: FontWeight.w700))),
                    Text('Estado',
                        style: TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                    SizedBox(width: 8),
                    Text('Total',
                        style: TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                    SizedBox(width: 32),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFF2C2C2E)),
              if (orders.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text('Sin pedidos',
                        style: TextStyle(color: Color(0xFF8E8E93))),
                  ),
                )
              else
                ...orders.map((o) => _OrderTableRow(order: o)),
            ],
          ),
        ),
      ],
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF6F22)
              : const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF8E8E93),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _OrderTableRow extends StatelessWidget {
  const _OrderTableRow({required this.order});

  final DashRecentOrder order;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                child: Text(
                  order.shortId,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  order.label,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _StatusBadge(status: order.status),
              const SizedBox(width: 8),
              Text(
                _formatCop(order.total),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded,
                    color: Color(0xFF8E8E93), size: 18),
                color: const Color(0xFF2C2C2E),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'detail',
                    child: Text('Ver detalle',
                        style: TextStyle(color: Colors.white)),
                  ),
                  PopupMenuItem(
                    value: 'status',
                    child: Text('Cambiar estado',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
                onSelected: (_) {},
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFF2C2C2E)),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      'preparing' => (
          'Preparación',
          const Color(0xFF2D2000),
          const Color(0xFFFFB800)
        ),
      'ready' => (
          'Listo',
          const Color(0xFF00213D),
          const Color(0xFF5AC8FA)
        ),
      'accepted' => (
          'Aceptado',
          const Color(0xFF1A1A00),
          const Color(0xFFFFD700)
        ),
      'delivered' || 'completed' => (
          'Servido',
          const Color(0xFF0D2E0D),
          const Color(0xFF4CAF50)
        ),
      _ => (
          'Pendiente',
          const Color(0xFF1C1C1E),
          const Color(0xFF8E8E93)
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AdminMenuManagementView extends StatelessWidget {
  const _AdminMenuManagementView();

  @override
  Widget build(BuildContext context) => const MenuManagementScreen();
}

class _AdminOrderManagementView extends StatelessWidget {
  const _AdminOrderManagementView();

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AdminTopBar(
            title: 'OrdeNow',
            showAvatar: false,
            leadingImage: 'lib/assets/images/background_bienvenida.png',
          ),
          const SizedBox(height: 22),
          const Text(
            'Live Commands',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Monitoring real-time kitchen output and financial reconciliations.',
            style: TextStyle(
              color: Color(0xFFD7C2B8),
              fontSize: 16,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF34312E),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              children: [
                Icon(Icons.search_rounded, color: Color(0xFFE5B29A)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Search order ID, guest...',
                    style: TextStyle(color: Color(0xFF8F847D)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.tune_rounded),
              label: const Text('Filters'),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'Active\nQueue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ),
              _QueueInfo(
                value: '${order.currentOrderStatus == 'preparing' ? 12 : 8}',
                label: 'PREPARING',
                color: const Color(0xFF7DDB7A),
              ),
              const SizedBox(width: 18),
              _QueueInfo(
                value: '${order.pendingPaymentTables.length + 4}',
                label: 'PENDING\nPAYMENT',
                color: const Color(0xFFF0B63E),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ActiveCommandCard(order: order),
          const SizedBox(height: 18),
          if (order.pendingPaymentTables.isNotEmpty)
            ...order.pendingPaymentTables.map(
              (table) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1C1A),
                    borderRadius: BorderRadius.circular(24),
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
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Customer requested cash settlement.',
                              style: TextStyle(color: Color(0xFFB8A59B)),
                            ),
                          ],
                        ),
                      ),
                      FilledButton(
                        onPressed: () => order.markAsPaid(paymentMethod: 'cash'),
                        child: const Text('Approve'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AdminProfileView extends StatelessWidget {
  const _AdminProfileView();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final flow = context.read<AppDemoProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AdminTopBar(
            title: 'OrdeNow',
            showAvatar: false,
            leadingImage: 'lib/assets/images/artisan_harvest_bowl.png',
          ),
          const SizedBox(height: 22),
          const Text(
            'Admin Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Configure your culinary ecosystem, manage staff access, and fine-tune your digital storefront.',
            style: TextStyle(
              color: Color(0xFFD7C2B8),
              fontSize: 16,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1C1A),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Business Settings',
                      style: TextStyle(
                        color: Color(0xFFFFC0A5),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.edit_outlined, color: Color(0xFF9F9088)),
                  ],
                ),
                SizedBox(height: 20),
                _InfoBlock(
                  label: 'RESTAURANT NAME',
                  value: "L'Essence de Paris",
                ),
                SizedBox(height: 16),
                _InfoBlock(
                  label: 'TAX ID',
                  value: 'FR-8820491823',
                ),
                SizedBox(height: 16),
                _InfoBlock(
                  label: 'BUSINESS ADDRESS',
                  value: '14 Avenue des Champs-\nÉlysées, 75008 Paris, France',
                  icon: Icons.place_outlined,
                ),
                SizedBox(height: 16),
                _MapPlaceholder(),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF2E2C29),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'System Preferences',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                _SettingTile(
                  icon: Icons.language_rounded,
                  label: 'Language',
                  value: settings.isSpanish ? 'Spanish (CO)' : 'English (US)',
                  accent: const Color(0xFFF0B63E),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
                const SizedBox(height: 14),
                _SettingTile(
                  icon: Icons.dark_mode_outlined,
                  label: 'Dark Theme',
                  value: '',
                  accent: const Color(0xFFE5B49D),
                  trailing: Switch(
                    value: settings.themeMode == ThemeMode.dark,
                    onChanged: (value) => settings.updateThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    ),
                    activeThumbColor: const Color(0xFFFF6B00),
                  ),
                ),
                const SizedBox(height: 14),
                _SettingTile(
                  icon: Icons.insights_outlined,
                  label: 'AI Insights',
                  value: '',
                  accent: const Color(0xFF7DDB7A),
                  trailing: Switch(
                    value: true,
                    onChanged: (_) {},
                    activeThumbColor: const Color(0xFF72DB6E),
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Support',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 18),
                _SupportRow(label: 'Knowledge Base', icon: Icons.open_in_new),
                SizedBox(height: 14),
                _SupportRow(label: 'Direct Chat', icon: Icons.chat_bubble_outline),
                SizedBox(height: 14),
                _SupportRow(label: 'API Documentation', icon: Icons.code),
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
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Staff\nManagement',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Manage roles and permissions for 12 active members.',
                            style: TextStyle(color: Color(0xFFB6A59D), height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.group_add_outlined),
                      label: const Text('Add Member'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...const [
                  _StaffMemberRow(
                    name: 'Marco Rossi',
                    role: 'EXECUTIVE CHEF',
                    imagePath: 'lib/assets/images/smoked_ribeye.png',
                    online: true,
                  ),
                  _StaffMemberRow(
                    name: 'Elena Vance',
                    role: 'GENERAL MANAGER',
                    imagePath: 'lib/assets/images/artisan_harvest_bowl.png',
                    online: true,
                  ),
                  _StaffMemberRow(
                    name: 'Simon Wright',
                    role: 'FLOOR SUPERVISOR',
                    imagePath: 'lib/assets/images/background_bienvenida.png',
                    online: true,
                  ),
                  _StaffMemberRow(
                    name: 'Clara J.',
                    role: 'SOMMELIER ASSISTANT',
                    imagePath: 'lib/assets/images/midnight_pasta.png',
                    online: false,
                  ),
                  _StaffMemberRow(
                    name: 'David Chen',
                    role: 'LEAD MIXOLOGIST',
                    imagePath: 'lib/assets/images/saffron_infused_sea_scallops.png',
                    online: true,
                  ),
                ],
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => flow.setAdminScreen(AdminScreen.dashboard),
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: const Text('Add Team Member'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminBottomBar extends StatelessWidget {
  const _AdminBottomBar({
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const labels = ['Inicio', 'Menú', 'Comandas', 'Perfil'];
    const icons = [
      Icons.home_rounded,
      Icons.restaurant_menu_rounded,
      Icons.receipt_long_rounded,
      Icons.person_rounded,
    ];

    return Container(
      color: Colors.black,
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(labels.length, (index) {
            final isSelected = selectedIndex == index;
            return GestureDetector(
              onTap: () => onTap(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icons[index],
                      color: isSelected
                          ? const Color(0xFFFF6F22)
                          : const Color(0xFF8E8E93),
                      size: 22,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[index],
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFFFF6F22)
                            : const Color(0xFF8E8E93),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _AdminTopBar extends StatelessWidget {
  const _AdminTopBar({
    required this.title,
    this.showAvatar = false,
    this.showMenuIcon = false,
    this.leadingImage,
  });

  final String title;
  final bool showAvatar;
  final bool showMenuIcon;
  final String? leadingImage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showMenuIcon)
          const Icon(Icons.menu_rounded, color: Color(0xFFE4B29B))
        else if (leadingImage != null)
          CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage(leadingImage!),
          ),
        if (showMenuIcon || leadingImage != null) const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            color: title == 'OrdeNow'
                ? const Color(0xFFFF6B00)
                : const Color(0xFFE5B49D),
            fontSize: title == 'OrdeNow' ? 18 : 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        const Icon(Icons.shopping_bag_outlined, color: Color(0xFFE5B49D)),
        if (showAvatar) ...[
          const SizedBox(width: 12),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFF4B2D1A),
            child: Icon(Icons.person, color: Color(0xFFE6B49D)),
          ),
        ],
      ],
    );
  }
}

class _QueueInfo extends StatelessWidget {
  const _QueueInfo({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$value ',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActiveCommandCard extends StatelessWidget {
  const _ActiveCommandCard({
    required this.order,
  });

  final OrderProvider order;

  @override
  Widget build(BuildContext context) {
    final activeOrder = order.activeOrder;
    final selectedTable = order.selectedTable;
    final orderedItems = order.orderedItems;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF3A2618),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF2A211C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF8D6825),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'ACTION\nREQUIRED',
                  style: TextStyle(
                    color: Color(0xFFFFE1A2),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    activeOrder == null ? '#ORD-9902' : '#ORD-${activeOrder.id.substring(0, 4).toUpperCase()}',
                    style: const TextStyle(
                      color: Color(0xFFD0C2BA),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatCop(activeOrder?.totalAmount ?? 142000),
                    style: const TextStyle(
                      color: Color(0xFFF0B63E),
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'PAY IN CASH',
                    style: TextStyle(
                      color: Color(0xFFF0B63E),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Table ${selectedTable?.number ?? 12} • 4\nGuests',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ...(orderedItems.isEmpty
                      ? const ['Aged Wagyu Sirloin x 2', 'Truffle Risotto', "Brunello di Montalcino '18"]
                      : orderedItems.take(3).map((item) => item.name))
                  .map(
                (name) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A3C36),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    name,
                    style: const TextStyle(color: Color(0xFFD7C2B8)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () => order.markAsPaid(paymentMethod: 'cash'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B00),
                    foregroundColor: const Color(0xFF281508),
                    padding: const EdgeInsets.symmetric(vertical: 22),
                  ),
                  child: const Text('Approve\nPayment', textAlign: TextAlign.center),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: OutlinedButton(
                  onPressed: order.hasActiveOrder ? order.advanceKitchenStatus : null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    backgroundColor: const Color(0xFF3A3835),
                  ),
                  child: const Text(
                    'View\nDigital Comanda',
                    textAlign: TextAlign.center,
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

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8C7E76),
            fontSize: 12,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, color: const Color(0xFF72DB6E)),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFF3B3937),
      ),
      child: Row(
        children: List.generate(
          3,
          (index) => Expanded(
            child: Container(
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : 1,
                right: index == 2 ? 0 : 1,
              ),
              decoration: BoxDecoration(
                color: index == 1 ? const Color(0xFF6B6967) : const Color(0xFFB3B1AF),
                borderRadius: BorderRadius.horizontal(
                  left: index == 0 ? const Radius.circular(18) : Radius.zero,
                  right: index == 2 ? const Radius.circular(18) : Radius.zero,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1C1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          if (value.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                value,
                style: const TextStyle(color: Color(0xFFE5B49D)),
              ),
            ),
          trailing,
        ],
      ),
    );
  }
}

class _SupportRow extends StatelessWidget {
  const _SupportRow({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFFD2C0B7), fontSize: 16),
          ),
        ),
        Icon(icon, size: 18, color: const Color(0xFF9C8E86)),
      ],
    );
  }
}

class _StaffMemberRow extends StatelessWidget {
  const _StaffMemberRow({
    required this.name,
    required this.role,
    required this.imagePath,
    required this.online,
  });

  final String name;
  final String role;
  final String imagePath;
  final bool online;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: AssetImage(imagePath),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: online
                        ? const Color(0xFF1DB954)
                        : const Color(0xFF7A7A7A),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: const TextStyle(
                    color: Color(0xFF8C7E76),
                    fontSize: 12,
                    letterSpacing: 1.2,
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
