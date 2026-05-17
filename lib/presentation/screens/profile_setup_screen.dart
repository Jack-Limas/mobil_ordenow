import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/app_copy.dart';
import '../providers/app_demo_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_utility_toggles.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  static const _commonAllergies = [
    'Mani',
    'Mariscos',
    'Gluten',
    'Lactosa',
    'Huevo',
    'Soya',
  ];

  final TextEditingController _otherAllergiesController =
      TextEditingController();
  final TextEditingController _preferencesController = TextEditingController();
  final Set<String> _selectedAllergies = {};
  bool _hasAllergies = false;

  @override
  void dispose() {
    _otherAllergiesController.dispose();
    _preferencesController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile({bool skip = false}) async {
    final copy = AppCopy.of(context);
    final auth = context.read<AuthProvider>();
    final flow = context.read<AppDemoProvider>();
    final allergies = skip || !_hasAllergies
        ? <String>[]
        : [
            ..._selectedAllergies,
            ..._splitValues(_otherAllergiesController.text),
          ];
    final preferences =
        skip ? <String>[] : _splitValues(_preferencesController.text);

    final success = await auth.updateInitialProfile(
      allergies: allergies,
      preferences: preferences,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(copy.profileSaved)),
      );
      flow.openCustomerArea();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(auth.errorMessage ?? copy.unableToSaveProfile),
      ),
    );
  }

  List<String> _splitValues(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
    final panelColor = isDarkMode
        ? const Color(0xFF1C1C1E).withValues(alpha: 0.82)
        : Colors.white.withValues(alpha: 0.88);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF171717);
    final mutedColor =
        isDarkMode ? const Color(0xFFD7D3D0) : const Color(0xFF5F5955);

    return Scaffold(
      body: Container(
        color: backgroundColor,
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: isDarkMode ? 0.34 : 0.16,
                child: Image.asset(
                  'lib/assets/images/saffron_infused_sea_scallops.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      backgroundColor.withValues(alpha: 0.18),
                      backgroundColor.withValues(alpha: 0.70),
                      backgroundColor,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Stack(
                children: [
                  const Positioned(
                    top: 16,
                    right: 20,
                    child: AppUtilityToggles(),
                  ),
                  Align(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(22, 78, 22, 28),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 430),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: panelColor,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: isDarkMode
                                      ? Colors.white.withValues(alpha: 0.10)
                                      : Colors.black.withValues(alpha: 0.06),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    copy.profileSetupTitle,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    copy.profileSetupDescription,
                                    style: TextStyle(
                                      color: mutedColor,
                                      fontSize: 15,
                                      height: 1.45,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 26),
                                  Text(
                                    copy.hasAllergiesQuestion,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _ChoiceButton(
                                          label: copy.yesHasAllergies,
                                          selected: _hasAllergies,
                                          onTap: () {
                                            setState(() {
                                              _hasAllergies = true;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _ChoiceButton(
                                          label: copy.noAllergies,
                                          selected: !_hasAllergies,
                                          onTap: () {
                                            setState(() {
                                              _hasAllergies = false;
                                              _selectedAllergies.clear();
                                              _otherAllergiesController.clear();
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_hasAllergies) ...[
                                    const SizedBox(height: 22),
                                    _SectionLabel(label: copy.commonAllergies),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: _commonAllergies.map((allergy) {
                                        final selected =
                                            _selectedAllergies.contains(allergy);
                                        return FilterChip(
                                          label: Text(allergy),
                                          selected: selected,
                                          onSelected: (value) {
                                            setState(() {
                                              if (value) {
                                                _selectedAllergies.add(allergy);
                                              } else {
                                                _selectedAllergies.remove(
                                                  allergy,
                                                );
                                              }
                                            });
                                          },
                                          selectedColor:
                                              const Color(0xFFFF6F22),
                                          checkmarkColor: Colors.white,
                                          labelStyle: TextStyle(
                                            color: selected
                                                ? Colors.white
                                                : textColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 18),
                                    _ProfileField(
                                      label: copy.otherAllergies,
                                      hint: copy.allergiesHint,
                                      controller: _otherAllergiesController,
                                      icon: Icons.warning_amber_rounded,
                                      isDarkMode: isDarkMode,
                                      maxLines: 2,
                                    ),
                                  ],
                                  const SizedBox(height: 20),
                                  _ProfileField(
                                    label: copy.preferencesLabel,
                                    hint: copy.preferencesHint,
                                    controller: _preferencesController,
                                    icon: Icons.restaurant_menu_rounded,
                                    isDarkMode: isDarkMode,
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 26),
                                  FilledButton.icon(
                                    onPressed: auth.isLoading
                                        ? null
                                        : () => _saveProfile(),
                                    icon: auth.isLoading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.check_rounded),
                                    label: Text(copy.saveProfile),
                                    style: FilledButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFFFF6F22),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextButton(
                                    onPressed: auth.isLoading
                                        ? null
                                        : () => _saveProfile(skip: true),
                                    child: Text(copy.skipForNow),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
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
      color: selected
          ? const Color(0xFFFF6F22)
          : Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFFFFB48E),
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    required this.isDarkMode,
    this.maxLines = 1,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final bool isDarkMode;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final inputColor =
        isDarkMode ? const Color(0xFFF7F7F8) : const Color(0xFF171717);
    final hintColor =
        isDarkMode ? const Color(0x88F7F7F8) : const Color(0x885F5955);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: label),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.topLeft,
          children: [
            TextField(
              controller: controller,
              maxLines: maxLines,
              minLines: maxLines,
              style: TextStyle(color: inputColor),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDarkMode
                    ? const Color(0xFF101012).withValues(alpha: 0.82)
                    : const Color(0xFFF4F4F5),
                hintText: hint,
                hintStyle: TextStyle(color: hintColor),
                contentPadding: EdgeInsets.fromLTRB(
                  48,
                  maxLines > 1 ? 18 : 16,
                  16,
                  16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 17),
              child: Icon(icon, size: 18, color: hintColor),
            ),
          ],
        ),
      ],
    );
  }
}
