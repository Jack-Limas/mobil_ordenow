import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_demo_provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final auth = context.read<AuthProvider>();
    final flow = context.read<AppDemoProvider>();
    final order = context.read<OrderProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: [
            const _SectionLabel('ADMINISTRADOR'),
            const SizedBox(height: 8),
            const Text(
              'Perfil y\nconfiguracion',
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 24),
            const _AdminAvatarCard(),
            const SizedBox(height: 18),
            _RestaurantCard(settings: settings),
            const SizedBox(height: 18),
            _SystemPreferencesCard(settings: settings),
            const SizedBox(height: 18),
            const _StaffCard(),
            const SizedBox(height: 18),
            const _SupportCard(),
            const SizedBox(height: 28),
            _SessionSection(
              onLogout: () async {
                await auth.logout();
                if (!context.mounted) return;
                order.clearDemoState();
                flow.backToWelcome();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFFF6F22),
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.6,
      ),
    );
  }
}

class _AdminAvatarCard extends StatelessWidget {
  const _AdminAvatarCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1C1C1E)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6F22), Color(0xFFE53E00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: const Text(
              'A',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin OrdeNow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'admin@ordenow.com',
                  style: TextStyle(
                    color: Color(0xFF636366),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 6),
                _RoleBadge(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6F22).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'SUPER ADMIN',
        style: TextStyle(
          color: Color(0xFFFF6F22),
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({required this.settings});

  final AppSettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1C1C1E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Datos del restaurante',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: const Icon(
                  Icons.edit_outlined,
                  color: Color(0xFF636366),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _DataRow(
            label: 'NOMBRE',
            value: 'OrdeNow Restaurant',
          ),
          _DataRow(
            label: settings.isSpanish ? 'CIUDAD' : 'CITY',
            value: 'Bogotá, Colombia',
          ),
          _DataRow(
            label: 'NIT',
            value: '900.123.456-7',
          ),
          _DataRow(
            label: settings.isSpanish ? 'MESAS ACTIVAS' : 'ACTIVE TABLES',
            value: '8',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF636366),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 10),
          const Divider(color: Color(0xFF1C1C1E), height: 1),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _SystemPreferencesCard extends StatelessWidget {
  const _SystemPreferencesCard({required this.settings});

  final AppSettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1C1C1E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            settings.isSpanish ? 'Preferencias del sistema' : 'System preferences',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _PrefTile(
            icon: Icons.dark_mode_outlined,
            label: settings.isSpanish ? 'Tema oscuro' : 'Dark theme',
            accent: const Color(0xFF8B5CF6),
            trailing: Switch(
              value: settings.themeMode == ThemeMode.dark,
              onChanged: (v) =>
                  settings.updateThemeMode(v ? ThemeMode.dark : ThemeMode.light),
              activeTrackColor: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
              activeColor: const Color(0xFF8B5CF6),
            ),
          ),
          const SizedBox(height: 10),
          _PrefTile(
            icon: Icons.language_rounded,
            label: settings.isSpanish ? 'Idioma' : 'Language',
            accent: const Color(0xFF5E9FFF),
            trailing: GestureDetector(
              onTap: settings.toggleLanguage,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF5E9FFF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  settings.isSpanish ? 'ES' : 'EN',
                  style: const TextStyle(
                    color: Color(0xFF5E9FFF),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _PrefTile(
            icon: Icons.insights_outlined,
            label: 'AI Insights',
            accent: const Color(0xFF62D26F),
            trailing: Switch(
              value: true,
              onChanged: (_) {},
              activeTrackColor: const Color(0xFF62D26F).withValues(alpha: 0.3),
              activeColor: const Color(0xFF62D26F),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrefTile extends StatelessWidget {
  const _PrefTile({
    required this.icon,
    required this.label,
    required this.accent,
    required this.trailing,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1C1C1E)),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  const _StaffCard();

  static const _staff = [
    _StaffMember('Marco Rossi', 'CHEF EJECUTIVO', true),
    _StaffMember('Elena Vance', 'GERENTE GENERAL', true),
    _StaffMember('Simon Wright', 'SUPERVISOR DE PISO', true),
    _StaffMember('Clara J.', 'ASISTENTE SOMMELIER', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1C1C1E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Personal activo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1C1C1E),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text(
                  'Agregar',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._staff.map(
            (member) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C1E),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          member.name[0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: member.online
                                ? const Color(0xFF62D26F)
                                : const Color(0xFF48484A),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF141414),
                              width: 1.5,
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
                          member.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          member.role,
                          style: const TextStyle(
                            color: Color(0xFF636366),
                            fontSize: 11,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffMember {
  const _StaffMember(this.name, this.role, this.online);

  final String name;
  final String role;
  final bool online;
}

class _SupportCard extends StatelessWidget {
  const _SupportCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1C1C1E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Soporte',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          _SupportItem(
            icon: Icons.menu_book_rounded,
            label: 'Base de conocimiento',
            onTap: () {},
          ),
          const Divider(color: Color(0xFF1C1C1E), height: 20),
          _SupportItem(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Chat directo',
            onTap: () {},
          ),
          const Divider(color: Color(0xFF1C1C1E), height: 20),
          _SupportItem(
            icon: Icons.code_rounded,
            label: 'Documentación API',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _SupportItem extends StatelessWidget {
  const _SupportItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF636366), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFD2C0B7),
                fontSize: 15,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF3A3A3C),
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _SessionSection extends StatelessWidget {
  const _SessionSection({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SESIÓN',
          style: TextStyle(
            color: Color(0xFF636366),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onLogout,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red, width: 1),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text(
              'Cerrar sesión',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
