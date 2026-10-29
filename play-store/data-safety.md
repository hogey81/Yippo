# Yippo: voorbereiding Google Play (Data safety, content rating, doelgroep)

Concept op basis van wat het spel doet (stand 29 oktober 2026). Controleer elk antwoord in Play Console voordat je indient; jij bent verantwoordelijk voor de juistheid. De privacyverklaring staat op https://www.yippogame.com/privacy en moet hiermee kloppen.

## Wat het spel verzamelt (feiten)
- Gastaccount: een willekeurig account-id (Supabase), zonder e-mailadres.
- Optioneel e-mailadres, alleen om voortgang te bewaren en in te loggen met een code. Niet voor reclame.
- Spelersnaam (automatisch of zelfgekozen, max. 20 tekens), zichtbaar op het scorebord en in leagues.
- Spelvoortgang (levels, sterren, scores, dieren, instellingen) in de cloud.
- Dagscores en leaguelidmaatschap (naam + score).
- Leeftijdskeuze (kind/volwassene) in het profiel. Kinderen kunnen geen e-mailadres koppelen.
- Geen advertenties, geen trackers, geen locatie, geen contacten, geen camera/microfoon, geen aankopen.
- In de app wordt Vercel Analytics niet geladen (alleen op de website).
- Verwerkers: Supabase (database en inloggen), Resend (verzenden van inlogcodes).

## Data safety (Play Console > App-inhoud > Gegevensbeveiliging)
- Verzamelt of deelt de app gebruikersgegevens? **Ja** (verzamelt).
- Alle gegevens worden versleuteld verzonden (HTTPS)? **Ja**.
- Kunnen gebruikers verzoeken om gegevensverwijdering? **Ja**: in de app (Account > account verwijderen) en via https://www.yippogame.com/delete-account.
- Gegevens delen met derden? **Nee.** Supabase en Resend verwerken data in opdracht (verwerkers); dat geldt in Play niet als delen.

Gegevenstypen om aan te vinken (allemaal "verzameld", niet "gedeeld"):
| Categorie | Type | Doel | Verplicht? |
|---|---|---|---|
| Persoonlijke gegevens | E-mailadres | Accountbeheer | Optioneel |
| Persoonlijke gegevens | Naam (spelersnaam) | App-functionaliteit (scorebord) | Verplicht (automatisch) |
| Persoonlijke gegevens | Gebruikers-ID's | App-functionaliteit, accountbeheer | Verplicht |
| App-activiteit | Gamevoortgang, scores (andere acties in de app) | App-functionaliteit | Verplicht |

Niet aanvinken: locatie, financiële info, gezondheid, berichten, foto's/video, audio, contacten, agenda, web-/zoekgeschiedenis, apparaat-ID's, advertentiegegevens, crashlogs (geen crashrapportage ingebouwd).

## Content rating (IARC-vragenlijst)
- Categorie: Spel.
- Geweld, bloed, seksuele inhoud, grof taalgebruik, drugs/alcohol/tabak, gokken: **allemaal nee**.
- Digitale aankopen / advertenties: **nee**.
- Gebruikers kunnen met elkaar communiceren of inhoud delen? Spelers zien elkaars spelersnaam op scorebord en in leagues, maar er is geen chat of vrije tekst/foto's. Beantwoord de vraag over interactie zo dat het klopt met dit gegeven; de naam is beperkt tot 20 tekens. Controleer of de vragenlijst "gebruikersnamen delen" apart noemt en vink dat dan aan.
- Locatie delen: **nee**.
- Verwacht resultaat: PEGI 3 / Everyone.

## Doelgroep en inhoud
- Doelgroep: alle leeftijden, inclusief kinderen onder 13. Dat valt onder het Families-beleid van Google. Daarbij horen strengere regels: geen advertenties of trackers (voldaan), een privacyverklaring (aanwezig), en zorgvuldigheid met persoonsgegevens van kinderen (kinderen krijgen geen e-mailkoppeling).
- Kies in "Doelgroep en inhoud" de leeftijdsgroepen die je bedoelt en vul de vragen daarover eerlijk in. Maakt dat het "gemengde doelgroep" (kinderen en volwassenen) of "voornamelijk kinderen"? Laat dat bepalen op basis van hoe je het spel positioneert.
- Toegang tot accountverwijdering: de URL hierboven moet openbaar bereikbaar zijn (is zo).

## Nog te doen voor het indienen
- [ ] Privacyverklaring nalopen op deze lijst (wat, waarom, bewaartermijn, verwerkers, contact: info@hunting4cards.com / privacy@hunting4cards.com).
- [ ] Ontwikkelaarsnaam hernoemen naar SDH Games na de testperiode.
- [ ] Android-app bouwen (Capacitor) en intern testen.
- [ ] Screenshots, korte en lange beschrijving, icoon 512x512, feature graphic 1024x500.
