// lib/models/watch.dart
class Watch {
  final String id;
  final String name;
  final String brand;
  final double price;
  final String category;
  final String description;

  Watch({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.category,
    required this.description,
  });

  String get displayPrice => '\$${price.toStringAsFixed(2)}';
  
  String get displayName => '$brand $name';
}