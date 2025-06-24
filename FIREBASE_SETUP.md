# 🔥 Firebase Beállítási Útmutató - reMOBILON

Ez az útmutató lépésről lépésre bemutatja, hogyan állítsd be a Firebase integrációt a reMOBILON alkalmazáshoz.

## 📋 Előfeltételek

- Flutter SDK telepítve
- Android Studio vagy VS Code
- Google fiók
- Node.js telepítve (Firebase CLI-hez)

## 🚀 1. lépés: Firebase projekt létrehozása

1. Menj a [Firebase Console](https://console.firebase.google.com/)-ra
2. Kattints a "Create a project" vagy "Add project" gombra
3. Add meg a projekt nevét (pl. "mvk-app")
4. Válaszd ki, hogy szeretnél-e Google Analytics-et használni
5. Kattints a "Create project" gombra

## 🔧 2. lépés: Flutter Firebase CLI telepítése

Nyisd meg a terminált és futtasd az alábbi parancsokat:

```bash
# Firebase CLI telepítése (ha még nincs telepítve)
npm install -g firebase-tools

# Firebase CLI bejelentkezés
firebase login

# FlutterFire CLI telepítése
flutter pub global activate flutterfire_cli

# PATH beállítása (zshrc-hez)
echo 'export PATH="$PATH":"$HOME/.pub-cache/bin"' >> ~/.zshrc
source ~/.zshrc
```

## 📱 3. lépés: Android alkalmazás hozzáadása

1. A Firebase Console-ban kattints az Android ikonra
2. Package name: `hu.remobilon.app` (vagy saját package neved)
3. App nickname: `reMOBILON Android`
4. **FONTOS:** SHA-1 certificate fingerprint megszerzése:

```bash
# Debug keystore SHA-1 lekérése
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

5. Másold ki a SHA-1 értéket és illeszd be a Firebase Console-ba
6. Kattints a "Register app" gombra
7. **Töltsd le a `google-services.json` fájlt** és helyezd el: `android/app/google-services.json`

## 🍎 4. lépés: iOS alkalmazás hozzáadása (opcionális)

1. A Firebase Console-ban kattints az iOS ikonra
2. iOS bundle ID: `hu.remobilon.hu` (vagy saját bundle id)
3. App nickname: `reMOBILON iOS`
4. **Töltsd le a `GoogleService-Info.plist` fájlt** és helyezd el: `ios/Runner/GoogleService-Info.plist`

## ⚡ 5. lépés: Firebase konfiguráció generálása

A projekt gyökérkönyvtárában futtasd:

```bash
# Firebase projekt konfigurálása
flutterfire configure

# Válaszd ki a Firebase projekted
# Válaszd ki a platformokat (Android, iOS)
# Konfirm the configuration
```

Ez automatikusan létrehozza a `lib/firebase_options.dart` fájlt.

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

## 🔐 6. lépés: Firebase szolgáltatások engedélyezése

### Authentication beállítása:
1. Firebase Console → Authentication → Get started
2. Sign-in method → Google → Enable
3. Support email beállítása
4. Save

### Firestore Database beállítása:
1. Firebase Console → Firestore Database → Create database
2. Start in test mode (később változtathatod production-re)
3. Válassz egy lokációt (europe-west3 ajánlott EU-hoz)

### Storage beállítása:
1. Firebase Console → Storage → Get started
2. Start in test mode
3. Válassz egy lokációt

## 📝 7. lépés: Szükséges Android fájlok létrehozása

### `android/app/src/main/res/values/styles.xml`
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Theme applied to the Android Application as soon as it is started. -->
    <style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <!-- Show a splash screen on the activity. Automatically removed when
             Flutter draws its first frame -->
        <item name="android:windowBackground">@drawable/launch_background</item>
    </style>
    
    <!-- Theme applied to the Android Application after the splash screen. -->
    <style name="NormalTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">?android:colorBackground</item>
    </style>
</resources>
```

### `android/app/src/main/res/xml/network_security_config.xml`
```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">localhost</domain>
        <domain includeSubdomains="true">10.0.2.2</domain>
        <domain includeSubdomains="true">192.168.1.0/24</domain>
    </domain-config>
</network-security-config>
```

### `android/app/src/main/res/drawable/launch_background.xml`
```xml
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@android:color/white" />
    <!-- Itt adhatsz hozzá saját splash screen képet -->
</layer-list>
```

## 🏗️ 8. lépés: Projekt build és futtatás

```bash
# Projekt tisztítása
flutter clean

# Dependencies telepítése
flutter pub get

# Android build
flutter build apk --debug

# Alkalmazás futtatása
flutter run
```

## 📋 9. lépés: GitHub repository előkészítése

### Fontos fájlok másolása:
1. Másold át `lib/firebase_options.dart` → `lib/firebase_options.dart.example`
2. Másold át `android/app/google-services.json` → `android/app/google-services.json.example`
3. Távolítsd el az érzékeny adatokat az example fájlokból

### .gitignore ellenőrzése:
Győződj meg róla, hogy a `.gitignore` fájl tartalmazza:
```gitignore
# 🔐 FIREBASE ÉRZÉKENY ADATOK
lib/firebase_options.dart
android/app/google-services.json
ios/Runner/GoogleService-Info.plist

# ⚠️ XML fájlok KIVÉTELEI - ezek kellenek!
!android/app/src/main/res/**/*.xml
!ios/**/*.xml
```

## 🐛 Hibaelhárítás

### Google Sign-In nem működik:
1. Ellenőrizd, hogy a `google-services.json` fájl az `android/app/` mappában van
2. Ellenőrizd, hogy a SHA-1 fingerprint helyes a Firebase Console-ban
3. Győződj meg róla, hogy a Google Sign-In engedélyezve van a Firebase Authentication-ban
4. Próbáld meg: `flutter clean && flutter pub get`

### Build hibák:
1. `flutter clean && flutter pub get`
2. Ellenőrizd, hogy minden szükséges XML fájl létezik
3. Restart Android Studio/VS Code
4. Ellenőrizd a `android/app/build.gradle.kts` fájlban a Google Services plugin-t

### Firebase kapcsolódási problémák:
1. Ellenőrizd az internet kapcsolatot
2. Ellenőrizd a Firebase projekt beállításait
3. Nézd meg a console log-okat a részletes hibaüzenetekért

### "ApiException: 10" hiba:
Ez DEVELOPER_ERROR, ami azt jelenti:
1. SHA-1 fingerprint nem stimmel
2. Package name nem egyezik
3. `google-services.json` hibás vagy hiányzó

## 📚 További információk

- [FlutterFire dokumentáció](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [Flutter Firebase Codelab](https://firebase.google.com/codelabs/firebase-get-to-know-flutter)

## ⚠️ Biztonsági megjegyzések

- A `firebase_options.dart` fájl NE legyen commitolva a git repository-ba
- A `google-services.json` és `GoogleService-Info.plist` fájlok NE legyenek commitolva
- Használj environment változókat production környezetben
- Firebase Security Rules beállítása production előtt kötelező

## 🎯 Gyors setup új projekthez

1. Clone a repository
2. `cp lib/firebase_options.dart.example lib/firebase_options.dart`
3. `cp android/app/google-services.json.example android/app/google-services.json`
4. Töltsd ki a saját Firebase adataiddal
5. `flutter clean && flutter pub get`
6. `flutter run`

---

**Készítette:** reMOBILON fejlesztői csapat  
**Utolsó frissítés:** 2025. június 25.
