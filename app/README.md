# Yippo Android-app (Capacitor)

De app is een Android-schil om https://www.yippogame.com (pakketnaam `com.yippogame.app`, die kan na publicatie niet meer veranderen).
Omdat de app de live site toont, zijn nieuwe werelden en fixes direct in de app te zien, zonder nieuwe release in de Play Store.
Zonder internet toont de app `www/offline.html`.

## Bouwen (in de cloud, geen Android Studio nodig)
- Testapp: wordt automatisch gebouwd bij elke wijziging in `app/` (of handmatig: GitHub > Actions > "Android testapp" > Run workflow). Download `Yippo-test.apk` bij Releases > "Android testapp".
- Play Store-versie: GitHub > Actions > "Android Play Store build" > Run workflow. Download `Yippo.aab` bij Releases > "Android Play Store-versie". Nodig: de geheimen `ANDROID_UPLOAD_KEYSTORE_B64` (de uploadsleutel als base64, formaat PKCS12, alias `upload`) en `ANDROID_UPLOAD_PASSWORD`. Dezelfde werkwijze als de Hunting4Cards-app.

## Lokaal (optioneel)
`cd app && npm ci && npx cap sync android && cd android && ./gradlew assembleDebug` (JDK 21 en Android SDK nodig).
