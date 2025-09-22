// lib/pages/product_detail_page.dart
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models/product.dart';
import '../models/brand.dart';
import '../widgets/price_text.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.productId});
  final String productId;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final Product? product = app.products.getById(widget.productId);
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Not found')),
        body: const Center(child: Text('Product not found')),
      );
    }

    final brand = brands.firstWhere(
      (b) => b.id == product.brandId,
      orElse: () => const Brand(id: '', name: 'Unknown', logoAsset: ''),
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, product, app, brand),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: isLandscape
                  ? _buildLandscapeLayout(context, product, app, brand)
                  : _buildPortraitLayout(context, product, app, brand),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, product, app),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    Product product,
    AppState app,
    Brand brand,
  ) {
    final isFavorite = app.isFavorite(product.id);

    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: _DetailImage(asset: product.imageAsset),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            app.toggleFavorite(product.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isFavorite ? 'Removed from favorites' : 'Added to favorites',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(isFavorite),
              color: isFavorite ? Colors.red : null,
            ),
          ),
        ),
        IconButton(
          onPressed: () => _showShareDialog(context, product),
          icon: const Icon(Icons.share),
        ),
      ],
    );
  }

  Widget _buildPortraitLayout(
    BuildContext context,
    Product product,
    AppState app,
    Brand brand,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductHeader(context, product, brand),
          const SizedBox(height: 16),
          _buildProductDescription(context, product),
          const SizedBox(height: 24),
          _buildSpecifications(context, product),
          const SizedBox(height: 24),
          _buildRelatedProducts(context, app, product),
          const SizedBox(height: 100), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    Product product,
    AppState app,
    Brand brand,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductHeader(context, product, brand),
                const SizedBox(height: 16),
                _buildProductDescription(context, product),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSpecifications(context, product),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductHeader(
    BuildContext context,
    Product product,
    Brand brand,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            brand.name,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Product name
        Text(
          product.name,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Category and price row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                product.category,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Spacer(),
            PriceText(product.price),
          ],
        ),
        const SizedBox(height: 12),

        // Rating (mock)
        Row(
          children: [
            ...List.generate(
              5,
              (i) => Icon(
                i < 4 ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Text('4.0 (128 reviews)'),
          ],
        ),
      ],
    );
  }

  Widget _buildProductDescription(BuildContext context, Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          product.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
      ],
    );
  }

  Widget _buildSpecifications(BuildContext context, Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Specifications',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSpecRow('Movement', 'Automatic'),
                _buildSpecRow('Case Material', 'Stainless Steel'),
                _buildSpecRow('Case Diameter', '42mm'),
                _buildSpecRow('Water Resistance', '300m'),
                _buildSpecRow('Crystal', 'Sapphire'),
                _buildSpecRow('Power Reserve', '70 hours'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildRelatedProducts(
    BuildContext context,
    AppState app,
    Product product,
  ) {
    final relatedProducts = app.products
        .getAll(brandId: product.brandId)
        .where((p) => p.id != product.id)
        .take(3)
        .toList();

    if (relatedProducts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'More from ${brands.firstWhere((b) => b.id == product.brandId).name}',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: relatedProducts.length,
            itemBuilder: (context, index) {
              final relatedProduct = relatedProducts[index];
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  child: InkWell(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductDetailPage(productId: relatedProduct.id),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.watch, size: 40),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            relatedProduct.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          PriceText(relatedProduct.price),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, Product product, AppState app) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Quantity selector
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      // Decrease quantity logic
                    },
                    icon: const Icon(Icons.remove),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '1',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Increase quantity logic
                    },
                    icon: const Icon(Icons.add),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Add to cart button
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  app.addToCart(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} added to cart'),
                      action: SnackBarAction(
                        label: 'View Cart',
                        onPressed: () {
                          Navigator.pop(context);
                          // Navigate to cart tab
                        },
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text(
                  'Add to Cart',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showShareDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Product'),
        content: Text('Share ${product.name} with friends and family!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share link copied to clipboard')),
              );
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }
}

class _DetailImage extends StatelessWidget {
  const _DetailImage({required this.asset});
  final String asset;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _assetExists(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            snapshot.data == false) {
          return const Center(
            child: Icon(Icons.watch_outlined, size: 120, color: Colors.grey),
          );
        }
        return Image.asset(asset, fit: BoxFit.contain);
      },
    );
  }

  Future<bool> _assetExists(BuildContext context) async {
    try {
      await DefaultAssetBundle.of(context).load(asset);
      return true;
    } catch (_) {
      return false;
    }
  }
}
