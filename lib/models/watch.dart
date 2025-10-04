// lib/models/watch.dart - WITH IMAGES
class Watch {
  final String id;
  final String name;
  final String brand;
  final double price;
  final String category;
  final String description;
  final String? imagePath; // Add this field

  Watch({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.category,
    required this.description,
    this.imagePath, // Make it optional for backwards compatibility
  });

  String get displayPrice => '\$${price.toStringAsFixed(2)}';
  String get displayName => '$brand $name';
}
