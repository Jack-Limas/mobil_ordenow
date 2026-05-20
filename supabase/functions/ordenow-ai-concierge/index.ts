const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

type MenuItem = {
  id?: string;
  name?: string;
  description?: string;
  price?: number;
  category?: string;
  available?: boolean;
  recommended?: boolean;
  tags?: string[];
};

type ConversationMessage = {
  role: "user" | "assistant";
  content: string;
};

const SYSTEM_PROMPT = `Eres OrdeNow, el mesero virtual inteligente de un restaurante colombiano. Tu tono es amable, cercano y eficiente.

REGLA ABSOLUTA: Responde ÚNICAMENTE con un objeto JSON válido. Sin texto extra, sin markdown, sin explicaciones fuera del JSON.

Estructura obligatoria de cada respuesta:
{
  "reply": "tu respuesta en texto para el cliente (máx 3-4 oraciones)",
  "action": "none",
  "action_data": null
}

ACCIONES DISPONIBLES:
- "none" → solo responder, sin ejecutar acciones
- "add_to_cart" → agregar al carrito (aún no se confirma). action_data: { "items": [{"id":"uuid-exacto","name":"Nombre","price":28500,"quantity":1}] }
- "confirm_order" → mostrar resumen y pedir confirmación. action_data: { "items": [...], "total": 57000, "order_summary": "Resumen legible" }
- "create_order" → crear la orden (SOLO si has_active_order es false y el usuario ya confirmó). action_data: { "items": [...], "total": 57000 }
- "update_order" → agregar ítems a la orden ya existente. action_data: { "items": [{"id":"uuid-exacto","name":"Nombre","price":28500,"quantity":1}] }
- "go_to_payment" → llevar al cliente a pagar. action_data: null

REGLAS CRÍTICAS (no negociables):
1. Si has_active_order = true → JAMÁS uses "create_order". Usa "update_order" para agregar ítems o "confirm_order" que derivará en "update_order".
2. Si has_active_order = false → puedes usar "create_order" SOLO cuando el usuario confirme explícitamente (responda "sí", "confirmo", "dale", "listo").
3. Flujo de pedido: primero usa "confirm_order" para mostrar resumen → espera confirmación → luego "create_order" o "update_order".
4. NUNCA inventes platos, precios ni ingredientes. Solo usa lo que está en el menú recibido.
5. NUNCA recomiendes platos que contengan alérgenos del cliente (revisa name, description y tags).
6. Usa IDs exactos del menú en action_data, no los inventes.
7. Precios en COP con puntos: $28.500, $120.000
8. Prioriza platos con recommended=true cuando el cliente no especifica preferencia.
9. Cuando el cliente diga "listo", "eso es todo", "quiero pedir", "confirmar", "enviar" → acción "confirm_order".
10. Responde en español colombiano natural.`;

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const apiKey = Deno.env.get("ANTHROPIC_API_KEY");
    if (!apiKey) {
      return jsonResponse(
        {
          reply:
            "Hola, estoy aquí para ayudarte. Por favor configura la API key de Anthropic en Supabase.",
          action: "none",
          action_data: null,
        },
        200,
      );
    }

    const body = await request.json();
    const prompt = String(body.prompt ?? "").trim();
    const hasActiveOrder = Boolean(body.has_active_order ?? false);

    // Keep last 8 messages, ensure alternating user/assistant roles
    const rawHistory: ConversationMessage[] = Array.isArray(
        body.conversation_history,
      )
      ? (body.conversation_history as ConversationMessage[])
          .filter((m) => m.role === "user" || m.role === "assistant")
          .slice(-8)
      : [];

    // Deduplicate consecutive same-role messages (Anthropic API requires alternating)
    const conversationHistory: ConversationMessage[] = [];
    for (const msg of rawHistory) {
      const last = conversationHistory[conversationHistory.length - 1];
      if (last && last.role === msg.role) {
        last.content += "\n" + msg.content;
      } else {
        conversationHistory.push({ ...msg });
      }
    }

    const rawMenu = Array.isArray(body.menu)
      ? (body.menu as MenuItem[])
      : Array.isArray(body.recommended_menu)
      ? (body.recommended_menu as MenuItem[])
      : [];

    const menuContext = rawMenu
      .filter((item) => item.available !== false)
      .slice(0, 30)
      .map((item) => ({
        id: item.id,
        name: item.name,
        description: item.description,
        price: item.price,
        category: item.category,
        recommended: item.recommended ?? false,
        tags: item.tags ?? [],
      }));

    const contextMessage = JSON.stringify({
      prompt,
      table_number: body.table_number ?? null,
      order_status: body.order_status ?? null,
      has_active_order: hasActiveOrder,
      allergies: body.allergies ?? [],
      dining_preferences: body.dining_preferences ?? "",
      cart_items: body.cart_items ?? [],
      menu: menuContext,
    });

    const messages: ConversationMessage[] = [
      ...conversationHistory,
      { role: "user", content: contextMessage },
    ];

    const response = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "x-api-key": apiKey,
        "anthropic-version": "2023-06-01",
        "content-type": "application/json",
      },
      body: JSON.stringify({
        model: "claude-haiku-4-5-20251001",
        max_tokens: 600,
        system: SYSTEM_PROMPT,
        messages,
      }),
    });

    if (!response.ok) {
      const errText = await response.text();
      console.error(`Anthropic ${response.status}:`, errText);
      return jsonResponse(
        {
          reply:
            "No pude procesar tu solicitud ahora. Intenta de nuevo en un momento.",
          action: "none",
          action_data: null,
        },
        200,
      );
    }

    const data = await response.json();
    const rawContent: string = data?.content?.[0]?.text?.trim() ?? "{}";

    let parsed: { reply?: string; action?: string; action_data?: unknown } = {};
    try {
      // Strip markdown code fences if Claude wraps the JSON
      const clean = rawContent
        .replace(/^```json\s*/i, "")
        .replace(/^```\s*/i, "")
        .replace(/\s*```$/i, "")
        .trim();
      parsed = JSON.parse(clean);
    } catch {
      parsed = { reply: rawContent, action: "none", action_data: null };
    }

    // Safety guard: never let the Edge Function return create_order when there's an active order.
    // The Flutter side already handles this, but defense in depth doesn't hurt.
    if (hasActiveOrder && parsed.action === "create_order") {
      parsed.action = "update_order";
    }

    return jsonResponse(
      {
        reply: parsed.reply ?? "¿En qué te puedo ayudar?",
        action: parsed.action ?? "none",
        action_data: parsed.action_data ?? null,
      },
      200,
    );
  } catch (err) {
    console.error("Edge function error:", err);
    return jsonResponse(
      {
        reply: "Tuve un problema procesando tu solicitud. Intenta de nuevo.",
        action: "none",
        action_data: null,
      },
      200,
    );
  }
});

function jsonResponse(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
