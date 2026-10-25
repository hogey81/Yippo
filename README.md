# 🐾 Yippo

Een match-3 spel met dieren. Eén bestand (`index.html`), geen build nodig.

- 40 levels met doelen: dieren verzamelen, ijs breken, speciale dieren maken, score halen
- Speciale dieren: 🦁 (4 op een rij) · 🐘 (2×2 vierkant) · 🐉 (L/T-vorm) · 🦄 (5 op een rij)
- Dagelijkse puzzel met reeks (streak) en deelknop
- Geluid, trillen op mobiel, hint, schudden, hamer
- Voortgang wordt in de browser opgeslagen

## Lokaal spelen
Open `index.html` in je browser.

## Vercel
Framework Preset: **Other**, geen build command, geen output directory. Vercel serveert `index.html` direct.

## Accounts, scorebord, leagues en cloud-opslag (Supabase)
Spelers krijgen automatisch een **gastaccount** (anoniem inloggen). Daaraan hangen hun naam, scores, leagues en voortgang.
De online functies staan uit zolang `SB_URL` en `SB_KEY` in `index.html` leeg zijn.

1. Maak een gratis project op supabase.com (of gebruik een bestaand project; alle namen beginnen met `yippo_`).
2. **Authentication → Sign In / Providers → Allow anonymous sign-ins**: aanzetten.
3. **SQL Editor**: plak de inhoud van `supabase/yippo.sql` en klik **Run** (opnieuw draaien is veilig).
4. **Project Settings → API Keys**: kopieer de Project URL en de publishable (of anon) key naar `SB_URL` en `SB_KEY` in `index.html`.

De tabellen zijn niet rechtstreeks te lezen of te schrijven (Row Level Security). Alles loopt via de `yippo_*`-functies,
die controleren wie je bent (`auth.uid()`), en namen, scores (0 tot 50.000) en datums valideren.
Spelers kunnen hun account en alle gegevens verwijderen via **Account** in het menu.

## Inloggen met e-mail (zonder wachtwoord)
Spelers beginnen als gast. Ze kunnen hun voortgang bewaren met een e-mailadres en een code van 6 cijfers
(`💾 Bewaar je voortgang`), en op een nieuw apparaat inloggen met `🔑 Inloggen`. Zie `supabase/email-templates.md`
voor de mailteksten die je in Supabase moet instellen.

## Voorproefje (?beta=1)
Alle functies (kaart, dierentuin, wereldkaart, nieuwe menu) staan voor iedereen aan. Werelden gaan open op hun `release`-moment (vrijdag 18:00). Met `?beta=1` kun je een wereld die nog dicht is alvast spelen om te testen (`?beta=0` zet het weer uit).

## Talen (Nederlands, Engels, Spaans)

De code schrijft Nederlandse teksten. `i18n.js` vertaalt wat er op het scherm komt naar Engels of Spaans (rijen `[nl, en, es]`, `{}` is een invulplek). De taal komt uit de keuze van de speler (🌐-knop in het menu), anders uit de taal van de telefoon; bestaande spelers blijven Nederlands tot ze zelf kiezen.

Nieuwe tekst toevoegen: voeg een rij toe aan `ROWS` in `i18n.js`. Voor een nieuwe taal komt er een kolom bij, plus `LANGS`/`IDX` in `i18n.js` en `NAME_SETS`/`LOCALES` in `index.html`. Teksten die nog niet vertaald zijn staan in `I18N.miss()` in de browserconsole.

## Adres
Het spel staat op https://www.yippogame.com (yippogame.com stuurt door). Het oude adres https://yippo-game.vercel.app blijft werken. De DNS staat bij Vercel (nameservers van Vercel ingesteld bij Hostinger).

## Beheerpagina (/beheer)
`beheer.html` (op https://www.yippogame.com/beheer) toont statistieken: actieve en nieuwe accounts, spelers per dag, voortgang per wereld, leagues. Inloggen met een code per e-mail; alleen adressen in de tabel `yippo_admins` krijgen cijfers terug (zie `supabase/admin.sql`, functie `yippo_admin_stats`). Het geeft alleen totalen terug, geen persoonsgegevens. Een beheeraccount maak je in Supabase onder Authentication, Users, Add user (met "Auto confirm user").
