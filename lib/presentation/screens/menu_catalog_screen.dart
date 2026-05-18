import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/app_copy.dart';
import '../../domain/entities/menu.dart';
import '../providers/ai_provider.dart';
import '../providers/app_demo_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/app_utility_toggles.dart';
import '../widgets/menu_item_card.dart';

class MenuCatalogScreen extends StatefulWidget {
  const MenuCatalogScreen({super.key});

  @override
  State<MenuCatalogScreen> createState() => _MenuCatalogScreenState();
}

class _MenuCatalogScreenState extends State<MenuCatalogScreen> {
  static const _menuImages = <String, String>{
    'menu-1': 'lib/assets/images/saffron_infused_sea_scallops.png',
    'menu-2': 'lib/assets/images/midnight_pasta.png',
    'menu-3': 'lib/assets/images/smoked_ribeye.png',
    'menu-4': 'lib/assets/images/artisan_harvest_bowl.png',
    'menu-5': 'lib/assets/images/background_bienvenida.png',
    'menu-6': 'lib/assets/images/background_bienvenida.png',
  };

  String? _selectedCategory;

  List<String> _categories(List<Menu> menu, AppCopy copy) {
    final allLabel = copy.isSpanish ? 'Todos' : 'All';
    return [allLabel, ...menu.map((m) => m.category).toSet()];
  }

  List<Menu> _filtered(List<Menu> menu, AppCopy copy) {
    final allLabel = copy.isSpanish ? 'Todos' : 'All';
    if (_selectedCategory == null || _selectedCategory == allLabel) return menu;
    return menu.where((m) => m.category == _selectedCategory).toList();
  }

  void _orderWithAi(BuildContext context, Menu menu) {
    final ai = context.read<AiProvider>();
    final order = context.read<OrderProvider>();
    ai.sendMessage(
      prompt: 'Quiero ordenar ${menu.name}',
      recommendedMenu: order.recommendedMenu,
      cartItems: order.cartItems,
      tableNumber: order.selectedTable?.number,
      orderStatus: order.currentOrderStatus,
    );
    context.read<AppDemoProvider>().setCustomerScreen(CustomerScreen.aiConcierge);
  }

  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    final order = context.watch<OrderProvider>();
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF171717);
    final mutedColor =
        isDarkMode ? const Color(0xFFC9C2BE) : const Color(0xFF625B56);
    final categories = _categories(order.menu, copy);
    final selectedCat = _selectedCategory ?? categories.first;
    final filtered = _filtered(order.menu, copy);

    return Scaffold(
      body: Container(
        color: backgroundColor,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'MENÚ',
                            style: TextStyle(
                              color: Color(0xFFFFB48E),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.6,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            copy.isSpanish ? 'Nuestros platos' : 'Our dishes',
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
              const SizedBox(height: 16),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = cat == selectedCat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _selectedCategory = cat);
                      },
                      selectedColor: const Color(0xFFFF6F22),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : mutedColor,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          copy.noTablesAvailable,
                          style: TextStyle(color: mutedColor),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          mainAxisExtent: 300,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return MenuItemCard(
                            menu: item,
                            imagePath: _menuImages[item.id] ??
                                'lib/assets/images/background_bienvenida.png',
                            onOrderWithAi: () => _orderWithAi(context, item),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
