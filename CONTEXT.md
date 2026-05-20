# OrdeNow — Documento de Contexto del Proyecto

## ¿Qué es OrdeNow?

OrdeNow es una aplicación móvil de gestión de comandas para restaurantes, construida en Flutter. El concepto central es que **el mesero es una IA**: el cliente interactúa directamente con un asistente virtual que recomienda platos, registra pedidos y conecta al cliente en tiempo real con la cocina. El administrador del restaurante gestiona mesas, menú, pedidos y pagos desde su propio panel.

---

## Roles de usuario

### Cliente
- Se registra e inicia sesión en la app.
- Selecciona su mesa (en tiempo real, las mesas ocupadas se bloquean).
- Interactúa con el **Mesero IA** por chat o voz para recibir recomendaciones y hacer su pedido.
- Agrega platos al carrito, realiza el checkout y hace seguimiento en tiempo real del estado de su pedido.
- Puede pagar en cualquier momento (antes o después de recibir la comida):
  - **Tarjeta/transferencia**: flujo digital simulado; no cierra el estado del pedido, el cliente sigue en la pantalla de seguimiento.
  - **Efectivo**: genera una `cash_request` en Supabase; el admin la confirma desde el KDS.
- Perfil con alergias y preferencias que la IA usa para filtrar recomendaciones.

### Administrador
- Panel con vista de todas las mesas ocupadas en tiempo real.
- Gestión de menú: crear, editar y eliminar platos.
- Sistema KDS (Kitchen Display System): visualiza y actualiza el estado de cada pedido.
- Estadísticas del día: ventas totales, pedidos activos (solo del día de hoy), ticket promedio.
- **No puede liberar una mesa hasta que el pago esté confirmado** (`paid = true` en `orders`).
- Al liberar una mesa desde el KDS, ambos providers (`OrdersKdsProvider` y `AdminDashboardProvider`) se actualizan optimistamente de inmediato.

---

## Stack tecnológico

| Capa | Tecnología |
|------|-----------|
| Frontend | Flutter (Dart), SDK ^3.11.0 |
| Estado | Provider (ChangeNotifier) |
| Backend | Supabase (PostgreSQL + Auth + Realtime + Storage + Edge Functions) |
| IA | Groq `llama-3.1-8b-instant` vía Supabase Edge Function (Deno/TypeScript) |
| Voz (entrada) | `speech_to_text ^7.3.0` — STT en español (es_CO) |
| Voz (salida) | `flutter_tts ^4.0.2` — TTS en español |
| Almacenamiento local | Hive (caché de sesión, menú, órdenes, tema) |

---

## Arquitectura del código (Clean Architecture)

```
lib/
├── core/
│   ├── config/          # Supabase, bootstrap de la app
│   ├── services/        # AiService, SyncService, NotificationService
│   ├── theme/           # Tema oscuro/claro
│   └── utils/           # Constants, AppCopy (i18n ES/EN), OrderStatuses
├── data/
│   ├── datasources/
│   │   ├── local/       # Hive: auth, menú, órdenes, mesas
│   │   └── remote/      # SupabaseService + OrderRemoteDataSource
│   ├── models/          # MenuModel, OrderModel, UserModel, TableModel
│   └── repositories/    # Implementaciones de repositorios
├── domain/
│   ├── entities/        # Menu, Order, User, TableEntity
│   ├── repositories/    # Interfaces/contratos
│   └── usecases/        # Login, Register, CreateOrder, UpdateProfile, etc.
└── presentation/
    ├── providers/        # State management (ChangeNotifier)
    ├── screens/          # Pantallas de admin y cliente
    └── widgets/          # AiChatBox, AiMessageBubble, etc.
```

---

## Base de datos (Supabase / PostgreSQL)

### Tablas principales

**`users`**
```
id, email, full_name, password, role (client|admin),
allergies (jsonb), preferences (jsonb), created_at, updated_at
```

**`restaurant_tables`**
```
id, number (unique), occupied (bool), needs_payment (bool)
```
- 20 mesas generadas por migración.

**`menu_items`**
```
id, name, description, price, category, available (bool),
recommended (bool), tags (jsonb), image_url
```

