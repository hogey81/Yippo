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
