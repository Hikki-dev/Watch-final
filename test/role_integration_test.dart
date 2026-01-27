// test/role_integration_test.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch_store/main.dart'; // To use WatchApp
import 'package:watch_store/controllers/app_controller.dart';
import 'package:watch_store/services/auth_service.dart';
import 'package:watch_store/services/data_service.dart';
import 'package:watch_store/models/watch.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:watch_store/models/user.dart' as import_user_model_alias;
import 'package:watch_store/views/admin/admin_dashboard_view.dart'
    as import_admin_view;
import 'package:watch_store/views/seller/seller_dashboard_view.dart'
    as import_seller_view;

// Mock DataService
class MockRoleDataService extends DataService {
  final String role;
  MockRoleDataService({required this.role});

  @override
  Future<List<Watch>> fetchWatchesFromApi() async => [];
  @override
  Future<List<Watch>> getWatchesFromLocalDb() async => [];

  @override
  Stream<List<Watch>> streamWatches() => Stream.value([]); // Return empty list immediately

  @override
  Future<void> saveWatchesToLocalDb(List<Watch> watches) async {} // Do nothing

  @override
  Future<Map<String, dynamic>> getUserData() async {
    return {
      'name': 'Test User',
      'email': 'test@example.com',
      'cartItems': [],
      'favorites': [],
      'role': role, // Dynamic role
    };
  }
}

// Mock AuthService
class MockAuthService extends AuthService {
  final _streamController = StreamController<fb.User?>.broadcast();

  @override
  Stream<fb.User?> get authStateChanges => _streamController.stream;

  @override
  fb.User? get currentUser => null;
}

class TestAppController extends AppController {
  TestAppController({required super.authService, super.dataService});

  void setMockUser(String role) {
    // Manually set the currentUser model to bypass Firebase dependencies
    currentUser = import_user_model_alias.User(
      id: 'mock_id',
      name: 'Mock User',
      email: 'mock@test.com',
      role: role,
      favorites: {},
    );
    isUserDataLoaded = true; // Ensure SplashView loop completes
    notifyListeners();
  }
}

void main() {
  setUp(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://example.com');
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Role Routing: Admin goes to Admin Dashboard', (
    WidgetTester tester,
  ) async {
    final mockAuth = MockAuthService();
    // We use a specific DataService though controller bypasses it for this specific test approach
    final mockData = MockRoleDataService(role: 'admin');

    final controller = TestAppController(
      authService: mockAuth,
      dataService: mockData,
    );
    controller.setMockUser('admin'); // Force Admin Role

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthService>.value(value: mockAuth),
          ChangeNotifierProvider<AppController>.value(value: controller),
        ],
        child: const WatchApp(), // Uses /home, /admin routes
      ),
    );

    // Allow Splash Screen Timer (2 seconds) to complete
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(); // Process navigation

    expect(controller.homeRoute, '/admin');

    // And verify AdminDashboardView renders if we pump it
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthService>.value(value: mockAuth),
          ChangeNotifierProvider<AppController>.value(value: controller),
        ],
        child: const MaterialApp(home: import_admin_view.AdminDashboardView()),
      ),
    );
    expect(find.text('Admin Dashboard'), findsOneWidget);
  });

  testWidgets('Role Routing: Seller goes to Seller Dashboard', (
    WidgetTester tester,
  ) async {
    final mockAuth = MockAuthService();
    final mockData = MockRoleDataService(role: 'seller');

    final controller = TestAppController(
      authService: mockAuth,
      dataService: mockData,
    );
    controller.setMockUser('seller');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthService>.value(value: mockAuth),
          ChangeNotifierProvider<AppController>.value(value: controller),
        ],
        child: const WatchApp(), // Uses /home, /seller routes
      ),
    );

    // Allow Splash Screen Timer
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(controller.homeRoute, '/seller');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthService>.value(value: mockAuth),
          ChangeNotifierProvider<AppController>.value(value: controller),
        ],
        child: const MaterialApp(
          home: import_seller_view.SellerDashboardView(),
        ),
      ),
    );
    expect(find.text('Seller Dashboard'), findsOneWidget);
  });
}
