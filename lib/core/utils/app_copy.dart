import 'package:flutter/widgets.dart';

class AppCopy {
  const AppCopy._({
    required this.localeCode,
  });

  final String localeCode;

  bool get isSpanish => localeCode == 'es';

  static String translateStatus(BuildContext context, String? status) {
    final copy = AppCopy.of(context);
    return switch (status) {
      'pending' => copy.isSpanish ? 'Pendiente' : 'Pending',
      'accepted' => copy.isSpanish ? 'Aceptado' : 'Accepted',
      'preparing' => copy.isSpanish ? 'Preparando' : 'Preparing',
      'ready' => copy.isSpanish ? 'Listo' : 'Ready',
      'delivered' => copy.isSpanish ? 'Entregado' : 'Delivered',
      'completed' => copy.isSpanish ? 'Completado' : 'Completed',
      _ => status ?? (copy.isSpanish ? 'Desconocido' : 'Unknown'),
    };
  }

  static String translateCategory(BuildContext context, String category) {
    final copy = AppCopy.of(context);
    return switch (category.toLowerCase()) {
      'main' || 'plato' || 'signature' || 'healthy' =>
        copy.isSpanish ? 'Plato' : 'Main',
      'drink' || 'bebida' => copy.isSpanish ? 'Bebida' : 'Drink',
      'dessert' || 'postre' => copy.isSpanish ? 'Postre' : 'Dessert',
      'starter' || 'entrada' => copy.isSpanish ? 'Entrada' : 'Starter',
      _ => category,
    };
  }

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
      ? 'Lista para recomendarte, tomar tu pedido y conectarte con la cocina.'
      : 'Ready to recommend, take your order, and connect you with the kitchen.';
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
  String get requiredFields => isSpanish
      ? 'Completa los campos requeridos.'
      : 'Please complete the required fields.';
  String get accountCreatedNextProfile => isSpanish
      ? 'Cuenta creada. En la siguiente pantalla configuraremos tu perfil.'
      : 'Account created. Your profile setup comes next.';
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
  String get profileSetupTitle => isSpanish
      ? 'Tu perfil inicial'
      : 'Your initial profile';
  String get profileSetupDescription => isSpanish
      ? 'Dile a OrdeNow que ingredientes debe evitar para que la IA cuide tus recomendaciones.'
      : 'Tell OrdeNow which ingredients to avoid so the AI can protect your recommendations.';
  String get hasAllergiesQuestion => isSpanish
      ? 'Tienes alergias alimentarias?'
      : 'Do you have food allergies?';
  String get yesHasAllergies => isSpanish ? 'Si, tengo' : 'Yes, I do';
  String get noAllergies => isSpanish ? 'No tengo' : 'No allergies';
  String get commonAllergies => isSpanish ? 'ALERGIAS COMUNES' : 'COMMON ALLERGIES';
  String get otherAllergies => isSpanish ? 'OTRAS ALERGIAS' : 'OTHER ALLERGIES';
  String get preferencesLabel => isSpanish ? 'PREFERENCIAS' : 'PREFERENCES';
  String get preferencesHint => isSpanish
      ? 'Ej. poco picante, vegetariano, sin cebolla'
      : 'E.g. mild spice, vegetarian, no onions';
  String get saveProfile => isSpanish ? 'Guardar perfil' : 'Save profile';
  String get skipForNow => isSpanish ? 'Omitir por ahora' : 'Skip for now';
  String get profileSaved => isSpanish
      ? 'Perfil guardado. La IA ya podra usar esta informacion.'
      : 'Profile saved. The AI can now use this information.';
  String get unableToSaveProfile => isSpanish
      ? 'No se pudo guardar el perfil inicial.'
      : 'Unable to save the initial profile.';
  String get tableSelectionTitle => isSpanish
      ? 'Elige tu mesa'
      : 'Choose your table';
  String get tableSelectionDescription => isSpanish
      ? 'Las mesas ocupadas se bloquean en tiempo real. Selecciona una disponible para iniciar tu experiencia.'
      : 'Occupied tables are locked in real time. Select an available table to start your experience.';
  String get tableSelectionBadge => isSpanish
      ? 'MESAS EN VIVO'
      : 'LIVE TABLES';
  String get availableTable => isSpanish ? 'Disponible' : 'Available';
  String get occupiedTable => isSpanish ? 'Ocupada' : 'Occupied';
  String get paymentPendingTable => isSpanish ? 'Pago pendiente' : 'Payment pending';
  String get selectedTable => isSpanish ? 'Mesa seleccionada' : 'Selected table';
  String get continueToAi => isSpanish ? 'Continuar a la IA' : 'Continue to AI';
  String get tableReserved => isSpanish
      ? 'Mesa reservada. Bienvenido a OrdeNow.'
      : 'Table reserved. Welcome to OrdeNow.';
  String get unableToReserveTable => isSpanish
      ? 'No se pudo reservar esta mesa.'
      : 'Unable to reserve this table.';
  String get noTablesAvailable => isSpanish
      ? 'Aun no hay mesas cargadas.'
      : 'No tables loaded yet.';
  String get retry => isSpanish ? 'Reintentar' : 'Retry';

