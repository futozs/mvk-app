import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Kedvenc megállók kezelését végző szolgáltatás
class FavoritesService extends ChangeNotifier {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  SharedPreferences? _prefs;
  static const String _favoritesKey = 'favorite_stops';
  static const String _userProfileKey =
      'user_profile'; // Jővőbeli profil adatok

  List<FavoriteStop> _favorites = [];
  bool _isInitialized = false;

  /// Service inicializálása
  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    await _loadFavorites();
    _isInitialized = true;

    debugPrint(
      '✅ FavoritesService inicializálva - ${_favorites.length} kedvenc',
    );
  }

  /// Kedvencek betöltése SharedPreferences-ből
  Future<void> _loadFavorites() async {
    try {
      final String? favoritesJson = _prefs?.getString(_favoritesKey);
      if (favoritesJson != null) {
        final List<dynamic> favoritesList = json.decode(favoritesJson);
        _favorites =
            favoritesList.map((item) => FavoriteStop.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('❌ Hiba a kedvencek betöltésekor: $e');
      _favorites = [];
    }
  }

  /// Kedvencek mentése SharedPreferences-be
  Future<void> _saveFavorites() async {
    try {
      final String favoritesJson = json.encode(
        _favorites.map((favorite) => favorite.toJson()).toList(),
      );
      await _prefs?.setString(_favoritesKey, favoritesJson);
      debugPrint('💾 Kedvencek mentve - ${_favorites.length} elem');
    } catch (e) {
      debugPrint('❌ Hiba a kedvencek mentésekor: $e');
    }
  }

  /// Összes kedvenc megálló lekérése
  List<FavoriteStop> get favorites => List.unmodifiable(_favorites);

  /// Kedvenc hozzáadása
  Future<bool> addFavorite({
    required String stopCode,
    required String stopName,
    String? nickname,
  }) async {
    // Ellenőrizzük, hogy már kedvenc-e
    if (isFavorite(stopCode)) {
      debugPrint('⚠️ A megálló már kedvenc: $stopCode');
      return false;
    }

    final favorite = FavoriteStop(
      stopCode: stopCode,
      stopName: stopName,
      nickname: nickname,
      addedAt: DateTime.now(),
    );
    _favorites.add(favorite);
    await _saveFavorites();
    notifyListeners(); // Értesítjük a UI-t a változásról

    // Automatikus felhő szinkronizáció ha be van kapcsolva
    if (isCloudSyncEnabled && FirebaseAuth.instance.currentUser != null) {
      await syncToCloud();
    }

    debugPrint('⭐ Kedvenc hozzáadva: ${favorite.displayName} ($stopCode)');
    return true;
  }

  /// Kedvenc eltávolítása
  Future<bool> removeFavorite(String stopCode) async {
    final initialLength = _favorites.length;
    _favorites.removeWhere((favorite) => favorite.stopCode == stopCode);

    if (_favorites.length < initialLength) {
      await _saveFavorites();
      notifyListeners(); // Értesítjük a UI-t a változásról

      // Automatikus felhő szinkronizáció ha be van kapcsolva
      if (isCloudSyncEnabled && FirebaseAuth.instance.currentUser != null) {
        await syncToCloud();
      }

      debugPrint('🗑️ Kedvenc eltávolítva: $stopCode');
      return true;
    }

    return false;
  }

  /// Kedvenc beceneveének frissítése
  Future<bool> updateNickname(String stopCode, String? nickname) async {
    final favoriteIndex = _favorites.indexWhere(
      (favorite) => favorite.stopCode == stopCode,
    );

    if (favoriteIndex != -1) {
      _favorites[favoriteIndex] = _favorites[favoriteIndex].copyWith(
        nickname: nickname,
      );
      await _saveFavorites();
      notifyListeners(); // Értesítjük a UI-t a változásról
      debugPrint('✏️ Becenév frissítve: $stopCode -> $nickname');
      return true;
    }

    return false;
  }

  /// Ellenőrzi, hogy a megálló kedvenc-e
  bool isFavorite(String stopCode) {
    return _favorites.any((favorite) => favorite.stopCode == stopCode);
  }

  /// Kedvenc megálló lekérése stopCode alapján
  FavoriteStop? getFavorite(String stopCode) {
    try {
      return _favorites.firstWhere((favorite) => favorite.stopCode == stopCode);
    } catch (e) {
      return null;
    }
  }

  /// Kedvencek szűrése név/becenév alapján
  List<FavoriteStop> searchFavorites(String query) {
    if (query.isEmpty) return favorites;

    final lowercaseQuery = query.toLowerCase();
    return _favorites.where((favorite) {
      return favorite.stopName.toLowerCase().contains(lowercaseQuery) ||
          (favorite.nickname?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  /// Kedvencek rendezése hozzáadás dátuma szerint
  List<FavoriteStop> get favoritesSortedByDate {
    final sorted = List<FavoriteStop>.from(_favorites);
    sorted.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return sorted;
  }

  /// Kedvencek rendezése név szerint
  List<FavoriteStop> get favoritesSortedByName {
    final sorted = List<FavoriteStop>.from(_favorites);
    sorted.sort((a, b) => a.displayName.compareTo(b.displayName));
    return sorted;
  }

  /// Jövőbeli profil adatok kezelésére előkészített függvények

  /// Felhasználói profil adatok mentése (jövőbeli feature)
  Future<void> saveUserProfile(Map<String, dynamic> profileData) async {
    await _prefs?.setString(_userProfileKey, json.encode(profileData));
    debugPrint('👤 Profil adatok mentve');
  }

  /// Felhasználói profil adatok betöltése (jövőbeli feature)
  Map<String, dynamic>? getUserProfile() {
    final String? profileJson = _prefs?.getString(_userProfileKey);
    if (profileJson != null) {
      try {
        return json.decode(profileJson);
      } catch (e) {
        debugPrint('❌ Hiba a profil betöltésekor: $e');
      }
    }
    return null;
  }

  /// Kedvencek szinkronizálása a felhőbe (Google bejelentkezés után)
  Future<bool> syncToCloud() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('⚠️ Nincs bejelentkezett felhasználó a szinkronizációhoz');
        return false;
      }

      final userId = user.uid;
      final firestore = FirebaseFirestore.instance;

      // Helyi kedvencek feltöltése a felhőbe
      final favoritesData =
          _favorites.map((favorite) => favorite.toJson()).toList();

      await firestore.collection('users').doc(userId).set({
        'favorites': favoritesData,
        'lastSyncTime': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint(
        '☁️ Kedvencek szinkronizálva a felhőbe: ${_favorites.length} elem',
      );
      return true;
    } catch (e) {
      debugPrint('❌ Hiba a felhő szinkronizáció során: $e');
      return false;
    }
  }

  /// Kedvencek visszaállítása a felhőből
  Future<bool> syncFromCloud() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('⚠️ Nincs bejelentkezett felhasználó a szinkronizációhoz');
        return false;
      }

      final userId = user.uid;
      final firestore = FirebaseFirestore.instance;

      final doc = await firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['favorites'] != null) {
          final cloudFavorites = List<dynamic>.from(data['favorites']);
          final restoredFavorites =
              cloudFavorites
                  .map((item) => FavoriteStop.fromJson(item))
                  .toList();

          // Egyesítés: helyi + felhő kedvencek (duplikációk elkerülése)
          final allFavorites = <String, FavoriteStop>{};

          // Helyi kedvencek hozzáadása
          for (final favorite in _favorites) {
            allFavorites[favorite.stopCode] = favorite;
          }

          // Felhő kedvencek hozzáadása (felülírják a helyieket ha újabbak)
          for (final favorite in restoredFavorites) {
            if (!allFavorites.containsKey(favorite.stopCode) ||
                favorite.addedAt.isAfter(
                  allFavorites[favorite.stopCode]!.addedAt,
                )) {
              allFavorites[favorite.stopCode] = favorite;
            }
          }

          _favorites = allFavorites.values.toList();
          await _saveFavorites();
          notifyListeners();

          debugPrint(
            '☁️ Kedvencek visszaállítva a felhőből: ${_favorites.length} elem',
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('❌ Hiba a felhőből történő szinkronizáció során: $e');
      return false;
    }
  }

  /// Automatikus szinkronizáció bekapcsolása
  Future<void> enableCloudSync() async {
    await _prefs?.setBool('cloud_sync_enabled', true);
    debugPrint('☁️ Automatikus felhő szinkronizáció bekapcsolva');
  }

  /// Automatikus szinkronizáció kikapcsolása
  Future<void> disableCloudSync() async {
    await _prefs?.setBool('cloud_sync_enabled', false);
    debugPrint('☁️ Automatikus felhő szinkronizáció kikapcsolva');
  }

  /// Ellenőrzi, hogy be van-e kapcsolva a felhő szinkronizáció
  bool get isCloudSyncEnabled => _prefs?.getBool('cloud_sync_enabled') ?? false;
}

/// Kedvenc megálló modell
class FavoriteStop {
  final String stopCode;
  final String stopName;
  final String? nickname;
  final DateTime addedAt;

  const FavoriteStop({
    required this.stopCode,
    required this.stopName,
    this.nickname,
    required this.addedAt,
  });

  /// Megjelenítendő név (becenév vagy eredeti név)
  String get displayName => nickname?.isNotEmpty == true ? nickname! : stopName;

  /// JSON-ból objektum létrehozása
  factory FavoriteStop.fromJson(Map<String, dynamic> json) {
    return FavoriteStop(
      stopCode: json['stopCode'] as String,
      stopName: json['stopName'] as String,
      nickname: json['nickname'] as String?,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }

  /// Objektum JSON-á alakítása
  Map<String, dynamic> toJson() {
    return {
      'stopCode': stopCode,
      'stopName': stopName,
      'nickname': nickname,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  /// Objektum másolása módosításokkal
  FavoriteStop copyWith({
    String? stopCode,
    String? stopName,
    String? nickname,
    DateTime? addedAt,
  }) {
    return FavoriteStop(
      stopCode: stopCode ?? this.stopCode,
      stopName: stopName ?? this.stopName,
      nickname: nickname ?? this.nickname,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FavoriteStop &&
        other.stopCode == stopCode &&
        other.stopName == stopName &&
        other.nickname == nickname &&
        other.addedAt == addedAt;
  }

  @override
  int get hashCode {
    return stopCode.hashCode ^
        stopName.hashCode ^
        nickname.hashCode ^
        addedAt.hashCode;
  }

  @override
  String toString() {
    return 'FavoriteStop(stopCode: $stopCode, stopName: $stopName, nickname: $nickname, addedAt: $addedAt)';
  }
}
