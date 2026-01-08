import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl =
      'https://laravel-watch-production.up.railway.app';
  static Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    debugPrint('GET Request: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      debugPrint('Error during GET request: $e');
      rethrow;
    }
  }

  // Generic POST method
  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    debugPrint('POST Request: $url');
    debugPrint('Body: $data');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      debugPrint('Error during POST request: $e');
      rethrow;
    }
  }

  // Helper to handle HTTP responses
  static dynamic _handleResponse(http.Response response) {
    debugPrint('Response Status: ${response.statusCode}');
    debugPrint('Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  // Fetch Products
  static Future<List<dynamic>> getProducts() async {
    try {
      final response = await get('api/products'); // Adjust endpoint if needed

      // Standard Laravel Resource response usually wraps list in 'data'
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return response['data'];
      } else if (response is List) {
        return response;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
      rethrow;
    }
  }

  // Fetch Users
  static Future<List<dynamic>> getUsers() async {
    try {
      final response = await get(
        'api/users',
      ); // Ensure this route exists in Laravel
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return response['data'];
      } else if (response is List) {
        return response;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching users: $e');
      rethrow;
    }
  }

  // Delete User
  static Future<void> deleteUser(int id) async {
    try {
      final url = Uri.parse('$baseUrl/api/users/$id');
      debugPrint('DELETE Request: $url');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      } else {
        throw Exception('Failed to delete user: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error deleting user: $e');
      rethrow;
    }
  }

  // Create User
  static Future<void> createUser(Map<String, dynamic> data) async {
    try {
      final response = await post('api/users', data);
      debugPrint('Create User Response: $response');
    } catch (e) {
      debugPrint('Error creating user: $e');
      rethrow;
    }
  }

  // Update User
  static Future<void> updateUser(int id, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl/api/users/$id');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to update user: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error updating user: $e');
      rethrow;
    }
  }

  // Create Product
  static Future<void> createProduct(Map<String, dynamic> data) async {
    try {
      // NOTE: Using the 'seller' prefix route as defined in Laravel, which Admin can also access
      final response = await post('api/seller/products', data);
      debugPrint('Create Product Response: $response');
    } catch (e) {
      debugPrint('Error creating product: $e');
      rethrow;
    }
  }

  // Update Product
  static Future<void> updateProduct(int id, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl/api/seller/products/$id');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to update product: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error updating product: $e');
      rethrow;
    }
  }

  // Delete Product
  static Future<void> deleteProduct(int id) async {
    try {
      final url = Uri.parse('$baseUrl/api/seller/products/$id');
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to delete product: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error deleting product: $e');
      rethrow;
    }
  }

  // Create Product with Image (Multipart)
  static Future<void> createProductMultipart(
    Map<String, String> fields,
    String? imagePath,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/api/seller/products');
      final request = http.MultipartRequest('POST', url);

      // Add fields
      request.fields.addAll(fields);

      // Add image if exists
      if (imagePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image', // Field name expected by Laravel
            imagePath,
          ),
        );
      }

      request.headers.addAll({'Accept': 'application/json'});

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Failed to create product: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error creating product (multipart): $e');
      rethrow;
    }
  }

  // Update Product with Image (Multipart)
  static Future<void> updateProductMultipart(
    int id,
    Map<String, String> fields,
    String? imagePath,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/api/seller/products/$id');
      // Using POST with _method=PUT to handle multipart/form-data on Laravel
      var request = http.MultipartRequest('POST', url);
      request.fields['_method'] = 'PUT';

      request.fields.addAll(fields);

      if (imagePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imagePath),
        );
      }

      request.headers.addAll({'Accept': 'application/json'});

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Failed to update product: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error updating product (multipart): $e');
      rethrow;
    }
  }
}
