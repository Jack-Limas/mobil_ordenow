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
        content: Text(auth.errorMessage ?? 'Unable to sign in.'),
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
                opacity: 0.4,
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
                      const Color(0xFF131313),
                      const Color(0xFF131313).withValues(alpha: 0.80),
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
                            constraints: const BoxConstraints(maxWidth: 342),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 24,
                                  sigmaY: 24,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(40),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF131313)
                                        .withValues(alpha: 0.60),
                                    borderRadius: BorderRadius.circular(32),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.40),
                                        offset: Offset(0, 25),
                                        blurRadius: 50,
                                        spreadRadius: -12,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            copy.welcomeBack,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Color(0xFFE5E2E1),
                                              fontSize: 30,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            copy.continueJourney,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Color(0xFFE4BEB1),
                                              fontSize: 14,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 32),
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0E0E0E)
                                              .withValues(alpha: 0.50),
                                          borderRadius: BorderRadius.circular(16),
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
                                                    _role = SignInRole.customer;
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
                                      const SizedBox(height: 32),
                                      _FieldBlock(
                                        label: copy.emailAddress,
                                        icon: Icons.mail_outline_rounded,
                                        child: TextField(
                                          controller: _emailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          style: const TextStyle(
                                            color: Color(0xFFE5E2E1),
                                          ),
                                          decoration: InputDecoration(
                                            hintText: copy.emailHint,
                                            hintStyle: const TextStyle(
                                              color: Color.fromRGBO(
                                                  229, 226, 225, 0.20),
                                            ),
                                            prefixIconColor:
                                                const Color.fromRGBO(
                                                    229, 226, 225, 0.40),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      _FieldBlock(
                                        label: copy.password,
                                        trailing: Text(
                                          copy.forgot,
                                          style: const TextStyle(
                                            color:
                                                Color.fromRGBO(229, 226, 225, 0.40),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.6,
                                          ),
                                        ),
                                        icon: Icons.lock_outline_rounded,
                                        child: TextField(
                                          controller: _passwordController,
                                          obscureText: true,
                                          style: const TextStyle(
                                            color: Color(0xFFE5E2E1),
                                          ),
                                          decoration: InputDecoration(
                                            hintText: '••••••••',
                                            hintStyle: const TextStyle(
                                              color: Color.fromRGBO(
                                                  229, 226, 225, 0.20),
                                            ),
                                            prefixIconColor:
                                                const Color.fromRGBO(
                                                    229, 226, 225, 0.40),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
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
                                              color: Color.fromRGBO(
                                                  255, 92, 0, 0.30),
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
                                      const SizedBox(height: 32),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Divider(
                                              color: Colors.white
                                                  .withValues(alpha: 0.05),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                            ),
                                            child: Text(
                                              copy.continueWith,
                                              style: const TextStyle(
                                                color: Color.fromRGBO(
                                                    229, 226, 225, 0.30),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 2.4,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Divider(
                                              color: Colors.white
                                                  .withValues(alpha: 0.05),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 32),
                                      Row(
                                        children: const [
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
                                      const SizedBox(height: 32),
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
                                            style: const TextStyle(
                                              color: Color(0xFFE4BEB1),
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
                          const SizedBox(height: 40),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 390),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    '© 2024\nORDENOW\nTECHNOLOGIES',
                                    style: TextStyle(
                                      color: Color.fromRGBO(229, 226, 225, 0.20),
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
                                      style: const TextStyle(
                                        color:
                                            Color.fromRGBO(229, 226, 225, 0.20),
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
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.10),
                      offset: Offset(0, 4),
                      blurRadius: 6,
                      spreadRadius: -4,
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.10),
                      offset: Offset(0, 10),
                      blurRadius: 15,
                      spreadRadius: -3,
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected
                  ? const Color(0xFF521800)
                  : const Color.fromRGBO(229, 226, 225, 0.60),
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
    this.trailing,
  });

  final String label;
  final Widget child;
  final IconData icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
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
            if (trailing case final widget?) widget,
          ],
        ),
        const SizedBox(height: 6),
        Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF2A2A2A).withValues(alpha: 0.50),
              prefixIconColor: const Color.fromRGBO(229, 226, 225, 0.40),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 17,
              ),
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
                      color: const Color.fromRGBO(229, 226, 225, 0.40),
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
        color: const Color(0xFF353533).withValues(alpha: 0.40),
        borderRadius: BorderRadius.circular(24),
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
