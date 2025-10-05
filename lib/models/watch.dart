// lib/models/watch.dart - FIXED
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
    required this.imagePath, // Now required
  });

  String get displayPrice => '\$${price.toStringAsFixed(2)}';
  String get displayName => '$brand $name';
}
