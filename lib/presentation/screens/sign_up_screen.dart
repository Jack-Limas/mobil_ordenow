import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/app_copy.dart';
import '../providers/app_demo_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_utility_toggles.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _preferencesController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _preferencesController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final copy = AppCopy.of(context);

    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            copy.isSpanish
                ? 'Las contrasenas no coinciden.'
                : 'Passwords do not match.',
          ),
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      fullName: _fullNameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      context.read<AppDemoProvider>().openCustomerDemo();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(auth.errorMessage ?? 'Unable to create account.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        color: const Color(0xFF131313),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.28,
                child: Image.asset(
                  'lib/assets/images/background_bienvenida.png',
                  fit: BoxFit.cover,
                ),
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
                      const Color(0xFF131313).withValues(alpha: 0.86),
                      Colors.transparent,
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
                      padding: const EdgeInsets.fromLTRB(24, 76, 24, 76),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 342),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: const Color(0xFF131313)
                                    .withValues(alpha: 0.62),
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    copy.createAccount,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFFE5E2E1),
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    copy.isSpanish
                                        ? 'Crea tu perfil para empezar a pedir con IA, recomendaciones y seguimiento en tiempo real.'
                                        : 'Create your profile to start ordering with AI, recommendations, and live tracking.',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFFE4BEB1),
                                      fontSize: 14,
                                      height: 1.45,
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  _RegisterField(
                                    label: copy.fullName,
                                    icon: Icons.person_outline_rounded,
                                    controller: _fullNameController,
                                    hint: copy.fullNameHint,
                                  ),
                                  const SizedBox(height: 16),
                                  _RegisterField(
                                    label: copy.emailAddress,
                                    icon: Icons.mail_outline_rounded,
                                    controller: _emailController,
                                    hint: copy.emailHint,
                                  ),
                                  const SizedBox(height: 16),
                                  _RegisterField(
                                    label: copy.password,
                                    icon: Icons.lock_outline_rounded,
                                    controller: _passwordController,
                                    hint: copy.passwordHint,
                                    obscureText: true,
                                  ),
                                  const SizedBox(height: 16),
                                  _RegisterField(
                                    label: copy.confirmPassword,
                                    icon: Icons.verified_user_outlined,
                                    controller: _confirmPasswordController,
                                    hint: copy.passwordHint,
                                    obscureText: true,
                                  ),
                                  const SizedBox(height: 16),
                                  _RegisterField(
                                    label: copy.allergiesPreferences,
                                    icon: Icons.spa_outlined,
                                    controller: _preferencesController,
                                    hint: copy.allergiesHint,
                                    maxLines: 3,
                                  ),
                                  const SizedBox(height: 22),
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFFB599),
                                          Color(0xFFFF5C00),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: FilledButton(
                                      onPressed:
                                          auth.isLoading ? null : _handleRegister,
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        foregroundColor: const Color(0xFF521800),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                      ),
                                      child: auth.isLoading
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              copy.signUp,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  TextButton(
                                    onPressed: () {
                                      context
                                          .read<AppDemoProvider>()
                                          .openSignIn();
                                    },
                                    child: Text(
                                      copy.alreadyHaveAccount,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Color(0xFFE4BEB1),
                                      ),
                                    ),
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

class _RegisterField extends StatelessWidget {
  const _RegisterField({
    required this.label,
    required this.icon,
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.maxLines = 1,
  });

  final String label;
  final IconData icon;
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xCCFFB599),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Stack(
          alignment: Alignment.topLeft,
          children: [
            TextField(
              controller: controller,
              obscureText: obscureText,
              maxLines: maxLines,
              minLines: maxLines,
              style: const TextStyle(color: Color(0xFFE5E2E1)),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF2A2A2A).withValues(alpha: 0.50),
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Color.fromRGBO(229, 226, 225, 0.20),
                ),
                contentPadding: EdgeInsets.fromLTRB(
                  48,
                  maxLines > 1 ? 18 : 17,
                  16,
                  17,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 18),
              child: Icon(
                icon,
                size: 18,
                color: const Color.fromRGBO(229, 226, 225, 0.40),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
