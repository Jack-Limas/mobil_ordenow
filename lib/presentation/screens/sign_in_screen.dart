import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/app_copy.dart';
import '../providers/app_demo_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_utility_toggles.dart';

enum SignInRole {
  customer,
  administrator,
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  SignInRole _role = SignInRole.customer;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final auth = context.read<AuthProvider>();
    final demo = context.read<AppDemoProvider>();
    final copy = AppCopy.of(context);

    if (_role == SignInRole.administrator) {
      demo.openAdminDemo();
      return;
    }

    final success = await auth.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      demo.openCustomerDemo();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(auth.errorMessage ?? copy.unableToSignIn),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? const Color(0xFF11100F) : const Color(0xFFF8EEE6);
    final panelColor = isDarkMode
        ? const Color(0xFF131313).withValues(alpha: 0.62)
        : Colors.white.withValues(alpha: 0.86);
    final headingColor =
        isDarkMode ? const Color(0xFFE5E2E1) : const Color(0xFF221813);
    final bodyColor =
        isDarkMode ? const Color(0xFFE4BEB1) : const Color(0xFF76584D);
    final mutedColor =
        isDarkMode ? const Color(0x66E5E2E1) : const Color(0x88665045);

    return Scaffold(
      body: Container(
        color: backgroundColor,
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: isDarkMode ? 0.38 : 0.24,
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
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [
                      backgroundColor,
                      backgroundColor.withValues(alpha: 0.82),
                      Colors.transparent,
                    ],
                    stops: const [0, 0.5, 1],
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
                      child: Column(
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 360),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 24,
                                  sigmaY: 24,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    color: panelColor,
                                    borderRadius: BorderRadius.circular(32),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.28),
                                        offset: Offset(0, 25),
                                        blurRadius: 50,
                                        spreadRadius: -12,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        copy.signInTitle,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: headingColor,
                                          fontSize: 30,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        copy.signInDescription,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: bodyColor,
                                          fontSize: 14,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 28),
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: isDarkMode
                                              ? const Color(0xFF0E0E0E)
                                                  .withValues(alpha: 0.50)
                                              : const Color(0xFFF3E4D8),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: _RoleButton(
                                                label: copy.customer,
                                                selected:
                                                    _role == SignInRole.customer,
                                                onTap: () {
                                                  setState(() {
                                                    _role =
                                                        SignInRole.customer;
                                                  });
                                                },
                                              ),
                                            ),
                                            Expanded(
                                              child: _RoleButton(
                                                label: copy.administrator,
                                                selected: _role ==
                                                    SignInRole.administrator,
                                                onTap: () {
                                                  setState(() {
                                                    _role =
                                                        SignInRole.administrator;
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      _FieldBlock(
                                        label: copy.emailAddress,
                                        icon: Icons.mail_outline_rounded,
                                        isDarkMode: isDarkMode,
                                        child: TextField(
                                          controller: _emailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          style: TextStyle(color: headingColor),
                                          decoration: InputDecoration(
                                            hintText: copy.emailHint,
                                            hintStyle: TextStyle(color: mutedColor),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      _FieldBlock(
                                        label: copy.password,
                                        icon: Icons.lock_outline_rounded,
                                        isDarkMode: isDarkMode,
                                        trailing: Text(
                                          copy.forgot,
                                          style: TextStyle(
                                            color: mutedColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.6,
                                          ),
                                        ),
                                        child: TextField(
                                          controller: _passwordController,
                                          obscureText: true,
                                          style: TextStyle(color: headingColor),
                                          decoration: InputDecoration(
                                            hintText: '••••••••',
                                            hintStyle: TextStyle(color: mutedColor),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 22),
                                      DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Color(0xFFFFB599),
                                              Color(0xFFFF5C00),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          boxShadow: const [
                                            BoxShadow(
                                              color:
                                                  Color.fromRGBO(255, 92, 0, 0.30),
                                              offset: Offset(0, 8),
                                              blurRadius: 30,
                                            ),
                                          ],
                                        ),
                                        child: FilledButton(
                                          onPressed:
                                              auth.isLoading ? null : _handleSignIn,
                                          style: FilledButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            foregroundColor:
                                                const Color(0xFF521800),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                            ),
                                          ),
                                          child: auth.isLoading
                                              ? const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : Text(
                                                  copy.signIn,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(height: 28),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Divider(
                                              color: mutedColor.withValues(
                                                alpha: 0.24,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                            ),
                                            child: Text(
                                              copy.continueWith,
                                              style: TextStyle(
                                                color: mutedColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 2.2,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Divider(
                                              color: mutedColor.withValues(
                                                alpha: 0.24,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      const Row(
                                        children: [
                                          Expanded(
                                            child: _SocialButton(
                                              assetPath:
                                                  'lib/assets/images/google_simbolo.png',
                                              label: 'Google',
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: _SocialButton(
                                              assetPath:
                                                  'lib/assets/images/apple_simbolo.png',
                                              label: 'Apple',
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      Center(
                                        child: TextButton(
                                          onPressed: () {
                                            context
                                                .read<AppDemoProvider>()
                                                .openSignUp();
                                          },
                                          child: Text(
                                            copy.newToOrdenow,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: bodyColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 390),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    copy.footerCopyright,
                                    style: TextStyle(
                                      color: mutedColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 2,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                                Wrap(
                                  spacing: 24,
                                  children: [
                                    copy.privacy,
                                    copy.terms,
                                    copy.accessibility,
                                  ].map(
                                    (item) => Text(
                                      item,
                                      style: TextStyle(
                                        color: mutedColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ).toList(),
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
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({
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
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFF5C00) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldBlock extends StatelessWidget {
  const _FieldBlock({
    required this.label,
    required this.child,
    required this.icon,
    required this.isDarkMode,
    this.trailing,
  });

  final String label;
  final Widget child;
  final IconData icon;
  final bool isDarkMode;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final mutedColor =
        isDarkMode ? const Color(0x66E5E2E1) : const Color(0x88665045);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xCCFFB599),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            trailing ?? const SizedBox.shrink(),
          ],
        ),
        const SizedBox(height: 6),
        Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: isDarkMode
                  ? const Color(0xFF2A2A2A).withValues(alpha: 0.50)
                  : const Color(0xFFF3E4D8),
              contentPadding: const EdgeInsets.fromLTRB(48, 17, 16, 17),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          child: Builder(
            builder: (context) {
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  child,
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Icon(
                      icon,
                      size: 18,
                      color: mutedColor,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.assetPath,
    required this.label,
  });

  final String assetPath;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF353533).withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            assetPath,
            width: 20,
            height: 20,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xCCE5E2E1),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
