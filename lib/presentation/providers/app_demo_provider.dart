import 'package:flutter/material.dart';

enum DemoExperience {
  welcome,
  signIn,
  signUp,
  customer,
  admin,
}

class AppDemoProvider extends ChangeNotifier {
  DemoExperience _experience = DemoExperience.welcome;

  DemoExperience get experience => _experience;

  bool get isWelcome => _experience == DemoExperience.welcome;
  bool get isSignIn => _experience == DemoExperience.signIn;
  bool get isSignUp => _experience == DemoExperience.signUp;
  bool get isCustomer => _experience == DemoExperience.customer;
  bool get isAdmin => _experience == DemoExperience.admin;

  void openSignIn() {
    _experience = DemoExperience.signIn;
    notifyListeners();
  }

  void openSignUp() {
    _experience = DemoExperience.signUp;
    notifyListeners();
  }

  void openCustomerDemo() {
    _experience = DemoExperience.customer;
    notifyListeners();
  }

  void openAdminDemo() {
    _experience = DemoExperience.admin;
    notifyListeners();
  }

  void backToWelcome() {
    _experience = DemoExperience.welcome;
    notifyListeners();
  }
}
