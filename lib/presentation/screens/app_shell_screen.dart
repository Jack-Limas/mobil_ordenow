import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ai_provider.dart';
import '../providers/app_demo_provider.dart';
import '../providers/order_provider.dart';
import 'admin_demo_screen.dart';
import 'customer_demo_screen.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';
import 'welcome_screen.dart';

class AppShellScreen extends StatelessWidget {
  const AppShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final demo = context.watch<AppDemoProvider>();

    switch (demo.experience) {
      case DemoExperience.signIn:
        return const SignInScreen();
      case DemoExperience.signUp:
        return const SignUpScreen();
      case DemoExperience.customer:
        return const CustomerDemoScreen();
      case DemoExperience.admin:
        return const AdminDemoScreen();
      case DemoExperience.welcome:
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
