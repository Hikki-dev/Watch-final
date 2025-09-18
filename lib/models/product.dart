class Product {
  final String id;
  final String brandId; // relates to Brand.id
  final String name;
  final double price;
  final String imageAsset; // 'assets/images/products/...'

  const Product({
    required this.id,
    required this.brandId,
    required this.name,
    required this.price,
    required this.imageAsset,
  });

  Product copyWith({
    String? id,
    String? brandId,
    String? name,
    double? price,
    String? imageAsset,
  }) {
    return Product(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      name: name ?? this.name,
      price: price ?? this.price,
      imageAsset: imageAsset ?? this.imageAsset,
    );
  }
}