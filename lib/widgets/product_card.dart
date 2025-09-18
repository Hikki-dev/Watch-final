import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/price_text.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.onAddToCart, required this.onOpen});

  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _ProductImage(asset: product.imageAsset, heroTag: product.id),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              PriceText(product.price),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onAddToCart,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Add to cart'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.asset, required this.heroTag});
  final String asset;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: FutureBuilder(
        future: _assetExists(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done || snapshot.data == false) {
            return const Center(child: Icon(Icons.watch_outlined, size: 48));
          }
          return Image.asset(asset, fit: BoxFit.cover);
        },
      ),
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
