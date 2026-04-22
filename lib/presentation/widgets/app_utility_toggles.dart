import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/app_copy.dart';
import '../../presentation/providers/app_settings_provider.dart';

class AppUtilityToggles extends StatelessWidget {
  const AppUtilityToggles({super.key});

  static const _moonImage = 'lib/assets/images/moon_mode.png';

  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    final settings = context.watch<AppSettingsProvider>();
    final isDarkMode = settings.themeMode == ThemeMode.dark ||
        (settings.themeMode == ThemeMode.system &&
            View.of(context).platformDispatcher.platformBrightness ==
                Brightness.dark);

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
          width: 40,
          height: 40,
          padding: EdgeInsets.zero,
          onTap: () {
            settings.updateThemeMode(
              isDarkMode ? ThemeMode.light : ThemeMode.dark,
            );
          },
          child: Center(
            child: isDarkMode
                ? Tooltip(
                    message: copy.switchTheme,
                    child: const Icon(
                      Icons.dark_mode_rounded,
                      size: 16,
                      color: Color(0xFFE5E2E1),
                    ),
                  )
                : Tooltip(
                    message: copy.switchTheme,
                    child: Image.asset(
                      _moonImage,
                      width: 16,
                      height: 16,
                      fit: BoxFit.contain,
                    ),
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
