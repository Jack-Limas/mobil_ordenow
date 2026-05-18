import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/app_copy.dart';
import '../providers/app_settings_provider.dart';
import '../widgets/app_utility_toggles.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.onStart,
  });

  static const _backgroundImage =
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=1080&q=80';
  static const _featuredImages = [
    'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=400&q=80',
    'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&q=80',
    'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400&q=80',
  ];

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    final settings = context.watch<AppSettingsProvider>();
    final isDarkMode = settings.themeMode == ThemeMode.dark ||
        (settings.themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    final size = MediaQuery.sizeOf(context);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF171717);
    final subtleText =
        isDarkMode ? const Color(0xFFD8D5D2) : const Color(0xFF5E5752);
    final scrimColor =
        isDarkMode ? Colors.black : Colors.white.withValues(alpha: 0.84);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              _backgroundImage,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const ColoredBox(color: Color(0xFF121212));
              },
              errorBuilder: (_, __, ___) =>
                  const ColoredBox(color: Color(0xFF121212)),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    scrimColor.withValues(alpha: isDarkMode ? 0.20 : 0.62),
                    scrimColor.withValues(alpha: isDarkMode ? 0.50 : 0.78),
                    scrimColor.withValues(alpha: isDarkMode ? 0.94 : 0.96),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 42),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _BrandMark(
                                subtitle: copy.sensorySommelier,
                                textColor: textColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const AppUtilityToggles(),
                          ],
                        ),
                        SizedBox(height: constraints.maxHeight < 720 ? 120 : 210),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _Badge(text: copy.welcomeBadge),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: size.width > 700 ? 620 : double.infinity,
                            ),
                            child: Text(
                              copy.welcomeHeadline,
                              style: TextStyle(
                                color: textColor,
                                fontSize: size.width < 380 ? 42 : 50,
                                fontWeight: FontWeight.w900,
                                height: 1.02,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: size.width > 700 ? 560 : double.infinity,
                            ),
                            child: Text(
                              copy.welcomeDescription,
                              style: TextStyle(
                                color: subtleText,
                                fontSize: 16,
                                height: 1.45,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _StatusPanel(
                          title: copy.aiReady,
                          description: copy.welcomePill,
                          textColor: textColor,
                          subtleText: subtleText,
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(height: 22),
                        _DishStrip(images: _featuredImages),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(255, 111, 34, 0.34),
                                  blurRadius: 28,
                                  offset: Offset(0, 14),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: onStart,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6F22),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    copy.getStarted,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 22,
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
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({
    required this.subtitle,
    required this.textColor,
  });

  final String subtitle;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'OrdeNow',
          style: TextStyle(
            color: textColor,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFFFFB48E),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.1,
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E).withValues(alpha: 0.58),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color(0xFFFF6F22).withValues(alpha: 0.36),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFFFFB48E),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({
    required this.title,
    required this.description,
    required this.textColor,
    required this.subtleText,
    required this.isDarkMode,
  });

  final String title;
  final String description;
  final Color textColor;
  final Color subtleText;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode
                ? const Color(0xFF1C1C1E).withValues(alpha: 0.74)
                : Colors.white.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.10)
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6F22),
                  borderRadius: BorderRadius.circular(14),
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
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: subtleText,
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
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

class _DishStrip extends StatelessWidget {
  const _DishStrip({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return AspectRatio(
            aspectRatio: 1.38,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    images[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const ColoredBox(color: Color(0xFF1C1C1E));
                    },
                    errorBuilder: (_, __, ___) =>
                        const ColoredBox(color: Color(0xFF1C1C1E)),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.16),
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
