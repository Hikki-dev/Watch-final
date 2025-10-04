// lib/main.dart
import 'package:flutter/material.dart';
import 'controllers/app_controller.dart';
import 'views/splash_view.dart';
import 'views/login_view.dart';
import 'views/home_view.dart';

void main() {
  runApp(WatchApp());
}

class WatchApp extends StatelessWidget {
  final AppController controller = AppController();

  WatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Watch Store',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      home: AppRouter(controller: controller),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1B5E20),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      cardTheme: const CardThemeData(elevation: 2, margin: EdgeInsets.all(8)),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4CAF50),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      cardTheme: const CardThemeData(elevation: 2, margin: EdgeInsets.all(8)),
    );
  }
}

class AppRouter extends StatefulWidget {
  final AppController controller;

  const AppRouter({super.key, required this.controller});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  bool showSplash = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() async {
    widget.controller.initialize();
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (showSplash) {
      return const SplashView();
    }

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        if (widget.controller.isLoggedIn) {
          return HomeView(controller: widget.controller);
        } else {
          return LoginView(controller: widget.controller);
        }
      },
    );
  }
}
