import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/menu.dart';
import '../providers/app_demo_provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/order_provider.dart';
import 'customer_app_screen.dart';

class AdminAppScreen extends StatelessWidget {
  const AdminAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<AppDemoProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF120F0D),
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
    );
  }
}

class _AdminDashboardView extends StatelessWidget {
  const _AdminDashboardView();

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>();
    final recentTotal = order.activeOrder?.totalAmount ?? 142.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AdminTopBar(
            title: 'Dashboard Summary',
            showAvatar: true,
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF252421),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0B63E),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.payments_outlined, color: Color(0xFFF0B63E)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Pending Cash\nVerifications',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        'There are 4 orders awaiting manual payment confirmation from the courier.',
                        style: TextStyle(color: Color(0xFFD5C1B8), height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _AdminMetricCard(
            label: 'REVENUE TODAY',
            value: '\$12,482.50',
            footer: '+14.2% from yesterday',
            accent: Color(0xFF7DDB7A),
          ),
          const SizedBox(height: 18),
          _AdminMetricCard(
            label: 'ACTIVE ORDERS',
            value: '${order.hasActiveOrder ? 42 : 18}',
            footer: 'Avg. Prep: 18 mins',
            accent: const Color(0xFFD7C1B7),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B00),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI CONCIERGE ALERT',
                  style: TextStyle(
                    color: Color(0x8C2B1600),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Stock Warning: Wagyu\nRibeye',
                  style: TextStyle(
                    color: Color(0xFF281508),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Projected to sell out in 45 mins based on current ordering velocity. Suggest adjusting featured listings.',
                  style: TextStyle(
                    color: Color(0xCC2B1600),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              Text(
                'Recent Activity',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Spacer(),
              Text(
                'VIEW LOG',
                style: TextStyle(
                  color: Color(0xFFE6B49D),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ActivityCard(
            icon: Icons.check_circle_outline_rounded,
            title: 'Order #8492\nCompleted',
            subtitle: 'Delivery to Upper East Side • 4 mins ago',
            amount: '\$${recentTotal.toStringAsFixed(2)}',
            status: 'CREDIT CARD',
            accent: const Color(0xFF7DDB7A),
          ),
          const SizedBox(height: 14),
          const _ActivityCard(
            icon: Icons.warning_amber_rounded,
            title: 'New Cash Order\n#8495',
            subtitle: 'Awaiting courier arrival • 12 mins ago',
            amount: '\$54.20',
            status: 'PENDING',
            accent: Color(0xFFF0B63E),
          ),
          const SizedBox(height: 14),
          const _ActivityCard(
            icon: Icons.schedule_rounded,
            title: 'Pre-order Logged',
            subtitle: 'Scheduled for 8:00 PM tonight • 22 mins ago',
            amount: '\$210.00',
            status: 'CORPORATE',
            accent: Color(0xFFE5B49D),
          ),
          const SizedBox(height: 24),
          const Text(
            'Top Dishes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          const _TopDishCard(
            title: 'Smoked Brisket',
            subtitle: '84 ORDERS TODAY',
            imagePath: 'lib/assets/images/smoked_ribeye.png',
            rank: '#1',
          ),
          const SizedBox(height: 16),
          const _TopDishCard(
            title: 'Truffle Gnocchi',
            subtitle: '62 ORDERS TODAY',
            imagePath: 'lib/assets/images/midnight_pasta.png',
            rank: '#2',
          ),
        ],
      ),
    );
  }
}

class _AdminMenuManagementView extends StatelessWidget {
  const _AdminMenuManagementView();

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
            showAvatar: true,
            showMenuIcon: true,
          ),
          const SizedBox(height: 22),
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Curate the ',
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: 'Palate',
                  style: TextStyle(color: Color(0xFFFFB9A0)),
                ),
              ],
            ),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Refine your culinary offerings and manage real-time availability for your diners.',
            style: TextStyle(
              color: Color(0xFFD8C2B8),
              fontSize: 16,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text('Add New Dish'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1C1A),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Dish Essence',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A2D29),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'EDITING MODE',
                        style: TextStyle(
                          color: Color(0xFFE7B49F),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const _AdminField(
                  label: 'DISH NAME',
                  hint: 'e.g. Saffron Risotto',
                ),
                const SizedBox(height: 16),
                const _AdminField(
                  label: 'BASE PRICE (\$)',
                  hint: '24.00',
                ),
                const SizedBox(height: 16),
                const _AdminField(
                  label: 'DESCRIPTION (THE NARRATIVE)',
                  hint: 'Describe the sensory experience, textures, and origins...',
                  minHeight: 110,
                ),
                const SizedBox(height: 18),
                const Text(
                  'INGREDIENTS & ALLERGENS',
                  style: TextStyle(
                    color: Color(0xFF8C7E76),
                    fontSize: 12,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: const [
                    _AdminTag(text: 'Vegan', accent: true),
                    _AdminTag(text: 'Gluten-Free'),
                    _AdminTag(text: 'Dairy'),
                    _AdminTag(text: 'Nuts'),
                    _AdminTag(text: 'Manage All', accent: true),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E2C29),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Live Availability',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Toggle visibility on the customer app.',
                              style: TextStyle(color: Color(0xFFB5A49C)),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: true,
                        onChanged: (_) {},
                        activeThumbColor: const Color(0xFF72DB6E),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text('Discard Draft'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {},
                        child: const Text('SAVE DISH CHANGES'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1C1A),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DISH PORTRAIT',
                  style: TextStyle(
                    color: Color(0xFF8C7E76),
                    fontSize: 12,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'lib/assets/images/midnight_pasta.png',
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined, color: Colors.white),
                          SizedBox(height: 8),
                          Text(
                            'Change Image',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF473515),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded,
                          color: Color(0xFFF0B63E)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'AI Pricing Insight\nDishes with this description perform 22% better at \$23.00.',
                          style: TextStyle(
                            color: Color(0xFFF4D7A8),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              Text(
                'Current Selection',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Spacer(),
              Icon(Icons.tune_rounded, color: Color(0xFF8C7E76)),
              SizedBox(width: 14),
              Icon(Icons.search_rounded, color: Color(0xFF8C7E76)),
            ],
          ),
          const SizedBox(height: 16),
          ...order.menu.take(4).map(
            (menu) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _AdminDishCard(menu: menu),
            ),
          ),
        ],
      ),
    );
  }
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
    const labels = ['Dashboard', 'Inventory', 'Kitchen', 'Settings'];
    const icons = [
      Icons.dashboard_outlined,
      Icons.inventory_2_outlined,
      Icons.auto_awesome_outlined,
      Icons.settings_outlined,
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF171413),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x22FFFFFF)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(labels.length, (index) {
          final isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () => onTap(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color:
                    isSelected ? const Color(0xFF3A2517) : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icons[index],
                    color: isSelected
                        ? const Color(0xFFFF7B1A)
                        : const Color(0xFF98908A),
                    size: 20,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    labels[index].toUpperCase(),
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFFFF7B1A)
                          : const Color(0xFF98908A),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
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

class _AdminMetricCard extends StatelessWidget {
  const _AdminMetricCard({
    required this.label,
    required this.value,
    required this.footer,
    required this.accent,
  });

  final String label;
  final String value;
  final String footer;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1C1A),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF7E726B),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            footer,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.status,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;
  final String status;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1C1A),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF2D2A27),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFB6A49D),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                status,
                style: TextStyle(
                  color: accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopDishCard extends StatelessWidget {
  const _TopDishCard({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.rank,
  });

  final String title;
  final String subtitle;
  final String imagePath;
  final String rank;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Image.asset(
            imagePath,
            width: double.infinity,
            height: 170,
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.78),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 20,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFFD7C1B7),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B00),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  rank,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
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

class _AdminField extends StatelessWidget {
  const _AdminField({
    required this.label,
    required this.hint,
    this.minHeight = 64,
  });

  final String label;
  final String hint;
  final double minHeight;

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
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          constraints: BoxConstraints(minHeight: minHeight),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF34312E),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            hint,
            style: const TextStyle(color: Color(0xFF716964)),
          ),
        ),
      ],
    );
  }
}

class _AdminTag extends StatelessWidget {
  const _AdminTag({
    required this.text,
    this.accent = false,
  });

  final String text;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: accent ? const Color(0xFF2F3B24) : const Color(0xFF2B2927),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: accent ? const Color(0xFF9ADB83) : const Color(0xFFD4C0B7),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AdminDishCard extends StatelessWidget {
  const _AdminDishCard({
    required this.menu,
  });

  final Menu menu;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1C1A),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              CustomerAppScreen.imageFor(menu.id),
              width: 110,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        menu.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '\$${menu.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFFEAB8A1),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  menu.category.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF8C7E76),
                    fontSize: 11,
                    letterSpacing: 1.3,
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
                    '\$${(activeOrder?.totalAmount ?? 142.50).toStringAsFixed(2)}',
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
