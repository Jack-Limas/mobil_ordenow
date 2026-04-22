import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_demo_provider.dart';

class CustomerAppScreen extends StatelessWidget {
  const CustomerAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<AppDemoProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF120F0D),
      body: SafeArea(
        child: Center(
          child: Text(
            'Customer screen: ${flow.customerScreen.name}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navigationIndex(flow.customerScreen),
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              flow.setCustomerScreen(CustomerScreen.menu);
            case 1:
              flow.setCustomerScreen(CustomerScreen.cart);
            case 2:
              flow.setCustomerScreen(CustomerScreen.aiConcierge);
            case 3:
              flow.setCustomerScreen(CustomerScreen.profile);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'AI',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  int _navigationIndex(CustomerScreen screen) {
    switch (screen) {
      case CustomerScreen.menu:
        return 0;
      case CustomerScreen.cart:
      case CustomerScreen.checkout:
      case CustomerScreen.tracking:
        return 1;
      case CustomerScreen.aiConcierge:
        return 2;
      case CustomerScreen.profile:
        return 3;
    }
  }
}