**`orders`**
```
id, user_id (→ users), table_id (→ restaurant_tables),
items (jsonb array de IDs), status, paid (bool), payment_method,
total_amount, notes, synced, created_at, updated_at
```
- Ciclo de estados: `pending → accepted → preparing → ready → delivered → completed`
- `paid` y `payment_method` se actualizan al confirmar cualquier tipo de pago.
- **IMPORTANTE**: Supabase Realtime no dispara confiablemente para cambios en la columna `paid`. El KDS usa `refreshPaymentStatus()` (consulta directa) para verificar el estado real.

**`cash_requests`**
```
id, order_id, table_id, amount, method, status (pending|confirmed),
created_at, updated_at
```
- Se crea cuando el cliente elige pago en efectivo en la pantalla de checkout.
- El admin la confirma desde el FAB naranja (💳) en el KDS.

---

## Integración de IA

### Flujo completo
1. El cliente escribe o habla en el chat del Mesero IA.
2. Flutter llama a `AiService.generateConciergeReply()`.
3. `AiService` invoca la Supabase Edge Function `ordenow-ai-concierge`.
4. La Edge Function llama a Groq `llama-3.1-8b-instant` con `response_format: { type: "json_object" }`.
5. La respuesta llega al chat. Si TTS está activo, también se reproduce por voz.
6. Si la IA detecta una acción (agregar al carrito, confirmar pedido, ir a pago), la ejecuta automáticamente.

### Payload enviado a la Edge Function
```json
{
  "prompt": "lo que escribió el cliente",
  "table_number": 5,
  "order_status": "preparing",
  "allergies": ["gluten", "mariscos"],
  "dining_preferences": "vegetariano",
  "cart_items": ["Ribeye Angus", "Agua mineral"],
  "menu": [ ...lista de platos disponibles... ],
  "conversation_history": [ ...últimas 8 mensajes... ]
}
```

### Acciones que puede devolver la IA
| Acción | Sin pedido activo | Con pedido activo |
|--------|-------------------|-------------------|
| `none` | Solo respuesta de texto | Solo respuesta de texto |
| `add_to_cart` | Agrega al carrito local | Agrega al carrito local |
| `confirm_order` | Muestra botones confirmar/cancelar → luego `create_order` | Muestra botones → luego `append_to_active_order` |
| `create_order` | Crea nueva orden en Supabase | **Redirigido a `appendItemsToActiveOrder()`** — nunca crea orden nueva si ya existe una |
| `update_order` | Agrega al carrito local | **Llama `appendItemsToActiveOrder()`** — actualiza la orden activa en Supabase |
| `go_to_payment` | Navega al checkout | Navega al checkout |

> **Invariante crítico**: `AiProvider._executeAction()` garantiza que nunca se crea una segunda orden cuando ya hay una activa. Siempre se redirige a `OrderProvider.appendItemsToActiveOrder()`.

### Campo `has_active_order` en el payload
Se envía `has_active_order: true/false` al Edge Function para que el modelo sepa si debe sugerir agregar a la orden existente o crear una nueva.

### Edge Function
- Archivo: `supabase/functions/ordenow-ai-concierge/index.ts`
- Runtime: Deno (TypeScript)
- Si la Edge Function falla, Flutter tiene un fallback local de búsqueda por palabras clave en el menú.

---

## Entrada de voz (AiChatBox)

**Archivo**: `lib/presentation/widgets/ai_chat_box.dart`

### Flujo UX
1. El usuario toca el botón de micrófono (izquierda) — la primera vez el sistema **solicita permiso de micrófono**.
2. Mientras escucha: el botón se torna naranja con glow y cambia a ícono de stop. El campo de texto muestra "Escuchando..." en naranja y el borde del campo se ilumina.
3. El usuario toca el botón de stop para terminar — el texto transcrito queda en el campo **sin enviarse**.
4. El usuario puede **revisar y editar** el texto antes de enviarlo.
5. Envío: toca el botón naranja de enviar (↑) que aparece animado, o presiona Enter.

### Implementación
- Inicialización **lazy**: `_initSpeech()` NO se llama en `initState`. Solo se llama cuando el usuario toca el micrófono por primera vez, garantizando que el permiso se pida en el momento correcto.
- `_hasText`: estado booleano reactivo que escucha al `TextEditingController` — controla la visibilidad animada del botón de envío.
- `localeId: 'es_CO'`, `listenFor: 30s`, `pauseFor: 4s`.
- Si el permiso es denegado, muestra un `SnackBar` informativo.

