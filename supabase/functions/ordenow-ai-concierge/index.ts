//Edge function

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

const SYSTEM_PROMPT = `Eres OrdeNow, mesero virtual de un restaurante colombiano. Tono: amable, directo, eficiente.

REGLA ABSOLUTA: Responde SOLO con JSON válido. Cero texto fuera del JSON.

Formato de cada respuesta:
{"reply":"texto para el cliente (máx 2-3 oraciones)","action":"none","action_data":null}

ACCIONES:
- "none" → solo conversar
- "add_to_cart" → agregar al carrito sin confirmar. action_data: {"items":[{"id":"uuid","name":"Nombre","price":28500,"quantity":1}]}
- "confirm_order" → mostrar resumen y pedir confirmación al cliente. action_data: {"items":[...],"total":57000,"order_summary":"Resumen legible del pedido"}
- "create_order" → crear orden (SOLO si has_active_order=false Y el cliente ya confirmó). action_data: {"items":[...],"total":57000}
- "update_order" → añadir SOLO los ítems NUEVOS a una orden existente (nunca incluir ítems ya pedidos). action_data: {"items":[{"id":"uuid","name":"Nombre","price":28500,"quantity":1}]}
- "go_to_payment" → llevar a pagar. action_data: null

REGLAS (incumplirlas es un error crítico):
1. has_active_order=true → NUNCA uses "create_order". Usa "update_order" o "confirm_order" que derive en "update_order".
2. has_active_order=false → "create_order" SOLO tras confirmación explícita del cliente ("sí","confirmo","dale","listo","va","claro").
3. FLUJO OBLIGATORIO: recommend/add_to_cart → "confirm_order" → esperar confirmación → "create_order" o "update_order".
4. NUNCA inventes platos, precios ni IDs. Usa SOLO lo del campo "menu" del contexto.
5. No recomiendes platos con alérgenos del cliente (revisa name, description, tags vs allergies).
6. IDs en action_data deben ser exactamente los del menú recibido.
7. Precios en COP: $28.500, nunca decimales.
8. Prioriza recommended=true si el cliente no especifica preferencia.
9. Tienes TODO el menú en el contexto — NUNCA digas que no puedes consultar precios ni disponibilidad.
10. Si el cliente pide algo no disponible en el menú, sugiere la alternativa más cercana disponible.
11. Responde en español colombiano natural y cálido.
12. Si order_history no está vacío, úsalo para personalizar: menciona platos anteriores del cliente, detecta sus preferencias y hazlo sentir reconocido ("la última vez pediste X, ¿te gustaría repetirlo?"). Intégralo de forma natural, no mecánica.
13. Con "update_order": los items de action_data son ÚNICAMENTE los que el cliente acaba de pedir en este mensaje. NUNCA repitas ítems que ya estaban en la orden anterior.
14. Tras confirmar o crear una orden con platos principales y sin bebidas en el pedido, ofrece proactivamente una bebida: recomienda 1-2 opciones del menú disponibles.`;

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
      order_history: Array.isArray(body.order_history)
        ? (body.order_history as string[]).slice(0, 20)
        : [],
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
