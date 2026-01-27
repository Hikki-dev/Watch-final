// test/widget_test.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:watch_store/main.dart';
import 'package:watch_store/models/watch.dart';
import 'package:watch_store/controllers/app_controller.dart';
import 'package:watch_store/services/auth_service.dart';
import 'package:watch_store/services/data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import 'package:flutter_dotenv/flutter_dotenv.dart';

// Simple Mocks for Smoke Test
class MockAuthServiceSimple extends AuthService {
  final _controller = StreamController<fb.User?>.broadcast();
  @override
  Stream<fb.User?> get authStateChanges => _controller.stream;
  @override
  fb.User? get currentUser => null;
}

class MockDataServiceSimple extends DataService {
  @override
  Future<List<Map<String, dynamic>>> getAllUsers() async => [];

  @override
  Future<List<Watch>> getWatchesFromLocalDb() async => [];

  @override
  Future<List<Watch>> fetchWatchesFromApi() async => [];
}

void main() {
  testWidgets('Watch app smoke test', (WidgetTester tester) async {
    // 0. Load Env
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://example.com');

    // 1. Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // 2. Setup Mocks
    final mockAuth = MockAuthServiceSimple();
    final mockData = MockDataServiceSimple();

    // 3. Build app with Providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthService>.value(value: mockAuth),
          ChangeNotifierProvider<AppController>(
            create: (context) =>
                AppController(authService: mockAuth, dataService: mockData)
                  ..initialize(),
          ),
        ],
        child: const WatchApp(),
      ),
    );

    // 4. Verify Splash
    expect(find.text('Watch Store'), findsOneWidget);

    // 5. Advance
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // 6. Verify Navigation to Login
    expect(find.text('Login'), findsWidgets);
  });
}
