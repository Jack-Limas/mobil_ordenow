import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/app_copy.dart';
import '../providers/app_settings_provider.dart';

class AppUtilityToggles extends StatelessWidget {
  const AppUtilityToggles({super.key});

  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    final settings = context.watch<AppSettingsProvider>();
    final activeThemeLabel = switch (settings.themeMode) {
      ThemeMode.dark => copy.themeDark,
      ThemeMode.light => copy.themeLight,
      ThemeMode.system => copy.themeSystem,
    };
    final activeThemeIcon = switch (settings.themeMode) {
      ThemeMode.dark => Icons.dark_mode_rounded,
      ThemeMode.light => Icons.light_mode_rounded,
      ThemeMode.system => Icons.brightness_auto_rounded,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GlassButton(
          onTap: () {
            settings.toggleLanguage();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.language_rounded,
                size: 14,
                color: Color(0xFFE5E2E1),
              ),
              const SizedBox(width: 8),
              Text(
                settings.isSpanish ? 'ES / EN' : 'EN / ES',
                style: const TextStyle(
                  color: Color(0xFFE5E2E1),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _GlassButton(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          onTap: () {
            settings.cycleThemeMode();
          },
          child: Tooltip(
            message: copy.switchTheme,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  activeThemeIcon,
                  size: 15,
                  color: const Color(0xFFE5E2E1),
                ),
                const SizedBox(width: 8),
                Text(
                  activeThemeLabel,
                  style: const TextStyle(
                    color: Color(0xFFE5E2E1),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.child,
    required this.onTap,
    this.width,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  });

  final Widget child;
  final VoidCallback onTap;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: const Color(0xFF1C1B1B).withValues(alpha: 0.40),
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: width,
              height: height,
              padding: padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: const Color(0xFFFFFFFF).withValues(alpha: 0.08),
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
