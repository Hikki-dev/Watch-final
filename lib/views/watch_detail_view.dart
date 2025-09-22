// lib/views/watch_detail_view.dart
import 'package:flutter/material.dart';
import '../controllers/app_controller.dart';

class WatchDetailView extends StatelessWidget {
  final AppController controller;
  final String watchId;

  const WatchDetailView({super.key, required this.controller, required this.watchId});

  @override
  Widget build(BuildContext context) {
    final watch = controller.getWatchById(watchId);
    if (watch == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Watch Not Found')),
        body: Center(child: Text('Watch not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(watch.name),
        actions: [
          ListenableBuilder(
            listenable: controller,
            builder: (context, child) {
              final isFav = controller.isFavorite(watch.id);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : null,
                ),
                onPressed: () => controller.toggleFavorite(watch.id),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Watch Image
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.watch, size: 120, color: Colors.grey),
            ),
            SizedBox(height: 24),
            
            // Watch Info
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(watch.brand, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
                Spacer(),
                Text(watch.displayPrice, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
              ],
            ),
            SizedBox(height: 12),
            
            Text(watch.name, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(watch.category, style: TextStyle(fontSize: 12)),
            ),
            SizedBox(height: 24),
            
            // Description
            Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(watch.description, style: TextStyle(fontSize: 16, height: 1.5)),
            SizedBox(height: 32),
            
            // Specifications
            Text('Specifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSpecRow('Movement', 'Automatic'),
                    _buildSpecRow('Case Material', 'Stainless Steel'),
                    _buildSpecRow('Water Resistance', '100m'),
                    _buildSpecRow('Warranty', '2 Years'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        child: FilledButton(
          onPressed: () {
            controller.addToCart(watch);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${watch.displayName} added to cart')),
            );
          },
          child: Text('Add to Cart'),
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}