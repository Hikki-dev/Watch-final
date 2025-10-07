// lib/controllers/app_controller.dart 
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

  // Get all brands 
  List<String> getBrands() {
    // Return all brand names from the brands list
    return [
      'Audemars Piguet',
      'Casio',
      'Citizen',
      'Omega',
      'Patek Philippe',
      'Richard Mille',
      'Rolex',
      'Seiko',
      'Swatch',
      'TAG Heuer',
    ];
  }

  // Get watches by brand - FIXED to handle case sensitivity
  List<Watch> getWatchesByBrand(String brand) {
    return allWatches
        .where((w) => w.brand.toLowerCase() == brand.toLowerCase())
        .toList();
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

  void _loadSampleWatches() {
    allWatches.addAll([
      // Audemars Piguet (AP)
      Watch(
        id: '1',
        name: 'Royal Oak',
        brand: 'Audemars Piguet',
        price: 85000.0,
        category: 'Luxury Sport',
        description: 'Iconic octagonal bezel luxury sports watch',
        imagePath: 'assets/images/watches/ap-royal-oak-1.jpg',
      ),
      Watch(
        id: '2',
        name: 'Royal Oak Offshore',
        brand: 'Audemars Piguet',
        price: 55000.0,
        category: 'Luxury Sport',
        description: 'Bold and oversized luxury chronograph',
        imagePath: 'assets/images/watches/ap-royal-oak-2.jpg',
      ),

      // Omega
      Watch(
        id: '3',
        name: 'Seamaster',
        brand: 'Omega',
        price: 5500.0,
        category: 'Diving',
        description: 'Professional diving watch',
        imagePath: 'assets/images/watches/omega-seamaster-1.jpg',
      ),
      Watch(
        id: '4',
        name: 'Speedmaster',
        brand: 'Omega',
        price: 6500.0,
        category: 'Chronograph',
        description: 'The legendary moonwatch',
        imagePath: 'assets/images/watches/omega-speedmaster-1.jpg',
      ),
      Watch(
        id: '5',
        name: 'Speedmaster Pro',
        brand: 'Omega',
        price: 7200.0,
        category: 'Chronograph',
        description: 'Professional moonwatch edition',
        imagePath: 'assets/images/watches/omega-speedmaster-2.jpg',
      ),

      // Patek Philippe
      Watch(
        id: '6',
        name: 'Calatrava',
        brand: 'Patek Philippe',
        price: 32000.0,
        category: 'Dress',
        description: 'Classic dress watch excellence',
        imagePath: 'assets/images/watches/patek-calatrava-1.jpg',
      ),
      Watch(
        id: '7',
        name: 'Nautilus',
        brand: 'Patek Philippe',
        price: 85000.0,
        category: 'Luxury Sport',
        description: 'Iconic porthole design luxury sports watch',
        imagePath: 'assets/images/watches/patek-nautilus-1.jpg',
      ),
      Watch(
        id: '8',
        name: 'Nautilus Blue',
        brand: 'Patek Philippe',
        price: 90000.0,
        category: 'Luxury Sport',
        description: 'Blue dial Nautilus variant',
        imagePath: 'assets/images/watches/patek-nautilus-2.jpg',
      ),

      // Richard Mille
      Watch(
        id: '9',
        name: 'RM 011',
        brand: 'Richard Mille',
        price: 150000.0,
        category: 'Luxury Sport',
        description: 'Ultra-light titanium sports chronograph',
        imagePath: 'assets/images/watches/richard-mille-1.jpg',
      ),
      Watch(
        id: '10',
        name: 'RM 027',
        brand: 'Richard Mille',
        price: 750000.0,
        category: 'Luxury Sport',
        description: 'Rafael Nadal edition tourbillon',
        imagePath: 'assets/images/watches/richard-mille-2.jpg',
      ),

      // Rolex
      Watch(
        id: '11',
        name: 'GMT-Master II',
        brand: 'Rolex',
        price: 15000.0,
        category: 'GMT',
        description: 'Dual timezone professional watch',
        imagePath: 'assets/images/watches/rolex-gmt-1.jpg',
      ),
      Watch(
        id: '12',
        name: 'Submariner',
        brand: 'Rolex',
        price: 13500.0,
        category: 'Diving',
        description: 'Iconic professional diving watch',
        imagePath: 'assets/images/watches/rolex-submariner-1.jpg',
      ),
      Watch(
        id: '13',
        name: 'Submariner Date',
        brand: 'Rolex',
        price: 14200.0,
        category: 'Diving',
        description: 'Professional diving watch with date',
        imagePath: 'assets/images/watches/rolex-submariner-2.jpg',
      ),

      // Swatch
      Watch(
        id: '14',
        name: 'Big Bold Chrono',
        brand: 'Swatch',
        price: 120.0,
        category: 'Fashion',
        description: 'Bold chronograph with vibrant colors',
        imagePath: 'assets/images/watches/swatch-big-bold-chrono-1.jpg',
      ),
      Watch(
        id: '15',
        name: 'Swatch Scubaqua',
        brand: 'Swatch',
        price: 65.0,
        category: 'Fashion',
        description: 'Transparent colorful diving watch',
        imagePath: 'assets/images/watches/swatch-scubaqua.jpg',
      ),
      Watch(
        id: '16',
        name: 'Sistem51 Irony',
        brand: 'Swatch',
        price: 150.0,
        category: 'Automatic',
        description: 'Mechanical automatic with see-through case',
        imagePath: 'assets/images/watches/swatch-sistem51-irony-1.jpg',
      ),
      Watch(
        id: '17',
        name: 'Skin Classic',
        brand: 'Swatch',
        price: 85.0,
        category: 'Fashion',
        description: 'Ultra-thin minimalist design',
        imagePath: 'assets/images/watches/swatch-skin-classic-1.jpg',
      ),

      // Casio
      Watch(
        id: '18',
        name: 'G-Shock',
        brand: 'Casio',
        price: 149.0,
        category: 'Digital Sport',
        description: 'Rugged shock-resistant digital watch',
        imagePath: 'assets/images/watches/casio-gshock.jpg',
      ),

      // Seiko
      Watch(
        id: '19',
        name: '5 Sports',
        brand: 'Seiko',
        price: 299.0,
        category: 'Automatic',
        description: 'Affordable automatic sports watch',
        imagePath: 'assets/images/watches/seiko-watch.jpg',
      ),

      // TAG Heuer
      Watch(
        id: '20',
        name: 'Carrera',
        brand: 'TAG Heuer',
        price: 3999.0,
        category: 'Chronograph',
        description: 'Racing-inspired chronograph',
        imagePath: 'assets/images/watches/tag-heur-watch.jpg',
      ),

      // Citizen
      Watch(
        id: '21',
        name: 'Eco-Drive',
        brand: 'Citizen',
        price: 399.0,
        category: 'Solar',
        description: 'Solar-powered quartz watch',
        imagePath: 'assets/images/watches/citizen-watch.jpg',
      ),
    ]);
  }
}
