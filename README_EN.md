# 🚌 reMOBILON - Modern Public Transportation App

[![Magyar verzió](https://img.shields.io/badge/📖_Magyar_verzió-green?style=for-the-badge&logo=readme&logoColor=white)](README.md)

Modern public transportation timetable and vehicle tracking for Miskolc.

## ⚡ Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/futozs/mvk-app.git
cd mvk-app
```

### 2. Firebase Configuration
```bash
# Copy example files
cp lib/firebase_options.dart.example lib/firebase_options.dart
cp android/app/google-services.json.example android/app/google-services.json

# ⚠️ IMPORTANT: Fill in your own Firebase data in the files!
# Detailed guide: FIREBASE_SETUP_EN.md
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Run Application
```bash
flutter run
```

## 🔥 Firebase Setup

Detailed Firebase setup guide: **[FIREBASE_SETUP_EN.md](FIREBASE_SETUP_EN.md)**

### Required Steps:
1. Create Firebase project
2. Add Android/iOS app
3. Configure SHA-1 fingerprint
4. Enable Firebase services
5. Download configuration files

## ⚠️ ALPHA VERSION WARNING

**THIS APPLICATION IS STILL UNDER DEVELOPMENT!**

- **NOT FINISHED** - Development is in early stages
- **NOT PRODUCTION READY** - For testing purposes only
- **INCOMPLETE FEATURES** - Many features are not yet implemented
- **BUGS EXPECTED** - The application may be unstable
- **UNDER CONTINUOUS DEVELOPMENT** - Everything may change daily

**This is an experimental project and proof-of-concept! Use at your own risk!**

## Features

- Modern, user-friendly interface
- Interactive map with OpenStreetMap integration
- Real-time vehicle tracking
- Detailed timetables and route planning
- GPS-based location services
- Beautiful animations and transitions

## Technologies

- **Flutter** - Cross-platform development
- **Bloc** - State management
- **OpenStreetMap** - Map visualization
- **Hive** - Local data storage
- **GTFS** - Transportation data
- **Material Design** - Modern UI

## Development

This application was created **with AI collaboration** using the "vibe coded" method - a combination of modern development and artificial intelligence.

## Running

```bash
# Install dependencies
flutter pub get

# Set up environment variables
# 1. Copy the .env.example file as .env
cp .env.example .env

# 2. Edit the .env file and add your own API keys
# WEATHER_API_KEY=your_openweathermap_api_key_here

# Run application in debug mode
flutter run --debug

# Build APK
flutter build apk
flutter build apk --no-tree-shake-icons
```

## Environment Variables

The application uses an `.env` file to store the weather API key.

### Setup:

1. **Copy the example file:**
   ```bash
   cp .env.example .env
   ```

2. **Edit the `.env` file:**
   ```env
   WEATHER_API_KEY=your_api_key_here
   ```

3. **Get OpenWeatherMap API key:**
   - Go to [OpenWeatherMap](https://openweathermap.org/api)
   - Register a free account
   - Copy the API key to the `.env` file

**⚠️ IMPORTANT: The `.env` file is not under version control! Never commit your API keys!**

## 🔐 Google Sign-In and Cloud Synchronization

The application supports Google account sign-in and cloud synchronization of favorites:

### Features:
- **Google Sign-In**: Secure authentication with Google account
- **Profile Picture Display**: Google account profile picture appears in the navigation bar
- **Automatic Synchronization**: Favorite stops are automatically synced to the cloud
- **Manual Synchronization**: Option for manual sync
- **Data Restoration**: Restore favorites from another device

### Usage:
1. Click the profile icon in the navigation bar
2. Sign in with your Google account
3. Enable automatic synchronization
4. Your favorites are automatically saved to the cloud

### 🔧 Firebase Setup:
**Detailed guide:** [FIREBASE_SETUP_EN.md](FIREBASE_SETUP_EN.md)

**Quick setup for developers:**
1. Create Firebase project on [Firebase Console](https://console.firebase.google.com/)
2. Add Android app to the project (with `hu.remobilon.app` package name)
3. Download `google-services.json` and place it at: `android/app/google-services.json`
4. Add SHA-1 fingerprint to Firebase project:
   ```bash
   cd android && ./gradlew signingReport
   ```
5. Detailed steps: [FIREBASE_SETUP_EN.md](FIREBASE_SETUP_EN.md)

⚠️ **IMPORTANT:** The `google-services.json` and other sensitive files are already in `.gitignore`!

## Screenshots 📱

<div align="center">
  <table>
    <tr>
      <td align="center">
        <a href="https://cdn.futozsombor.hu/u/BIfWO9.jpg">
          <img src="https://cdn.futozsombor.hu/u/BIfWO9.jpg" width="200" alt="Loading Screen">
        </a>
        <br>
        <em>Loading Screen</em>
      </td>
      <td align="center">
        <a href="https://cdn.futozsombor.hu/u/jl4COt.jpg">
          <img src="https://cdn.futozsombor.hu/u/jl4COt.jpg" width="200" alt="Home Page">
        </a>
        <br>
        <em>Home Page</em>
      </td>
    </tr>
    <tr>
      <td align="center">
        <a href="https://cdn.futozsombor.hu/u/qbYJYl.jpg">
          <img src="https://cdn.futozsombor.hu/u/qbYJYl.jpg" width="200" alt="Favorites">
        </a>
        <br>
        <em>Favorites</em>
      </td>
      <td align="center">
        <a href="https://cdn.futozsombor.hu/u/kgmEVD.jpg">
          <img src="https://cdn.futozsombor.hu/u/kgmEVD.jpg" width="200" alt="Settings">
        </a>
        <br>
        <em>Settings</em>
      </td>
    </tr>
  </table>
</div>

*Click on the images for larger view*

## License
whynot

This project was created for educational and demonstration purposes!!!
