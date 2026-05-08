// @ts-nocheck — Deno Edge; IDE não resolve `npm:`/`Deno`. Validar: npx deno check supabase/functions/validate-access-code/index.ts
import { createClient } from "npm:@supabase/supabase-js@2";
const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS, "Content-Type": "application/json" },
  });
}

function normalizeCode(raw: string): string {
  return raw.trim().toUpperCase().replace(/\s+/g, "");
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: CORS });
  }

  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  let body: { code?: string };
  try {
    body = await req.json();
  } catch {
    return json({ error: "Invalid JSON" }, 400);
  }

  const normalized = normalizeCode(body?.code ?? "");
  if (!normalized || normalized.length < 4) {
    return json({ error: "Código inválido." }, 400);
  }

  const url = Deno.env.get("SUPABASE_URL");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!url || !serviceKey) {
    console.error("Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY");
    return json({ error: "Server misconfigured" }, 500);
  }

  const admin = createClient(url, serviceKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const { data, error } = await admin
    .from("access_codes")
    .update({
      used: true,
      used_at: new Date().toISOString(),
    })
    .eq("code", normalized)
    .eq("used", false)
    .select("id")
    .maybeSingle();

  if (error) {
    console.error("access_codes update:", error);
    return json({ error: "Erro ao validar o código." }, 500);
  }

  if (!data) {
    return json(
      { error: "Código inválido ou já utilizado." },
      400,
    );
  }

  return json({ success: true, id: data.id });
});
