// lib/main_demo.dart
//
// A Firebase-free entry point for local demos and screenshots.
//
// It signs in to a local Laravel-Watch API with one of its seeded accounts and
// swaps Firebase Auth for a stand-in user, so every screen runs against real
// data without a Firebase project. It is not used by the real app (lib/main.dart).
//
//   flutter run -d chrome -t lib/main_demo.dart \
//     --dart-define=DEMO_ROLE=customer   # or seller, admin
//
// On the web the role can also be chosen in the address: /?role=admin
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/app_controller.dart';
import 'main.dart' show WatchApp;
import 'services/auth_service.dart';

const _role = String.fromEnvironment('DEMO_ROLE', defaultValue: 'customer');

const _accounts = {
  'customer': ('customer@example.com', 'Jane Customer'),
  'seller': ('seller@example.com', 'John Seller'),
  'admin': ('admin@example.com', 'Admin User'),
};

/// Just enough of a Firebase user for the app to treat the visitor as signed in.
class _DemoUser implements fb.User {
  _DemoUser(this.email, this.displayName);

  @override
  final String email;
  @override
  final String displayName;
  @override
  String get uid => 'demo-$email';
  @override
  String? get photoURL => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _DemoAuthService extends AuthService {
  _DemoAuthService(this._user);
  final _DemoUser _user;

  @override
  Stream<fb.User?> get authStateChanges => Stream.value(_user);
  @override
  fb.User? get currentUser => _user;
  @override
  Future<void> logoutBackend() async {}
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Hive.initFlutter();

  final role = Uri.base.queryParameters['role'] ?? _role;
  final (email, name) = _accounts[role] ?? _accounts['customer']!;
  final auth = _DemoAuthService(_DemoUser(email, name));

  final response = await http.post(
    Uri.parse('${auth.baseUrl}/login'),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    body: jsonEncode({'email': email, 'password': 'password'}),
  );
  final token = jsonDecode(response.body)['data']['access_token'] as String;
  await (await SharedPreferences.getInstance()).setString('auth_token', token);

  // Load everything before the first frame, so the splash screen goes straight
  // to the signed-in home screen instead of racing the API.
  final controller = AppController(authService: auth);
  await controller.initialize();
  for (var i = 0; i < 50 && controller.currentUser == null; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>.value(value: auth),
        ChangeNotifierProvider<AppController>.value(value: controller),
      ],
      child: const WatchApp(),
    ),
  );
}
