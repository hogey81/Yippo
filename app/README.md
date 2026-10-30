# Yippo Android-app (Capacitor)

De app is een Android-schil om https://www.yippogame.com (pakketnaam `com.yippogame.app`, die kan na publicatie niet meer veranderen).
Omdat de app de live site toont, zijn nieuwe werelden en fixes direct in de app te zien, zonder nieuwe release in de Play Store.
Zonder internet toont de app `www/offline.html`.

## Bouwen (in de cloud, geen Android Studio nodig)
GitHub > repo Yippo > Actions > "Android-app bouwen" > Run workflow. Daarna onderaan op de run: Artifacts.
- `yippo-debug-apk`: installeer op je eigen telefoon om te testen (zet "onbekende apps installeren" aan).
- `yippo-release-aab`: ondertekend bestand voor Google Play (alleen als de vier geheimen hieronder staan).

## Geheimen voor de ondertekende AAB (GitHub > Settings > Secrets and variables > Actions)
- `ANDROID_KEYSTORE_BASE64`: de uploadsleutel (.jks) als base64
- `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`
Bewaar de sleutel (.jks) en de wachtwoorden ook buiten GitHub (wachtwoordmanager). Google Play beheert de echte appsleutel (Play App Signing); dit is alleen de uploadsleutel.

## Lokaal (optioneel)
`cd app && npm ci && npx cap sync android && cd android && ./gradlew assembleDebug` (JDK 21 en Android SDK nodig).
