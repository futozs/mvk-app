import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class SyncService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isSyncEnabled = false;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  bool get isSyncEnabled => _isSyncEnabled;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;

  SyncService() {
    _loadSyncSettings();
  }

  Future<void> _loadSyncSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isSyncEnabled = prefs.getBool('sync_enabled') ?? false;
    final lastSyncTimestamp = prefs.getInt('last_sync_time');
    if (lastSyncTimestamp != null) {
      _lastSyncTime = DateTime.fromMillisecondsSinceEpoch(lastSyncTimestamp);
    }
    notifyListeners();
  }

  Future<void> setSyncEnabled(bool enabled) async {
    _isSyncEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sync_enabled', enabled);
    notifyListeners();

    if (enabled && _auth.currentUser != null) {
      await syncToCloud();
    }
  }

  Future<bool> syncToCloud() async {
    if (!_isSyncEnabled || _auth.currentUser == null) return false;

    try {
      _isSyncing = true;
      notifyListeners();

      final userId = _auth.currentUser!.uid;
      final prefs = await SharedPreferences.getInstance();

      // Kedvencek szinkronizálása
      await _syncFavorites(userId, prefs);

      // Egyéb beállítások szinkronizálása
      await _syncSettings(userId, prefs);

      _lastSyncTime = DateTime.now();
      await prefs.setInt(
        'last_sync_time',
        _lastSyncTime!.millisecondsSinceEpoch,
      );

      _isSyncing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSyncing = false;
      notifyListeners();
      debugPrint('Hiba a szinkronizáció során: $e');
      return false;
    }
  }

  Future<void> _syncFavorites(String userId, SharedPreferences prefs) async {
    // Helyi kedvencek feltöltése
    final localFavorites = prefs.getStringList('favorite_stops') ?? [];
    final localFavoriteRoutes = prefs.getStringList('favorite_routes') ?? [];

    await _firestore.collection('users').doc(userId).set({
      'favorites': {
        'stops': localFavorites,
        'routes': localFavoriteRoutes,
        'lastUpdated': FieldValue.serverTimestamp(),
      },
    }, SetOptions(merge: true));

    // Felhőből letöltés és összehasonlítás
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists && doc.data()?['favorites'] != null) {
      final cloudFavorites = doc.data()!['favorites'] as Map<String, dynamic>;
      final cloudStops = List<String>.from(cloudFavorites['stops'] ?? []);
      final cloudRoutes = List<String>.from(cloudFavorites['routes'] ?? []);

      // Egyesítés (helyi + felhő)
      final mergedStops = {...localFavorites, ...cloudStops}.toList();
      final mergedRoutes = {...localFavoriteRoutes, ...cloudRoutes}.toList();

      // Helyi tárolás frissítése
      await prefs.setStringList('favorite_stops', mergedStops);
      await prefs.setStringList('favorite_routes', mergedRoutes);

      // Felhő frissítése az egyesített adatokkal
      await _firestore.collection('users').doc(userId).update({
        'favorites.stops': mergedStops,
        'favorites.routes': mergedRoutes,
        'favorites.lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _syncSettings(String userId, SharedPreferences prefs) async {
    // App beállítások szinkronizálása
    final settings = {
      'theme_mode': prefs.getString('theme_mode'),
      'notifications_enabled': prefs.getBool('notifications_enabled'),
      'location_permission': prefs.getBool('location_permission'),
      'lastUpdated': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('users').doc(userId).set({
      'settings': settings,
    }, SetOptions(merge: true));
  }

  Future<bool> syncFromCloud() async {
    if (!_isSyncEnabled || _auth.currentUser == null) return false;

    try {
      _isSyncing = true;
      notifyListeners();

      final userId = _auth.currentUser!.uid;
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        final data = doc.data()!;
        final prefs = await SharedPreferences.getInstance();

        // Kedvencek visszaállítása
        if (data['favorites'] != null) {
          final favorites = data['favorites'] as Map<String, dynamic>;
          final stops = List<String>.from(favorites['stops'] ?? []);
          final routes = List<String>.from(favorites['routes'] ?? []);

          await prefs.setStringList('favorite_stops', stops);
          await prefs.setStringList('favorite_routes', routes);
        }

        // Beállítások visszaállítása
        if (data['settings'] != null) {
          final settings = data['settings'] as Map<String, dynamic>;

          if (settings['theme_mode'] != null) {
            await prefs.setString('theme_mode', settings['theme_mode']);
          }
          if (settings['notifications_enabled'] != null) {
            await prefs.setBool(
              'notifications_enabled',
              settings['notifications_enabled'],
            );
          }
          if (settings['location_permission'] != null) {
            await prefs.setBool(
              'location_permission',
              settings['location_permission'],
            );
          }
        }

        _lastSyncTime = DateTime.now();
        await prefs.setInt(
          'last_sync_time',
          _lastSyncTime!.millisecondsSinceEpoch,
        );
      }

      _isSyncing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSyncing = false;
      notifyListeners();
      debugPrint('Hiba a felhőből történő szinkronizáció során: $e');
      return false;
    }
  }

  String get syncStatusText {
    if (_isSyncing) return 'Szinkronizáció...';
    if (_lastSyncTime == null) return 'Nincs szinkronizáció';

    final now = DateTime.now();
    final difference = now.difference(_lastSyncTime!);

    if (difference.inMinutes < 1) return 'Most szinkronizálva';
    if (difference.inHours < 1)
      return '${difference.inMinutes} perce szinkronizálva';
    if (difference.inDays < 1)
      return '${difference.inHours} órája szinkronizálva';
    return '${difference.inDays} napja szinkronizálva';
  }
}
