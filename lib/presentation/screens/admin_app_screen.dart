import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_demo_provider.dart';

class AdminAppScreen extends StatelessWidget {
  const AdminAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<AppDemoProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF120F0D),
      body: SafeArea(
        child: Center(
          child: Text(
            'Admin screen: ${flow.adminScreen.name}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: flow.adminScreen.index,
        onDestinationSelected: (index) {
          flow.setAdminScreen(AdminScreen.values[index]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Inventory',
          ),
          NavigationDestination(
            icon: Icon(Icons.soup_kitchen_outlined),
            selectedIcon: Icon(Icons.soup_kitchen),
            label: 'Kitchen',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
