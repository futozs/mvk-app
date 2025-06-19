# 🔥 Firebase Google Bejelentkezés Beállítási Útmutató

Ez az útmutató lépésről lépésre végigvezet a Firebase Google Sign-In integrációján a reMOBILON alkalmazásban.

## 📋 Előfeltételek

- Flutter fejlesztői környezet beállítva
- Android Studio vagy VS Code
- Google fiók
- Internet kapcsolat

## 🚀 1. lépés: Firebase Projekt Létrehozása

1. **Menj a [Firebase Console](https://console.firebase.google.com/)-ra**
2. **Kattints a "Create a project" gombra**
3. **Add meg a projekt nevét** (pl.: `remobilon-app-project`)
4. **Engedélyezd a Google Analytics-et** (opcionális)
5. **Válaszd ki vagy hozz létre egy Analytics fiókot**
6. **Kattints a "Create project" gombra**

## 📱 2. lépés: Android App Hozzáadása

1. **A Firebase Console-ban kattints az Android ikonra**
2. **Töltsd ki az Android package name mezőt:**
   ```
   hu.remobilon.app
   ```
3. **App nickname (opcionális):**
   ```
   reMOBILON
   ```
4. **Debug signing certificate SHA-1** - ezt a következő paranccsal kapod meg:
   ```bash
   cd "android"
   ./gradlew signingReport
   ```
   Vagy macOS-en:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
5. **Kattints a "Register app" gombra**

## 📄 3. lépés: google-services.json Letöltése

1. **Töltsd le a `google-services.json` fájlt**
2. **Helyezd be a következő helyre:**
   ```
   android/app/google-services.json
   ```
3. **FONTOS: Ez a fájl érzékeny adatokat tartalmaz - soha ne commitold git-be!**

## 🔧 4. lépés: Android Gradle Konfiguráció

A következő fájlok már be vannak állítva a projektben:

### `android/build.gradle.kts`
```kotlin
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

### `android/app/build.gradle.kts`
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}
```

## 🔐 5. lépés: Firebase Authentication Beállítása

### Google Sign-In Engedélyezése:

1. **A Firebase Console-ban menj az "Authentication" menüpontra**
2. **Kattints a "Get started" gombra (ha ez az első használat)**
3. **Menj a "Sign-in method" fülre**
4. **Kattints a "Google" providerre**
5. **Kapcsold be az "Enable" kapcsolót**
6. **Állítsd be a "Project public-facing name" mezőt** (pl. "reMOBILON")
7. **Válaszd ki a "Project support email"-t** (a saját email címed)
8. **Kattints a "Save" gombra**

## 🗄️ 6. lépés: Firestore Database Beállítása

### Database Létrehozása:

1. **A Firebase Console-ban menj a "Firestore Database" menüpontra**
2. **Kattints a "Create database" gombra**
3. **Válaszd a "Start in test mode" opciót** (később módosítható)
4. **Válassz egy régiót** (ajánlott: `europe-west3` - Frankfurt)
5. **Kattints a "Done" gombra**

### Biztonsági Szabályok Beállítása:

1. **Menj a "Rules" fülre**
2. **Cseréld ki a meglévő szabályokat erre:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Felhasználók csak a saját adataikat olvashatják/írhatják
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Felhasználói kedvencek
    match /users/{userId}/favorites/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

3. **Kattints a "Publish" gombra**

### Firestore API Engedélyezése:

1. **Menj a következő linkre:** 
   ```
   https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=PROJEKT_ID
   ```
   (Cseréld ki a `PROJEKT_ID`-t a saját Firebase projekt ID-dra)
2. **Kattints az "ENABLE" gombra**
3. **Várj néhány percet, hogy a változások életbe lépjenek**

## 📦 7. lépés: Flutter Függőségek

A `pubspec.yaml` fájlban már be vannak állítva a következő csomagok:
```yaml
dependencies:
  firebase_core: ^2.32.0
  firebase_auth: ^4.20.0
  google_sign_in: ^6.2.1
  cloud_firestore: ^4.17.5
```

##  8. lépés: nope

1. nincs 8. lépés
   
## ✅ 9. lépés: Tesztelés

1. **Indítsd el az alkalmazást:**
   ```bash
   flutter run
   ```

2. **Teszteld a bejelentkezést:**
   - Kattints a profil ikonra a navigációs sávban
   - Próbálj meg bejelentkezni Google fiókkal
   - Ellenőrizd, hogy megjelenik-e a profilkép

3. **Teszteld a szinkronizációt:**
   - Adj hozzá kedvenceket
   - Kapcsold be a felhő szinkronizációt
   - Ellenőrizd a Firestore Console-ban, hogy mentődnek-e az adatok

## 🚨 Hibakeresés

### "sign_in_failed, ApiException: 10" hiba
- **Ok:** Hiányzó vagy hibás SHA-1 ujjlenyomat
- **Megoldás:** Add hozzá a debug SHA-1 ujjlenyomatot a Firebase projekthez

### "A Firebase App named [DEFAULT] already exists" hiba
- **Ok:** A Firebase többször van inicializálva
- **Megoldás:** Már megoldva a kódban try-catch blokkal

### google-services.json hiányzik
- **Ok:** A fájl nincs a megfelelő helyen
- **Megoldás:** Helyezd be az `android/app/` mappába

## 🔒 Biztonsági Megjegyzések

1. **SOHA ne commitold a következő fájlokat:**
   - `google-services.json`
   - `GoogleService-Info.plist`
   - `.env` fájl
   - Bármilyen API kulcs

2. **Production környezetben:**
   - Használj production SHA-1 ujjlenyomatot
   - Állítsd be a Firestore security rules-t
   - Engedélyezd a domain korlátozásokat

3. **A .gitignore fájl már tartalmazza ezeket:**
   ```gitignore
   android/app/google-services.json
   ios/Runner/GoogleService-Info.plist
   .env
   .env.*
   ```

## 📞 Segítség

Ha problémába ütközöl:
1. Ellenőrizd a Firebase Console logs-okat
2. Nézd meg a Flutter/Android logokat
3. Győződj meg róla, hogy minden függőség frissítve van
4. Tisztítsd meg a build cache-t: `flutter clean && flutter pub get`

## ✨ Készen vagy!

Most már teljes mértékben működik a Google bejelentkezés és a felhő szinkronizáció a reMOBILON alkalmazásban! 🎉