  String get roleLabel => isSpanish ? 'ROL DE CUENTA' : 'ACCOUNT ROLE';
  String get roleCustomer => isSpanish ? '🍽 Cliente' : '🍽 Customer';
  String get roleAdministrator => isSpanish ? '⚙ Administrador' : '⚙ Administrator';
  String get accountCreatedAdminArea => isSpanish
      ? 'Cuenta admin creada. Bienvenido al panel.'
      : 'Admin account created. Welcome to the panel.';

  // ── Admin home ──────────────────────────────────────────────────────────────
  String get adminOccupiedTables =>
      isSpanish ? 'Mesas ocupadas' : 'Occupied tables';
  String get adminInService =>
      isSpanish ? 'en servicio • Tiempo real' : 'in service • Real time';
  String get adminRealStats =>
      isSpanish ? 'Estadísticas reales' : 'Real statistics';
  String get adminDailySales =>
      isSpanish ? 'Ventas del dia' : 'Daily sales';
  String get adminActiveOrders =>
      isSpanish ? 'Pedidos activos' : 'Active orders';
  String get adminAvgTicket =>
      isSpanish ? 'Ticket promedio' : 'Average ticket';
  String get adminReleaseTable => isSpanish ? 'Liberar' : 'Release';
  String get adminOccupied => isSpanish ? 'Ocupada' : 'Occupied';
  String get adminNoTables =>
      isSpanish ? 'No hay mesas ocupadas' : 'No occupied tables';
  String get adminNoTablesSub => isSpanish
      ? 'Cuando un cliente reserve una mesa, aparecerá aquí.'
      : 'When a client reserves a table, it will appear here.';

  // ── KDS ─────────────────────────────────────────────────────────────────────
  String get kdsTitle =>
      isSpanish ? 'Gestión de Comandas' : 'Order Management';
  String get kdsStartPrep =>
      isSpanish ? 'Comenzar Preparación' : 'Start Preparation';
  String get kdsMarkReady =>
      isSpanish ? 'Listo para servir' : 'Ready to serve';
  String get kdsConfirmCash =>
      isSpanish ? 'Confirmar Pago en Caja' : 'Confirm Cash Payment';
  String get kdsActive => isSpanish ? 'Activos' : 'Active';

  // ── Menu management ──────────────────────────────────────────────────────────
  String get menuMgmtTitle =>
      isSpanish ? 'Gestión del Menú' : 'Menu Management';
  String get menuAddItem =>
      isSpanish ? 'Añadir Nuevo Plato' : 'Add New Dish';
  String get menuPublish =>
      isSpanish ? 'Publicar en Menú' : 'Publish to Menu';
  String get menuCurrent =>
      isSpanish ? 'Platos Actuales' : 'Current Dishes';
  String get menuSubtitle => isSpanish
      ? 'Administra y optimiza tus platos del menú'
      : 'Manage and optimize your menu dishes';
  String get menuAll => isSpanish ? 'Todos' : 'All';
  String get menuOrderIa => isSpanish ? 'Ordenar con IA' : 'Order with AI';