### Permisos configurados
- **Android** (`AndroidManifest.xml`): `RECORD_AUDIO` + `INTERNET`
- **iOS** (`Info.plist`): `NSMicrophoneUsageDescription` + `NSSpeechRecognitionUsageDescription`

---

## Pantallas principales del cliente

| Pantalla | Descripción |
|----------|-------------|
| Bienvenida | Landing con hero image y botón "Iniciar" |
| Login / Registro | Formulario con roles (cliente/admin), campos de email y contraseña |
| Selección de mesa | Grid de mesas en tiempo real. Las ocupadas están bloqueadas |
| IA Concierge | Chat con el Mesero IA. Chips de sugerencias rápidas, entrada de voz y botón de envío |
| Menú | Grid de platos con filtro por categoría, precio y botón "Ordenar con IA" |
| Carrito | Lista de items con controles de cantidad, subtotal y botón de pagar |
| Checkout/Pago | Elige tarjeta (simulado) o efectivo (genera cash_request). Accesible desde el seguimiento también |
| Seguimiento | Progreso del pedido en tiempo real. Muestra opción de pagar si aún no se ha pagado |
| Historial | Lista de platos del último pedido (persiste aunque la sesión haya terminado) |
| Perfil | Configuración de alergias, preferencias, idioma y tema |

### Navegación del cliente (CustomerScreen enum)
```
welcome → signIn/signUp → tableSelection → ai (concierge) → menu → cart → checkout → tracking → history → profile
```
- La app usa `IndexedStack` para mantener todas las vistas vivas (el estado no se destruye al cambiar de pestaña).
- `AppDemoProvider.setCustomerScreen()` maneja la navegación interna.

---

## Pantallas principales del administrador

| Pantalla | Descripción |
|----------|-------------|
| Home | Grid de mesas ocupadas con estado, total de la orden y botón liberar |
| Estadísticas | Ventas del día (filtradas a hoy), pedidos activos, ticket promedio |
| Gestión de Menú | CRUD completo de platos: nombre, descripción, precio, categoría, tags, imagen, disponibilidad |
| KDS (Comandas) | Lista de pedidos activos con botones para avanzar estado y cobrar. Vista en tiempo real |
| Perfil admin | Información de cuenta y opción de cerrar sesión |

---

## Flujo de pago

### Efectivo
1. Cliente elige efectivo en checkout → se crea `cash_request` en Supabase.
2. En el KDS aparece un FAB naranja (💳) y un banner de alerta.
3. Admin confirma con el botón → `cash_request.status = confirmed`, `order.status = completed`, `table.occupied = false`.
4. `AdminDashboardProvider` se actualiza optimistamente → la mesa desaparece del home.

### Tarjeta/Transferencia digital
1. Cliente elige tarjeta en checkout → se simula el pago, `order.paid = true`, `order.payment_method = 'card'`.
2. El cliente vuelve a la pantalla de seguimiento (no se borra el estado del pedido).
3. En el KDS, el botón "Cerrar pedido" estaba bloqueado. Como Realtime no dispara confiablemente para `paid`, el KDS usa `refreshPaymentStatus()` para consultar directamente.
4. Una vez verificado `paid = true`, el admin puede liberar la mesa.

---

## Estado en tiempo real (Supabase Realtime)

| Stream | Consumidor | Notas |
|--------|-----------|-------|
| `watchTables()` | `AdminDashboardProvider` | Se actualiza al ocupar/liberar mesas |
| `watchAllOrders()` | `AdminDashboardProvider` | Todos los pedidos; se filtra por hoy para stats |
| `watchActiveOrders()` | `OrdersKdsProvider` | Solo pedidos en estado activo |
| `watchOrdersByUser()` | `OrderProvider` (cliente) | Estado del pedido en tiempo real |
| `watchMenu()` | Catálogo de menú | Cambios del admin se reflejan al cliente |
| `watchAllPendingCashRequests()` | `OrdersKdsProvider` | Cash requests pendientes para el KDS |

