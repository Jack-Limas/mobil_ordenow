import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/table.dart';
import '../providers/admin_dashboard_provider.dart';
import '../providers/app_demo_provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/orders_kds_provider.dart';
import '../widgets/offline_banner.dart';
import 'admin_profile_screen.dart';
import 'menu_management_screen.dart';
import 'orders_kds_screen.dart';

String _formatCop(double value) {
  final intVal = value.toInt();
  return '\$${intVal.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
}

class AdminAppScreen extends StatefulWidget {
  const AdminAppScreen({super.key});

  @override
  State<AdminAppScreen> createState() => _AdminAppScreenState();
}

class _AdminAppScreenState extends State<AdminAppScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.read<AuthProvider>().isClient) {
        context.read<AppDemoProvider>().openTableSelection();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<AppDemoProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: IndexedStack(
                index: flow.adminScreen.index,
                children: const [
                  _AdminHomeView(),
                  MenuManagementScreen(),
                  OrdersKdsScreen(showBackButton: false),
                  AdminProfileScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _AdminBottomBar(
        selectedIndex: flow.adminScreen.index,
        onTap: (index) => flow.setAdminScreen(AdminScreen.values[index]),
      ),
    );
  }
}

class _AdminHomeView extends StatelessWidget {
  const _AdminHomeView();

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<AdminDashboardProvider>();
    final settings = context.watch<AppSettingsProvider>();

    return Column(
      children: [
        _AdminAppBar(settings: settings),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            children: [
              const Text(
                'Mesas ocupadas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${dash.occupiedTables.length} mesas en servicio • Tiempo real',
                style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
              ),
              const SizedBox(height: 20),
              _OccupiedTablesSection(dash: dash),
              const SizedBox(height: 22),
              _StatsSection(dash: dash),
            ],
          ),
        ),
      ],
    );
  }
}

class _AdminAppBar extends StatelessWidget {
  const _AdminAppBar({required this.settings});

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
          const SizedBox(width: 8),
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
    );
  }
}

class _OccupiedTablesSection extends StatelessWidget {
  const _OccupiedTablesSection({required this.dash});

  final AdminDashboardProvider dash;

  @override
  Widget build(BuildContext context) {
    final tables = dash.occupiedTables;
    if (tables.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.table_restaurant_outlined,
              color: Color(0xFF3A3A3C),
              size: 48,
            ),
            SizedBox(height: 14),
            Text(
              'No hay mesas ocupadas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Cuando un cliente reserve una mesa, aparecera aqui.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF8E8E93), height: 1.4),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      itemCount: tables.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.88,
      ),
      itemBuilder: (context, index) {
        final table = tables[index];
        final activeOrder = dash.activeOrderForTable(table.id);
        return _TableServiceCard(
          table: table,
          orderStatus: activeOrder?['status']?.toString(),
          orderTotal: (activeOrder?['total_amount'] as num?)?.toDouble() ?? 0,
          hasOrder: activeOrder != null,
          onOpenOrder: activeOrder == null
              ? null
              : () => context.read<AppDemoProvider>().setAdminScreen(
                  AdminScreen.orderManagement,
                ),
          onRelease: () => _confirmRelease(context, dash, table),
        );
      },
    );
  }

  Future<void> _confirmRelease(
    BuildContext context,
    AdminDashboardProvider dash,
    TableEntity table,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: Text(
          'Liberar mesa ${table.number}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'La mesa quedará disponible para nuevos clientes. Si tiene una orden activa, se marcará como completada.',
          style: TextStyle(color: Color(0xFF8E8E93)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF6F22),
            ),
            child: const Text('Liberar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Capture order ID before releasing (dash does optimistic update immediately)
      final activeOrder = dash.activeOrderForTable(table.id);
      await dash.releaseTable(table.id);
      // Immediately sync KDS local state so the comanda disappears without
      // waiting for the Realtime event, which can lag.
      if (context.mounted && activeOrder != null) {
        await context.read<OrdersKdsProvider>().releaseTable(
          orderId: activeOrder['id'] as String,
          tableId: table.id,
        );
      }
    }
  }
}

class _TableServiceCard extends StatelessWidget {
  const _TableServiceCard({
    required this.table,
    required this.orderStatus,
    required this.orderTotal,
    required this.hasOrder,
    required this.onOpenOrder,
    required this.onRelease,
  });

  final TableEntity table;
  final String? orderStatus;
  final double orderTotal;
  final bool hasOrder;
  final VoidCallback? onOpenOrder;
  final VoidCallback onRelease;

  @override
  Widget build(BuildContext context) {
    final color = table.needsPayment
        ? const Color(0xFFFFB800)
        : const Color(0xFFFF6F22);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: table.needsPayment
            ? const Color(0xFF3A2618)
            : const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const Spacer(),
              Icon(Icons.table_restaurant_rounded, color: color, size: 20),
            ],
          ),
          const Spacer(),
          Text(
            'Mesa ${table.number}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            table.needsPayment ? 'Pago pendiente' : _statusLabel(orderStatus),
            style: const TextStyle(color: Color(0xFFB8A59B), fontSize: 12),
          ),
          if (orderTotal > 0) ...[
            const SizedBox(height: 6),
            Text(
              _formatCop(orderTotal),
              style: TextStyle(color: color, fontWeight: FontWeight.w800),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onOpenOrder,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF3A3A3C)),
                  ),
                  child: const Text('Comanda'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: onRelease,
                style: IconButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.event_available_rounded, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _statusLabel(String? status) {
    return switch (status) {
      'pending' => 'Pendiente',
      'accepted' => 'Aceptado',
      'preparing' => 'Preparando',
      'ready' => 'Listo',
      _ => hasOrder ? 'Con pedido' : 'Ocupada',
    };
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.dash});

  final AdminDashboardProvider dash;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estadisticas reales',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        _MetricTile(
          label: 'Ventas del dia',
          value: _formatCop(dash.salesToday),
          icon: Icons.show_chart_rounded,
        ),
        const SizedBox(height: 10),
        _MetricTile(
          label: 'Pedidos activos',
          value: '${dash.activeOrders}',
          icon: Icons.receipt_long_rounded,
        ),
        const SizedBox(height: 10),
        _MetricTile(
          label: 'Ticket promedio',
          value: _formatCop(dash.avgTicket),
          icon: Icons.payments_rounded,
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF6F22), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF8E8E93)),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminBottomBar extends StatelessWidget {
  const _AdminBottomBar({required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const labels = ['Inicio', 'Menu', 'Comandas', 'Perfil'];
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
