# Pushmeldingen: wat je moet aanpassen voordat je de versie met meldingen uploadt

Dit is een concept. Controleer elk antwoord zelf. Ik heb de regels van Google niet laten nakijken door een jurist of door Google.

## 1. Veiligheid van gegevens (Play Console)
Voeg toe: categorie **Apparaat- of andere ID's** (het pushtoken van de telefoon).
- Verzameld of gedeeld: **Verzameld**. Het token gaat ook via Firebase Cloud Messaging van Google; Google verwerkt dat als dienstverlener in jouw opdracht. Controleer in de uitleg van Play of dat bij jou als "delen" geldt.
- Kortstondig verwerkt: **Nee**
- Vereist of optioneel: **Optioneel** (alleen als de speler meldingen aanzet; alleen volwassenen)
- Doel: **App-functionaliteit**

## 2. Privacyverklaring (privacy.html): zinnen om toe te voegen
**Nederlands:** "Als je als volwassene meldingen aanzet, bewaren we een technisch pushtoken van je telefoon, gekoppeld aan je account, om je een bericht te kunnen sturen als iemand in je league het dagrecord verbetert. We sturen niet meer dan één melding per dag en niet tussen 22:00 en 08:00. Je kunt meldingen op elk moment uitzetten in het menu (Account), dan verwijderen we het token. Kinderen krijgen geen meldingen. Voor het versturen gebruiken we Firebase Cloud Messaging van Google."

**English:** "If you are an adult and turn on notifications, we store a technical push token for your phone, linked to your account, so we can send you a message when someone in your league beats the daily record. We send at most one notification per day and not between 10 pm and 8 am. You can turn notifications off at any time in the menu (Account); we then delete the token. Children do not receive notifications. We use Google's Firebase Cloud Messaging to deliver them."

**Español:** "Si eres adulto y activas los avisos, guardamos un token técnico de tu teléfono, vinculado a tu cuenta, para poder enviarte un mensaje cuando alguien de tu liga supere el récord del día. Enviamos como máximo un aviso al día y no entre las 22:00 y las 08:00. Puedes desactivar los avisos en cualquier momento en el menú (Cuenta); entonces borramos el token. Los niños no reciben avisos. Para enviarlos usamos Firebase Cloud Messaging de Google."

Voeg bij de lijst "Wie helpt ons daarbij?" toe: *Firebase Cloud Messaging (Google): het bezorgen van meldingen* (of, als je namen liever niet noemt, "een meldingsdienst").

## 3. Overige punten
- Firebase **Analytics blijft uit** (anders komt er een tracker bij en klopt "geen trackers" niet meer).
- Alleen volwassen accounts kunnen een telefoon aanmelden (de server controleert dat).
- De Play Store-vermelding noemt nu "no ads": dat blijft kloppen.
