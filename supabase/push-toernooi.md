# Pushmeldingen voor het toernooi (voorbereid, nog niet aan)

De pushmeldingen komen pas aan zodra Yippo in de Play Store staat en de tweede release (met push) is uitgerold.
Zie ook `push-stappen.md` en `play-store/push-privacy-en-datasafety.md`.

## Wat er al klaarstaat
- `yippo_bracket_players_to_notify()` (in `bracket.sql`): geeft per ronde de spelers die nog moeten spelen, met de naam van hun tegenstander.
  Alleen aan te roepen met de service-sleutel (service_role).
- De app kent de rondes al (kwartfinale do, halve finale vr, finale za).

## Wat er nog moet gebeuren bij het aanzetten
1. Pushmeldingen inrichten zoals in `push-stappen.md` (Firebase, Supabase-functie, `PUSH_ENABLED=true`).
2. Een geplande taak (Supabase Edge Function met schedule) elke dag om 08:00 en om 18:00 Europe/Amsterdam (nooit tussen 22:00 en 08:00):
   - 08:00: roept `yippo_bracket_players_to_notify()` aan en stuurt "Jouw kwartfinale staat klaar: jij tegen {naam}. Je hebt tot 23:59."
   - 18:00: dezelfde lijst, maar alleen wie nog niet heeft gespeeld: "Laatste kans: speel je {ronde} vandaag nog."
   - Ma 08:00: "Nieuwe week! Speel de kwalificatie, de beste 8 gaan door." (alleen wie push heeft aangezet)
3. Teksten in nl/en/es toevoegen aan de Edge Function (zelfde aanpak als `push-record`).
4. Alleen volwassen accounts die meldingen zelf hebben aangezet krijgen ze (net als bij de dagrecord-melding).

## Tot die tijd
Op het hoofdscherm staat de knop "Jouw beurt!" (pulserend) zodra je wedstrijd klaarstaat.
