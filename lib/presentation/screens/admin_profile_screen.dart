import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_settings_provider.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
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
              children: const [
                _IdentitySection(),
                SizedBox(height: 16),
                _HorariosCard(),
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
