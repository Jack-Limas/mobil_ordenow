import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ai_provider.dart';
import '../providers/app_demo_provider.dart';
import '../providers/order_provider.dart';
import 'admin_app_screen.dart';
import 'customer_app_screen.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';
import 'welcome_screen.dart';

class AppShellScreen extends StatelessWidget {
  const AppShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appFlow = context.watch<AppDemoProvider>();

    switch (appFlow.stage) {
      case AppStage.signIn:
        return const SignInScreen();
      case AppStage.signUp:
        return const SignUpScreen();
      case AppStage.customer:
        return const CustomerAppScreen();
      case AppStage.admin:
        return const AdminAppScreen();
      case AppStage.welcome:
        return WelcomeScreen(
          onCustomerDemo: () {
            context.read<OrderProvider>().clearDemoState();
            context.read<AiProvider>().resetConversation();
            context.read<AppDemoProvider>().openSignIn();
          },
          onAdminDemo: () {
            context.read<OrderProvider>().clearDemoState();
            context.read<AiProvider>().resetConversation();
            context.read<AppDemoProvider>().openSignIn();
          },
        );
    }
  }
}
