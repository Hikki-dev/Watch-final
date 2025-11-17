import 'dart:convert'; 
import 'package:flutter/foundation.dart'; // <-- 2. ADD: For debugPrint
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../models/watch.dart';

class DataService {
  final String _watchBox = 'watchCache';
  final String _apiUrl = dotenv.env['SSP_API_URL'] ?? '';

  // 1. Fetch data from your SSP API
  Future<List<Watch>> fetchWatchesFromApi() async {
    if (_apiUrl.isEmpty) {
      // 3. FIX: Use debugPrint instead of print
      debugPrint("SSP_API_URL not found in .env file");
      return [];
    }

    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        String jsonString = response.body;

        // Decode and parse the JSON
        List<dynamic> jsonList = json.decode(
          jsonString,
        ); // <-- Now 'json' is defined
        List<Watch> watches = jsonList
            .map((json) => Watch.fromJson(json))
            .toList();

        // 4. FIX: Save the decoded watches to the DB
        await saveWatchesToLocalDb(watches);

        return watches;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("API Fetch Error: $e");
      return [];
    }
  }

  // 2. Save List<Watch> to local DB (Hive)
  Future<void> saveWatchesToLocalDb(List<Watch> watches) async {
    final box = await Hive.openBox<String>(_watchBox);
    // 5. FIX: Convert List<Watch> to a JSON string
    List<Map<String, dynamic>> jsonList = watches
        .map((w) => w.toJson())
        .toList();
    String jsonString = json.encode(jsonList);
    await box.put('all_watches', jsonString);
  }

  // 3. Get data from local DB (Hive)
  Future<List<Watch>> getWatchesFromLocalDb() async {
    final box = await Hive.openBox<String>(_watchBox);
    final String? jsonString = box.get('all_watches');

    if (jsonString != null && jsonString.isNotEmpty) {
      // Decode and parse the cached JSON
      List<dynamic> jsonList = json.decode(
        jsonString,
      ); // <-- Now 'json' is defined
      return jsonList.map((json) => Watch.fromJson(json)).toList();
    } else {
      return [];
    }
  }
}
