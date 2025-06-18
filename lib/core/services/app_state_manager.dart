import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Globális alkalmazás állapot kezelő
/// Kezeli az alkalmazás lifecycle-ját és a háttérből való visszatérést
class AppStateManager extends ChangeNotifier with WidgetsBindingObserver {
  static final AppStateManager _instance = AppStateManager._internal();
  factory AppStateManager() => _instance;
  AppStateManager._internal();

  // Alkalmazás állapotok
  AppLifecycleState _lifecycleState = AppLifecycleState.resumed;
  bool _isInitialized = false;
  bool _isBackgroundMode = false;
  DateTime? _backgroundTime;
  bool _shouldShowSplash = true;

  // Getters
  AppLifecycleState get lifecycleState => _lifecycleState;
  bool get isInitialized => _isInitialized;
  bool get isBackgroundMode => _isBackgroundMode;
  bool get shouldShowSplash => _shouldShowSplash;

  /// Alkalmazás állapot manager inicializálása
  void initialize() {
    if (_isInitialized) return;

    WidgetsBinding.instance.addObserver(this);
    _isInitialized = true;
    debugPrint('🟢 AppStateManager: Inicializálva');
  }

  /// Alkalmazás első indítás után
  void markAppAsStarted() {
    _shouldShowSplash = false;
    notifyListeners();
    debugPrint('🟢 AppStateManager: App elindítva - splash mellőzhető');
  }

  /// Splash screen kényszerítése (debug/újraindítás)
  void forceSplashScreen() {
    _shouldShowSplash = true;
    notifyListeners();
    debugPrint('🔄 AppStateManager: Splash screen kényszerítése');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final previousState = _lifecycleState;
    _lifecycleState = state;

    switch (state) {
      case AppLifecycleState.resumed:
        _handleAppResumed(previousState);
        break;
      case AppLifecycleState.inactive:
        _handleAppInactive();
        break;
      case AppLifecycleState.paused:
        _handleAppPaused();
        break;
      case AppLifecycleState.detached:
        _handleAppDetached();
        break;
      case AppLifecycleState.hidden:
        _handleAppHidden();
        break;
    }

    notifyListeners();
  }

  void _handleAppResumed(AppLifecycleState previousState) {
    if (_isBackgroundMode) {
      final backgroundDuration =
          _backgroundTime != null
              ? DateTime.now().difference(_backgroundTime!)
              : Duration.zero;

      debugPrint('🟢 AppStateManager: App visszatért a foreground-ba');
      debugPrint(
        '⏱️ Háttérben töltött idő: ${backgroundDuration.inSeconds} másodperc',
      );

      // Ha kevesebb mint 30 másodpercet töltött a háttérben, ne splash screen
      if (backgroundDuration.inSeconds < 30) {
        _shouldShowSplash = false;
        debugPrint('✅ Gyors visszatérés - splash mellőzése');
      } else if (backgroundDuration.inMinutes > 5) {
        // Ha 5 percnél tovább volt háttérben, refresh szükséges
        _shouldShowSplash = true;
        debugPrint('🔄 Hosszú háttér idő - splash screen megjelenítése');
      }

      _isBackgroundMode = false;
      _backgroundTime = null;
    }
  }

  void _handleAppInactive() {
    debugPrint('🟡 AppStateManager: App inaktív (átmeneti állapot)');
    // Ne csináljunk semmit - átmeneti állapot
  }

  void _handleAppPaused() {
    debugPrint('🟡 AppStateManager: App háttérbe került');
    _isBackgroundMode = true;
    _backgroundTime = DateTime.now();

    // Memory management - tisztítsuk a nem szükséges cache-eket
    _cleanupMemory();
  }

  void _handleAppDetached() {
    debugPrint('🔴 AppStateManager: App leválasztva (teljes kilépés)');
    // Ez igazi kilépés - legközelebb splash screen kell
    _shouldShowSplash = true;
  }

  void _handleAppHidden() {
    debugPrint('🟡 AppStateManager: App elrejtve');
    // Hasonló a paused-hoz
    if (!_isBackgroundMode) {
      _isBackgroundMode = true;
      _backgroundTime = DateTime.now();
    }
  }

  void _cleanupMemory() {
    // Memória optimalizálás háttérbe kerüléskor
    try {
      // Rendszer szintű garbage collection javaslat
      debugPrint('🧹 AppStateManager: Memória tisztítás...');
    } catch (e) {
      debugPrint('❌ AppStateManager: Memória tisztítás hiba: $e');
    }
  }

  /// Vissza gomb kezelése - megakadályozza a véletlenszerű kilépést
  Future<bool> handleBackButton(BuildContext context) async {
    debugPrint('⬅️ AppStateManager: Vissza gomb megnyomva');

    // Ha root route-on vagyunk, háttérbe küldjük az app-ot ahelyett hogy kilépnénk
    if (Navigator.of(context).canPop()) {
      return true; // Engedjük a navigációt
    } else {
      // Root route - háttérbe küldés
      await _moveToBackground();
      return false; // Ne lépjen ki
    }
  }

  Future<void> _moveToBackground() async {
    try {
      debugPrint('📱 AppStateManager: Alkalmazás háttérbe küldése...');
      // SystemNavigator.pop() helyett SystemChrome használata
      await SystemChannels.platform.invokeMethod('SystemNavigator.pop', false);
    } catch (e) {
      debugPrint('❌ AppStateManager: Háttérbe küldés hiba: $e');
      // Fallback - régi módszer
      try {
        SystemNavigator.pop();
      } catch (e2) {
        debugPrint('❌ AppStateManager: Fallback háttérbe küldés hiba: $e2');
      }
    }
  }

  /// Teljes reset (fejlesztéshez)
  void reset() {
    _isBackgroundMode = false;
    _backgroundTime = null;
    _shouldShowSplash = true;
    notifyListeners();
    debugPrint('🔄 AppStateManager: Teljes reset végrehajtva');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Debug információk
  Map<String, dynamic> getDebugInfo() {
    return {
      'lifecycleState': _lifecycleState.toString(),
      'isInitialized': _isInitialized,
      'isBackgroundMode': _isBackgroundMode,
      'shouldShowSplash': _shouldShowSplash,
      'backgroundTime': _backgroundTime?.toString() ?? 'null',
      'backgroundDuration':
          _backgroundTime != null
              ? DateTime.now().difference(_backgroundTime!).toString()
              : 'null',
    };
  }
}
