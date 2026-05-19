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
- Puede pagar con tarjeta (inmediato) o solicitar el pago en efectivo en caja.
- Tiene perfil con alergias y preferencias que la IA usa para filtrar recomendaciones.

### Administrador
- Panel con vista de todas las mesas ocupadas en tiempo real.
- Gestión de menú: crear, editar y eliminar platos.
- Sistema KDS (Kitchen Display System): visualiza y actualiza el estado de cada pedido (pendiente → aceptado → preparando → listo → entregado → completado).
- Estadísticas del día: ventas totales, pedidos activos, ticket promedio.
- Puede liberar mesas cuando el cliente termina.

---

## Stack tecnológico

| Capa | Tecnología |
|------|-----------|
| Frontend | Flutter (Dart), SDK ^3.11.0 |
| Estado | Provider (ChangeNotifier) |
| Backend | Supabase (PostgreSQL + Auth + Realtime + Storage + Edge Functions) |
| IA | OpenAI GPT-4o-mini vía Supabase Edge Function (Deno/TypeScript) |
| Almacenamiento local | Hive (caché de sesión, menú, órdenes) |
| Voz | speech_to_text + flutter_tts (entrada y salida de voz para el chat IA) |

---

## Arquitectura del código (Clean Architecture)

```
lib/
├── core/
│   ├── config/          # Supabase, bootstrap de la app
│   ├── services/        # AiService, SyncService, NotificationService
│   ├── theme/           # Tema oscuro/claro
│   └── utils/           # Constants, AppCopy (i18n ES/EN), helpers
├── data/
│   ├── datasources/
│   │   ├── local/       # Hive: auth, menú, órdenes, mesas
│   │   └── remote/      # SupabaseService + datasources remotos
│   ├── models/          # MenuModel, OrderModel, UserModel, TableModel
│   └── repositories/    # Implementaciones de repositorios
├── domain/
│   ├── entities/        # Menu, Order, User, TableEntity
│   ├── repositories/    # Interfaces/contratos
│   └── usecases/        # Login, Register, CreateOrder, UpdateProfile, etc.
└── presentation/
    ├── providers/        # State management (ChangeNotifier)
    ├── screens/          # Pantallas de admin y cliente
    └── widgets/          # Componentes reutilizables
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
- Las imágenes están en Supabase Storage o en URLs externas.

**`orders`**
```
id, user_id (→ users), table_id (→ restaurant_tables),
items (jsonb), status, paid (bool), payment_method,
total_amount, notes, synced, created_at, updated_at
```
- Ciclo de estados: `pending → accepted → preparing → ready → delivered → completed`

**`cash_requests`**
```
id, order_id, table_id, amount, method, status (pending|completed),
created_at, updated_at
```

---

## Integración de IA

### Flujo completo
1. El cliente escribe o habla en el chat de la pantalla IA.
2. Flutter llama a `AiService.generateConciergeReply()`.
3. `AiService` invoca la Supabase Edge Function `ordenow-ai-concierge`.
4. La Edge Function llama a OpenAI GPT-4o-mini con todo el contexto.
5. La respuesta llega al chat del cliente en texto. Si TTS está activo, también por voz.

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
  "recommended_menu": [ ...misma lista... ]
}
```

### Respuesta esperada
```json
{ "reply": "texto de respuesta de la IA" }
```

### Edge Function
- Archivo: `supabase/functions/ordenow-ai-concierge/index.ts`
- Runtime: Deno (TypeScript)
- Endpoint OpenAI: `POST /v1/chat/completions`
- Modelo: `gpt-4o-mini`
- Secret en Supabase: `OPENAI_API_KEY`
- Si la IA falla, Flutter tiene un fallback local de búsqueda por palabras clave en el menú.

---

## Pantallas principales del cliente

| Pantalla | Descripción |
|----------|-------------|
| Bienvenida | Landing con hero image y botón "Iniciar" |
| Login / Registro | Formulario con roles (cliente/admin), campos de email y contraseña |
| Selección de mesa | Grid de mesas en tiempo real. Las ocupadas están bloqueadas |
| IA Concierge | Chat con el Mesero IA. Chips de sugerencias rápidas + entrada de voz |
| Menú | Grid de platos con filtro por categoría, precio y botón "Ordenar con IA" |
| Carrito | Lista de items con controles de cantidad, subtotal y botón de pagar |
| Checkout/Pago | Elige tarjeta (inmediato) o efectivo (genera cash_request para el admin) |
| Seguimiento | Progreso del pedido en tiempo real: Recibido → Cocinando → Reparto → Entregado |
| Historial | Lista de platos pedidos en sesiones anteriores |
| Perfil | Configuración de alergias, preferencias, idioma y tema |

---

## Pantallas principales del administrador

| Pantalla | Descripción |
|----------|-------------|
| Home | Grid de mesas ocupadas con estado, total de la orden y botón liberar |
| Estadísticas | Ventas del día, pedidos activos, ticket promedio (datos reales de Supabase) |
| Gestión de Menú | CRUD completo de platos: nombre, descripción, precio, categoría, tags, imagen, disponibilidad |
| KDS (Comandas) | Lista de pedidos activos con botones para avanzar estado. Vista en tiempo real |
| Perfil admin | Información de cuenta y opción de cerrar sesión |

---

## Estado en tiempo real

Todos los datos críticos usan **Supabase Realtime** (streams):
- `watchTables()` → admin ve mesas ocupadas al instante.
- `watchAllOrders()` → admin ve nuevos pedidos en KDS sin refrescar.
- `watchOrdersByUser()` → cliente ve el avance de su pedido en tiempo real.
- `watchMenu()` → si el admin cambia el menú, el cliente lo ve de inmediato.

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

## Estado actual del proyecto

- Auth con Supabase funcional (login y registro).
- Menú cargado desde Supabase con imágenes en Storage.
- Mesas en tiempo real (20 mesas).
- Flujo de pedido completo: carrito → checkout → seguimiento.
- KDS funcional para el admin.
- IA conectada a GPT-4o-mini vía Edge Function. Tiene fallback local si la Edge Function falla.
- Saludo personalizado de la IA al abrir el chat (usa el nombre del usuario desde Supabase Auth).
- Tema oscuro/claro persistido en Hive.
