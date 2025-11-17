// lib/controllers/app_controller.dart
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../models/watch.dart';
import '../models/user.dart';
import '../models/cart.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';

class AppController extends ChangeNotifier {
  final AuthService authService;

  // Services
  final DataService _dataService = DataService();
  final Connectivity _connectivity = Connectivity();
  final ImagePicker _imagePicker = ImagePicker();
  final Battery _battery = Battery();

  // State
  User? currentUser; // This is your app's User model
  final Cart cart = Cart();
  List<Watch> allWatches = [];
  bool isLoading = true;
  String? _userFullName; // For storing the name from registration

  // Constructor
  AppController({required this.authService}) {
    // Listen to auth changes
    authService.authStateChanges.listen(_onAuthStateChanged);
    // Set the initial user if already logged in
    _onAuthStateChanged(authService.currentUser);
  }

  // Initialize data
  Future<void> initialize() async {
    isLoading = true;
    notifyListeners();

    // 1. Load from cache first (for offline support)
    allWatches = await _dataService.getWatchesFromLocalDb();
    if (allWatches.isNotEmpty) {
      isLoading = false;
      notifyListeners();
    }

    // 2. Check for network connectivity (Criteria 5)
    final List<ConnectivityResult> connectivityResult = await _connectivity
        .checkConnectivity();
    final bool isOnline =
        connectivityResult.isNotEmpty &&
        !connectivityResult.contains(ConnectivityResult.none);

    if (isOnline) {
      // 3. If online, fetch from API (Criteria 3)
      final apiWatches = await _dataService.fetchWatchesFromApi();
      if (apiWatches.isNotEmpty) {
        allWatches = apiWatches;
        // 4. Save fresh data to local DB (Criteria 3)
        await _dataService.saveWatchesToLocalDb(allWatches);
      }
    }

    isLoading = false;
    notifyListeners();
  }

  // Update user state when auth changes
  void _onAuthStateChanged(fb.User? firebaseUser) {
    if (firebaseUser == null) {
      currentUser = null;
      _userFullName = null;
      cart.clear();
    } else {
      // Create your app User from the firebase User
      currentUser = User(
        id: firebaseUser.uid,
        name:
            _userFullName ??
            firebaseUser.displayName ??
            firebaseUser.email!.split('@')[0].toUpperCase(),
        email: firebaseUser.email!,
      );
    }
    notifyListeners();
  }

  // Called from register view to set the name
  void setUserFullName(String name) {
    _userFullName = name;
    if (currentUser != null) {
      currentUser = User(
        id: currentUser!.id,
        name: name,
        email: currentUser!.email,
      );
      notifyListeners();
    }
  }

  // --- EXISTING LOGIC ---

  List<String> getBrands() {
    return allWatches.map((w) => w.brand).toSet().toList()..sort();
  }

  List<Watch> getWatchesByBrand(String brand) {
    return allWatches
        .where((w) => w.brand.toLowerCase() == brand.toLowerCase())
        .toList();
  }

  List<Watch> searchWatches(String query) {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    return allWatches
        .where(
          (w) =>
              w.name.toLowerCase().contains(q) ||
              w.brand.toLowerCase().contains(q) ||
              w.category.toLowerCase().contains(q),
        )
        .toList();
  }

  Watch? getWatchById(String id) {
    try {
      return allWatches.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }

  // Cart operations
  void addToCart(Watch watch) {
    cart.addWatch(watch);
    notifyListeners();
  }

  void removeFromCart(String watchId) {
    cart.removeWatch(watchId);
    notifyListeners();
  }

  void updateCartQuantity(String watchId, int quantity) {
    cart.updateQuantity(watchId, quantity);
    notifyListeners();
  }

  // --- ADDED THIS METHOD ---
  void clearCart() {
    cart.clear();
    notifyListeners();
  }
  // -------------------------

  // Favorites
  void toggleFavorite(String watchId) {
    if (currentUser != null) {
      currentUser!.toggleFavorite(watchId);
      notifyListeners();
    }
  }

  bool isFavorite(String watchId) {
    return currentUser?.isFavorite(watchId) ?? false;
  }

  List<Watch> getFavoriteWatches() {
    if (currentUser == null) return [];
    return allWatches.where((w) => currentUser!.isFavorite(w.id)).toList();
  }

  // --- DEVICE CAPABILITY METHODS ---

  Future<XFile?> pickProfileImage() async {
    try {
      return await _imagePicker.pickImage(source: ImageSource.camera);
    } catch (e) {
      debugPrint("Camera Error: $e");
      return null;
    }
  }

  Future<String> getCurrentLocationAddress() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return 'Permission denied';
        }
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      return 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
    } catch (e) {
      debugPrint("Geolocation Error: $e");
      return 'Could not get location';
    }
  }

  Future<int> getBatteryLevel() async {
    try {
      return await _battery.batteryLevel;
    } catch (e) {
      debugPrint("Battery Error: $e");
      return -1;
    }
  }
}
