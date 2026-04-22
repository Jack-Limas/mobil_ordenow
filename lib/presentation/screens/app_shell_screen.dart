import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/constants.dart';
import '../providers/app_settings_provider.dart';
import '../widgets/feature_highlight_card.dart';

class AppShellScreen extends StatelessWidget {
  const AppShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsProvider = context.watch<AppSettingsProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.appName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.appTagline,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Base lista para construir autenticacion, menu, chat IA y pedidos.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Configuracion inicial',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tema de la app',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: Text('Sistema'),
                            icon: Icon(Icons.phone_iphone_rounded),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            label: Text('Claro'),
                            icon: Icon(Icons.light_mode_rounded),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text('Oscuro'),
                            icon: Icon(Icons.dark_mode_rounded),
                          ),
                        ],
                        selected: {settingsProvider.themeMode},
                        onSelectionChanged: (selection) {
                          settingsProvider.updateThemeMode(selection.first);
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Idioma base',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'es',
                            label: Text('ES'),
                            icon: Icon(Icons.language_rounded),
                          ),
                          ButtonSegment(
                            value: 'en',
                            label: Text('EN'),
                            icon: Icon(Icons.translate_rounded),
                          ),
                        ],
                        selected: {settingsProvider.locale.languageCode},
                        onSelectionChanged: (selection) {
                          settingsProvider.updateLanguage(selection.first);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Modulos planeados',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              const FeatureHighlightCard(
                icon: Icons.smart_toy_rounded,
                title: 'Chat IA y voz',
                description:
                    'Base visual lista para integrar texto, voz y respuestas simuladas.',
              ),
              const SizedBox(height: 12),
              const FeatureHighlightCard(
                icon: Icons.receipt_long_rounded,
                title: 'Pedidos y pagos',
                description:
                    'Se preparara flujo completo de carrito, ordenes y pagos en COP.',
              ),
              const SizedBox(height: 12),
              const FeatureHighlightCard(
                icon: Icons.restaurant_rounded,
                title: 'Panel admin y cocina',
                description:
                    'La arquitectura ya queda separada para cliente, administrador y KDS.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
