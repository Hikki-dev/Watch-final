import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('Verify Connection to Production Backend', () async {
    // 1. Read .env directly to get the URL (simulating what dotenv does)
    final envFile = File('.env');
    expect(envFile.existsSync(), true, reason: '.env file must exist');

    final lines = await envFile.readAsLines();
    String? baseUrl;

    for (var line in lines) {
      if (line.startsWith('API_BASE_URL=')) {
        baseUrl = line.split('=')[1].trim();
        break;
      }
    }

    expect(baseUrl, isNotNull, reason: 'API_BASE_URL not found in .env');
    print('Testing connection to: $baseUrl');

    // 2. Make a real HTTP request to the /products endpoint
    // We use /products as it's a GET request likely to handle public access or at least return JSON
    final url = Uri.parse('$baseUrl/products');

    try {
      final response = await http.get(url);

      print('Status Code: ${response.statusCode}');

      // We expect 200 OK if products are public
      // If auth is required, we might get 401, but that STILL means we connected!
      // So valid codes are 200-299 or 401/403 (meaning server reached).
      // 404 might mean wrong endpoint but still connected.
      // 500+ means server error.
      // Connection refused/timeout throws exception.

      bool connected = response.statusCode >= 200 && response.statusCode < 500;
      expect(
        connected,
        true,
        reason:
            'Server reachable but returned error code: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        print('Connection Successful! Data received.');
      } else {
        print(
          'Connection Successful! Server responded with code: ${response.statusCode}',
        );
      }
    } catch (e) {
      fail('Could not connect to backend: $e');
    }
  });
}
