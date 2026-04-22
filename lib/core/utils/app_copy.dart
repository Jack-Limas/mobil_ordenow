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
      isSpanish ? 'SOMMELIER SENSORIAL' : 'SENSORY SOMMELIER';

  String get welcomeHeadline =>
      isSpanish ? 'Eleva\nTu Paladar.' : 'Elevate\nYour Palate.';

  String get welcomeDescription => isSpanish
      ? 'Experiencias gastronomicas guiadas por IA segun tu perfil sensorial.\nBienvenido al futuro del apetito.'
      : 'AI-curated dining experiences tailored to your unique sensory profile.\nWelcome to the future of appetite.';

  String get welcomeBadge =>
      isSpanish ? 'EXPERIENCIA GASTRONOMICA' : 'DINING EXPERIENCE';
  String get welcomePill => isSpanish
      ? 'Personalizacion, voz y IA en un solo flujo.'
      : 'Voice, personalization, and AI in one flow.';
  String get getStarted => isSpanish ? 'Comenzar' : 'Get Started';
  String get openAdminDemo =>
      isSpanish ? 'Abrir demo admin' : 'Open Admin Demo';
  String get aiConciergeOnline =>
      isSpanish ? 'IA CONCIERGE EN LINEA' : 'AI CONCIERGE ONLINE';
  String get switchLanguage =>
      isSpanish ? 'Cambiar a ingles' : 'Switch to Spanish';
  String get switchTheme =>
      isSpanish ? 'Cambiar tema' : 'Toggle theme';
  String get aiReady => isSpanish ? 'IA lista para asistir' : 'AI ready to assist';

  String get curatedDishes =>
      isSpanish ? 'PLATOS CURADOS' : 'CURATED DISHES';
  String get michelinChefs =>
      isSpanish ? 'CHEFS MICHELIN' : 'MICHELIN CHEFS';

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
