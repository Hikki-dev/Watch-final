// lib/services/data_service.dart
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appcounter/models/watch.dart';

class DataService {
  final String _watchBoxName = 'watchCache';
  final CollectionReference _productsCollection = FirebaseFirestore.instance
      .collection('products');
  final CollectionReference _usersCollection = FirebaseFirestore.instance
      .collection('users');

  // Get live user data (Favorites/Profile Image Path/Cart Items)
  Stream<Map<String, dynamic>> streamUserData(String userId) {
    return _usersCollection.doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return {};
      }
      return snapshot.data() as Map<String, dynamic>;
    });
  }

  // Update user's favorites in Firestore (MODIFIED)
  Future<void> updateFavorites(
    String userId,
    String userName, // <-- ADDED
    String userEmail, // <-- ADDED
    Set<String> favorites,
  ) async {
    // Firestore stores Sets as Lists in the database
    await _usersCollection.doc(userId).set({
      'name': userName, // <-- SAVED
      'email': userEmail, // <-- SAVED
      'favorites': favorites.toList(),
    }, SetOptions(merge: true));
  }

  // Update user's profile image URL in Firestore (MODIFIED)
  Future<void> updateProfileImagePath(
    String userId,
    String userName, // <-- ADDED
    String userEmail, // <-- ADDED
    String? imageUrl,
  ) async {
    await _usersCollection.doc(userId).set({
      'name': userName, // <-- SAVED
      'email': userEmail, // <-- SAVED
      'profileImagePath': imageUrl,
    }, SetOptions(merge: true));
  }

  // Update user's cart items in Firestore (MODIFIED)
  // cartItems should be a List of Maps: [{'watchId': '123', 'quantity': 2}]
  Future<void> updateCart(
    String userId,
    String userName, // <-- ADDED
    String userEmail, // <-- ADDED
    List<Map<String, dynamic>> cartItems,
  ) async {
    await _usersCollection.doc(userId).set({
      'name': userName, // <-- SAVED
      'email': userEmail, // <-- SAVED
      'cartItems': cartItems,
    }, SetOptions(merge: true));
  }

  // Fetch data from Firestore
  Future<List<Watch>> fetchWatchesFromApi() async {
    try {
      final QuerySnapshot snapshot = await _productsCollection.get();
      final List<Watch> watches = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Watch.fromJson(data);
      }).toList();

      await saveWatchesToLocalDb(watches);
      return watches;
    } catch (e) {
      debugPrint("Firestore Fetch Error: $e");
      return [];
    }
  }

  // Save List<Watch> to local DB (Hive)
  Future<void> saveWatchesToLocalDb(List<Watch> watches) async {
    final box = await Hive.openBox(_watchBoxName);
    final List<Map<String, dynamic>> watchMaps = watches
        .map((watch) => watch.toJson())
        .toList();
    await box.put('all_watches', watchMaps);
  }

  // Get data from local DB (Hive)
  Future<List<Watch>> getWatchesFromLocalDb() async {
    final box = await Hive.openBox(_watchBoxName);
    final List<dynamic>? watchMaps = box.get('all_watches');

    if (watchMaps != null) {
      // --- THIS IS THE FIX ---
      // We can't just 'cast'. We must 'map' and convert each item.
      final List<Watch> watches = watchMaps.map((item) {
        // 1. 'item' is a LinkedMap<dynamic, dynamic>
        // 2. We create a new Map<String, dynamic> from it.
        final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(item);
        // 3. Now we can safely pass it to fromJson
        return Watch.fromJson(jsonMap);
      }).toList();
      // -----------------------

      return watches;
    } else {
      // No data in cache
      return [];
    }
  }
}
