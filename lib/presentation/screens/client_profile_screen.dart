import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/app_copy.dart';
import '../../domain/entities/menu.dart';
import '../providers/app_demo_provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/app_utility_toggles.dart';
class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  bool _showAllHistory = false;

  static const _commonAllergies = [
    'Mani', 'Mariscos', 'Gluten', 'Lactosa', 'Huevo', 'Soya',
  ];

  Future<void> _showAddAllergyDialog(AuthProvider auth) async {
    final selected = <String>{};
    final customController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(ctx).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Añadir alergias',
            style: TextStyle(
              color: Theme.of(ctx).colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selecciona tus alergias:',
                style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _commonAllergies.map((a) {
                  final isSelected = selected.contains(a);
                  return GestureDetector(
                    onTap: () => setDialogState(() {
                      if (isSelected) selected.remove(a);
                      else selected.add(a);
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFF6F22)
                            : Theme.of(ctx).colorScheme.surface,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        a,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF8E8E93),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: customController,
                style: TextStyle(
                  color: Theme.of(ctx).colorScheme.onSurface,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: 'Otras (separadas por coma)',
                  hintStyle: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: Theme.of(ctx).colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color(0xFF8E8E93)),
              ),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final u = auth.currentUser;
                if (u == null) return;
                final custom = customController.text
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toSet();
                final merged = {...u.allergies, ...selected, ...custom}.toList();
                await auth.updateInitialProfile(
                  allergies: merged,
                  preferences: u.preferences,
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF6F22),
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    customController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<AppSettingsProvider>();
    final order = context.watch<OrderProvider>();
    final flow = context.read<AppDemoProvider>();
    final user = auth.currentUser;

    return Column(
      children: [
        const _ProfileAppBar(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            children: [
              _AvatarSection(
                name: user?.fullName ?? '',
                email: user?.email ?? '',
              ),
              const SizedBox(height: 20),
              _AjustesCard(settings: settings),
              const SizedBox(height: 16),
              _BienestarCard(
                allergies: user?.allergies ?? const [],
                onRemove: (allergy) async {
                  final u = auth.currentUser;
                  if (u == null) return;
                  final newList = List<String>.from(u.allergies)
                    ..remove(allergy);
                  await auth.updateInitialProfile(
                    allergies: newList,
                    preferences: u.preferences,
                  );
                },
                onAdd: () => _showAddAllergyDialog(auth),
              ),
              const SizedBox(height: 16),
              _HistorialCard(
                order: order,
                showAll: _showAllHistory,
                onToggleAll: () =>
                    setState(() => _showAllHistory = !_showAllHistory),
              ),
              const SizedBox(height: 24),
              _LogoutButton(
                onLogout: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => const _LogoutDialog(),
                  );
                  if (confirmed != true) return;
                  if (!context.mounted) return;
                  await auth.logout();
                  if (!context.mounted) return;
                  order.clearDemoState();
                  flow.backToWelcome();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// App Bar
// ─────────────────────────────────────────

class _ProfileAppBar extends StatelessWidget {
  const _ProfileAppBar();

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

// ─────────────────────────────────────────
// Avatar + nombre + email
// ─────────────────────────────────────────

class _AvatarSection extends StatelessWidget {
  const _AvatarSection({required this.name, required this.email});

  final String name;
  final String email;

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || name.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF6F22), Color(0xFFFF8C42)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                _initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6F22),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          name.isNotEmpty ? name : 'Usuario',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: const TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Ajustes card (idioma + tema)
// ─────────────────────────────────────────

class _AjustesCard extends StatelessWidget {
  const _AjustesCard({required this.settings});

  final AppSettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings_rounded, color: Color(0xFFFF6F22), size: 20),
              const SizedBox(width: 10),
              Text(
                AppCopy.of(context).profileSettings,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                AppCopy.of(context).settingsLanguage,
                style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 14),
              ),
              const Spacer(),
              _TogglePill(
                options: const ['Español', 'English'],
                selectedIndex: settings.isSpanish ? 0 : 1,
                onTap: (i) => settings.updateLanguage(i == 0 ? 'es' : 'en'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Theme.of(context).dividerColor, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                AppCopy.of(context).profileTheme,
                style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 14),
              ),
              const Spacer(),
              _ThemeSelector(
                selected: settings.themeMode,
                onTap: settings.updateThemeMode,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TogglePill extends StatelessWidget {
  const _TogglePill({
    required this.options,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(options.length, (i) {
          final isSelected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFF6F22)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                options[i],
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF8E8E93),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({required this.selected, required this.onTap});

  final ThemeMode selected;
  final ValueChanged<ThemeMode> onTap;

  @override
  Widget build(BuildContext context) {
    const modes = [ThemeMode.dark, ThemeMode.light, ThemeMode.system];
    const icons = [
      Icons.dark_mode_rounded,
      Icons.light_mode_rounded,
      Icons.computer_rounded,
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(modes.length, (i) {
        final isSelected = selected == modes[i];
        return GestureDetector(
          onTap: () => onTap(modes[i]),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 36,
            height: 36,
            margin: EdgeInsets.only(left: i > 0 ? 8 : 0),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFFF6F22)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icons[i],
              color: isSelected ? Colors.white : const Color(0xFF8E8E93),
              size: 18,
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────
// Bienestar card (alergias)
// ─────────────────────────────────────────

class _BienestarCard extends StatelessWidget {
  const _BienestarCard({
    required this.allergies,
    required this.onRemove,
    required this.onAdd,
  });

  final List<String> allergies;
  final ValueChanged<String> onRemove;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.spa_rounded, color: Color(0xFF4CAF50), size: 20),
              const SizedBox(width: 10),
              Text(
                AppCopy.of(context).profileWellness,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            AppCopy.of(context).profileAllergiesLabel,
            style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...allergies.map(
                (a) => _AllergyChip(label: a, onRemove: () => onRemove(a)),
              ),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: const Color(0xFFFF6F22).withValues(alpha: 0.6),
                    ),
                  ),
                  child: Text(
                    AppCopy.of(context).profileAddAllergy,
                    style: const TextStyle(
                      color: Color(0xFFFF6F22),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
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

class _AllergyChip extends StatelessWidget {
  const _AllergyChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              size: 14,
              color: Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Historial de pedidos
// ─────────────────────────────────────────

class _HistorialCard extends StatelessWidget {
  const _HistorialCard({
    required this.order,
    required this.showAll,
    required this.onToggleAll,
  });

  final OrderProvider order;
  final bool showAll;
  final VoidCallback onToggleAll;

  List<MapEntry<Menu, int>> _deduped() {
    final items = order.orderedItems;
    final counts = <String, int>{};
    final menuMap = <String, Menu>{};
    for (final item in items) {
      counts.update(item.id, (v) => v + 1, ifAbsent: () => 1);
      menuMap[item.id] = item;
    }
    return counts.entries
        .map((e) => MapEntry(menuMap[e.key]!, e.value))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final all = _deduped();
    final visible = showAll ? all : all.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.history_rounded,
                color: Color(0xFFFF6F22),
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                AppCopy.of(context).historyTitle,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (all.length > 3)
                GestureDetector(
                  onTap: onToggleAll,
                  child: Text(
                    showAll ? 'Ver menos' : 'Ver todo ›',
                    style: const TextStyle(
                      color: Color(0xFFFF6F22),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          if (visible.isEmpty) ...[
            const SizedBox(height: 16),
            Text(
              AppCopy.of(context).profileNoOrders,
              style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
            ),
          ] else ...[
            const SizedBox(height: 14),
            ...visible.map(
              (entry) => _HistoryRow(
                menu: entry.key,
                quantity: entry.value,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.menu, required this.quantity});

  final Menu menu;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _HistoryItemImage(menu: menu),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quantity > 1 ? '${menu.name} ×$quantity' : menu.name,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  menu.category,
                  style: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatCop(menu.price * quantity),
            style: const TextStyle(
              color: Color(0xFFFF6F22),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Cerrar sesión
// ─────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: onLogout,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF3A1A1A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Color(0xFFFF4444), size: 20),
              SizedBox(width: 10),
              Text(
                'Cerrar Sesión',
                style: TextStyle(
                  color: Color(0xFFFF4444),
                  fontSize: 15,
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

class _LogoutDialog extends StatelessWidget {
  const _LogoutDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        '¿Cerrar sesión?',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: const Text(
        '¿Seguro que deseas cerrar sesión?',
        style: TextStyle(color: Color(0xFF8E8E93)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Color(0xFF8E8E93)),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFFF4444),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Cerrar sesión',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _HistoryItemImage extends StatelessWidget {
  const _HistoryItemImage({required this.menu});

  final Menu menu;

  @override
  Widget build(BuildContext context) {
    final url = menu.imageUrl.trim();
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          url,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const _HistoryImageFallback(),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        url.isNotEmpty ? url : 'lib/assets/images/background_bienvenida.png',
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _HistoryImageFallback(),
      ),
    );
  }
}

class _HistoryImageFallback extends StatelessWidget {
  const _HistoryImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      color: Theme.of(context).colorScheme.surface,
      child: const Icon(Icons.restaurant_rounded, color: Color(0xFFFF6F22), size: 24),
    );
  }
}

String _formatCop(double value) {
  final intVal = value.toInt();
  return '\$${intVal.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
}
