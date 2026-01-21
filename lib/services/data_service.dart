import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch_store/models/watch.dart';

class DataService {
  final String _watchBoxName = 'watchCache';
  final String baseUrl =
      dotenv.env['API_BASE_URL'] ??
      'https://laravel-watch-production.up.railway.app/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // --- User Data (Replaces Firestore Stream) ---

  // Fetches user profile, role, and cart in one go (or separate calls if needed)
  // For now, we'll fetch /api/user and /api/cart
  Future<Map<String, dynamic>> getUserData() async {
    final token = await _getToken();
    if (token == null) return {};

    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/user',
        ), // You might need a dedicated endpoint for full profile + cart
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final userJson = jsonDecode(response.body);

        // Also fetch cart
        final cartResponse = await http.get(
          Uri.parse('$baseUrl/cart'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );

        List<dynamic> cartItems = [];
        if (cartResponse.statusCode == 200) {
          final cartData = jsonDecode(cartResponse.body);
          // Transform API cart response to the format AppController expects
          // API returns: { data: { cart_items: [ { product_id: ..., quantity: ..., product: {...} } ] } }
          // AppController expects: List<Map<String, dynamic>> [{'watchId': '...', 'quantity': ...}]

          if (cartData['data'] != null &&
              cartData['data']['cart_items'] != null) {
            cartItems = (cartData['data']['cart_items'] as List).map((item) {
              return {
                'watchId': item['product']['id']
                    .toString(), // Ensure ID is string to match Watch model
                'quantity': item['quantity'],
              };
            }).toList();
          }
        }

        return {
          'name': userJson['name'],
          'email': userJson['email'],
          // 'profileImagePath': userJson['profile_photo_url'], // If you have this field
          'role': userJson['role'],
          'cartItems': cartItems,
          // 'favorites': ... // If you add favorites API
        };
      }
    } catch (e) {
      debugPrint("API Get User Data Error: $e");
    }
    return {};
  }

  // Stream is removed because API is request-response.
  // We will poll or just fetch on load.
  // For compatibility with AppController, we can return a Stream that emits once.
  Stream<Map<String, dynamic>> streamUserData(String userId) async* {
    // Initial fetch
    yield await getUserData();
    // In a real app, you might poll periodically or use websockets
  }

  // --- Cart Management (API) ---

  Future<void> updateCart(
    String userId,
    String userName,
    String userEmail,
    List<Map<String, dynamic>> cartItems,
  ) async {
    debugPrint("Warning: updateCart called. Please use granular API methods.");
  }

  // New specific methods for API interaction
  Future<void> addToCartApi(String watchId, int quantity) async {
    final token = await _getToken();
    if (token == null) return;

    try {
      await http.post(
        Uri.parse('$baseUrl/cart/add/$watchId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'quantity': quantity}),
      );
    } catch (e) {
      debugPrint("API Add to Cart Error: $e");
    }
  }

  Future<void> removeFromCartApi(String watchId) async {
    final token = await _getToken();
    if (token == null) return;

    try {
      await http.delete(
        Uri.parse('$baseUrl/cart/product/$watchId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
    } catch (e) {
      debugPrint("API Remove from Cart Error: $e");
    }
  }

  Future<void> updateCartQuantityApi(String watchId, int quantity) async {
    final token = await _getToken();
    if (token == null) return;

    try {
      await http.patch(
        Uri.parse('$baseUrl/cart/product/$watchId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'quantity': quantity}),
      );
    } catch (e) {
      debugPrint("API Update Cart Quantity Error: $e");
    }
  }

  Future<void> clearCartApi() async {
    final token = await _getToken();
    if (token == null) return;

    try {
      await http.delete(
        Uri.parse('$baseUrl/cart/clear'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
    } catch (e) {
      debugPrint("API Clear Cart Error: $e");
    }
  }

  // --- Product Data (API) ---

  // Stream watches replaced by Fetch
  // We can keep the stream signature but just emit once for compatibility or refactor Controller.
  Stream<List<Watch>> streamWatches() async* {
    while (true) {
      yield await fetchWatchesFromApi();
      await Future.delayed(const Duration(seconds: 30)); // Poll every 30s
    }
    // Alternatively just yield once:
    // yield await fetchWatchesFromApi();
  }

  Future<List<Watch>> fetchWatchesFromApi() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Assuming API returns { data: [...] } or just [...]
        // Adjust based on your actual API response structure (ProductController check needed)

        // ProductController::index returns: return response()->json(['data' => $products]); ?
        // Or via Resource... usually 'data' wrapper.

        final List<dynamic> productsJson = (data['data'] != null)
            ? data['data']
            : data;

        final List<Watch> watches = productsJson.map((json) {
          return Watch.fromJson({
            'id': json['id']
                .toString(), // Integers in MySQL, String in Watch ID
            'name': json['name'],
            'brand': json['brand'] ?? 'Generic',
            'price': (json['price'] is num)
                ? (json['price'] as num).toDouble()
                : double.tryParse(json['price'].toString()) ?? 0.0,
            'description': json['description'],
            'category': json['category_id'].toString(), // Mapping ID or name?
            'imagePath':
                json['image'], // Ensure this is full URL or handle in UI
            'stock': json['stock'],
            // 'isFeatured': json['is_featured'] == 1,
          });
        }).toList();

        await saveWatchesToLocalDb(watches);
        return watches;
      }
    } catch (e) {
      debugPrint("API Fetch Watches Error: $e");
    }
    return [];
  }

  // --- Local DB (Hive) - Keep for caching ---
  Future<void> saveWatchesToLocalDb(List<Watch> watches) async {
    final box = await Hive.openBox(_watchBoxName);
    final List<Map<String, dynamic>> watchMaps = watches
        .map((watch) => watch.toJson())
        .toList();
    await box.put('all_watches', watchMaps);
  }

  Future<List<Watch>> getWatchesFromLocalDb() async {
    final box = await Hive.openBox(_watchBoxName);
    final List<dynamic>? watchMaps = box.get('all_watches');

    if (watchMaps != null) {
      final List<Watch> watches = watchMaps.map((item) {
        final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(item);
        return Watch.fromJson(jsonMap);
      }).toList();
      return watches;
    } else {
      return [];
    }
  }

  // Stubs for other methods to prevent compilation errors
  Future<void> updateFavorites(
    String userId,
    String userName,
    String userEmail,
    Set<String> favorites,
  ) async {}
  Future<void> updateProfileImagePath(
    String userId,
    String userName,
    String userEmail,
    String? imageUrl,
  ) async {}

  // --- Admin API Methods ---

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final token = await _getToken();
    if (token == null) return [];

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
    } catch (e) {
      debugPrint("API Get All Users Error: $e");
    }
    return [];
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    final token = await _getToken();
    if (token == null) return;

    try {
      await http.patch(
        Uri.parse('$baseUrl/admin/users/$userId/role'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'role': newRole}),
      );
    } catch (e) {
      debugPrint("API Update User Role Error: $e");
      rethrow;
    }
  }

  Future<void> deleteUser(String userId) async {
    final token = await _getToken();
    if (token == null) return;

    try {
      await http.delete(
        Uri.parse('$baseUrl/admin/users/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
    } catch (e) {
      debugPrint("API Delete User Error: $e");
      rethrow;
    }
  }

  // --- Watch Management Methods ---

  Future<void> addWatch(Watch watch) async {
    // Implement Add Watch API call if needed for Admin
  }

  Future<void> updateWatch(Watch watch) async {
    // Implement Update Watch API call
  }

  Future<void> updateStock(String watchId, int newStock) async {
    // Implement Update Stock API call
  }

  Future<void> deleteWatch(String watchId) async {
    final token = await _getToken();
    if (token == null) return;

    try {
      await http.delete(
        Uri.parse('$baseUrl/products/$watchId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
    } catch (e) {
      debugPrint("API Delete Watch Error: $e");
      rethrow;
    }
  }
}
