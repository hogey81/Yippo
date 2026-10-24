# Pushmeldingen (dagrecord verbeterd): opzet en checklist

Wat al klaar staat in de code:
- `push.sql`: tabellen voor telefoons en wachtrij, aan- en afmelden (alleen volwassen accounts), en een trigger die een record opmerkt.
- `functions/push-record/index.ts`: de serverfunctie die de melding via Firebase (FCM) verstuurt. Maximaal één melding per telefoon per dag, niet tussen 22:00 en 08:00, in nl/en/es.

Wat er nog moet gebeuren (pas na de testperiode, samen met de Android-app):
1. Firebase-project maken (gratis), daarin de Android-app `Yippo` toevoegen, `google-services.json` downloaden.
2. In Firebase: Project settings -> Service accounts -> "Generate new private key" (JSON).
3. Supabase: SQL Editor -> `push.sql` draaien.
4. Supabase: Edge Functions -> `push-record` plaatsen (`supabase functions deploy push-record`) en het geheim `FCM_SERVICE_ACCOUNT` zetten (de hele JSON van stap 2).
5. De functie elke paar minuten laten draaien: Supabase -> Integrations -> Cron, taak "elke 5 minuten", type Edge Function `push-record`.
6. In de app (Capacitor Push Notifications): knop "🔔 Meldingen" in het menu, alleen voor volwassen accounts; roept `yippo_register_device(token, taal)` aan. Kanaal `daily-record`.
7. Privacyverklaring aanvullen: pushtoken en voorkeur voor meldingen.
8. Testen met twee telefoons: de ene verbetert het dagrecord, de andere ontvangt de melding.
