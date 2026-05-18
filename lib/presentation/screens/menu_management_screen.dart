import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/menu.dart';
import '../providers/order_provider.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  Menu? _editing;
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  bool _availableToggle = true;
  bool _recommendedToggle = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _openEditor(Menu item) {
    setState(() {
      _editing = item;
      _nameController.text = item.name;
      _descController.text = item.description;
      _priceController.text = item.price.toInt().toString();
      _availableToggle = item.available;
      _recommendedToggle = item.recommended;
    });
  }

  void _closeEditor() => setState(() => _editing = null);

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: _editing != null
            ? _EditorPane(
                item: _editing!,
                nameController: _nameController,
                descController: _descController,
                priceController: _priceController,
                availableToggle: _availableToggle,
                recommendedToggle: _recommendedToggle,
                onAvailableChanged: (v) =>
                    setState(() => _availableToggle = v),
                onRecommendedChanged: (v) =>
                    setState(() => _recommendedToggle = v),
                onDiscard: _closeEditor,
                onSave: _closeEditor,
              )
            : _CatalogPane(
                menu: order.menu,
                onEdit: _openEditor,
              ),
      ),
    );
  }
}

class _CatalogPane extends StatelessWidget {
  const _CatalogPane({
    required this.menu,
    required this.onEdit,
  });

  final List<Menu> menu;
  final ValueChanged<Menu> onEdit;

  static const _menuImages = <String, String>{
    'menu-1': 'lib/assets/images/saffron_infused_sea_scallops.png',
    'menu-2': 'lib/assets/images/midnight_pasta.png',
    'menu-3': 'lib/assets/images/smoked_ribeye.png',
    'menu-4': 'lib/assets/images/artisan_harvest_bowl.png',
    'menu-5': 'lib/assets/images/background_bienvenida.png',
    'menu-6': 'lib/assets/images/background_bienvenida.png',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MENÚ',
                      style: TextStyle(
                        color: Color(0xFFFF6F22),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.6,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Gestión de carta',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6F22),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text(
                  'Nuevo plato',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            itemCount: menu.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = menu[index];
              return _MenuManagementTile(
                item: item,
                imagePath: _menuImages[item.id] ??
                    'lib/assets/images/background_bienvenida.png',
                onEdit: () => onEdit(item),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MenuManagementTile extends StatelessWidget {
  const _MenuManagementTile({
    required this.item,
    required this.imagePath,
    required this.onEdit,
  });

  final Menu item;
  final String imagePath;
  final VoidCallback onEdit;

  String _formatCop(double value) {
    final intVal = value.toInt();
    return '\$${intVal.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1C1C1E)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              imagePath,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 72,
                height: 72,
                color: const Color(0xFF1C1C1E),
                child: const Icon(Icons.restaurant_rounded,
                    color: Color(0xFF2C2C2E), size: 32),
              ),
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
                        item.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: item.available
                            ? const Color(0xFF62D26F)
                            : const Color(0xFF48484A),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.category.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF636366),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      _formatCop(item.price),
                      style: const TextStyle(
                        color: Color(0xFFFF6F22),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    if (item.recommended)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6F22).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'AI Pick',
                          style: TextStyle(
                            color: Color(0xFFFF6F22),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: Color(0xFFFF6F22),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorPane extends StatelessWidget {
  const _EditorPane({
    required this.item,
    required this.nameController,
    required this.descController,
    required this.priceController,
    required this.availableToggle,
    required this.recommendedToggle,
    required this.onAvailableChanged,
    required this.onRecommendedChanged,
    required this.onDiscard,
    required this.onSave,
  });

  final Menu item;
  final TextEditingController nameController;
  final TextEditingController descController;
  final TextEditingController priceController;
  final bool availableToggle;
  final bool recommendedToggle;
  final ValueChanged<bool> onAvailableChanged;
  final ValueChanged<bool> onRecommendedChanged;
  final VoidCallback onDiscard;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Row(
            children: [
              GestureDetector(
                onTap: onDiscard,
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                'Editar plato',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              _EditorField(
                controller: nameController,
                label: 'NOMBRE DEL PLATO',
                hint: 'Ej. Saffron Risotto',
              ),
              const SizedBox(height: 14),
              _EditorField(
                controller: priceController,
                label: 'PRECIO (COP)',
                hint: '68000',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),
              _EditorField(
                controller: descController,
                label: 'DESCRIPCIÓN',
                hint: 'Describe la experiencia sensorial...',
                minLines: 3,
                maxLines: 5,
              ),
              const SizedBox(height: 20),
              _ToggleTile(
                label: 'Disponible',
                subtitle: 'Visible en la app del cliente',
                value: availableToggle,
                onChanged: onAvailableChanged,
                activeColor: const Color(0xFF62D26F),
              ),
              const SizedBox(height: 10),
              _ToggleTile(
                label: 'AI Pick',
                subtitle: 'La IA lo recomendará activamente',
                value: recommendedToggle,
                onChanged: onRecommendedChanged,
                activeColor: const Color(0xFFFF6F22),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDiscard,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF2C2C2E)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Descartar',
                        style: TextStyle(color: Color(0xFF8C8C8E)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: FilledButton(
                      onPressed: onSave,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6F22),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Guardar cambios',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EditorField extends StatelessWidget {
  const _EditorField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF636366),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          minLines: minLines,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF3A3A3C)),
            filled: true,
            fillColor: const Color(0xFF141414),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF1C1C1E)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF1C1C1E)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFFF6F22)),
            ),
          ),
        ),
      ],
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.activeColor,
  });

  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1C1C1E)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF636366),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: activeColor.withValues(alpha: 0.3),
            activeColor: activeColor,
          ),
        ],
      ),
    );
  }
}
