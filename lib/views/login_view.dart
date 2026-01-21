import 'package:firebase_auth/firebase_auth.dart'; // Import this for Exception handling
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../services/auth_service.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loginWithGoogle() async {
    final authService = context.read<AuthService>();
    final controller = context.read<AppController>();

    try {
      // 1. Firebase/Google Sign-In
      final userCredential = await authService.signInWithGoogle();

      if (!mounted) return;

      // 2. Backend Login (Laravel API)
      final user = userCredential.user;
      if (user != null && user.email != null) {
        // Try to get Google ID from provider data
        String? googleId;
        for (var profile in user.providerData) {
          if (profile.providerId == 'google.com') {
            googleId = profile.uid;
            break;
          }
        }

        final token = await authService.loginToBackend(
          user.email!,
          user.displayName,
          googleId,
        );

        if (token == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to connect to server. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // 3. Force Data Refresh from Backend
        controller.refreshUserData();
      }

      controller.setUserFullName(userCredential.user?.displayName ?? 'User');

      // Wait for Data to sync
      int attempts = 0;
      while (!controller.isUserDataLoaded && attempts < 20) {
        await Future.delayed(const Duration(milliseconds: 200));
        attempts++;
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, controller.homeRoute);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'ERROR_ABORTED_BY_USER') return; // Ignore user cancellation

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In Failed: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _login() async {
    final authService = context.read<AuthService>();
    final controller = context.read<AppController>();

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    try {
      // 1. Attempt Login
      final userCredential = await authService.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      // 2. Success Logic
      controller.setUserFullName(
        userCredential.user?.displayName ??
            _emailController.text.split('@')[0].toUpperCase(),
      );

      // Wait for Firestore to sync role
      int attempts = 0;
      while (!controller.isUserDataLoaded && attempts < 20) {
        await Future.delayed(const Duration(milliseconds: 200));
        attempts++;
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, controller.homeRoute);
    } on FirebaseAuthException catch (e) {
      // 3. Error Handling
      if (!mounted) return;

      String message = 'Login failed';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is invalid.';
      } else if (e.code == 'user-disabled') {
        message = 'This user has been disabled.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      // General errors
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (Keep your existing UI code exactly as it is) ...
    // Just copy the `build` method from your previous file here.
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.watch,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _hidePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _hidePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => _hidePassword = !_hidePassword),
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _login,
                  child: const Text('Login'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(
                    Icons.g_mobiledata,
                    size: 28,
                  ), // Use a built-in icon or custom asset
                  label: const Text('Sign in with Google'),
                  onPressed: _loginWithGoogle,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
