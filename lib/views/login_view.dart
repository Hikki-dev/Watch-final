import 'package:firebase_auth/firebase_auth.dart'; // Import this for Exception handling
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../services/auth_service.dart';
import '../theme/lux_theme.dart';
import '../widgets/lux_widgets.dart';

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
        final idToken = await user.getIdToken();
        final token = idToken == null
            ? null
            : await authService.loginToBackend(idToken, user.displayName);

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

      // Safari on iPhone often blocks the Google window on this site.
      final blocked =
          e.code == 'popup-blocked' ||
          e.code == 'web-context-canceled' ||
          (e.message ?? '').toLowerCase().contains('popup');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            blocked
                ? 'This browser blocked the Google sign-in window. Use your '
                      'email and password, or open this page in Chrome.'
                : 'Google Sign-In Failed: ${e.message}',
          ),
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
    final c = context.lux;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Reveal(
                    child: Column(
                      children: [
                        Text(
                          'LUXWATCH',
                          style: TextStyle(
                            fontFamily: LuxFonts.display,
                            fontSize: 26,
                            letterSpacing: 8,
                            color: c.text,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          'Welcome Back',
                          style: text.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Sign in to continue.',
                          style: text.bodyMedium?.copyWith(color: c.mute),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  Reveal(
                    index: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.mail_outline),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _passwordController,
                          obscureText: _hidePassword,
                          autofillHints: const [AutofillHints.password],
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              tooltip: _hidePassword
                                  ? 'Show password'
                                  : 'Hide password',
                              icon: Icon(
                                _hidePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () => setState(
                                () => _hidePassword = !_hidePassword,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: _login,
                          child: const Text('Login'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          icon: Image.asset(
                            'assets/images/google_g.png',
                            width: 20,
                            height: 20,
                            filterQuality: FilterQuality.high,
                          ),
                          label: const Text('Sign in with Google'),
                          onPressed: _loginWithGoogle,
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/register'),
                          child: const Text('Create Account'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
