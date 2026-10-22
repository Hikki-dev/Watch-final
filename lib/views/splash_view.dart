// lib/views/splash_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../theme/lux_theme.dart';
import '../widgets/lux_widgets.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Minimum splash duration so the intro can play.
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final controller = context.read<AppController>();
    final user = controller.currentUser;

    if (user != null) {
      // Wait for the controller to finish loading user data (bounded).
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
    final c = context.lux;
    final fade = CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic);
    return Scaffold(
      backgroundColor: c.bg,
      body: Center(
        child: FadeTransition(
          opacity: fade,
          child: AnimatedBuilder(
            animation: fade,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, (1 - fade.value) * 14),
              child: child,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'LUXWATCH',
                  style: TextStyle(
                    fontFamily: LuxFonts.display,
                    fontSize: 34,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 10,
                    color: c.text,
                  ),
                ),
                const SizedBox(height: 14),
                const Eyebrow('Fine watches, reviewed'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
