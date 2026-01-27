// lib/controllers/app_controller.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../models/watch.dart';
import '../models/user.dart';
import '../models/cart.dart';
import '../models/cart_item.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import '../services/image_service.dart';

class AppController extends ChangeNotifier {
  final AuthService authService;

  // Services
  final DataService _dataService;
  final Connectivity _connectivity = Connectivity();

  final Battery _battery = Battery();

  // State
  User? currentUser; // app's User model
  final Cart cart = Cart();
  List<Watch> allWatches = [];
  bool isLoading = true;
  bool isUserDataLoaded = false; // Add this flag
  bool isUploadingProfileImage = false; // New state for upload loading
  String? _userFullName; // For storing the name from registration

  // --- API Data Subscription Fields ---
  StreamSubscription<Map<String, dynamic>>? _userDataSubscription;

  // Private fields to hold streamed data from Firestore
  Set<String> _dbFavorites = {};
  String? _dbProfileImagePath;
  List<Map<String, dynamic>> _dbCartItems = [];
  String? _dbRole;

  // Constructor
  AppController({required this.authService, DataService? dataService})
    : _dataService = dataService ?? DataService() {
    // Listen to auth changes
    authService.authStateChanges.listen(_onAuthStateChanged);
    _onAuthStateChanged(authService.currentUser);
  }