**Limitación conocida**: Supabase Realtime no dispara confiablemente cuando solo cambia la columna `paid`. Solución: `refreshPaymentStatus()` en `OrdersKdsProvider` hace una consulta directa a Supabase.

---

## Providers clave

### `OrderProvider` (`order_provider.dart`)
- `_activeOrder`: pedido activo actual.
- `_completedOrder`: último pedido completado (persiste para el historial).
- `historyItems`: devuelve items de `_activeOrder ?? _completedOrder`.
- `clearDemoState()`: guarda `_activeOrder` en `_completedOrder` antes de limpiar.
- `loadUserSession()`: retorna `true` si hay pedido activo; `false` si no (y pobla `_completedOrder` con el último pedido completado de Supabase).
- `finalizeDigitalPayment()`: marca `paid = true` localmente y en Supabase sin limpiar el estado.

### `OrdersKdsProvider` (`orders_kds_provider.dart`)
- `KdsActiveOrder`: modelo local con campos `paid` y `paymentMethod`.
- `refreshPaymentStatus(orderId)`: consulta Supabase directamente para actualizar `paid`/`paymentMethod`.
- `releaseTable()`: actualización optimista (elimina de `_activeOrders`) + llama a Supabase.
- `confirmCashPayment()`: actualización optimista de orden y cash_request + llama a Supabase.
- `startPreparation()`, `markReady()`: actualizaciones optimistas de estado.

### `AdminDashboardProvider` (`admin_dashboard_provider.dart`)
- `occupiedTables`: mesas con `occupied = true` o `needsPayment = true`, ordenadas por número.
- `activeOrders` (getter): filtra pedidos activos **solo del día de hoy**.
- `releaseTable(tableId)`: actualización optimista + dos try-catch independientes (uno para `updateOrderStatus`, otro para `updateTableStatus`) para que un fallo no bloquee al otro.

### `AiProvider` (`ai_provider.dart`)
- `sendMessage()`, `sendGreeting()`: llaman a `AiService`.
- `toggleTts()`: activa/desactiva text-to-speech.
- `confirmPendingOrder()`, `cancelPendingOrder()`: gestión del flujo de confirmación de pedido por IA.
- Guarda el historial de conversación (últimas 8 mensajes).

---

## Internacionalización (i18n)

- Soporte ES/EN mediante la clase `AppCopy` (`lib/core/utils/app_copy.dart`).
- Toggle de idioma disponible en todas las pantallas.
- La IA siempre responde en español colombiano (instrucción en el system prompt).

---

## Moneda

- Todo en **COP (pesos colombianos)**.
- Formato con puntos como separador de miles: `$28.500`, `$120.000`.

---

## Credenciales de prueba (entorno de desarrollo)

- Admin: `admin@ordenow.com` / `12345678`
- Los clientes se registran con su email real desde la app.

---

## Comandos útiles

```bash
# Correr la app en emulador
flutter run

# Analizar errores de código
dart analyze lib/

# Desplegar Edge Function de IA (después de cambios en index.ts)
supabase functions deploy ordenow-ai-concierge

# Ver logs del Edge Function en tiempo real
supabase functions logs ordenow-ai-concierge --tail
```

---

## Estado actual del proyecto (Mayo 2026)

- Auth con Supabase funcional (login y registro).
- Menú cargado desde Supabase con imágenes en Storage.
- Mesas en tiempo real (20 mesas). Selección bloquea mesas ocupadas.
- Flujo de pedido completo: carrito → checkout → seguimiento → historial.
- Pago antes o después de recibir la comida (efectivo o digital).
- KDS funcional: avance de estado + gate de pago antes de liberar mesa.
- Al liberar mesa en KDS, el home del admin se actualiza inmediatamente (sin esperar Realtime).
- IA conectada a Groq `llama-3.1-8b-instant` vía Edge Function. Fallback local si falla.
- Saludo personalizado de la IA al abrir el chat (usa nombre, alergias y preferencias del usuario).
- Entrada de voz: micrófono en el chat con permiso lazy, transcripción editable antes de enviar, botón de envío animado.
- Tema oscuro/claro persistido en Hive.
- Estadísticas del admin muestran datos reales filtrados por el día actual.
- Sesión: re-login después de un pedido completado va a selección de mesa (no bloquea el flujo).
