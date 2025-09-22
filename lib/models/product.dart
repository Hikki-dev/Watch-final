// lib/models/product.dart
class Product {
  final String id;
  final String brandId; // relates to Brand.id
  final String name;
  final double price;
  final String description;
  final String imageAsset; // 'assets/images/products/...'
  final String category;

  const Product({
    required this.id,
    required this.brandId,
    required this.name,
    required this.price,
    required this.description,
    required this.imageAsset,
    required this.category,
  });

  Product copyWith({
    String? id,
    String? brandId,
    String? name,
    double? price,
    String? description,
    String? imageAsset,
    String? category,
  }) {
    return Product(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      imageAsset: imageAsset ?? this.imageAsset,
      category: category ?? this.category,
    );
  }
}
