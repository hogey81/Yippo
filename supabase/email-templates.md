# Mailteksten voor Yippo (inloggen met een code)

Het spel stuurt geen links maar een **code van 6 cijfers**. Daarvoor moeten de mailteksten in Supabase de code (`{{ .Token }}`) tonen.
Pas in Supabase onder **Authentication → Emails → Templates** (of **Email Templates**) deze drie sjablonen aan.
Gebruik voor alle drie dezelfde tekst:

| Sjabloon in Supabase | Wanneer verstuurd |
|---|---|
| **Confirm email change** (Change Email Address) | Een gast koppelt zijn e-mailadres (💾 Bewaar je voortgang) |
| **Magic Link** | Iemand logt in op een nieuw apparaat (🔑 Inloggen) |
| **Confirm sign up** | Reserve, voor als Supabase dit sjabloon toch gebruikt |

## Onderwerp (Subject)
```
Jouw Yippo-code: {{ .Token }}
```
De code staat in het onderwerp, zodat je hem al in de melding op je telefoon ziet.

## Berichttekst (Message body, HTML)
```html
<div style="font-family:Arial,Helvetica,sans-serif;max-width:420px;margin:0 auto;padding:24px;text-align:center;color:#2b0057">
  <h2 style="margin:0 0 8px">🐮 Jouw Yippo-code</h2>
  <p style="margin:0 0 12px">Vul deze verificatiecode in het spel in:</p>
  <p style="font-size:38px;font-weight:bold;letter-spacing:10px;background:#f1e6ff;border-radius:14px;padding:16px;margin:0 0 12px;-webkit-user-select:all;user-select:all">{{ .Token }}</p>
  <p style="margin:0 0 16px;font-size:14px">Kopieer de code en tik in het spel op <b>📋 Plak</b>.</p>
  <p style="color:#666;font-size:13px;margin:0 0 6px">De code is een uur geldig. Heb je dit niet aangevraagd? Dan kun je deze mail gewoon negeren.</p>
  <p style="color:#999;font-size:12px;margin:0">Your Yippo verification code is {{ .Token }}</p>
</div>
```

## Overige instellingen (controleren)
- **Authentication → Sign In / Providers → Email**: de e-mailprovider staat **aan**. "Email OTP Length" op **6** (standaard).
- **Anonymous sign-ins** staan aan (al gedaan).
- Voor het testen met je eigen adres werkt de standaard-mailserver van Supabase. Die stuurt weinig mails per uur en alleen naar adressen van je eigen team.
  Voor echte spelers koppel je een eigen mailservice (SMTP, bijvoorbeeld Resend) onder **Authentication → Emails → SMTP Settings**.