  // ── Admin profile ────────────────────────────────────────────────────────────
  String get settingsLanguage => isSpanish ? 'Idioma' : 'Language';
  String get settingsAppearance => isSpanish ? 'Apariencia' : 'Appearance';

  // ── Client profile ───────────────────────────────────────────────────────────
  String get profileSettings => isSpanish ? 'Ajustes' : 'Settings';
  String get profileTheme => isSpanish ? 'Tema' : 'Theme';
  String get profileWellness => isSpanish ? 'Bienestar' : 'Wellness';
  String get profileAllergiesLabel =>
      isSpanish ? 'Alergias persistentes:' : 'Persistent allergies:';
  String get profileAddAllergy => isSpanish ? '+ Añadir' : '+ Add';
  String get profileNoOrders =>
      isSpanish ? 'Sin pedidos en esta sesión.' : 'No orders in this session.';
  String get profileLogout => isSpanish ? 'Cerrar Sesion' : 'Sign Out';

  // ── Order tracking ───────────────────────────────────────────────────────────
  String get trackingTitle => isSpanish ? 'Seguimiento' : 'Tracking';
  String get trackingReceived => isSpanish ? 'Recibido' : 'Received';
  String get trackingCooking => isSpanish ? 'Cocinando' : 'Cooking';
  String get trackingDelivery => isSpanish ? 'Reparto' : 'Delivery';
  String get trackingDelivered => isSpanish ? 'Entregado' : 'Delivered';
  String get trackingActiveOrder =>
      isSpanish ? 'Sin pedido activo' : 'No active order';
  String get trackingExplore =>
      isSpanish ? 'Explora el Menú' : 'Explore the Menu';
  String get trackingViewOnly =>
      isSpanish ? 'Solo consulta' : 'View only';
  String get trackingOrder => isSpanish ? 'Pedido' : 'Order';
  String get trackingStartedAt => isSpanish ? 'Iniciado a las' : 'Started at';
  String get trackingInKitchen => isSpanish ? 'En Cocina' : 'In Kitchen';
  String get trackingReady => isSpanish ? 'Listo' : 'Ready';
  String get trackingYourSelection =>
      isSpanish ? 'Tu Selección' : 'Your Selection';
  String trackingItemCount(int n) =>
      isSpanish ? '$n artículo${n == 1 ? '' : 's'}' : '$n item${n == 1 ? '' : 's'}';
  String get trackingPayment => isSpanish ? 'Pago' : 'Payment';
  String get trackingPayWait => isSpanish
      ? 'Puedes pagar ahora o esperar a recibir tu pedido.'
      : 'You can pay now or wait until you receive your order.';
  String get trackingPayNow => isSpanish ? 'Pagar Pedido' : 'Pay Order';
  String get trackingExploreAction => isSpanish ? 'Explorar' : 'Explore';
  String get trackingIaOrder => isSpanish ? '✦ IA Order' : '✦ AI Order';

  // ── Payment ──────────────────────────────────────────────────────────────────
  String get paymentTitle => isSpanish ? 'Pago y Comanda' : 'Payment & Order';
  String get paymentTotal => isSpanish ? 'Monto Total' : 'Total Amount';
  String get paymentMethod =>
      isSpanish ? 'Selecciona Método de Pago' : 'Select Payment Method';
  String get paymentDigital => isSpanish ? 'Pago Digital' : 'Digital Payment';
  String get paymentCash => isSpanish ? 'Pago en Efectivo' : 'Cash Payment';
  String get paymentFinish =>
      isSpanish ? 'Finalizar Visita' : 'End Visit';

  // ── History ──────────────────────────────────────────────────────────────────
  String get historyTitle =>
      isSpanish ? 'Historial de pedidos' : 'Order history';
  String get historyEmpty => isSpanish ? 'Sin historial' : 'No history';
  String get historyEmptySub => isSpanish
      ? 'Tus pedidos anteriores\naparecerán aquí.'
      : 'Your previous orders\nwill appear here.';

