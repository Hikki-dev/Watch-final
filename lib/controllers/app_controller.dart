// lib/controllers/app_controller.dart
import 'dart:async'; // <-- ADDED
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_storage/firebase_storage.dart'; // <-- ADDED

import '../models/watch.dart';
import '../models/user.dart';
import '../models/cart.dart';
import '../models/cart_item.dart'; // <-- ADDED for local cart reconstruction
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
  User? currentUser; // app's User model
  final Cart cart = Cart();
  List<Watch> allWatches = [];
  bool isLoading = true;
  String? _userFullName; // For storing the name from registration

  // --- ADDED: Firestore Live Data Fields ---
  StreamSubscription<Map<String, dynamic>>? _userDataSubscription;

  // Private fields to hold streamed data from Firestore
  Set<String> _dbFavorites = {};
  String? _dbProfileImagePath;
  // Stores raw cart items: [{'watchId': '123', 'quantity': 2}, ...]
  List<Map<String, dynamic>> _dbCartItems = [];
  // ------------------------------------------

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

    // Re-trigger auth listener to make sure we process fetched watches
    // and correctly hydrate the cart/favorites if a user is logged in.
    _onAuthStateChanged(authService.currentUser);

    isLoading = false;
    notifyListeners();
  }

  // Update user state when auth changes (MODIFIED for live data)
  void _onAuthStateChanged(fb.User? firebaseUser) {
    _userDataSubscription?.cancel(); // Cancel previous stream
    _userDataSubscription = null;

    if (firebaseUser == null) {
      currentUser = null;
      _userFullName = null;
      cart.clear(); // Clear local cart
      _dbFavorites.clear();
      _dbProfileImagePath = null;
      _dbCartItems.clear();
      // No need to call _updateCurrentUserModel(null) as we set it to null above
    } else {
      // Start listening to live user data from Firestore
      _userDataSubscription = _dataService.streamUserData(firebaseUser.uid).listen((
        userData,
      ) {
        // Update local private state from the stream
        _dbFavorites =
            (userData['favorites'] as List?)
                ?.map((e) => e.toString())
                .toSet() ??
            {};
        _dbProfileImagePath = userData['profileImagePath'] as String?;
        // Ensure cart items are correctly typed
        _dbCartItems =
            (userData['cartItems'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e))
                .toList() ??
            [];

        _updateCurrentUserModel(firebaseUser); // Update the User model
        _updateLocalCartFromDb(); // Update the separate Cart ChangeNotifier
        notifyListeners(); // Notify all listeners (like HomeView/FavoritesView)
      });

      // Update initial user model immediately (with initial/cached state)
      _updateCurrentUserModel(firebaseUser);
    }
    notifyListeners();
  }

  // Helper to create or update the local User model from streamed data
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
      profileImagePath: _dbProfileImagePath, // <-- Include streamed data
      favorites: _dbFavorites, // <-- Include streamed data
    );
  }

  // Called from register view to set the name
  void setUserFullName(String name) {
    _userFullName = name;
    _updateCurrentUserModel(authService.currentUser);
    notifyListeners();
  }

  // -----------------------------------------------------------
  // Cart Persistence Helpers
  // -----------------------------------------------------------

  // Helper to rebuild the local Cart ChangeNotifier instance from streamed DB data
  void _updateLocalCartFromDb() {
    if (allWatches.isEmpty) return; // Wait until watches are loaded

    final List<CartItem> newItems = [];
    for (var itemMap in _dbCartItems) {
      final watch = getWatchById(itemMap['watchId'] as String);
      // Skip if watch data isn't loaded (shouldn't happen after initialize)
      if (watch != null && itemMap['quantity'] as int > 0) {
        newItems.add(
          CartItem(watch: watch, quantity: itemMap['quantity'] as int),
        );
      }
    }
    cart.replaceAll(newItems); // Requires cart.replaceAll(List<CartItem>)
  }

  // Helper to convert Cart to DB-ready format (List<Map>)
  List<Map<String, dynamic>> _cartToDbFormat(Cart cartToFormat) {
    return cartToFormat.items
        .map((item) => {'watchId': item.watch.id, 'quantity': item.quantity})
        .toList();
  }

  // Helper to get a mutable copy of the current cart state
  Cart _getCurrentMutableCart() {
    final mutableCart = Cart();
    _dbCartItems.forEach((itemMap) {
      final watch = getWatchById(itemMap['watchId'] as String);
      if (watch != null) {
        // Use addWatch to correctly process quantity merge
        mutableCart.addWatch(watch, quantity: itemMap['quantity'] as int);
      }
    });
    return mutableCart;
  }

  // -----------------------------------------------------------
  // Core Logic (Refactored to be Firestore-backed)
  // -----------------------------------------------------------

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

  // Cart operations (MODIFIED to pass user name/email)
  void addToCart(Watch watch) {
    if (currentUser == null) return;
    final mutableCart = _getCurrentMutableCart();
    mutableCart.addWatch(watch, quantity: 1);
    _dataService.updateCart(
      currentUser!.id,
      currentUser!.name, // <-- PASSED
      currentUser!.email, // <-- PASSED
      _cartToDbFormat(mutableCart),
    );
  }

  void removeFromCart(String watchId) {
    if (currentUser == null) return;
    final mutableCart = _getCurrentMutableCart();
    mutableCart.removeWatch(watchId);
    _dataService.updateCart(
      currentUser!.id,
      currentUser!.name, // <-- PASSED
      currentUser!.email, // <-- PASSED
      _cartToDbFormat(mutableCart),
    );
  }

  void updateCartQuantity(String watchId, int quantity) {
    if (currentUser == null) return;
    final mutableCart = _getCurrentMutableCart();
    mutableCart.updateQuantity(watchId, quantity);
    _dataService.updateCart(
      currentUser!.id,
      currentUser!.name, // <-- PASSED
      currentUser!.email, // <-- PASSED
      _cartToDbFormat(mutableCart),
    );
  }

  // MODIFIED to be asynchronous and pass user name/email
  Future<void> clearCart() async {
    if (currentUser == null) return;
    await _dataService.updateCart(
      currentUser!.id,
      currentUser!.name, // <-- PASSED
      currentUser!.email, // <-- PASSED
      [],
    );
    // The stream listener handles updating the local cart and notifying listeners.
  }

  // Favorites (MODIFIED to pass user name/email)
  void toggleFavorite(String watchId) {
    if (currentUser == null) return;

    // Create new set with the toggled state
    final newFavorites = Set<String>.from(_dbFavorites);
    if (newFavorites.contains(watchId)) {
      newFavorites.remove(watchId);
    } else {
      newFavorites.add(watchId);
    }

    // Update Firestore, the stream will then update the UI
    _dataService.updateFavorites(
      currentUser!.id,
      currentUser!.name, // <-- PASSED
      currentUser!.email, // <-- PASSED
      newFavorites,
    );
  }

  bool isFavorite(String watchId) {
    // Reads from the currentUser model, which is updated by the live stream
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

  // Uploads image to storage and saves URL to Firestore (MODIFIED to pass user name/email)
  Future<void> updateProfilePicture(XFile file) async {
    if (currentUser == null) return;
    final userId = currentUser!.id;
    // Create a reference to the Firebase Storage path
    final storageRef = FirebaseStorage.instance.ref().child(
      'user_profiles/$userId/profile_image.jpg',
    );

    try {
      // Upload file to Firebase Storage
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      await storageRef.putData(await file.readAsBytes(), metadata);

      // Get the download URL
      final imageUrl = await storageRef.getDownloadURL();

      // Update Firestore with the new URL, including name/email
      await _dataService.updateProfileImagePath(
        userId,
        currentUser!.name, // <-- PASSED
        currentUser!.email, // <-- PASSED
        imageUrl,
      );

      // The stream listener handles updating the currentUser and UI.
    } catch (e) {
      debugPrint("Profile Image Upload Error: $e");
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
