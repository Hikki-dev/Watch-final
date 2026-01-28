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

      debugPrint(
        "Backend Google Login Response: ${response.statusCode} - ${response.body}",
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['data']['access_token'];
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          return token;
        } else {
          throw Exception("Google Login: Token not found in response.");
        }
      } else {
        // Return server error message
        final body = response.body;
        try {
          final json = jsonDecode(body);
          if (json['message'] != null) throw Exception(json['message']);
          if (json['error'] != null) throw Exception(json['error']);
        } catch (_) {}
        throw Exception("Backend Google Login Failed: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Backend Connection Error: $e");
      rethrow;
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

  // Sign in (Refactored to throw errors and sync with backend)
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      if (kIsWeb) {
        await _firebaseAuth.setPersistence(Persistence.SESSION);
      }

      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // --- BACKEND SYNC ---
      // We must authenticate with the Laravel backend to get a Sanctum token
      // for subsequent API requests (like profile uploads)
      await _loginWithEmailBackend(email, password);

      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint("Sign-in Error: ${e.code}");
      rethrow;
    }
  }

  // Sign up (Refactored to throw errors and sync with backend)
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

      // --- BACKEND SYNC ---
      // Register on backend to create User record + get token
      // We'll use the /register endpoint
      await _registerWithBackend(name, email, password);

      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint("Sign-up Error: ${e.code}");
      rethrow;
    }
  }

  // --- Helper: Backend Email Login ---
  Future<void> _loginWithEmailBackend(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      debugPrint(
        "Backend Login Response: ${response.statusCode} - ${response.body}",
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Correct path: data -> data -> access_token
        final token = data['data']['access_token'];
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          debugPrint("Backend Email Login Successful. Token saved.");
        } else {
          debugPrint("Backend Login: Token not found in response.");
        }
      } else {
        debugPrint(
          "Backend Email Login Failed: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      debugPrint("Backend Email Login Error: $e");
    }
  }

  // --- Helper: Backend Registration ---
  Future<void> _registerWithBackend(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password, // Usually required
        }),
      );

      debugPrint(
        "Backend Reg Response: ${response.statusCode} - ${response.body}",
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Correct path: data -> data -> access_token
        final token = data['data']['access_token'];
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          debugPrint("Backend Registration Successful. Token saved.");
        } else {
          debugPrint("Backend Reg: Token not found in response.");
        }
      } else {
        debugPrint(
          "Backend Registration Failed: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      debugPrint("Backend Registration Error: $e");
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
