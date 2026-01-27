import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // Used for kIsWeb
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsi;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  FirebaseAuth get _firebaseAuth => FirebaseAuth.instance;
  final String baseUrl =
      dotenv.env['API_BASE_URL'] ??
      'https://laravel-watch-production.up.railway.app/api';

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  User? get currentUser => _firebaseAuth.currentUser;

  // --- Backend Integration ---

  Future<String?> loginToBackend(
    String email,
    String? name,
    String? googleId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'name': name, 'google_id': googleId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['data']['access_token'];
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          return token;
        }
      }
      debugPrint("Backend Login Failed: ${response.body}");
      return null;
    } catch (e) {
      debugPrint("Backend Connection Error: $e");
      return null;
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> logoutBackend() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // --- Firebase Auth Methods ---

  // Sign in (Refactored to throw errors)
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      if (kIsWeb) {
        await _firebaseAuth.setPersistence(Persistence.SESSION);
      }
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // FIX: Rethrow the specific error so the LoginView can catch it
      debugPrint("Sign-in Error: ${e.code}");
      rethrow;
    }
  }

  // Sign up (Refactored to throw errors)
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      if (kIsWeb) {
        await _firebaseAuth.setPersistence(Persistence.SESSION);
      }

      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint("Sign-up Error: ${e.code}");
      rethrow;
    }
  }

  // Google Sign-In
  Future<UserCredential> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        await _firebaseAuth.setPersistence(Persistence.SESSION);
        // For web, we can use signInWithPopup or redirect
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        return await _firebaseAuth.signInWithPopup(googleProvider);
      } else {
        // Native (Android/iOS)
        final gsi.GoogleSignIn googleSignIn = gsi.GoogleSignIn();
        final gsi.GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          // User canceled the sign-in
          throw FirebaseAuthException(
            code: 'ERROR_ABORTED_BY_USER',
            message: 'Sign in aborted by user',
          );
        }

        final gsi.GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await _firebaseAuth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("Google Sign-In Error: ${e.code}");
      rethrow;
    } catch (e) {
      debugPrint("Google Sign-In General Error: $e");
      throw FirebaseAuthException(
        code: 'ERROR_GENERAL_LOGIN_FAILED',
        message: 'Google Sign-In failed: $e',
      );
    }
  }

  Future<void> signOut() async {
    // Also sign out of Google to ensure account selection is shown next time
    try {
      if (!kIsWeb) {
        await gsi.GoogleSignIn().signOut();
      }
    } catch (e) {
      // Ignore errors here if not signed in with Google
    }
    await logoutBackend(); // Clear backend token
    await _firebaseAuth.signOut();
  }
}
