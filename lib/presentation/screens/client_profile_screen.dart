import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/app_copy.dart';
import '../providers/app_demo_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/app_utility_toggles.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  final _nameController = TextEditingController();
  final _allergiesController = TextEditingController();
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _nameController.text = user.fullName;
      _allergiesController.text = user.allergies.join(', ');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile(BuildContext context) async {
    setState(() => _isSaving = true);
    final auth = context.read<AuthProvider>();
    final allergiesList = _allergiesController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    await auth.updateInitialProfile(
      fullName: _nameController.text.trim(),
      allergies: allergiesList,
    );
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final order = context.watch<OrderProvider>();
    final flow = context.read<AppDemoProvider>();
    final copy = AppCopy.of(context);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF171717);
    final surfaceColor =
        isDarkMode ? const Color(0xFF1C1C1E) : const Color(0xFFF4F4F5);
    final mutedColor =
        isDarkMode ? const Color(0xFFC9C2BE) : const Color(0xFF625B56);

    final user = auth.currentUser;

    return Scaffold(
      body: Container(
        color: backgroundColor,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PERFIL',
                            style: TextStyle(
                              color: Color(0xFFFFB48E),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.6,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            copy.isSpanish ? 'Tu cuenta' : 'Your account',
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
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
                  children: [
                    _AvatarHeader(
                      name: user?.fullName ?? '',
                      email: user?.email ?? '',
                      textColor: textColor,
                      mutedColor: mutedColor,
                    ),
                    const SizedBox(height: 24),
                    if (_isEditing) ...[
                      _EditProfileCard(
                        nameController: _nameController,
                        allergiesController: _allergiesController,
                        textColor: textColor,
                        surfaceColor: surfaceColor,
                        copy: copy,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                final u = auth.currentUser;
                                if (u != null) {
                                  _nameController.text = u.fullName;
                                  _allergiesController.text =
                                      u.allergies.join(', ');
                                }
                                setState(() => _isEditing = false);
                              },
                              child: Text(
                                copy.isSpanish ? 'Cancelar' : 'Cancel',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed:
                                  _isSaving ? null : () => _saveProfile(context),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6F22),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      copy.isSpanish ? 'Guardar' : 'Save',
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      _InfoCard(
                        title: copy.isSpanish ? 'Información' : 'Information',
                        items: [
                          _InfoItem(
                            icon: Icons.person_rounded,
                            label: copy.isSpanish ? 'Nombre' : 'Name',
                            value: user?.fullName.isNotEmpty == true
                                ? user!.fullName
                                : '—',
                          ),
                          _InfoItem(
                            icon: Icons.email_rounded,
                            label: copy.isSpanish
                                ? 'Correo electrónico'
                                : 'Email',
                            value: user?.email ?? '—',
                          ),
                        ],
                        textColor: textColor,
                        surfaceColor: surfaceColor,
                        mutedColor: mutedColor,
                      ),
                      const SizedBox(height: 16),
                      _AllergiesCard(
                        allergies: user?.allergies ?? const [],
                        textColor: textColor,
                        surfaceColor: surfaceColor,
                        mutedColor: mutedColor,
                        copy: copy,
                      ),
                      const SizedBox(height: 16),
                      _StatsCard(
                        orderedCount: order.orderedItems.length,
                        tableNumber: order.selectedTable?.number,
                        textColor: textColor,
                        surfaceColor: surfaceColor,
                        mutedColor: mutedColor,
                        copy: copy,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              setState(() => _isEditing = true),
                          icon: const Icon(Icons.edit_rounded),
                          label: Text(
                            copy.isSpanish
                                ? 'Editar perfil'
                                : 'Edit profile',
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    _DangerZone(
                      copy: copy,
                      mutedColor: mutedColor,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarHeader extends StatelessWidget {
  const _AvatarHeader({
    required this.name,
    required this.email,
    required this.textColor,
    required this.mutedColor,
  });

  final String name;
  final String email;
  final Color textColor;
  final Color mutedColor;

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || name.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6F22), Color(0xFFFF8C42)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: Text(
            _initials,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isNotEmpty ? name : 'Guest',
                style: TextStyle(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.items,
    required this.textColor,
    required this.surfaceColor,
    required this.mutedColor,
  });

  final String title;
  final List<_InfoItem> items;
  final Color textColor;
  final Color surfaceColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(item.icon, color: const Color(0xFFFF6F22), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          style: TextStyle(
                            color: mutedColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          item.value,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
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

class _InfoItem {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _AllergiesCard extends StatelessWidget {
  const _AllergiesCard({
    required this.allergies,
    required this.textColor,
    required this.surfaceColor,
    required this.mutedColor,
    required this.copy,
  });

  final List<String> allergies;
  final Color textColor;
  final Color surfaceColor;
  final Color mutedColor;
  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.no_meals_rounded,
                color: Color(0xFFFF6F22),
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                copy.isSpanish ? 'Alergias y restricciones' : 'Allergies & restrictions',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (allergies.isEmpty)
            Text(
              copy.isSpanish
                  ? 'Sin alergias registradas.'
                  : 'No allergies registered.',
              style: TextStyle(color: mutedColor),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allergies
                  .map(
                    (a) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6F22).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        a,
                        style: const TextStyle(
                          color: Color(0xFFFF6F22),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.orderedCount,
    required this.tableNumber,
    required this.textColor,
    required this.surfaceColor,
    required this.mutedColor,
    required this.copy,
  });

  final int orderedCount;
  final int? tableNumber;
  final Color textColor;
  final Color surfaceColor;
  final Color mutedColor;
  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatTile(
              icon: Icons.restaurant_rounded,
              value: '$orderedCount',
              label: copy.isSpanish ? 'Platos pedidos' : 'Dishes ordered',
              textColor: textColor,
              mutedColor: mutedColor,
            ),
          ),
          Container(width: 1, height: 48, color: mutedColor.withValues(alpha: 0.2)),
          Expanded(
            child: _StatTile(
              icon: Icons.table_restaurant_rounded,
              value: tableNumber != null ? '#$tableNumber' : '—',
              label: copy.isSpanish ? 'Mesa actual' : 'Current table',
              textColor: textColor,
              mutedColor: mutedColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.textColor,
    required this.mutedColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFFF6F22), size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: mutedColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _EditProfileCard extends StatelessWidget {
  const _EditProfileCard({
    required this.nameController,
    required this.allergiesController,
    required this.textColor,
    required this.surfaceColor,
    required this.copy,
  });

  final TextEditingController nameController;
  final TextEditingController allergiesController;
  final Color textColor;
  final Color surfaceColor;
  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            copy.isSpanish ? 'Editar perfil' : 'Edit profile',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: copy.fullName,
              prefixIcon: const Icon(Icons.person_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: allergiesController,
            decoration: InputDecoration(
              labelText: copy.allergiesPreferences,
              hintText: copy.allergiesHint,
              prefixIcon: const Icon(Icons.no_meals_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _DangerZone extends StatelessWidget {
  const _DangerZone({
    required this.copy,
    required this.mutedColor,
    required this.onLogout,
  });

  final AppCopy copy;
  final Color mutedColor;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          copy.isSpanish ? 'Sesión' : 'Session',
          style: TextStyle(
            color: mutedColor,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
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
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: Text(
              copy.isSpanish ? 'Cerrar sesión' : 'Sign out',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
