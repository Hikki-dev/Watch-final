// lib/controllers/app_controller.dart
import 'package:flutter/foundation.dart';
import '../models/watch.dart';
import '../models/user.dart';
import '../models/cart.dart';

class AppController extends ChangeNotifier {
  // Private properties
  User? _currentUser;
  final Cart _cart = Cart();
  final List<Watch> _watches = [];

  // Public getters
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  Cart get cart => _cart;
  List<Watch> get allWatches => List.unmodifiable(_watches);

  // Initialize app data
  void initialize() {
    _loadWatchData();
    _cart.addListener(() => notifyListeners());
  }

  // Authentication
  void login(String email, String password) {
    _currentUser = User(
      id: '1',
      name: email.split('@')[0].toUpperCase(),
      email: email,
    );
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _cart.clear();
    notifyListeners();
  }

  // Watch operations
  List<String> getBrands() {
    return _watches.map((w) => w.brand).toSet().toList()..sort();
  }

  List<Watch> getWatchesByBrand(String brand) {
    return _watches.where((w) => w.brand == brand).toList();
  }

  List<Watch> searchWatches(String query) {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    return _watches
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
      return _watches.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }

  // Cart operations
  void addToCart(Watch watch) {
    _cart.addWatch(watch);
  }

  void removeFromCart(String watchId) {
    _cart.removeWatch(watchId);
  }

  void updateCartQuantity(String watchId, int quantity) {
    _cart.updateQuantity(watchId, quantity);
  }

  // Favorites
  void toggleFavorite(String watchId) {
    if (_currentUser != null) {
      _currentUser!.toggleFavorite(watchId);
      notifyListeners();
    }
  }

  bool isFavorite(String watchId) {
    return _currentUser?.isFavorite(watchId) ?? false;
  }

  List<Watch> getFavoriteWatches() {
    if (_currentUser == null) return [];
    return _watches.where((w) => _currentUser!.isFavorite(w.id)).toList();
  }

  // Load sample data
  void _loadWatchData() {
    _watches.clear();
    _watches.addAll([
      // Rolex
      Watch(
        id: '1',
        name: 'Submariner',
        brand: 'Rolex',
        price: 12999.0,
        category: 'Diving',
        description:
            'Professional diving watch with exceptional water resistance',
      ),
      Watch(
        id: '2',
        name: 'Daytona',
        brand: 'Rolex',
        price: 15999.0,
        category: 'Racing',
        description: 'Racing chronograph designed for speed enthusiasts',
      ),
      Watch(
        id: '3',
        name: 'GMT-Master II',
        brand: 'Rolex',
        price: 14999.0,
        category: 'GMT',
        description: 'Dual timezone watch for international travelers',
      ),

      // Omega
      Watch(
        id: '4',
        name: 'Speedmaster',
        brand: 'Omega',
        price: 5999.0,
        category: 'Space',
        description: 'The moonwatch worn on every lunar mission',
      ),
      Watch(
        id: '5',
        name: 'Seamaster',
        brand: 'Omega',
        price: 4599.0,
        category: 'Diving',
        description: 'Professional diving watch with Co-Axial movement',
      ),
      Watch(
        id: '6',
        name: 'Constellation',
        brand: 'Omega',
        price: 3999.0,
        category: 'Dress',
        description: 'Elegant timepiece with distinctive design',
      ),

      // Patek Philippe
      Watch(
        id: '7',
        name: 'Nautilus',
        brand: 'Patek Philippe',
        price: 29999.0,
        category: 'Sport',
        description: 'Luxury sports watch with iconic porthole design',
      ),
      Watch(
        id: '8',
        name: 'Calatrava',
        brand: 'Patek Philippe',
        price: 25999.0,
        category: 'Dress',
        description: 'Classic dress watch epitomizing elegance',
      ),

      // Casio
      Watch(
        id: '9',
        name: 'G-Shock',
        brand: 'Casio',
        price: 149.0,
        category: 'Digital',
        description: 'Rugged digital watch for extreme conditions',
      ),
      Watch(
        id: '10',
        name: 'Edifice',
        brand: 'Casio',
        price: 299.0,
        category: 'Sport',
        description: 'Sporty chronograph inspired by motor racing',
      ),

      // Seiko
      Watch(
        id: '11',
        name: '5 Sports',
        brand: 'Seiko',
        price: 299.0,
        category: 'Sport',
        description: 'Affordable automatic sport watch with reliability',
      ),
      Watch(
        id: '12',
        name: 'Prospex',
        brand: 'Seiko',
        price: 599.0,
        category: 'Diving',
        description: 'Professional diving watch with superior water resistance',
      ),

      // Swatch
      Watch(
        id: '13',
        name: 'Sistem51',
        brand: 'Swatch',
        price: 199.0,
        category: 'Casual',
        description: 'Innovative automatic movement with 51 components',
      ),
      Watch(
        id: '14',
        name: 'Irony',
        brand: 'Swatch',
        price: 149.0,
        category: 'Casual',
        description: 'Metal case collection with style and durability',
      ),

      // TAG Heuer
      Watch(
        id: '15',
        name: 'Carrera',
        brand: 'TAG Heuer',
        price: 3999.0,
        category: 'Racing',
        description: 'Racing-inspired chronograph with timeless design',
      ),
    ]);
  }
}
