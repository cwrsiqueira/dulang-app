// @ts-nocheck — Deno Edge; IDE não resolve `npm:`/`Deno`. Validar: npx deno check supabase/functions/validate-access-code/index.ts
import { createClient } from "npm:@supabase/supabase-js@2";
const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const CODE_RE = /^[A-Z0-9]{8,32}$/;
const ATTEMPT_WINDOW_MS = 60_000;
const MAX_ATTEMPTS_PER_WINDOW = 12;
const attemptsByClient = new Map<string, { count: number; windowStart: number }>();

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS, "Content-Type": "application/json" },
  });
}

function normalizeCode(raw: string): string {
  return raw.trim().toUpperCase().replace(/\s+/g, "");
}

function clientKey(req: Request): string {
  const fwd = req.headers.get("x-forwarded-for") ?? "";
  const firstIp = fwd.split(",")[0]?.trim();
  return firstIp || req.headers.get("x-real-ip") || "unknown";
}

function rateLimited(client: string): boolean {
  const now = Date.now();
  const current = attemptsByClient.get(client);
  if (!current || now - current.windowStart > ATTEMPT_WINDOW_MS) {
    attemptsByClient.set(client, { count: 1, windowStart: now });
    return false;
  }
  current.count += 1;
  attemptsByClient.set(client, current);
  return current.count > MAX_ATTEMPTS_PER_WINDOW;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: CORS });
  }

  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  const client = clientKey(req);
  if (rateLimited(client)) {
    return json({ error: "Muitas tentativas. Aguarde 1 minuto." }, 429);
  }

  let body: { code?: string };
  try {
    body = await req.json();
  } catch {
    return json({ error: "Invalid JSON" }, 400);
  }

  const normalized = normalizeCode(body?.code ?? "");
  if (!normalized || !CODE_RE.test(normalized)) {
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
