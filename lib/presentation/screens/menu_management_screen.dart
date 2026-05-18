import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/menu.dart';
import '../providers/app_settings_provider.dart';
import '../providers/menu_management_provider.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  final _scrollCtrl = ScrollController();
  final _formAnchorKey = GlobalKey();

  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _ingredientsCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  String _category = 'Plato';
  Menu? _editingItem;

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _ingredientsCtrl.dispose();
    _descCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  void _openEdit(Menu item) {
    setState(() {
      _editingItem = item;
      _nameCtrl.text = item.name;
      _priceCtrl.text = item.price.toInt().toString();
      _descCtrl.text = item.description;
      _ingredientsCtrl.text = item.tags.join(', ');
      _imageCtrl.clear();
      _category = _mapCategory(item.category);
    });
    _scrollToForm();
  }

  void _openNew({String name = '', String description = ''}) {
    setState(() {
      _editingItem = null;
      _nameCtrl.text = name;
      _descCtrl.text = description;
      _priceCtrl.clear();
      _ingredientsCtrl.clear();
      _imageCtrl.clear();
      _category = 'Plato';
    });
    _scrollToForm();
  }

  void _cancelEdit() => setState(() {
        _editingItem = null;
        _nameCtrl.clear();
        _priceCtrl.clear();
        _descCtrl.clear();
        _ingredientsCtrl.clear();
        _imageCtrl.clear();
        _category = 'Plato';
      });

  String _mapCategory(String raw) {
    const map = {
      'Main': 'Plato',
      'Drink': 'Bebida',
      'Dessert': 'Postre',
      'Starter': 'Entrada',
      'Signature': 'Plato',
      'Healthy': 'Plato',
    };
    return map[raw] ?? 'Plato';
  }

  Future<void> _scrollToForm() async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (_formAnchorKey.currentContext != null) {
      await Scrollable.ensureVisible(
        _formAnchorKey.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _confirmDelete(Menu item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '¿Eliminar plato?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          '¿Seguro que quieres eliminar "${item.name}"? Esta acción no se puede deshacer.',
          style: const TextStyle(color: Color(0xFF8E8E93)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF8E8E93)),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<MenuManagementProvider>().deleteMenuItem(item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mgmt = context.watch<MenuManagementProvider>();
    return Stack(
      children: [
        Column(
          children: [
            const _MenuMgmtAppBar(),
            Expanded(
              child: ListView(
                controller: _scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                children: [
                  const _MenuHeader(),
                  const SizedBox(height: 20),
                  _CurrentDishesSection(
                    menu: mgmt.menu,
                    loading: mgmt.loading,
                    onEdit: _openEdit,
                    onDelete: _confirmDelete,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(key: _formAnchorKey),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: _openNew,
            backgroundColor: const Color(0xFFFF6F22),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

// ── App Bar ──────────────────────────────────────────────────────────────────

class _MenuMgmtAppBar extends StatelessWidget {
  const _MenuMgmtAppBar();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    return SafeArea(
      bottom: false,
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
        child: Row(
          children: [
            const Icon(
              Icons.restaurant_menu_rounded,
              color: Color(0xFFFF6F22),
              size: 22,
            ),
            const SizedBox(width: 8),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
      ),
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────────────

class _MenuHeader extends StatelessWidget {
  const _MenuHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gestión del Menú',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Administra y optimiza tus platos actuales con inteligencia artificial',
          style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13, height: 1.4),
        ),
      ],
    );
  }
}

// ── Current Dishes Section ────────────────────────────────────────────────────

class _CurrentDishesSection extends StatelessWidget {
  const _CurrentDishesSection({
    required this.menu,
    required this.loading,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Menu> menu;
  final bool loading;
  final ValueChanged<Menu> onEdit;
  final ValueChanged<Menu> onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                const Text(
                  '✕ Platos Actuales',
                  style: TextStyle(
                    color: Color(0xFFFF6F22),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF8E8E93),
                  size: 22,
                ),
              ],
            ),
          ),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(
                color: Color(0xFFFF6F22),
                strokeWidth: 2,
              ),
            )
          else if (menu.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Text(
                'No hay platos en el menú. Añade el primero.',
                style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
              ),
            )
          else
            for (var i = 0; i < menu.length; i++) ...[
              if (i > 0)
                const Divider(
                  color: Color(0xFF2C2C2E),
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                ),
              _DishCard(
                item: menu[i],
                onEdit: () => onEdit(menu[i]),
                onDelete: () => onDelete(menu[i]),
              ),
            ],
        ],
      ),
    );
  }
}

class _DishCard extends StatelessWidget {
  const _DishCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final Menu item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String _formatCop(double v) {
    final s = v.toInt().toString();
    return '\$${s.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _DishImage(item: item),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6F22),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.category.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    item.description,
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  _formatCop(item.price),
                  style: const TextStyle(
                    color: Color(0xFFFF6F22),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              _IconBtn(
                icon: Icons.edit_rounded,
                color: const Color(0xFF5AC8FA),
                onTap: onEdit,
              ),
              const SizedBox(height: 8),
              _IconBtn(
                icon: Icons.delete_outline_rounded,
                color: const Color(0xFFD32F2F),
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DishImage extends StatelessWidget {
  const _DishImage({required this.item});

  final Menu item;

  @override
  Widget build(BuildContext context) {
    const size = 70.0;
    final placeholder = Container(
      width: size,
      height: size,
      color: const Color(0xFF2C2C2E),
      child: const Icon(
        Icons.restaurant_rounded,
        color: Color(0xFF48484A),
        size: 28,
      ),
    );
    return SizedBox(
      width: size,
      height: size,
      child: placeholder,
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}