  // ── Navigation (customer) ────────────────────────────────────────────────────
  String get navIa => isSpanish ? 'IA' : 'AI';
  String get navMenu => isSpanish ? 'Menú' : 'Menu';
  String get navOrders => isSpanish ? 'Pedidos' : 'Orders';
  String get navHistory => isSpanish ? 'Historial' : 'History';
  String get navProfile => isSpanish ? 'Perfil' : 'Profile';

  // ── Navigation (admin) ───────────────────────────────────────────────────────
  String get adminNavHome => isSpanish ? 'Inicio' : 'Home';
  String get adminNavOrders => isSpanish ? 'Comandas' : 'Orders';
  String get adminNavMenu => isSpanish ? 'Menu' : 'Menu';
  String get adminNavProfile => isSpanish ? 'Perfil' : 'Profile';

  // ── AI Concierge ─────────────────────────────────────────────────────────────
  String get iaListening =>
      isSpanish ? 'ESCUCHANDO TUS ANTOJOS...' : 'LISTENING TO YOUR CRAVINGS...';
  String get iaPlaceholder => isSpanish ? 'Escribe aquí...' : 'Type here...';
  String get iaOfflineNotice => isSpanish
      ? 'La IA no está disponible sin conexión. Explora el menú para hacer tu pedido.'
      : 'AI is not available offline. Explore the menu to place your order.';
  String get iaChip1 =>
      isSpanish ? 'Recomiéndame algo saludable' : 'Recommend something healthy';
  String get iaChip2 =>
      isSpanish ? 'Quiero algo con mucho sabor' : 'I want something flavorful';
  String get iaChip3 =>
      isSpanish ? 'Una bebida refrescante' : 'A refreshing drink';
  String get iaChip4 =>
      isSpanish ? 'El plato especial del chef' : "The chef's special dish";
  String get cancelOrder => isSpanish ? 'Cancelar' : 'Cancel';
  String get confirmOrder => isSpanish ? 'Confirmar pedido' : 'Confirm order';

  // ── Smart cart ────────────────────────────────────────────────────────────────
  String get cartYourSelection =>
      isSpanish ? 'TU SELECCION' : 'YOUR SELECTION';
  String get cartTitle => isSpanish ? 'Carrito Inteligente' : 'Smart Cart';
  String get cartEmpty =>
      isSpanish ? 'Tu carrito esta vacio' : 'Your cart is empty';
  String get cartEmptySub => isSpanish
      ? 'Agrega platos desde el menu para construir tu pedido y desbloquear maridajes de IA.'
      : 'Add dishes from the menu to build your order and unlock AI pairings.';
  String get cartBrowse => isSpanish ? 'Ver Menu' : 'Browse Menu';
  String get cartSubtotal => 'Subtotal';
  String get cartServiceFee =>
      isSpanish ? 'Tarifa de servicio' : 'Delivery Fee';
  String get cartFree => isSpanish ? 'GRATIS' : 'FREE';
  String get cartTotal => isSpanish ? 'TOTAL' : 'TOTAL AMOUNT';
  String get cartCheckout => isSpanish ? 'PAGAR' : 'CHECKOUT';

  // ── Catalog ───────────────────────────────────────────────────────────────────
  String get menuEmptyCategory =>
      isSpanish ? 'No hay platos en esta categoría' : 'No dishes in this category';

  // ── Admin (additions) ────────────────────────────────────────────────────────
  String get adminTableLabel => isSpanish ? 'Mesa' : 'Table';
  String get adminReleaseTableTitle => isSpanish ? 'Liberar mesa' : 'Release table';
  String get adminReleaseTableContent => isSpanish
      ? 'La mesa quedará disponible para nuevos clientes. Si tiene una orden activa, se marcará como completada.'
      : 'The table will become available for new customers. If it has an active order, it will be marked as completed.';
  String get adminComanda => isSpanish ? 'Comanda' : 'Order';
  String get adminWithOrder => isSpanish ? 'Con pedido' : 'With order';
  String get cancelar => isSpanish ? 'Cancelar' : 'Cancel';
  String get confirmar => isSpanish ? 'Confirmar' : 'Confirm';

