# Pushmeldingen aanzetten: stappen voor jou

De code is klaar (app, site en serverfunctie). Er gebeurt niets voor spelers zolang `PUSH_ENABLED` in `index.html` op `false` staat. Doe deze stappen pas als de eerste release is goedgekeurd.
De namen van knoppen in Firebase, Supabase en GitHub kunnen iets afwijken van wat hier staat.

## A. Firebase (ongeveer 20 minuten)
1. Ga naar https://console.firebase.google.com (met je Google-account) en kies **Project toevoegen**.
2. Naam: `Yippo`. Zet **Google Analytics UIT** (de app heeft geen trackers; dat blijft zo).
3. Klik in het projectoverzicht op het **Android-pictogram** om een app toe te voegen.
   - Pakketnaam: `com.yippogame.app` (precies zo)
   - Bijnaam: `Yippo`
   - Klik op **App registreren** en download **google-services.json**. De rest van de stappen mag je overslaan.
4. Klik op het **tandwiel** (Projectinstellingen) → tabblad **Servicesleutels / Service accounts** → **Nieuwe privésleutel genereren**. Er wordt een `.json`-bestand gedownload. **Dit bestand is geheim:** zet het nooit in GitHub en deel het niet.
5. Zet `google-services.json` in GitHub: repo `hogey81/Yippo` → map `app/android/app` → **Add file → Upload files** → kies het bestand → **Commit changes**.

## B. Supabase (ongeveer 20 minuten)
1. **SQL Editor → New query:** plak de inhoud van `supabase/push.sql` en klik op **Run**. (Veilig om opnieuw te draaien.)
2. **Edge Functions → Deploy a new function** (via de editor in de browser):
   - Naam: `push-record`
   - Plak de inhoud van `supabase/functions/push-record/index.ts` en klik op **Deploy**.
3. **Edge Functions → Secrets** (of *Manage secrets*): maak een geheim `FCM_SERVICE_ACCOUNT` met als waarde de **hele inhoud** van het geheime `.json`-bestand uit stap A4.
4. **Integrations → Cron** (zet de extensie pg_cron aan als dat wordt gevraagd): maak een taak die **elke 5 minuten** de Edge Function `push-record` aanroept.

## C. De app
1. Zeg het tegen mij. Ik zet `PUSH_ENABLED` op `true`, controleer alles en je bouwt een nieuwe Play Store-versie (zelfde knop als de vorige keer, de versiecode loopt vanzelf op).
2. Je uploadt die nieuwe `Yippo.aab` als **tweede release** in de gesloten test (Releases → Nieuwe release maken). Testers krijgen hem als gewone update; de 14 dagen blijven lopen.
3. Pas **vóór** je die versie uploadt de **Veiligheid van gegevens** en de **privacyverklaring** aan (zie `play-store/push-privacy-en-datasafety.md`).

## D. Testen met twee telefoons
1. Beide telefoons: eigen volwassen account (e-mail gekoppeld) in dezelfde league (maak een league, deel de code).
2. Beide: menu → Account → **🔔 Meldingen aan**, toestemming geven.
3. Telefoon 1 speelt de dagelijkse puzzel (eerste score van de dag in de league telt niet als verbetering).
4. Telefoon 2 speelt en haalt een **hogere** score. Telefoon 1 hoort binnen ongeveer 5 minuten een melding te krijgen ("🏆 Nieuw dagrecord in …").
5. Let op: niet tussen 22:00 en 08:00 (Nederlandse tijd), en maximaal één melding per telefoon per dag.

## Als iets niet werkt
- Geen melding: kijk in Supabase onder Edge Functions → push-record → **Logs**.
- Een melding die niet binnenkomt: staat de telefoon in energiebesparing, of zijn meldingen voor Yippo uitgezet in de Android-instellingen?
