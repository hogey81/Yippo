# Beoordeling vragen in de app (voorbereid, staat uit)

Officiële Google-pop-up (in-app review) via plug-in `@capacitor-community/in-app-review`.

**Aanzetten** (pas na goedkeuring eerste release):
1. In `index.html`: `REVIEW_ENABLED=true`.
2. Nieuwe .aab bouwen (workflow android-release) en uploaden als tweede release, samen met pushmeldingen.
3. Testen: de pop-up werkt alleen via Play Store-installatie (niet via sideload).

**Wanneer:** na het winnen van level 10, 20 of 40 (2,2 s na het scherm "Level gehaald"), alleen als:
- speler is volwassen (`S.age==='adult'`), minstens 2 verschillende speeldagen, minstens 1 dier in de dierentuin;
- laatste verzoek ≥ 30 dagen geleden en maximaal 3 keer in totaal.

Data safety en privacyverklaring hoeven niet te veranderen: de plug-in verzamelt niets.
