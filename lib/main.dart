// lib/main.dart - WITH THEME SUPPORT
import 'package:flutter/material.dart';
import 'views/splash_view.dart';
import 'views/login_view.dart';
import 'views/register_view.dart';
import 'views/home_view.dart';
import 'views/brand_view.dart';
import 'views/watch_detail_view.dart';
import 'controllers/app_controller.dart';

void main() {
  runApp(WatchApp());
}

class WatchApp extends StatefulWidget {
  const WatchApp({super.key});

  @override
  State<WatchApp> createState() => _WatchAppState();
}

class _WatchAppState extends State<WatchApp> {
  final AppController controller = AppController();
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    controller.initialize();
  }

  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Watch Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      
      // VANILLA ROUTING - Named routes
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashView(controller: controller),
        '/login': (context) => LoginView(controller: controller),
        '/register': (context) => RegisterView(controller: controller),
        '/home': (context) => HomeView(
          controller: controller,
          onThemeChanged: _setThemeMode,
          currentThemeMode: _themeMode,
        ),
      },
      
      // For routes that need parameters
      onGenerateRoute: (settings) {
        if (settings.name == '/brand') {
          final brandName = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => BrandView(
              controller: controller,
              brandName: brandName,
            ),
          );
        }
        if (settings.name == '/watch') {
          final watchId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => WatchDetailView(
              controller: controller,
              watchId: watchId,
            ),
          );
        }
        return null;
      },
    );
  }
}