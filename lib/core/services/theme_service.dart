import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Téma kezelő szolgáltatás
/// Kezeli a világos/sötét mód váltását és a beállítások tárolását
class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // Rendszer beállítás alapján
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  bool get isLightMode {
    if (_themeMode == ThemeMode.system) {
      // Rendszer beállítás alapján
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.light;
    }
    return _themeMode == ThemeMode.light;
  }

  bool get isSystemMode => _themeMode == ThemeMode.system;

  /// Téma mód inicializálása SharedPreferences-ből
  Future<void> initTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 0; // 0 = system

      switch (themeIndex) {
        case 0:
          _themeMode = ThemeMode.system;
          break;
        case 1:
          _themeMode = ThemeMode.light;
          break;
        case 2:
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }

      notifyListeners();
    } catch (e) {
      // Hiba esetén alapértelmezett
      _themeMode = ThemeMode.system;
    }
  }

  /// Téma váltás
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    // Mentés SharedPreferences-be
    try {
      final prefs = await SharedPreferences.getInstance();
      int themeIndex;
      switch (mode) {
        case ThemeMode.system:
          themeIndex = 0;
          break;
        case ThemeMode.light:
          themeIndex = 1;
          break;
        case ThemeMode.dark:
          themeIndex = 2;
          break;
      }
      await prefs.setInt(_themeKey, themeIndex);
    } catch (e) {
      // Silent fail
    }
  }

  /// Téma váltás következő opcióra
  Future<void> toggleTheme() async {
    switch (_themeMode) {
      case ThemeMode.system:
        await setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.light:
        await setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        await setThemeMode(ThemeMode.system);
        break;
    }
  }

  /// Téma név lekérése
  String get themeModeName {
    switch (_themeMode) {
      case ThemeMode.system:
        return 'Automatikus';
      case ThemeMode.light:
        return 'Világos';
      case ThemeMode.dark:
        return 'Sötét';
    }
  }

  /// Téma ikon lekérése
  IconData get themeModeIcon {
    switch (_themeMode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
    }
  }

  /// Téma leírás lekérése
  String get themeModeDescription {
    switch (_themeMode) {
      case ThemeMode.system:
        return 'Követi a rendszer beállítását';
      case ThemeMode.light:
        return 'Mindig világos mód';
      case ThemeMode.dark:
        return 'Mindig sötét mód';
    }
  }
}
