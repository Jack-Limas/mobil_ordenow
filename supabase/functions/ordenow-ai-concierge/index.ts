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
  image_url?: string;
};

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const apiKey = Deno.env.get("OPENAI_API_KEY");
    if (!apiKey) {
      return jsonResponse(
        { reply: "La IA aun no tiene configurada su API key en Supabase." },
        200,
      );
    }

    const body = await request.json();
    const prompt = String(body.prompt ?? "").trim();
    const menu = Array.isArray(body.menu)
      ? body.menu as MenuItem[]
      : body.recommended_menu as MenuItem[] ?? [];

    const menuContext = menu
      .filter((item) => item.available !== false)
      .slice(0, 80)
      .map((item) => ({
        id: item.id,
        name: item.name,
        description: item.description,
        price: item.price,
        category: item.category,
        recommended: item.recommended,
        tags: item.tags ?? [],
        image_url: item.image_url,
      }));

    const response = await fetch("https://api.openai.com/v1/responses", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "gpt-5.4-mini",
        input: [
          {
            role: "system",
            content:
              "Eres el asistente de OrdeNow para un restaurante. Responde en espanol claro, corto y amable. Recomienda solo platos que existan en el menu enviado. Si el cliente menciona ingredientes como pollo, pasta, carne, bebida, saludable o alergias, busca coincidencias en nombre, descripcion, categoria y tags. No inventes precios ni platos. Si no hay coincidencias, dilo y ofrece alternativas cercanas.",
          },
          {
            role: "user",
            content: JSON.stringify({
              prompt,
              table_number: body.table_number ?? null,
              order_status: body.order_status ?? null,
              allergies: body.allergies ?? [],
              dining_preferences: body.dining_preferences ?? "",
              cart_items: body.cart_items ?? [],
              menu: menuContext,
            }),
          },
        ],
        max_output_tokens: 450,
      }),
    });

    if (!response.ok) {
      return jsonResponse(
        { reply: "No pude consultar la IA ahora. Puedo seguir con recomendaciones del menu local." },
        200,
      );
    }

    const data = await response.json();
    const reply = extractText(data) ??
      "Puedo ayudarte a elegir segun tu antojo. Dime si quieres pollo, carne, pasta, algo saludable o una bebida.";

    return jsonResponse({ reply }, 200);
  } catch (_) {
    return jsonResponse(
      { reply: "Tuve un problema leyendo el menu para la IA. Intenta de nuevo." },
      200,
    );
  }
});

function extractText(data: unknown): string | null {
  if (!data || typeof data !== "object") return null;
  const record = data as Record<string, unknown>;
  if (typeof record.output_text === "string") return record.output_text;

  const output = record.output;
  if (!Array.isArray(output)) return null;

  const parts: string[] = [];
  for (const item of output) {
    if (!item || typeof item !== "object") continue;
    const content = (item as Record<string, unknown>).content;
    if (!Array.isArray(content)) continue;
    for (const block of content) {
      if (!block || typeof block !== "object") continue;
      const text = (block as Record<string, unknown>).text;
      if (typeof text === "string") parts.push(text);
    }
  }

  return parts.length > 0 ? parts.join("\n") : null;
}

function jsonResponse(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}
