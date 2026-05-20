# OrdeNow

Sistema de pedidos para restaurantes con concierge de IA. Los clientes hacen sus pedidos desde el celular, el admin gestiona el menú y monitorea mesas en tiempo real, y la cocina recibe las comandas al instante.

---

## Tecnologías

| Capa | Tecnología |
|---|---|
| Frontend | Flutter 3 · Dart 3.11+ |
| State management | Provider / ChangeNotifier |
| Base de datos remota | Supabase (PostgreSQL + Realtime) |
| Base de datos local | Hive (caché offline) |
| IA | Claude Haiku 4.5 via Supabase Edge Function (Deno/TypeScript) |
| Voz | `speech_to_text` (STT) · `flutter_tts` (TTS) |
| Conectividad | `connectivity_plus` |
| Variables de entorno | `flutter_dotenv` (archivo `.env`) |

---

## Arquitectura

Sigue **Clean Architecture** con tres capas:

```
lib/
├── domain/          # Entidades puras (Menu, Order, User, Table…)
│                    # No depende de Flutter ni de Supabase
├── data/
│   ├── models/      # JSON ↔ entidad (OrderModel, UserModel…)
│   └── datasources/
│       ├── remote/  # SupabaseService, AuthRemoteDataSource,
│       │            # OrderRemoteDataSource…
│       └── local/   # HiveService (caché offline)
└── presentation/
    ├── providers/   # Estado de la app (ChangeNotifier)
    └── screens/     # UI
```

### Providers principales

| Provider | Responsabilidad |
|---|---|
| `AuthProvider` | Login, registro, sesión activa, rol (admin/client) |
| `OrderProvider` | Carrito, orden activa, historial, pago, sincronización |
| `AiProvider` | Chat con el concierge, TTS, acción pendiente de confirmar |
| `AdminDashboardProvider` | Mesas ocupadas, estadísticas del día en tiempo real |
| `OrdersKdsProvider` | Lista de comandas activas para la cocina |
| `AppDemoProvider` | Navegación entre tabs (admin y cliente) |
| `AppSettingsProvider` | Idioma y modo de tema |
| `ConnectivityProvider` | Estado de red (online/offline) |

---

## Base de datos (Supabase)

.env
SUPABASE_URL= https://jzkosbnlvdtjbjnofapj.supabase.co
SUPABASE_ANON_KEY= eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp6a29zYm5sdmR0amJqbm9mYXBqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ0NjQwOTUsImV4cCI6MjA5MDA0MDA5NX0.TqgiByFB8sC-8qZ7x95m6nJhzDNmF_lVindSLerIk_w

### Tablas

```
users
  id, email, full_name, password, role (admin|client),
  allergies (jsonb), preferences (jsonb), created_at, updated_at

restaurant_tables
  id, number, occupied, needs_payment

menu_items
  id, name, description, price, category, available,
  recommended, tags (jsonb), image_url

orders
  id, user_id → users, table_id → restaurant_tables,
  items (jsonb — array de IDs de menu_items),
  status (pending|accepted|preparing|ready|completed|paid),
  paid, payment_method (cash|digital), total_amount,
  notes, synced, created_at, updated_at

cash_requests
  id, order_id → orders, table_id → restaurant_tables,
  amount, method, status (pending|approved|rejected), created_at, updated_at
```

### Realtime

Los streams de Flutter usan `.stream(primaryKey: ['id'])` de `supabase_flutter`.  
Para que los **UPDATE** de órdenes lleguen al KDS en tiempo real se requiere:

```sql
ALTER PUBLICATION supabase_realtime ADD TABLE orders;
ALTER TABLE orders REPLICA IDENTITY FULL;
```

Sin esto, solo los INSERT se propagan; los cambios en items/estado de una orden existente no llegan al admin hasta que recargue.

### Migraciones

```
supabase/migrations/
├── ordenow_core_schema.sql   # Tablas, admin por defecto, 20 mesas
└── seed_full_menu.sql        # Menú completo de ejemplo
```

---

## Concierge de IA

### Versión del modelo
**Claude Haiku 4.5** (`claude-haiku-4-5-20251001`) — equilibrio entre velocidad y calidad para respuestas de restaurante.

### Flujo completo

```
Cliente escribe/habla
        │
        ▼
AiProvider.sendMessage()
        │  contexto: menú, carrito, estado orden, alergias,
        │            preferencias, historial de pedidos (últimos 20 platos)
        ▼
AiService.generateConciergeReply()
        │
        ▼
Supabase Edge Function  ←──────────────────────┐
(supabase/functions/ordenow-ai-concierge/)      │
        │  POST a Anthropic API                 │
        │  System prompt + historial de chat    │
        ▼                                       │
Claude Haiku 4.5                               │
        │  responde con JSON estructurado        │
        ▼                                       │
{ reply, action, action_data }                  │
        │                                       │
        ▼                                       │
AiProvider._executeAction()                     │
  - add_to_cart   → agrega al carrito local     │
  - confirm_order → muestra resumen al usuario  │
  - create_order  → crea orden en Supabase ─────┘
  - update_order  → agrega ítems a orden activa
  - go_to_payment → navega a pantalla de pago
        │
        ▼
FlutterTTS lee la respuesta en voz alta (si TTS activo)
```

