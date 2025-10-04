// lib/controllers/app_controller.dart - SIMPLIFIED
import 'package:flutter/foundation.dart';
import '../models/watch.dart';
import '../models/user.dart';
import '../models/cart.dart';

class AppController extends ChangeNotifier {
  User? currentUser;
  final Cart cart = Cart();
  final List<Watch> allWatches = [];

  // Initialize with sample data
  void initialize() {
    _loadSampleWatches();
  }

  // Simple login - accepts any credentials
  void login(String email, String password) {
    currentUser = User(
      id: '1',
      name: email.split('@')[0].toUpperCase(),
      email: email,
    );
    notifyListeners();
  }

  void logout() {
    currentUser = null;
    cart.clear();
    notifyListeners();
  }

  // Get unique brands
  List<String> getBrands() {
    return allWatches.map((w) => w.brand).toSet().toList()..sort();
  }

  // Get watches by brand
  List<Watch> getWatchesByBrand(String brand) {
    return allWatches.where((w) => w.brand == brand).toList();
  }

  // Search watches
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

  // Get watch by ID
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

  // Load sample data
  void _loadSampleWatches() {
    allWatches.addAll([
      // Rolex
      Watch(
        id: '1',
        name: 'Submariner',
        brand: 'Rolex',
        price: 12999.0,
        category: 'Diving',
        description: 'Professional diving watch',
        imagePath: 'lib/images/watches/rolex_submariner.png',
      ),
      Watch(
        id: '2',
        name: 'Daytona',
        brand: 'Rolex',
        price: 15999.0,
        category: 'Racing',
        description: 'Racing chronograph',
        imagePath: 'lib/images/watches/rolex_daytona.png',
      ),
      Watch(
        id: '3',
        name: 'GMT-Master II',
        brand: 'Rolex',
        price: 14999.0,
        category: 'GMT',
        description: 'Dual timezone watch',
        imagePath: 'lib/images/watches/rolex_gmt.png',
      ),

      // Omega
      Watch(
        id: '4',
        name: 'Speedmaster',
        brand: 'Omega',
        price: 5999.0,
        category: 'Space',
        description: 'The moonwatch',
        imagePath: 'lib/images/watches/omega_speedmaster.png',
      ),
      Watch(
        id: '5',
        name: 'Seamaster',
        brand: 'Omega',
        price: 4599.0,
        category: 'Diving',
        description: 'Professional diving watch',
        imagePath: 'lib/images/watches/omega_seamaster.png',
      ),
      Watch(
        id: '6',
        name: 'Constellation',
        brand: 'Omega',
        price: 3999.0,
        category: 'Dress',
        description: 'Elegant timepiece',
        imagePath: 'lib/images/watches/omega_constellation.png',
      ),

      // Patek Philippe
      Watch(
        id: '7',
        name: 'Nautilus',
        brand: 'Patek Philippe',
        price: 29999.0,
        category: 'Sport',
        description: 'Luxury sports watch',
        imagePath: 'lib/images/watches/patek_nautilus.png',
      ),
      Watch(
        id: '8',
        name: 'Calatrava',
        brand: 'Patek Philippe',
        price: 25999.0,
        category: 'Dress',
        description: 'Classic dress watch',
        imagePath: 'lib/images/watches/patek_calatrava.png',
      ),

      // Casio
      Watch(
        id: '9',
        name: 'G-Shock',
        brand: 'Casio',
        price: 149.0,
        category: 'Digital',
        description: 'Rugged digital watch',
        imagePath: 'lib/images/watches/casio_gshock.png',
      ),
      Watch(
        id: '10',
        name: 'Edifice',
        brand: 'Casio',
        price: 299.0,
        category: 'Sport',
        description: 'Sporty chronograph',
        imagePath: 'lib/images/watches/casio_edifice.png',
      ),

      // Seiko
      Watch(
        id: '11',
        name: '5 Sports',
        brand: 'Seiko',
        price: 299.0,
        category: 'Sport',
        description: 'Affordable automatic',
        imagePath: 'lib/images/watches/seiko_5sports.png',
      ),
      Watch(
        id: '12',
        name: 'Prospex',
        brand: 'Seiko',
        price: 599.0,
        category: 'Diving',
        description: 'Professional diving watch',
        imagePath: 'lib/images/watches/seiko_prospex.png',
      ),

      // TAG Heuer
      Watch(
        id: '13',
        name: 'Carrera',
        brand: 'TAG Heuer',
        price: 3999.0,
        category: 'Racing',
        description: 'Racing chronograph',
        imagePath: 'lib/images/watches/tag_carrera.png',
      ),
      Watch(
        id: '14',
        name: 'Monaco',
        brand: 'TAG Heuer',
        price: 5999.0,
        category: 'Racing',
        description: 'Iconic square watch',
        imagePath: 'lib/images/watches/tag_monaco.png',
      ),

      // Citizen
      Watch(
        id: '15',
        name: 'Eco-Drive',
        brand: 'Citizen',
        price: 399.0,
        category: 'Casual',
        description: 'Solar-powered watch',
        imagePath: 'lib/images/watches/citizen_ecodrive.png',
      ),
    ]);
  }
}
