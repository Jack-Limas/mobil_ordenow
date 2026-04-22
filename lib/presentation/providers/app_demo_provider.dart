import 'package:flutter/material.dart';

enum AppStage {
  welcome,
  signIn,
  signUp,
  customer,
  admin,
}

enum CustomerScreen {
  menu,
  cart,
  aiConcierge,
  checkout,
  tracking,
  profile,
}

enum AdminScreen {
  dashboard,
  menuManagement,
  orderManagement,
  profile,
}

class AppDemoProvider extends ChangeNotifier {
  AppStage _stage = AppStage.welcome;
  CustomerScreen _customerScreen = CustomerScreen.menu;
  AdminScreen _adminScreen = AdminScreen.dashboard;

  AppStage get stage => _stage;
  CustomerScreen get customerScreen => _customerScreen;
  AdminScreen get adminScreen => _adminScreen;

  bool get isWelcome => _stage == AppStage.welcome;
  bool get isSignIn => _stage == AppStage.signIn;
  bool get isSignUp => _stage == AppStage.signUp;
  bool get isCustomer => _stage == AppStage.customer;
  bool get isAdmin => _stage == AppStage.admin;

  void openSignIn() {
    _stage = AppStage.signIn;
    notifyListeners();
  }

  void openSignUp() {
    _stage = AppStage.signUp;
    notifyListeners();
  }

  void openCustomerArea({
    CustomerScreen screen = CustomerScreen.menu,
  }) {
    _stage = AppStage.customer;
    _customerScreen = screen;
    notifyListeners();
  }

  void openAdminArea({
    AdminScreen screen = AdminScreen.dashboard,
  }) {
    _stage = AppStage.admin;
    _adminScreen = screen;
    notifyListeners();
  }

  void setCustomerScreen(CustomerScreen screen) {
    if (_customerScreen == screen) {
      return;
    }

    _customerScreen = screen;
    notifyListeners();
  }

  void setAdminScreen(AdminScreen screen) {
    if (_adminScreen == screen) {
      return;
    }

    _adminScreen = screen;
    notifyListeners();
  }

  void backToWelcome() {
    _stage = AppStage.welcome;
    notifyListeners();
  }
}
