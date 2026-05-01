const BREVO_API = "https://api.brevo.com/v3/contacts";

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

function getEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value?.trim()) throw new Error(`Missing env: ${name}`);
  return value.trim();
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: CORS });
  }

  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  let email: string;
  try {
    const body = await req.json();
    email = (body?.email ?? "").trim().toLowerCase();
  } catch {
    return json({ error: "Invalid JSON" }, 400);
  }

  if (!email || !EMAIL_RE.test(email)) {
    return json({ error: "Invalid email" }, 400);
  }

  let apiKey: string;
  let listId: number;
  try {
    apiKey = getEnv("BREVO_API_KEY");
    listId = parseInt(getEnv("BREVO_LIST_ID"), 10);
    if (isNaN(listId)) throw new Error("BREVO_LIST_ID is not a number");
  } catch (e) {
    console.error("Config error:", e);
    return json({ error: "Server misconfigured" }, 500);
  }

  try {
    const res = await fetch(BREVO_API, {
      method: "POST",
      headers: {
        accept: "application/json",
        "content-type": "application/json",
        "api-key": apiKey,
      },
      body: JSON.stringify({
        email,
        listIds: [listId],
        updateEnabled: true,
        attributes: { PLANO: "gratuito" },
      }),
    });

    // 201 = criado, 204 = já existe (updateEnabled)
    if (res.status === 201 || res.status === 204) {
      return json({ success: true });
    }

    const text = await res.text();
    console.error("Brevo error:", res.status, text);
    return json({ error: "Brevo error", detail: text }, res.status);
  } catch (e) {
    console.error("Fetch error:", e);
    return json({ error: "Network error" }, 502);
  }
});
