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

  List<String> _categories(List<Menu> menu) {
    return ['Todos', ...menu.map((m) => m.category).toSet()];
  }

  List<Menu> _filtered(List<Menu> menu) {
    if (_selectedCategory == null || _selectedCategory == 'Todos') return menu;
    return menu.where((m) => m.category == _selectedCategory).toList();
  }

  void _orderWithAi(Menu menu) {
    final ai = context.read<AiProvider>();
    final order = context.read<OrderProvider>();
    ai.sendMessage(
      prompt: 'El cliente quiere saber sobre: ${menu.name}',
      recommendedMenu: order.menu,
      cartItems: order.cartItems,
      tableNumber: order.selectedTable?.number,
      orderStatus: order.currentOrderStatus,
    );
    context.read<AppDemoProvider>().setCustomerScreen(
      CustomerScreen.aiConcierge,
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>();
    final categories = _categories(order.menu);
    final selectedCat = _selectedCategory ?? 'Todos';
    final filtered = _filtered(order.menu);

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            const _CatalogAppBar(),
            ShaderMask(
              shaderCallback: (rect) => const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.white, Colors.white, Colors.transparent],
                stops: [0.0, 0.80, 1.0],
              ).createShader(rect),
              blendMode: BlendMode.dstIn,
              child: SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = cat == selectedCat;
                    final displayCat = cat == 'Todos'
                        ? AppCopy.of(context).menuAll
                        : AppCopy.translateCategory(context, cat);
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFF6F22)
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(999),
                          border: isSelected
                              ? null
                              : Border.all(
                                  color: Theme.of(context).dividerColor,
                                ),
                        ),
                        child: Text(
                          displayCat,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF8E8E93),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? const _EmptyCategory()
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            mainAxisExtent: 320,
                          ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return MenuItemCard(
                          menu: item,
                          imagePath: item.imageUrl.isNotEmpty
                              ? item.imageUrl
                              : _menuImages[item.id] ??
                                    'lib/assets/images/background_bienvenida.png',
                          onOrderWithAi: () => _orderWithAi(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogAppBar extends StatelessWidget {
  const _CatalogAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
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
          Text(
            'OrdeNow',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          const AppUtilityToggles(),
        ],
      ),
    );
  }
}

class _EmptyCategory extends StatelessWidget {
  const _EmptyCategory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.restaurant_rounded, color: Color(0xFF3A3A3C), size: 56),
          const SizedBox(height: 16),
          Text(
            AppCopy.of(context).menuEmptyCategory,
            style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 15),
          ),
        ],
      ),
    );
  }
}
