// lib/services/data_service.dart
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appcounter/models/watch.dart';

class DataService {
  final String _watchBoxName = 'watchCache';
  final CollectionReference _productsCollection = FirebaseFirestore.instance
      .collection('products');

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
