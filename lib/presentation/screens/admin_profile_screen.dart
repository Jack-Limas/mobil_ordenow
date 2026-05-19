import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/datasources/local/hive_service.dart';
import '../providers/app_demo_provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final user = context.watch<AuthProvider>().currentUser;

    return Column(
      children: [
        _ProfileAppBar(settings: settings),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            children: [
              _IdentityCard(
                name: user?.fullName.isNotEmpty == true
                    ? user!.fullName
                    : 'Administrador',
                email: user?.email ?? 'admin@ordenow.com',
              ),
              const SizedBox(height: 16),
              _LanguageCard(settings: settings),
              const SizedBox(height: 16),
              _AppearanceCard(settings: settings),
              const SizedBox(height: 24),
              const _LogoutButton(),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileAppBar extends StatelessWidget {
  const _ProfileAppBar({required this.settings});

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

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.name, required this.email});

  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF2C2C2E),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Color(0xFFFF6F22),
              size: 38,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF1A3A1A),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF4CAF50)),
            ),
            child: const Text(
              'ADMINISTRADOR',
              style: TextStyle(
                color: Color(0xFF4CAF50),
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({required this.settings});

  final AppSettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(icon: Icons.translate_rounded, label: 'Idioma'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _OptionButton(
                  label: 'Español',
                  selected: settings.isSpanish,
                  onTap: () => settings.updateLanguage('es'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _OptionButton(
                  label: 'English',
                  selected: !settings.isSpanish,
                  onTap: () => settings.updateLanguage('en'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard({required this.settings});

  final AppSettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(icon: Icons.palette_rounded, label: 'Apariencia'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _OptionButton(
                  label: 'Oscuro',
                  selected: settings.themeMode == ThemeMode.dark,
                  onTap: () => settings.updateThemeMode(ThemeMode.dark),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _OptionButton(
                  label: 'Claro',
                  selected: settings.themeMode == ThemeMode.light,
                  onTap: () => settings.updateThemeMode(ThemeMode.light),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _OptionButton(
                  label: 'Sistema',
                  selected: settings.themeMode == ThemeMode.system,
                  onTap: () => settings.updateThemeMode(ThemeMode.system),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF6F22), size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF6F22) : const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: const Color(0xFF3A1A1A),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _confirmLogout(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'Cerrar sesion',
                style: TextStyle(
                  color: Color(0xFFFF4444),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text(
          'Cerrar sesion',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tendras que iniciar sesion nuevamente.',
          style: TextStyle(color: Color(0xFF8E8E93)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Cerrar sesion',
              style: TextStyle(color: Color(0xFFFF4444)),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final auth = context.read<AuthProvider>();
    final order = context.read<OrderProvider>();
    final flow = context.read<AppDemoProvider>();

    await auth.logout();
    await HiveService.getUserBox().clear();
    if (!context.mounted) return;
    order.clearDemoState();
    flow.backToWelcome();
  }
}
