import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Stream to listen for auth changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Get current user (if any)
  User? get currentUser => _firebaseAuth.currentUser;

  // Sign in with Email
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint("Sign-in Error: ${e.message}");
      return null;
    }
  }

  // Register with Email
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String name, // <-- 1. ADD THE 'name' PARAMETER
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. UPDATE THE USER'S PROFILE WITH THE NAME
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint("Sign-up Error: ${e.message}");
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
