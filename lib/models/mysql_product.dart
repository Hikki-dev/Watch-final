class MysqlProduct {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final int stock;

  MysqlProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.stock,
  });

  factory MysqlProduct.fromJson(Map<String, dynamic> json) {
    // Determine image URL: Use 'image' or 'image_url' field, or fallback
    String? img = json['image'] ?? json['image_url'];

    // If image is a relative path (not starting with http), prepend the Base URL
    if (img != null && !img.startsWith('http')) {
      // Use the domain from ApiService, removing '/api' if present or just accessing the root
      // Assuming ApiService.baseUrl is the root "https://...app".
      // If Laravel returns "storage/img.jpg", we need "https://...app/storage/img.jpg"
      // Note: We need to import ApiService for this.

      // Hardcoding the domain here or importing ApiService is fine.
      // Let's use the explicit string to avoid circular dependency issues if ApiService imports this model.
      const baseUrl = 'https://laravel-watch-production.up.railway.app';

      // Ensure we don't double slash
      if (img.startsWith('/')) {
        img = '$baseUrl$img';
      } else {
        img = '$baseUrl/$img';
      }
    }

    return MysqlProduct(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? 'Unknown Product',
      description: json['description'] ?? '',
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price'].toString()) ?? 0.0,
      imageUrl: img,
      stock: json['stock'] is int
          ? json['stock']
          : int.tryParse(json['stock'].toString()) ?? 0,
    );
  }
}