  // ── KDS (additions) ──────────────────────────────────────────────────────────
  String get kdsCashPending =>
      isSpanish ? 'Pago Efectivo Pendiente' : 'Cash Payment Pending';
  String get kdsRequestsClosing =>
      isSpanish ? 'solicita cierre de cuenta' : 'requests account closure';
  String get kdsJustArrived => isSpanish ? 'Recién llegada' : 'Just arrived';
  String kdsMinutesAgo(int n) =>
      isSpanish ? 'Hace $n min' : '$n min ago';
  String get kdsOrderDetail =>
      isSpanish ? 'Detalle de Comanda' : 'Order Detail';
  String get kdsOpen => isSpanish ? 'Abierta' : 'Open';
  String get kdsSubtotal => 'Subtotal';
  String get kdsServiceFee => isSpanish ? 'Servicio (10%)' : 'Service (10%)';
  String get kdsTotal => isSpanish ? 'Total' : 'Total';
  String get kdsCloseAndRelease =>
      isSpanish ? 'Cerrar pedido y liberar mesa' : 'Close order & release table';
  String get kdsAwaitingPayment =>
      isSpanish ? 'Esperando confirmación de pago' : 'Awaiting payment confirmation';
  String get kdsCashMessage => isSpanish
      ? 'Pago en efectivo solicitado. Confírmalo con el botón naranja (💳).'
      : 'Cash payment requested. Confirm it with the orange button (💳).';
  String get kdsDigitalMessage => isSpanish
      ? 'Pago digital pendiente. Toca "Verificar" para comprobar.'
      : 'Digital payment pending. Tap "Verify" to check.';
  String get kdsVerify => isSpanish ? 'Verificar' : 'Verify';
  String get kdsNoOrders =>
      isSpanish ? 'Sin órdenes activas' : 'No active orders';
  String get kdsNoOrdersSub => isSpanish
      ? 'Las nuevas comandas aparecerán aquí\nen tiempo real.'
      : 'New orders will appear here\nin real time.';
  String kdsConfirmCashQuestion(String tableLabel, String amount) => isSpanish
      ? '¿Confirmar pago en efectivo de $tableLabel por $amount?'
      : 'Confirm cash payment from $tableLabel for $amount?';
  String get kdsTurn => isSpanish ? 'TURNO' : 'TURN';
  List<String> get monthAbbreviations => isSpanish
      ? ['', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic']
      : ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  // ── Menu management (additions) ──────────────────────────────────────────────
  String get menuEmptyList => isSpanish
      ? 'No hay platos en el menú. Añade el primero.'
      : 'No dishes in the menu. Add the first one.';
  String get menuEditItem => isSpanish ? 'Editar Plato' : 'Edit Dish';
  String get menuSaveChanges => isSpanish ? 'Guardar Cambios' : 'Save Changes';
  String get menuCancelEdit =>
      isSpanish ? 'Cancelar edición' : 'Cancel editing';
  String get menuDeleteTitle =>
      isSpanish ? '¿Eliminar plato?' : 'Delete dish?';
  String menuDeleteContent(String name) => isSpanish
      ? '¿Seguro que quieres eliminar "$name"? Esta acción no se puede deshacer.'
      : 'Are you sure you want to delete "$name"? This action cannot be undone.';
  String get menuDeleteButton => isSpanish ? 'Eliminar' : 'Delete';
  String get menuRequired =>
      isSpanish ? 'Nombre y precio son obligatorios' : 'Name and price are required';
  String get menuPublishedSuccess => isSpanish
      ? '¡Plato publicado! Ya está disponible para los clientes'
      : 'Dish published! Now available to customers';
  String get menuFieldName => isSpanish ? 'Nombre del Plato*' : 'Dish Name*';
  String get menuFieldPrice => isSpanish ? 'Precio (\$)*' : 'Price (\$)*';
  String get menuFieldCategory => isSpanish ? 'Categoría' : 'Category';
  String get menuFieldIngredients => isSpanish ? 'Ingredientes' : 'Ingredients';
  String get menuFieldDescription => isSpanish ? 'Descripción' : 'Description';
  String get menuFieldImage =>
      isSpanish ? 'Imagen de referencia' : 'Reference image';
}
