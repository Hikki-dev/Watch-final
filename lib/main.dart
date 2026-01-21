// lib/main.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'controllers/app_controller.dart';
import 'services/auth_service.dart';
import 'views/splash_view.dart';
import 'views/login_view.dart';
import 'views/register_view.dart';
import 'views/home_view.dart';
import 'views/brand_view.dart';
import 'views/watch_detail_view.dart';
import 'views/admin/admin_dashboard_view.dart';
import 'views/seller/seller_dashboard_view.dart';

import 'firebase_options.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      try {
        await dotenv.load(fileName: ".env");
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        await Hive.initFlutter();
        // Optimize Image Caching
        CachedNetworkImage.logLevel = CacheManagerLogLevel.debug;
        // Custom cache manager can be configured here if needed,
        // but default is usually sufficient for standard apps.

        runApp(
          MultiProvider(
            providers: [
              Provider<AuthService>(create: (_) => AuthService()),
              ChangeNotifierProvider<AppController>(
                create: (context) =>
                    AppController(authService: context.read<AuthService>())
                      ..initialize(),
              ),
            ],
            child: const WatchApp(),
          ),
        );
      } catch (e, stack) {
        debugPrint('Error initializing app: $e\n$stack');
        // Render a simple error widget if initialization fails
        runApp(
          MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Initialization Error: $e')),
            ),
          ),
        );
      }
    },
    (error, stack) {
      debugPrint('Uncaught error: $error\n$stack');
    },
  );
}

class WatchApp extends StatefulWidget {
  const WatchApp({super.key});
  @override
  State<WatchApp> createState() => _WatchAppState();
}

class _WatchAppState extends State<WatchApp> {
  ThemeMode _themeMode = ThemeMode.system;

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

      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashView(),
        '/login': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),
        '/home': (context) => HomeView(
          onThemeChanged: _setThemeMode,
          currentThemeMode: _themeMode,
        ),
        '/admin': (context) => const AdminDashboardView(),
        '/seller': (context) => const SellerDashboardView(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/brand') {
          final brandName = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => BrandView(brandName: brandName),
          );
        }
        if (settings.name == '/watch') {
          final watchId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => WatchDetailView(watchId: watchId),
          );
        }
        return null;
      },
    );
  }
}
