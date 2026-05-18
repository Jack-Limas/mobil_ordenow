import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/datasources/local/hive_service.dart';
import '../providers/app_demo_provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  bool _aiGrouping = true;
  bool _visualAlerts = true;
  String _timezone = 'GMT-5 (Ciudad de México)';

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();

    return Column(
      children: [
        _ProfileAppBar(settings: settings),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _IdentitySection(),
                const SizedBox(height: 16),
                const _HorariosCard(),
                const SizedBox(height: 16),
                _KdsSettingsCard(
                  aiGrouping: _aiGrouping,
                  visualAlerts: _visualAlerts,
                  onAiGroupingChanged: (v) => setState(() => _aiGrouping = v),
                  onVisualAlertsChanged: (v) => setState(() => _visualAlerts = v),
                ),
                const SizedBox(height: 16),
                _LocalizacionCard(settings: settings, timezone: _timezone, onTimezoneChanged: (v) => setState(() => _timezone = v!)),
                const SizedBox(height: 16),
                _AparienciaCard(settings: settings),
                const SizedBox(height: 24),
                const _SecuritySection(),
                const SizedBox(height: 12),
                const _LogoutButton(),
              ],
            ),
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
            child: const Icon(Icons.restaurant_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Text(
            'OrdeNow',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          const Icon(Icons.notifications_outlined, color: Color(0xFF8E8E93), size: 22),
          const SizedBox(width: 14),
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
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdentitySection extends StatelessWidget {
  const _IdentitySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1C1C1E),
                  ),
                  child: const Icon(Icons.store_rounded, color: Color(0xFF8E8E93), size: 40),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  _Badge('VERIFICADO', Color(0xFF4CAF50), Color(0xFF1A3A1A)),
                  SizedBox(width: 6),
                  _Badge('IA JEFE', Color(0xFFFF6F22), Color(0xFF2A1A00)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Mesa Fusion & Grill',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        const Text(
          '📍 Polanco, CDMX, ID-0942',
          style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF6F22),
                side: const BorderSide(color: Color(0xFFFF6F22)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Editar Perfil'),
            ),
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF8E8E93),
                side: const BorderSide(color: Color(0xFF3A3A3C)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('⋯', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label, this.color, this.bg);

  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5),
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

class _HorariosCard extends StatelessWidget {
  const _HorariosCard();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time_rounded, color: Color(0xFFFF6F22), size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Horarios',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Icon(Icons.edit_rounded, color: Color(0xFF8E8E93), size: 18),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _HorarioRow('Lun - Vie', '08:00 - 23:00', false),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Color(0xFF2C2C2E), height: 1),
          ),
          const _HorarioRow('Sábados', '10:00 - 21:00', false),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Color(0xFF2C2C2E), height: 1),
          ),
          const _HorarioRow('Domingos', 'Cerrado', true),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF6F22),
                side: const BorderSide(color: Color(0xFFFF6F22)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Gestionar Calendario ›'),
            ),
          ),
        ],
      ),
    );
  }
}

class _HorarioRow extends StatelessWidget {
  const _HorarioRow(this.day, this.hours, this.isClosed);

  final String day;
  final String hours;
  final bool isClosed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(day, style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 14)),
        ),
        Text(
          hours,
          style: TextStyle(
            color: isClosed ? const Color(0xFFFF4444) : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _KdsSettingsCard extends StatelessWidget {
  const _KdsSettingsCard({
    required this.aiGrouping,
    required this.visualAlerts,
    required this.onAiGroupingChanged,
    required this.onVisualAlertsChanged,
  });

  final bool aiGrouping;
  final bool visualAlerts;
  final ValueChanged<bool> onAiGroupingChanged;
  final ValueChanged<bool> onVisualAlertsChanged;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(icon: Icons.settings_rounded, label: 'Ajustes KDS'),
          const SizedBox(height: 6),
          const Text(
            'Configuración avanzada para estaciones de cocina y despacho',
            style: TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
          ),
          const SizedBox(height: 16),
          _KdsToggle(
            label: 'Agrupación IA',
            sublabel: 'Por estación de cocina',
            value: aiGrouping,
            onChanged: onAiGroupingChanged,
          ),
          const SizedBox(height: 12),
          _KdsToggle(
            label: 'Alertas Visuales',
            sublabel: 'Modo alta prioridad',
            value: visualAlerts,
            onChanged: onVisualAlertsChanged,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF6F22),
                side: const BorderSide(color: Color(0xFFFF6F22)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Configurar Terminales ›'),
            ),
          ),
        ],
      ),
    );
  }
}

