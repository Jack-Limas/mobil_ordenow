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
  role: "user" | "assistant" | "system";
  content: string;
};

const SYSTEM_PROMPT = `Eres OrdeNow, el mesero virtual de un restaurante colombiano. Tu tono es amable, natural y directo.

IMPORTANTE: Siempre responde ÚNICAMENTE con un objeto JSON válido con esta estructura exacta:
{
  "reply": "texto de tu respuesta para el usuario",
  "action": "none",
  "action_data": null
}

Los valores posibles de "action" son:
- "none": solo responde, no ejecutes ninguna acción
- "add_to_cart": agrega items al carrito. action_data debe tener { "items": [{"id":"uuid","name":"nombre","price":28500,"quantity":1}] }
- "confirm_order": muestra resumen y espera confirmación. action_data debe tener { "items": [...], "total": 57000, "order_summary": "resumen" }
- "create_order": crea la orden (solo cuando el usuario confirmó explícitamente). action_data debe tener { "items": [...], "total": 57000 }
- "go_to_payment": navega a pago. action_data: null
- "update_order": agrega más items a orden existente. action_data igual que add_to_cart

REGLAS DE NEGOCIO:
1. Solo recomienda platos del menú recibido. NUNCA inventes platos, precios ni ingredientes.
2. Filtra alergias: NUNCA recomiendes platos que contengan alérgenos del cliente en nombre, descripción o tags.
3. Responde en español colombiano. Máximo 3-4 oraciones en el campo "reply".
4. Precios siempre en formato COP con puntos: $28.500, $120.000
5. Prioriza platos recomendados cuando el cliente no especifica preferencia.
6. Para agregar al carrito necesitas el ID exacto del plato del menú.
7. Espera confirmación explícita antes de crear la orden (action: create_order).
8. Cuando el usuario dice "listo", "eso es todo", "enviar pedido", "confirmar" → usa action: "confirm_order" primero.
9. Solo usa action: "create_order" cuando el usuario responda "sí", "confirmo", "adelante", "enviar" después de ver el resumen.

CONTEXTO QUE RECIBES:
- prompt: mensaje actual del usuario
- conversation_history: historial completo (úsalo para tener memoria de la conversación)
- table_number, order_status, allergies, dining_preferences, cart_items, menu`;

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const apiKey = Deno.env.get("GROQ_API_KEY");
    if (!apiKey) {
      return jsonResponse(
        {
          reply: "La IA aún no tiene configurada su API key en Supabase.",
          action: "none",
          action_data: null,
        },
        200,
      );
    }

    const body = await request.json();
    const prompt = String(body.prompt ?? "").trim();
    const conversationHistory: ConversationMessage[] = Array.isArray(
        body.conversation_history,
      )
      ? (body.conversation_history as ConversationMessage[]).slice(-8)
      : [];

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
      allergies: body.allergies ?? [],
      dining_preferences: body.dining_preferences ?? "",
      cart_items: body.cart_items ?? [],
      menu: menuContext,
    });

    const response = await fetch(
      "https://api.groq.com/openai/v1/chat/completions",
      {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${apiKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model: "llama-3.1-8b-instant",
          messages: [
            { role: "system", content: SYSTEM_PROMPT },
            ...conversationHistory,
            { role: "user", content: contextMessage },
          ],
          max_tokens: 600,
          temperature: 0.7,
          response_format: { type: "json_object" },
        }),
      },
    );

    if (!response.ok) {
      const errText = await response.text();
      console.error(`Groq ${response.status}:`, errText);
      return jsonResponse(
        {
          reply:
            "No pude consultar la IA ahora. Intenta de nuevo en un momento.",
          action: "none",
          action_data: null,
        },
        200,
      );
    }

    const data = await response.json();
    const rawContent: string =
      data?.choices?.[0]?.message?.content?.trim() ?? "{}";

    let parsed: { reply?: string; action?: string; action_data?: unknown } = {};
    try {
      parsed = JSON.parse(rawContent);
    } catch {
      parsed = { reply: rawContent, action: "none", action_data: null };
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

