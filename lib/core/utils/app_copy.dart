import 'package:flutter/widgets.dart';

class AppCopy {
  const AppCopy._({
    required this.localeCode,
  });

  final String localeCode;

  bool get isSpanish => localeCode == 'es';

  static AppCopy of(BuildContext context) {
    return AppCopy._(
      localeCode: Localizations.localeOf(context).languageCode,
    );
  }

  String get appName => 'OrdeNow';
  String get sensorySommelier =>
      isSpanish ? 'RESTAURANTE INTELIGENTE' : 'SMART RESTAURANT';

  String get welcomeHeadline =>
      isSpanish ? 'Pide con IA.\nDisfruta sin esperar.' : 'Order with AI.\nEnjoy without waiting.';

  String get welcomeDescription => isSpanish
      ? 'OrdeNow conecta tu mesa, tus gustos y la cocina en tiempo real para que cada pedido sea claro, rapido y personalizado.'
      : 'OrdeNow connects your table, tastes, and kitchen in real time so every order feels clear, fast, and personal.';

  String get welcomeBadge =>
      isSpanish ? 'BIENVENIDA EXOTICA' : 'EXOTIC WELCOME';
  String get welcomePill => isSpanish
      ? 'Tema, idioma y sesion local listos con Provider + Hive.'
      : 'Theme, language, and local session ready with Provider + Hive.';
  String get getStarted => isSpanish ? 'Iniciar' : 'Start';
  String get openAdminDemo =>
      isSpanish ? 'Abrir demo admin' : 'Open Admin Demo';
  String get aiConciergeOnline =>
      isSpanish ? 'IA CONCIERGE EN LINEA' : 'AI CONCIERGE ONLINE';
  String get switchLanguage =>
      isSpanish ? 'Cambiar a ingles' : 'Switch to Spanish';
  String get switchTheme =>
      isSpanish ? 'Cambiar tema' : 'Change theme';
  String get themeDark => isSpanish ? 'Oscuro' : 'Dark';
  String get themeLight => isSpanish ? 'Claro' : 'Light';
  String get themeSystem => isSpanish ? 'Sistema' : 'System';
  String get aiReady => isSpanish ? 'IA lista para tomar tu orden' : 'AI ready to take your order';

  String get curatedDishes =>
      isSpanish ? 'PEDIDOS GUIADOS' : 'GUIDED ORDERS';
  String get michelinChefs =>
      isSpanish ? 'MESAS EN TIEMPO REAL' : 'REAL-TIME TABLES';

  String get welcomeBack =>
      isSpanish ? 'Bienvenido de Nuevo' : 'Welcome Back';
  String get continueJourney => isSpanish
      ? 'Ingresa tus datos para continuar\ntu recorrido.'
      : 'Please enter your details to continue\nyour journey.';

  String get signIn => isSpanish ? 'Iniciar Sesion' : 'Sign In';
  String get signUp => isSpanish ? 'Registrarme' : 'Sign Up';
  String get createAccount =>
      isSpanish ? 'Crear Cuenta' : 'Create Account';
  String get signInTitle => isSpanish
      ? 'Accede a tu mesa inteligente'
      : 'Enter your smart table journey';
  String get signUpTitle => isSpanish
      ? 'Crea tu perfil gastronomico'
      : 'Create your dining profile';
  String get customer => isSpanish ? 'Cliente' : 'Customer';
  String get administrator =>
      isSpanish ? 'Administrador' : 'Administrator';
  String get emailAddress =>
      isSpanish ? 'CORREO ELECTRONICO' : 'EMAIL ADDRESS';
  String get password => isSpanish ? 'CONTRASENA' : 'PASSWORD';
  String get forgot => isSpanish ? 'OLVIDE?' : 'FORGOT?';
  String get continueWith =>
      isSpanish ? 'O CONTINUA CON' : 'OR CONTINUE WITH';
  String get newToOrdenow => isSpanish
      ? 'Nuevo en OrdeNow? Crea una cuenta'
      : 'New to OrdeNow? Create an account';
  String get alreadyHaveAccount => isSpanish
      ? 'Ya tienes cuenta? Inicia sesion'
      : 'Already have an account? Sign in';
  String get fullName => isSpanish ? 'NOMBRE COMPLETO' : 'FULL NAME';
  String get confirmPassword =>
      isSpanish ? 'CONFIRMAR CONTRASENA' : 'CONFIRM PASSWORD';
  String get allergiesPreferences => isSpanish
      ? 'ALERGIAS O PREFERENCIAS'
      : 'ALLERGIES OR PREFERENCES';
  String get signInDescription => isSpanish
      ? 'Inicia sesion para continuar con recomendaciones, pedido asistido y seguimiento en tiempo real.'
      : 'Sign in to continue with recommendations, AI-assisted ordering, and live tracking.';
  String get signUpDescription => isSpanish
      ? 'Crea tu perfil para empezar a pedir con IA, recomendaciones y seguimiento en tiempo real.'
      : 'Create your profile to start ordering with AI, recommendations, and live tracking.';
  String get passwordMismatch =>
      isSpanish ? 'Las contrasenas no coinciden.' : 'Passwords do not match.';
  String get unableToCreateAccount => isSpanish
      ? 'No se pudo crear la cuenta.'
      : 'Unable to create account.';
  String get unableToSignIn =>
      isSpanish ? 'No se pudo iniciar sesion.' : 'Unable to sign in.';
  String get footerCopyright => '(C) 2026\nORDENOW\nTECHNOLOGIES';

  String get privacy => isSpanish ? 'PRIVACIDAD' : 'PRIVACY';
  String get terms => isSpanish ? 'TERMINOS' : 'TERMS';
  String get accessibility =>
      isSpanish ? 'ACCESIBILIDAD' : 'ACCESSIBILITY';

  String get emailHint =>
      isSpanish ? 'gourmet@ordenow.com' : 'gourmet@ordenow.com';
  String get passwordHint =>
      isSpanish ? 'Ingresa tu contrasena' : 'Enter your password';
  String get fullNameHint =>
      isSpanish ? 'Tu nombre completo' : 'Your full name';
  String get allergiesHint => isSpanish
      ? 'Ej. peanuts, gluten free, low spice'
      : 'E.g. peanuts, gluten free, low spice';
}
