// lib/views/splash_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../services/auth_service.dart';

class SplashView extends StatefulWidget {
  // 2. REMOVE controller from constructor
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // 1. Wait for min splash duration (UI experience)
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // 2. Get Access to Providers
    final authService = context.read<AuthService>();
    final controller = context.read<AppController>();

    // 3. Check if user is logged in
    final user = authService.currentUser;

    if (user != null) {
      // 4. Wait for Controller to fully load user data (Strict Sync)
      // We loop until isUserDataLoaded is true or timeout
      int attempts = 0;
      while (!controller.isUserDataLoaded && attempts < 20) {
        await Future.delayed(const Duration(milliseconds: 200));
        attempts++;
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, controller.homeRoute);
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.watch, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text(
              'Watch Store',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Premium Timepieces',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
