// lib/models/watch.dart
class Watch {
  final String id;
  final String name;
  final String brand;
  final double price;
  final String category;
  final String description;
  final String imagePath; // Made required (not nullable)

  Watch({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.category,
    required this.description,
    required this.imagePath,
  });

  String get displayPrice => '\$${price.toStringAsFixed(2)}';
  String get displayName => '$brand $name';

  // --- ADD THIS (FOR API & LOCAL DB) ---
  // Converts JSON (from API/DB) into a Watch object
  factory Watch.fromJson(Map<String, dynamic> json) {
    //
    // IMPORTANT:
    // You MUST match these string keys (e.g., 'product_name', 'brand_name')
    // to the exact keys your SSP API sends in its JSON response.
    //
    return Watch(
      id: json['id'].toString(), // 'id' or '_id'
      name: json['name'] ?? 'No Name', // 'name' or 'product_name'
      brand: json['brand'] ?? 'No Brand', // 'brand' or 'brand_name'
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] ?? 'Uncategorized',
      description: json['description'] ?? 'No description available.',
      imagePath:
          json['imagePath'] ??
          'assets/images/watches/ap-royal-oak-1.jpg', // A fallback
    );
  }

  // --- ADD THIS (FOR LOCAL DB) ---
  // Converts a Watch object into JSON to store in Hive
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'price': price,
      'category': category,
      'description': description,
      'imagePath': imagePath,
    };
  }
}
