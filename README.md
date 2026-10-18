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

## Wereldwijd scorebord en leagues (Supabase)
Het scorebord staat uit zolang `SB_URL` en `SB_KEY` in `index.html` leeg zijn.

1. Maak een gratis project op supabase.com (of gebruik een bestaand project, alle namen beginnen met `yippo_`).
2. Open **SQL Editor**, plak de inhoud van `supabase/yippo.sql` en klik **Run**.
3. Ga naar **Project Settings → API** en kopieer de **Project URL** en de **anon public key**.
4. Zet ze bovenin het scriptdeel `online: scorebord + leagues` van `index.html` bij `SB_URL` en `SB_KEY`.

De tabellen zijn niet rechtstreeks te lezen of te schrijven (Row Level Security); alles loopt via de `yippo_*`-functies,
die namen, scores (0 tot 50.000) en datums controleren.
