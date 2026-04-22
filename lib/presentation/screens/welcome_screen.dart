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
    final isDarkMode = settings.themeMode == ThemeMode.dark;
    final baseBackground =
        isDarkMode ? const Color(0xFF131313) : const Color(0xFFF4E8E0);
    final primaryText = isDarkMode ? Colors.white : const Color(0xFF241A15);
    final secondaryText =
        isDarkMode ? const Color(0xFFE4BEB1) : const Color(0xFF6D5247);

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
                      baseBackground.withValues(alpha: 0.40),
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
                      baseBackground.withValues(alpha: 0.80),
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
                          const AppUtilityToggles(),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Text(
                        copy.welcomeHeadline,
                        style: TextStyle(
                          color: primaryText,
                          fontSize: 48,
                          fontWeight: FontWeight.w400,
                          height: 1.25,
                          letterSpacing: -2.4,
                        ),
                      ),
                      Text(
                        '\n${copy.welcomeDescription}',
                        style: TextStyle(
                          color: secondaryText,
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
                                onTap: onCustomerDemo,
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
                                        copy.getStarted,
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
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _OnlineDot(),
                                      SizedBox(width: 12),
                                      Text(
                                        copy.aiConciergeOnline,
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
                              label: copy.curatedDishes,
                              value: '12.4k+',
                            ),
                          ),
                          SizedBox(width: 32),
                          Expanded(
                            child: WelcomeMetric(
                              label: copy.michelinChefs,
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
    final copy = AppCopy.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          copy.appName,
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
          copy.sensorySommelier,
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
