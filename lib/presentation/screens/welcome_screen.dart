import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_settings_provider.dart';
import '../widgets/welcome_metric.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const _backgroundImage =
      'lib/assets/images/background_bienvenida.png';
  static const _moonImage = 'lib/assets/images/moon_mode.png';

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final isDarkMode = settings.themeMode == ThemeMode.dark ||
        (settings.themeMode == ThemeMode.system &&
            View.of(context).platformDispatcher.platformBrightness ==
                Brightness.dark);

    return Scaffold(
      body: Container(
        color: const Color(0xFF131313),
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
                      const Color(0xFF131313),
                      const Color(0xFF131313).withValues(alpha: 0.40),
                      Colors.transparent,
                    ],
                    stops: const [0, 0.5, 1],
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
                      const Color(0xFF131313).withValues(alpha: 0.80),
                      Colors.transparent,
                      Colors.transparent,
                    ],
                    stops: const [0, 0.5, 1],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -116,
              top: 181,
              child: _BlurCircle(
                size: 384,
                color: const Color(0xFFFFB599).withValues(alpha: 0.10),
                blur: 120,
              ),
            ),
            Positioned(
              left: -96,
              bottom: 97,
              child: _BlurCircle(
                size: 256,
                color: const Color(0xFF7DDB7A).withValues(alpha: 0.05),
                blur: 100,
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.sizeOf(context).height - 64,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(child: _BrandBlock()),
                          const SizedBox(width: 16),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _LanguageToggle(
                                currentLanguageCode:
                                    settings.locale.languageCode,
                                onChanged: settings.updateLanguage,
                              ),
                              const SizedBox(width: 16),
                              _ThemeToggle(
                                isDarkMode: isDarkMode,
                                onPressed: () {
                                  settings.updateThemeMode(
                                    isDarkMode
                                        ? ThemeMode.light
                                        : ThemeMode.dark,
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Elevate\nYour Palate.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w400,
                          height: 1.25,
                          letterSpacing: -2.4,
                        ),
                      ),
                      const Text(
                        '\nAI-curated dining experiences tailored\n'
                        'to your unique sensory profile.\n'
                        'Welcome to the future of appetite.',
                        style: TextStyle(
                          color: Color(0xFFE4BEB1),
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          height: 1.625,
                        ),
                      ),
                      const SizedBox(height: 48),
                      Center(
                        child: Column(
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFFF5C00),
                                    Color(0xFF802A00),
                                  ],
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromRGBO(255, 92, 0, 0.25),
                                    blurRadius: 40,
                                  ),
                                ],
                              ),
                              child: InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(12),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 20,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Get Started',
                                        style: TextStyle(
                                          color: Color(0xFF521800),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          height: 1.55,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 16,
                                        color: Color(0xFF521800),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _OnlineDot(),
                                      SizedBox(width: 12),
                                      Text(
                                        'AI CONCIERGE ONLINE',
                                        style: TextStyle(
                                          color: Color(0xFF7DDB7A),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.4,
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
                      const SizedBox(height: 70),
                      const Row(
                        children: [
                          Expanded(
                            child: WelcomeMetric(
                              label: 'CURATED DISHES',
                              value: '12.4k+',
                            ),
                          ),
                          SizedBox(width: 32),
                          Expanded(
                            child: WelcomeMetric(
                              label: 'MICHELIN CHEFS',
                              value: '450+',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            3,
                            (index) => Padding(
                              padding: EdgeInsets.only(left: index == 0 ? 0 : 24),
                              child: Icon(
                                [
                                  Icons.camera_alt_outlined,
                                  Icons.music_note_outlined,
                                  Icons.play_circle_outline_rounded,
                                ][index],
                                size: 20,
                                color: const Color(0xFFE5E2E1)
                                    .withValues(alpha: 0.40),
                              ),
                            ),
                          ),
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
    );
  }
}

class _BrandBlock extends StatelessWidget {
  const _BrandBlock();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'OrdeNow',
          style: TextStyle(
            color: Color(0xFFFF5C00),
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.5,
            height: 1.2,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'SENSORY SOMMELIER',
          style: TextStyle(
            color: Color(0xCCFFB599),
            fontSize: 10,
            fontWeight: FontWeight.w400,
            letterSpacing: 3,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle({
    required this.currentLanguageCode,
    required this.onChanged,
  });

  final String currentLanguageCode;
  final Future<void> Function(String languageCode) onChanged;

  @override
  Widget build(BuildContext context) {
    return _GlassShell(
      padding: const EdgeInsets.all(4),
      borderRadius: 999,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LanguageChip(
            label: 'EN',
            selected: currentLanguageCode == 'en',
            onTap: () => onChanged('en'),
          ),
          _LanguageChip(
            label: 'ES',
            selected: currentLanguageCode == 'es',
            onTap: () => onChanged('es'),
          ),
        ],
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFF5C00) : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? const Color(0xFF521800)
                  : const Color(0xFFE5E2E1).withValues(alpha: 0.60),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.33,
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle({
    required this.isDarkMode,
    required this.onPressed,
  });

  final bool isDarkMode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _GlassShell(
      width: 40,
      height: 40,
      borderRadius: 999,
      child: IconButton(
        onPressed: onPressed,
        splashRadius: 20,
        padding: EdgeInsets.zero,
        icon: Opacity(
          opacity: isDarkMode ? 1 : 0.8,
          child: Image.asset(
            WelcomeScreen._moonImage,
            width: 18,
            height: 18,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _GlassShell extends StatelessWidget {
  const _GlassShell({
    this.child,
    this.padding,
    this.width,
    this.height,
    required this.borderRadius,
  });

  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0xFF353533).withValues(alpha: 0.40),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          child: child,
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