class _KdsToggle extends StatelessWidget {
  const _KdsToggle({
    required this.label,
    required this.sublabel,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String sublabel;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              Text(sublabel, style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: const Color(0xFFFF6F22),
          activeTrackColor: const Color(0xFFFF6F22).withValues(alpha: 0.3),
        ),
      ],
    );
  }
}

class _LocalizacionCard extends StatelessWidget {
  const _LocalizacionCard({
    required this.settings,
    required this.timezone,
    required this.onTimezoneChanged,
  });

  final AppSettingsProvider settings;
  final String timezone;
  final ValueChanged<String?> onTimezoneChanged;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(icon: Icons.language_rounded, label: 'Localización'),
          const SizedBox(height: 16),
          _DropdownRow(
            label: 'Idioma del Sistema',
            value: settings.isSpanish ? 'Español (Latinoamérica)' : 'English (US)',
            items: const ['Español (Latinoamérica)', 'English (US)'],
            onChanged: (v) {
              if (v == 'Español (Latinoamérica)') {
                settings.updateLanguage('es');
              } else {
                settings.updateLanguage('en');
              }
            },
          ),
          const SizedBox(height: 12),
          _DropdownRow(
            label: 'Zona Horaria',
            value: timezone,
            items: const ['GMT-5 (Ciudad de México)', 'GMT-3 (Buenos Aires)', 'GMT-5 (Bogotá)', 'GMT+0 (Londres)'],
            onChanged: onTimezoneChanged,
          ),
        ],
      ),
    );
  }
}

class _DropdownRow extends StatelessWidget {
  const _DropdownRow({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF2C2C2E),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF8E8E93)),
              items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _AparienciaCard extends StatelessWidget {
  const _AparienciaCard({required this.settings});

  final AppSettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(icon: Icons.palette_rounded, label: 'Apariencia'),
          const SizedBox(height: 16),
          Row(
            children: [
              _ThemeButton(
                icon: Icons.dark_mode_rounded,
                label: 'Oscuro',
                isActive: settings.themeMode == ThemeMode.dark,
                onTap: () => settings.updateThemeMode(ThemeMode.dark),
              ),
              const SizedBox(width: 8),
              _ThemeButton(
                icon: Icons.light_mode_rounded,
                label: 'Claro',
                isActive: settings.themeMode == ThemeMode.light,
                onTap: () => settings.updateThemeMode(ThemeMode.light),
              ),
              const SizedBox(width: 8),
              _ThemeButton(
                icon: Icons.laptop_rounded,
                label: 'Sistema',
                isActive: settings.themeMode == ThemeMode.system,
                onTap: () => settings.updateThemeMode(ThemeMode.system),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  const _ThemeButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFFF6F22) : const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecuritySection extends StatelessWidget {
  const _SecuritySection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SEGURIDAD DE LA CUENTA',
          style: TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Última conexión: Hoy 16:30 - CDMX, MX',
          style: TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
        ),
      ],
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
                'Cerrar Sesión',
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
        title: const Text('¿Cerrar sesión?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Se cerrará la sesión actual. Tendrás que iniciar sesión nuevamente.',
          style: TextStyle(color: Color(0xFF8E8E93)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF8E8E93))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Color(0xFFFF4444), fontWeight: FontWeight.w700),
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
