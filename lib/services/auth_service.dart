import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      debugPrint('🔄 Google Sign-In kezdeményezése...');
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        debugPrint('❌ Google Sign-In megszakítva a felhasználó által');
        return false;
      }

      debugPrint('✅ Google felhasználó sikeresen kiválasztva: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      debugPrint('🔑 Token megszerzése...');
      debugPrint('Access token: ${googleAuth.accessToken != null ? "✅" : "❌"}');
      debugPrint('ID token: ${googleAuth.idToken != null ? "✅" : "❌"}');

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint('🔐 Firebase credential létrehozva, bejelentkezés...');

      // Once signed in, return the UserCredential
      final userCredential = await _auth.signInWithCredential(credential);
      
      debugPrint('🎉 Sikeres Firebase bejelentkezés: ${userCredential.user?.email}');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ Hiba a Google bejelentkezés során: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint('Hiba a kijelentkezés során: $e');
    }
  }

  String? get userDisplayName => _user?.displayName;
  String? get userEmail => _user?.email;
  String? get userPhotoURL => _user?.photoURL;
}
