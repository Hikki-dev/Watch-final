import 'package:flutter/material.dart';
import '../app_state.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';

class BrandPage extends StatelessWidget {
  const BrandPage({super.key, required this.brandId, required this.brandName});
  final String brandId;
  final String brandName;

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final products = app.products.getAll(brandId: brandId);

    return Scaffold(
      appBar: AppBar(
        title: Text(brandName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: products.length,
          itemBuilder: (context, i) {
            final p = products[i];
            return ProductCard(
              product: p,
              onAddToCart: () => app.addToCart(p),
              onOpen: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProductDetailPage(productId: p.id)),
              ),
            );
          },
        ),
      ),
    );
  }
}
