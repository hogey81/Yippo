// Supabase Edge Function: verstuurt de pushmelding "iemand in je league heeft het dagrecord verbeterd" via Firebase Cloud Messaging.
// Leest de wachtrij yippo_push_queue (zie push.sql). Wordt elke paar minuten aangeroepen (zie push.md).
// Geheimen (Supabase -> Edge Functions -> Secrets): FCM_SERVICE_ACCOUNT = de hele JSON van het Firebase-servicesleutelbestand.
// SUPABASE_URL en SUPABASE_SERVICE_ROLE_KEY zijn er al automatisch.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const sb = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
const sa = JSON.parse(Deno.env.get("FCM_SERVICE_ACCOUNT") || "{}");

const TEXT: Record<string, (n: string, s: string, l: string) => { title: string; body: string }> = {
  nl: (n, s, l) => ({ title: `🏆 Nieuw dagrecord in ${l}`, body: `${n} heeft het dagrecord verbeterd: ${s} punten. Kun jij hem verslaan?` }),
  en: (n, s, l) => ({ title: `🏆 New daily record in ${l}`, body: `${n} beat the daily record: ${s} points. Can you beat them?` }),
  es: (n, s, l) => ({ title: `🏆 Nuevo récord del día en ${l}`, body: `${n} ha mejorado el récord del día: ${s} puntos. ¿Puedes superarlo?` }),
};

const b64url = (b: ArrayBuffer | string) =>
  btoa(typeof b === "string" ? b : String.fromCharCode(...new Uint8Array(b))).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");

async function accessToken(): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const head = b64url(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const claim = b64url(JSON.stringify({
    iss: sa.client_email, scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token", iat: now, exp: now + 3600,
  }));
  const pem = String(sa.private_key).replace(/-----[^-]+-----/g, "").replace(/\s+/g, "");
  const key = await crypto.subtle.importKey("pkcs8", Uint8Array.from(atob(pem), (c) => c.charCodeAt(0)),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" }, false, ["sign"]);
  const sig = await crypto.subtle.sign("RSASSA-PKCS1-v1_5", key, new TextEncoder().encode(`${head}.${claim}`));
  const r = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST", headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({ grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer", assertion: `${head}.${claim}.${b64url(sig)}` }),
  });
  return (await r.json()).access_token;
}

// Geen meldingen tussen 22:00 en 08:00 (Nederlandse tijd)
function quietHours(): boolean {
  const h = Number(new Intl.DateTimeFormat("en-GB", { hour: "numeric", hour12: false, timeZone: "Europe/Amsterdam" }).format(new Date()));
  return h >= 22 || h < 8;
}

Deno.serve(async () => {
  if (!sa.client_email) return new Response("FCM_SERVICE_ACCOUNT ontbreekt", { status: 500 });
  const { data: queue } = await sb.from("yippo_push_queue").select("*").is("sent_at", null).order("id").limit(20);
  if (!queue || !queue.length) return new Response("niets te doen");
  const quiet = quietHours();
  let sent = 0;
  let token: string | null = null;
  for (const q of queue) {
    const age = Date.now() - new Date(q.created_at).getTime();
    // oude of tussentijds ingehaalde records niet meer melden; 's nachts wachten we (max 6 uur)
    const { data: members } = await sb.from("yippo_members").select("player_id").eq("code", q.league_code);
    const ids = (members || []).map((m: { player_id: string }) => m.player_id);
    const { data: top } = ids.length
      ? await sb.from("yippo_scores").select("score").eq("day", q.day).in("player_id", ids).order("score", { ascending: false }).limit(1)
      : { data: [] };
    const outdated = !ids.length || age > 6 * 3600e3 || (top && top[0] && top[0].score > q.score);
    if (quiet && !outdated) continue;
    if (!outdated) {
      const { data: devices } = await sb.from("yippo_devices").select("*").in("player_id", ids).neq("player_id", q.player_id)
        .or(`last_push_day.is.null,last_push_day.neq.${q.day}`).limit(500);   // alleen leden van de league, maximaal één melding per telefoon per dag
      for (const d of devices || []) {
        token = token || await accessToken();
        const m = (TEXT[d.lang] || TEXT.nl)(q.name, String(q.score).replace(/\B(?=(\d{3})+(?!\d))/g, d.lang === "en" ? "," : "."), q.league_name);
        const r = await fetch(`https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`, {
          method: "POST", headers: { Authorization: `Bearer ${token}`, "Content-Type": "application/json" },
          body: JSON.stringify({ message: { token: d.token, notification: m, android: { priority: "normal", notification: { channel_id: "daily-record" } }, data: { type: "daily-record" } } }),
        });
        if (r.ok) { sent++; await sb.from("yippo_devices").update({ last_push_day: q.day }).eq("token", d.token); }
        else if (r.status === 404 || r.status === 400) await sb.from("yippo_devices").delete().eq("token", d.token);   // telefoon bestaat niet meer
      }
    }
    await sb.from("yippo_push_queue").update({ sent_at: new Date().toISOString() }).eq("id", q.id);
  }
  return new Response(`verstuurd: ${sent}`);
});
