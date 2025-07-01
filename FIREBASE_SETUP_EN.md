# 🔥 Firebase Setup Guide - reMOBILON

[![Magyar verzió](https://img.shields.io/badge/📖_Magyar_verzió-green?style=for-the-badge&logo=readme&logoColor=white)](FIREBASE_SETUP.md)

This guide shows step-by-step how to set up Firebase integration for the reMOBILON application.

## 📋 Prerequisites

- Flutter SDK installed
- Android Studio or VS Code
- Google account
- Node.js installed (for Firebase CLI)

## 🚀 Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project" button
3. Enter the project name (e.g., "mvk-app")
4. Choose whether you want to use Google Analytics
5. Click the "Create project" button

## 🔧 Step 2: Install Flutter Firebase CLI

Open terminal and run the following commands:

```bash
# Install Firebase CLI (if not already installed)
npm install -g firebase-tools

# Firebase CLI login
firebase login

# Install FlutterFire CLI
flutter pub global activate flutterfire_cli

# Set PATH (for zshrc)
echo 'export PATH="$PATH":"$HOME/.pub-cache/bin"' >> ~/.zshrc
source ~/.zshrc
```

## 📱 Step 3: Add Android Application

1. In Firebase Console click the Android icon
2. Package name: `hu.remobilon.app` (or your own package name)
3. App nickname: `reMOBILON Android`
4. **IMPORTANT:** Get SHA-1 certificate fingerprint:

```bash
# Get debug keystore SHA-1
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

5. Copy the SHA-1 value and paste it into Firebase Console
6. Click the "Register app" button
7. **Download the `google-services.json` file** and place it at: `android/app/google-services.json`

## 🍎 Step 4: Add iOS Application (optional)

1. In Firebase Console click the iOS icon
2. iOS bundle ID: `hu.remobilon.hu` (or your own bundle id)
3. App nickname: `reMOBILON iOS`
4. **Download the `GoogleService-Info.plist` file** and place it at: `ios/Runner/GoogleService-Info.plist`

## ⚡ Step 5: Generate Firebase Configuration

Run in the project root directory:

```bash
# Configure Firebase project
flutterfire configure

# Select your Firebase project
# Select platforms (Android, iOS)
# Confirm the configuration
```

This will automatically create the `lib/firebase_options.dart` file.

## 📱 Step 2: Add Android App

1. **In Firebase Console click the Android icon**
2. **Fill in the Android package name field:**
   ```
   hu.remobilon.app
   ```
3. **App nickname (optional):**
   ```
   reMOBILON
   ```
4. **Debug signing certificate SHA-1** - get this with the following command:
   ```bash
   cd "android"
   ./gradlew signingReport
   ```
   Or on macOS:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
5. **Click the "Register app" button**

## 📄 Step 3: Download google-services.json

1. **Download the `google-services.json` file**
2. **Place it at the following location:**
   ```
   android/app/google-services.json
   ```
3. **IMPORTANT: This file contains sensitive data - never commit it to git!**

## 🔧 Step 4: Android Gradle Configuration

The following files are already configured in the project:

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

## 🔐 Step 5: Setup Firebase Authentication

### Enable Google Sign-In:

1. **In Firebase Console go to "Authentication" menu**
2. **Click "Get started" button (if this is first use)**
3. **Go to "Sign-in method" tab**
4. **Click on "Google" provider**
5. **Toggle the "Enable" switch**
6. **Set the "Project public-facing name" field** (e.g., "reMOBILON")
7. **Select "Project support email"** (your email address)
8. **Click "Save" button**

## 🔐 Step 6: Enable Firebase Services

### Setup Authentication:
1. Firebase Console → Authentication → Get started
2. Sign-in method → Google → Enable
3. Set support email
4. Save

### Setup Firestore Database:
1. Firebase Console → Firestore Database → Create database
2. Start in test mode (you can change to production later)
3. Choose a location (europe-west3 recommended for EU)

### Setup Storage:
1. Firebase Console → Storage → Get started
2. Start in test mode
3. Choose a location

## 📝 Step 7: Create Required Android Files

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
    <!-- You can add your own splash screen image here -->
</layer-list>
```

## 🏗️ Step 8: Build and Run Project

```bash
# Clean project
flutter clean

# Install dependencies
flutter pub get

# Android build
flutter build apk --debug

# Run application
flutter run
```

## 📋 Step 9: Prepare GitHub Repository

### Copy Important Files:
1. Copy `lib/firebase_options.dart` → `lib/firebase_options.dart.example`
2. Copy `android/app/google-services.json` → `android/app/google-services.json.example`
3. Remove sensitive data from example files

### Check .gitignore:
Make sure the `.gitignore` file contains:
```gitignore
# 🔐 FIREBASE SENSITIVE DATA
lib/firebase_options.dart
android/app/google-services.json
ios/Runner/GoogleService-Info.plist

# ⚠️ XML FILE EXCEPTIONS - these are needed!
!android/app/src/main/res/**/*.xml
!ios/**/*.xml
```

## 🐛 Troubleshooting

### Google Sign-In not working:
1. Check that the `google-services.json` file is in the `android/app/` folder
2. Check that the SHA-1 fingerprint is correct in Firebase Console
3. Make sure Google Sign-In is enabled in Firebase Authentication
4. Try: `flutter clean && flutter pub get`

### Build errors:
1. `flutter clean && flutter pub get`
2. Check that all required XML files exist
3. Restart Android Studio/VS Code
4. Check the Google Services plugin in `android/app/build.gradle.kts`

### Firebase connection problems:
1. Check internet connection
2. Check Firebase project settings
3. Look at console logs for detailed error messages

### "ApiException: 10" error:
This is DEVELOPER_ERROR, which means:
1. SHA-1 fingerprint doesn't match
2. Package name doesn't match
3. `google-services.json` is incorrect or missing

## 📚 Further Information

- [FlutterFire documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [Flutter Firebase Codelab](https://firebase.google.com/codelabs/firebase-get-to-know-flutter)

## ⚠️ Security Notes

- The `firebase_options.dart` file should NOT be committed to git repository
- The `google-services.json` and `GoogleService-Info.plist` files should NOT be committed
- Use environment variables in production environment
- Setting up Firebase Security Rules is mandatory before production

## 🎯 Quick Setup for New Project

1. Clone the repository
2. `cp lib/firebase_options.dart.example lib/firebase_options.dart`
3. `cp android/app/google-services.json.example android/app/google-services.json`
4. Fill in your own Firebase data
5. Copy GTFS data to `assets/mvkzrt/` folder
6. `flutter clean && flutter pub get`
7. `flutter run`

## 🗂️ GTFS Data

The application requires GTFS data placed in the `assets/mvkzrt/` folder:
- `*.txt` files: GTFS format timetable data
- `*.json` files: Processed JSON format data

**Important:** These data files are NOT uploaded to the Git repository for security reasons!

---

**Created by:** reMOBILON development team  
**Last updated:** June 25, 2025
