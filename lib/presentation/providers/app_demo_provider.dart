import 'package:flutter/material.dart';

enum DemoExperience {
  welcome,
  customer,
  admin,
}

class AppDemoProvider extends ChangeNotifier {
  DemoExperience _experience = DemoExperience.welcome;

  DemoExperience get experience => _experience;

  bool get isWelcome => _experience == DemoExperience.welcome;
  bool get isCustomer => _experience == DemoExperience.customer;
  bool get isAdmin => _experience == DemoExperience.admin;

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