  // Initialize data
  Future<void> initialize() async {
    try {
      isLoading = true;
      notifyListeners();

      // 1. Load from cache first
      try {
        allWatches = await _dataService.getWatchesFromLocalDb();
        if (allWatches.isNotEmpty) {
          isLoading = false;
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error loading from local DB: $e');
        // Continue to fetch from API even if local load fails
      }

      // 2. Check for network connectivity
      final List<ConnectivityResult> connectivityResult = await _connectivity
          .checkConnectivity();
      final bool isOnline =
          connectivityResult.isNotEmpty &&
          !connectivityResult.contains(ConnectivityResult.none);

      if (isOnline) {
        // 3. Start listening to Watch Data Stream
        // Cancel existing subscription if any to avoid duplicates
        _userDataSubscription?.cancel();

        // Note: We're using a separate subscription for global watches, ideally should be a field
        // But for now we'll just listen. In a production app, we'd store this subscription.
        _dataService.streamWatches().listen(
          (watches) async {
            if (watches.isNotEmpty) {
              // Only update if data is actually different to avoid rebuilds
              // A simple check is length or first item ID, deeply checking equality is expensive
              bool hasChanged = allWatches.length != watches.length;
              if (!hasChanged && allWatches.isNotEmpty) {
                // rudimentary check: if first item changed
                hasChanged = allWatches.first.id != watches.first.id;
              }

              if (hasChanged || allWatches.isEmpty) {
                allWatches = watches;
                // Update local cache in background
                _dataService.saveWatchesToLocalDb(allWatches);
                notifyListeners();
              }
            }
          },
          onError: (e) {
            debugPrint('Error streaming watches: $e');
          },
        );

        // 4. Also fetch once to ensure we have data immediately if stream is slow
        try {
          final apiWatches = await _dataService.fetchWatchesFromApi();
          if (apiWatches.isNotEmpty) {
            allWatches = apiWatches;
            // 4. Save fresh data to local DB
            await _dataService.saveWatchesToLocalDb(allWatches);
            notifyListeners();
          }
        } catch (e) {
          debugPrint('Error fetching from API: $e');
        }
      }

      // Re-trigger auth listener to ensure data is synced
      _onAuthStateChanged(authService.currentUser);
    } catch (e, stack) {
      debugPrint('Fatal error in AppController.initialize: $e\n$stack');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Public method to force refresh user data (called after backend login)
  void refreshUserData() {
    _onAuthStateChanged(authService.currentUser);
  }

  // Update user state when auth changes
  // Update user state when auth changes
  void _onAuthStateChanged(fb.User? firebaseUser) async {
    _userDataSubscription?.cancel();
    _userDataSubscription = null;

    if (firebaseUser == null) {
      isUserDataLoaded = false;
      cart.clear();
      _dbFavorites.clear();
      _dbProfileImagePath = null;
      _dbCartItems.clear();
      _dbRole = null;
    } else {
      // API Implementation: Fetch full user profile once on login
      // Ideally this should be polled or re-fetched when actions occur
      try {
        final userData = await _dataService.getUserData();
        if (userData.isNotEmpty) {
          _dbFavorites =
              (userData['favorites'] as List?)
                  ?.map((e) => e.toString())
                  .toSet() ??
              {};
          _dbProfileImagePath = userData['profileImagePath'] as String?;
          _dbCartItems =
              (userData['cartItems'] as List?)
                  ?.map((e) => Map<String, dynamic>.from(e))
                  .toList() ??
              [];
          _dbRole = userData['role'] as String?;
        }
      } catch (e) {
        debugPrint('Error fetching user data from API: $e');
      }

      isUserDataLoaded = true;
      _updateCurrentUserModel(firebaseUser);
      _updateLocalCartFromDb();
      notifyListeners();
    }
    notifyListeners();
  }

  void _updateCurrentUserModel(fb.User? firebaseUser) {
    if (firebaseUser == null) {
      currentUser = null;
      return;
    }
    currentUser = User(
      id: firebaseUser.uid,
      name:
          _userFullName ??
          firebaseUser.displayName ??
          firebaseUser.email!.split('@')[0].toUpperCase(),
      email: firebaseUser.email!,
      profileImagePath: _dbProfileImagePath ?? firebaseUser.photoURL,
      favorites: _dbFavorites,
      role: _dbRole ?? 'customer', // Default to customer
    );
  }

  // Route helper
  String get homeRoute {
    if (currentUser?.isAdmin == true) return '/admin';
    if (currentUser?.isSeller == true) return '/seller';
    return '/home';
  }

  void setUserFullName(String name) {
    _userFullName = name;
    _updateCurrentUserModel(authService.currentUser);
    notifyListeners();
  }

  // --- Cart Logic ---

  void _updateLocalCartFromDb() {
    if (allWatches.isEmpty) return;

    final List<CartItem> newItems = [];
    for (var itemMap in _dbCartItems) {
      final watch = getWatchById(itemMap['watchId'] as String);
      if (watch != null && itemMap['quantity'] as int > 0) {
        newItems.add(
          CartItem(watch: watch, quantity: itemMap['quantity'] as int),
        );
      }
    }
    cart.replaceAll(newItems);
  }

  List<Map<String, dynamic>> _cartToDbFormat(Cart cartToFormat) {
    return cartToFormat.items
        .map((item) => {'watchId': item.watch.id, 'quantity': item.quantity})
        .toList();
  }

  Cart _getCurrentMutableCart() {
    final mutableCart = Cart();
    for (var itemMap in _dbCartItems) {
      final watch = getWatchById(itemMap['watchId'] as String);
      if (watch != null) {
        mutableCart.addWatch(watch, quantity: itemMap['quantity'] as int);
      }
    }
    return mutableCart;
  }

  // --- Core Logic ---

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

  void addToCart(Watch watch) {
    if (currentUser == null) return;

    // Optimistic Update (Local)
    final mutableCart = _getCurrentMutableCart();
    mutableCart.addWatch(watch, quantity: 1);

    // Sync with Server
    _dataService.addToCartApi(watch.id, 1);

    // Update local state to reflect UI change immediately
    // Note: Ideally we await the API and then update, but for responsiveness we do this.
    // We should probably re-fetch cart after a while or on error.
    _dbCartItems = _cartToDbFormat(mutableCart);
    _updateLocalCartFromDb(); // Refreshes 'cart' object
    notifyListeners();
  }

  void removeFromCart(String watchId) {
    if (currentUser == null) return;

    final mutableCart = _getCurrentMutableCart();
    mutableCart.removeWatch(watchId);

    _dataService.removeFromCartApi(watchId);

    _dbCartItems = _cartToDbFormat(mutableCart);
    _updateLocalCartFromDb();
    notifyListeners();
  }

  void updateCartQuantity(String watchId, int quantity) {
    if (currentUser == null) return;

    final mutableCart = _getCurrentMutableCart();
    mutableCart.updateQuantity(watchId, quantity);

    _dataService.updateCartQuantityApi(watchId, quantity);

    _dbCartItems = _cartToDbFormat(mutableCart);
    _updateLocalCartFromDb();
    notifyListeners();
  }

  Future<void> clearCart() async {
    if (currentUser == null) return;

    await _dataService.clearCartApi();

    cart.clear();
    _dbCartItems.clear();
    notifyListeners();
  }

  void toggleFavorite(String watchId) {
    if (currentUser == null) return;
    final newFavorites = Set<String>.from(_dbFavorites);
    if (newFavorites.contains(watchId)) {
      newFavorites.remove(watchId);
    } else {
      newFavorites.add(watchId);
    }
    _dataService.updateFavorites(
      currentUser!.id,
      currentUser!.name,
      currentUser!.email,
      newFavorites,
    );
  }

  bool isFavorite(String watchId) {
    return currentUser?.isFavorite(watchId) ?? false;
  }

  List<Watch> getFavoriteWatches() {
    if (currentUser == null) return [];
    return allWatches.where((w) => currentUser!.isFavorite(w.id)).toList();
  }

  // --- DEVICE CAPABILITY METHODS ---

  // MODIFIED: Now accepts specific ImageSource (Camera or Gallery)
  Future<void> pickAndUploadProfileImage({required ImageSource source}) async {
    if (currentUser == null) return;

    final imageService = ImageService();

    // 1. Pick
    final file = await imageService.pickImage(source: source);
    if (file == null) return;

    // START LOADING
    isUploadingProfileImage = true;
    notifyListeners();

    final userId = currentUser!.id;
    debugPrint("Starting Profile Picture Update for User: $userId");

    try {
      // 2. Process
      final imageString = await imageService.fileToBase64(file);

      if (imageString != null) {
        await _dataService.updateProfileImagePath(
          userId,
          currentUser!.name,
          currentUser!.email,
          imageString,
        );
        debugPrint("API updated with new Base64 Profile Image.");
      }
    } catch (e) {
      debugPrint("❌ Profile Image Update Error: $e");
    } finally {
      // STOP LOADING
      isUploadingProfileImage = false;
      notifyListeners();
    }
  }

  Future<String> getCurrentLocationAddress() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return 'Location services are disabled.';
    }

    // 2. Check permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return 'Location permissions are permanently denied';
    }

    // 3. Get Position
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      return 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
    } catch (e) {
      debugPrint("Geolocation Error: $e");
      return 'Could not determine location';
    }
  }

  Future<int> getBatteryLevel() async {
    try {
      int level = await _battery.batteryLevel;
      // On some platforms (especially Web), it might return 0 if unsupported or blocked.
      // Treat 0 as -1 (unknown) unless we are sure it's dead (unlikely while app is running).
      if (level == 0 && kIsWeb) {
        return -1;
      }
      return level;
    } catch (e) {
      debugPrint("Battery Error: $e");
      return -1;
    }
  }
}
