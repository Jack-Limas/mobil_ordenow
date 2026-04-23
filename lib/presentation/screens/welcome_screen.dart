import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/app_copy.dart';
import '../providers/app_settings_provider.dart';
import '../widgets/app_utility_toggles.dart';
import '../widgets/welcome_metric.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.onCustomerDemo,
    required this.onAdminDemo,
  });

  static const _backgroundImage =
      'lib/assets/images/background_bienvenida.png';

  final VoidCallback onCustomerDemo;
  final VoidCallback onAdminDemo;

  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    final settings = context.watch<AppSettingsProvider>();
    final isDarkMode = settings.themeMode == ThemeMode.dark ||
        (settings.themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    final baseBackground =
        isDarkMode ? const Color(0xFF11100F) : const Color(0xFFF8EEE6);
    final primaryText = isDarkMode ? Colors.white : const Color(0xFF241A15);
    final secondaryText =
        isDarkMode ? const Color(0xFFE4BEB1) : const Color(0xFF7A5B4E);

    return Scaffold(
      body: Container(
        color: baseBackground,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                _backgroundImage,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      baseBackground,
                      baseBackground.withValues(alpha: 0.44),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      baseBackground.withValues(alpha: 0.86),
                      baseBackground.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -120,
              top: 190,
              child: _BlurCircle(
                size: 340,
                color: const Color(0xFFFF924F).withValues(alpha: 0.14),
                blur: 120,
              ),
            ),
            Positioned(
              left: -90,
              bottom: 90,
              child: _BlurCircle(
                size: 240,
                color: const Color(0xFF7DDB7A).withValues(alpha: 0.06),
                blur: 100,
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.sizeOf(context).height - 56,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(child: _BrandBlock()),
                          const SizedBox(width: 16),
                          const AppUtilityToggles(),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _TagBadge(
                        text: copy.welcomeBadge,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 22),
                      Text(
                        copy.welcomeHeadline,
                        style: TextStyle(
                          color: primaryText,
                          fontSize: 50,
                          fontWeight: FontWeight.w400,
                          height: 1.05,
                          letterSpacing: -2.6,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        copy.welcomeDescription,
                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.white.withValues(alpha: 0.76),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.06)
                                : const Color(0xFFD8B8A8).withValues(alpha: 0.45),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B00),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    copy.aiReady,
                                    style: TextStyle(
                                      color: primaryText,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    copy.welcomePill,
                                    style: TextStyle(
                                      color: secondaryText,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 34),
                      Center(
                        child: Column(
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFFF7B1A),
                                    Color(0xFFFF5C00),
                                  ],
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromRGBO(255, 92, 0, 0.28),
                                    blurRadius: 34,
                                  ),
                                ],
                              ),
                              child: InkWell(
                                onTap: onCustomerDemo,
                                borderRadius: BorderRadius.circular(18),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 18,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        copy.getStarted,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: onAdminDemo,
                              icon: const Icon(Icons.dashboard_customize_rounded),
                              label: Text(copy.openAdminDemo),
                            ),
                            const SizedBox(height: 24),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2A2A2A)
                                        .withValues(alpha: 0.60),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: const Color(0xFF5B4137)
                                          .withValues(alpha: 0.15),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const _OnlineDot(),
                                      const SizedBox(width: 12),
                                      Text(
                                        copy.aiConciergeOnline,
                                        style: const TextStyle(
                                          color: Color(0xFF7DDB7A),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.3,
                                          height: 1.42,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 56),
                      Row(
                        children: [
                          Expanded(
                            child: WelcomeMetric(
                              label: copy.curatedDishes,
                              value: '12.4k+',
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: WelcomeMetric(
                              label: copy.michelinChefs,
                              value: '450+',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandBlock extends StatelessWidget {
  const _BrandBlock();

  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          copy.appName,
          style: const TextStyle(
            color: Color(0xFFFF6B00),
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          copy.sensorySommelier,
          style: const TextStyle(
            color: Color(0xCCFFB599),
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 3,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _TagBadge extends StatelessWidget {
  const _TagBadge({
    required this.text,
    required this.isDarkMode,
  });

  final String text;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B00).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFFFFA274).withValues(alpha: 0.22),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isDarkMode ? const Color(0xFFFFC3A3) : const Color(0xFF8E4A28),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  const _BlurCircle({
    required this.size,
    required this.color,
    required this.blur,
  });

  final double size;
  final Color color;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blur / 2, sigmaY: blur / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}

class _OnlineDot extends StatelessWidget {
  const _OnlineDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Color(0xFF7DDB7A),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0xFF7DDB7A),
            blurRadius: 10,
          ),
        ],
      ),
    );
  }
}