### Contexto que recibe la IA en cada mensaje

```json
{
  "prompt": "texto del usuario",
  "table_number": 5,
  "order_status": "preparing",
  "has_active_order": true,
  "allergies": ["mariscos"],
  "dining_preferences": "vegetariano",
  "cart_items": [...],
  "order_history": ["Bandeja paisa", "Limonada de coco", ...],
  "menu": [{ "id", "name", "description", "price", "category",
             "recommended", "tags" }]
}
```

`order_history` contiene los nombres de los últimos 20 platos pedidos por el usuario en visitas anteriores (guardados en Hive) — la IA los usa para personalizar el saludo y las recomendaciones.

### Reglas del System Prompt (resumen)

1. Solo responde JSON válido — sin texto fuera del JSON
2. Si `has_active_order=true` nunca usa `create_order`, usa `update_order`
3. Flujo obligatorio: recomendar → `confirm_order` → esperar confirmación → `create_order`/`update_order`
4. Nunca inventa platos — solo usa los del campo `menu`
5. No recomienda platos con alérgenos del cliente
6. Tras confirmar un pedido con platos principales sin bebidas, sugiere 1-2 bebidas del menú
7. `update_order` solo incluye ítems nuevos, nunca repite los ya pedidos
8. Si el historial no está vacío, personaliza el saludo mencionando visitas anteriores

---

## Caché offline (Hive)

| Box | Contenido |
|---|---|
| `settings_box` | Tema, idioma, userId activo, tableId seleccionada, historial de pedidos (`order_history_{userId}`) |
| `user_box` | Perfil del usuario serializado |
| `order_box` | Orden activa (con flag `synced: bool`) |
| `menu_box` | Menú completo cacheado |
| `table_box` | Estado de mesas cacheado |

Si la app arranca sin red, lee de Hive. Al recuperar conexión, `SyncService` reintenta sincronizar las órdenes no sincronizadas (`synced: false`).

---

## Roles de usuario

| Rol | Acceso |
|---|---|
| **admin** | Dashboard de mesas, gestión de menú, KDS (comandas), perfil |
| **client** | Chat con IA, catálogo, seguimiento de pedido, historial, perfil |

El rol se determina en `AuthProvider` al hacer login leyendo el campo `role` de la tabla `users`.  
El admin por defecto es `admin@ordenow.com` / `12345678`.

---

## Pantallas

```
Autenticación
  WelcomeScreen → SignInScreen / SignUpScreen → ProfileSetupScreen

Cliente (CustomerAppScreen)
  ├── IA concierge (_AiConciergeView) — chat + voz
  ├── Menú (MenuCatalogScreen)
  ├── Seguimiento (OrderTrackingScreen)
  ├── Historial (_HistoryView)
  └── Perfil (ClientProfileScreen)

Admin (AdminAppScreen)
  ├── Inicio — mesas ocupadas + estadísticas del día
  ├── Menú (MenuManagementScreen) — CRUD de ítems
  ├── Comandas (OrdersKdsScreen) — KDS en tiempo real
  └── Perfil (AdminProfileScreen)

Shared
  TableSelectionScreen — el cliente elige su mesa al entrar
  PaymentScreen — pago digital o efectivo
```

---

## Configuración inicial

### 1. Clonar y dependencias

```bash
git clone <repo>
cd ordenow
flutter pub get
```

### 2. Crear archivo `.env` en la raíz del proyecto

```env
SUPABASE_URL=https://xxxxxxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

> Este archivo **no se sube al repositorio** (está en `.gitignore`).  
> Pídele las credenciales a quien administra el proyecto Supabase.

### 3. Aplicar esquema en Supabase

En el SQL Editor de tu proyecto Supabase, ejecuta en orden:

```sql
-- 1. Tablas, admin y mesas
\i supabase/migrations/ordenow_core_schema.sql

-- 2. Menú de ejemplo
\i supabase/migrations/seed_full_menu.sql

-- 3. Realtime para órdenes (necesario para KDS en tiempo real)
ALTER PUBLICATION supabase_realtime ADD TABLE orders;
ALTER TABLE orders REPLICA IDENTITY FULL;
```

### 4. Deploy de la Edge Function

```bash
supabase login
supabase functions deploy ordenow-ai-concierge --no-verify-jwt
```

Agrega la variable de entorno en Supabase Dashboard → Edge Functions → Secrets:
```
ANTHROPIC_API_KEY=sk-ant-...
```

### 5. Correr la app

```bash
flutter run
```

---

## Variables de entorno

| Variable | Dónde se configura | Descripción |
|---|---|---|
| `SUPABASE_URL` | `.env` (raíz del proyecto) | URL del proyecto Supabase |
| `SUPABASE_ANON_KEY` | `.env` (raíz del proyecto) | Anon key pública de Supabase |
| `ANTHROPIC_API_KEY` | Supabase Dashboard → Secrets | API key de Anthropic para el concierge IA |
