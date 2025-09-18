import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models/product.dart';
import '../widgets/price_text.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.productId});
  final String productId;

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final Product? product = app.products.getById(productId);

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Not found')),
        body: const Center(child: Text('Product not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Hero(
              tag: product.id,
              child: _DetailImage(asset: product.imageAsset),
            ),
          ),
          const SizedBox(height: 16),
          Text(product.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          PriceText(product.price),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => app.addToCart(product),
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Add to cart'),
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
        if (snapshot.connectionState != ConnectionState.done || snapshot.data == false) {
          return const Center(child: Icon(Icons.watch_outlined, size: 96));
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
