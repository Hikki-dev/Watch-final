import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart'; // <-- 1. REMOVE THIS
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'controllers/app_controller.dart';
import 'services/auth_service.dart';
import 'views/splash_view.dart';
import 'views/login_view.dart';
import 'views/register_view.dart';
import 'views/home_view.dart';
import 'views/brand_view.dart';
import 'views/watch_detail_view.dart';

import 'firebase_options.dart'; // <-- 2. ADD THIS IMPORT

// Use async main to initialize services
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load .env file
  // await dotenv.load(fileName: ".env"); // <-- 3. REMOVE THIS

  // 2. Initialize Firebase
  await Firebase.initializeApp(
    // 4. ADD THE OPTIONS FROM YOUR FIREBASE_OPTIONS.DART FILE
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Initialize Hive (Local DB)
  await Hive.initFlutter();

  // Run the app with Providers
  runApp(
    MultiProvider(
      providers: [
        // Provide the AuthService
        Provider<AuthService>(create: (_) => AuthService()),

        // Provide the AppController
        ChangeNotifierProvider<AppController>(
          create: (context) => AppController(
            // Give the controller access to the AuthService
            authService: context.read<AuthService>(),
          )..initialize(), // ..initialize() calls the method right away
        ),
      ],
      child: WatchApp(),
    ),
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

      // These routes are correct. The views will get the
      // controller from Provider when they need it.
      initialRoute: '/splash',
      routes: {
        '/splash': (context) =>
            SplashView(controller: context.read<AppController>()),
        '/login': (context) =>
            LoginView(controller: context.read<AppController>()),
        '/register': (context) =>
            RegisterView(controller: context.read<AppController>()),
        '/home': (context) => HomeView(
          onThemeChanged: _setThemeMode,
          currentThemeMode: _themeMode,
        ),
      },

      // This is also correct.
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
