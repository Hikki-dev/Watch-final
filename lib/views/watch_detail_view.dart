// lib/views/watch_detail_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. Import Provider
import '../controllers/app_controller.dart';
import '../models/watch.dart'; // Import the Watch model
import '../widgets/universal_image.dart';
import '../widgets/animated_favorite_button.dart';

class WatchDetailView extends StatelessWidget {
  // 2. Remove controller from constructor
  final String watchId;

  const WatchDetailView({
    super.key,
    required this.watchId,
    // The 'controller' parameter is removed
  });

  @override
  Widget build(BuildContext context) {
    // 3. Get controller from Provider
    // We use .watch() so the widget rebuilds if the favorite status changes
    final controller = context.watch<AppController>();
    final Watch? watch = controller.getWatchById(watchId);

    if (watch == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Not Found')),
        body: const Center(child: Text('Watch not found')),
      );
    }

    final orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: AppBar(
        title: Text(watch.name),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: AnimatedFavoriteButton(
              isFavorite: controller.isFavorite(watch.id),
              onToggle: () => controller.toggleFavorite(watch.id),
              size: 24,
            ),
          ),
        ],
      ),
      body: orientation == Orientation.landscape
          ? _buildLandscape(context, watch)
          : _buildPortrait(context, watch),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: watch.isInStock
              ? () {
                  controller.addToCart(watch);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to cart')),
                  );
                }
              : null, // Disable if out of stock
          style: watch.isInStock
              ? null
              : ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.grey),
                ),
          child: Text(watch.isInStock ? 'Add to Cart' : 'Out of Stock'),
        ),
      ),
    );
  }

  // 7. Type the parameter as Watch
  Widget _buildPortrait(BuildContext context, Watch watch) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              // 8. No null check needed as imagePath is required
              child: UniversalImage(
                imagePath: watch.imagePath,
                fit: BoxFit.cover,
                errorWidget: const Center(
                  child: Icon(Icons.watch, size: 120, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Info
          Row(
            children: [
              Chip(label: Text(watch.brand)),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    watch.displayPrice,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${watch.stock} left',
                    style: TextStyle(
                      fontSize: 14,
                      color: watch.isInStock ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            watch.name,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(watch.category),
          const SizedBox(height: 24),

          // Description
          const Text(
            'Description',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(watch.description),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // 7. Type the parameter as Watch
  Widget _buildLandscape(BuildContext context, Watch watch) {
    return Row(
      children: [
        // Left - Image
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                // 8. No null check needed
                child: UniversalImage(
                  imagePath: watch.imagePath,
                  fit: BoxFit.cover,
                  errorWidget: const Center(
                    child: Icon(Icons.watch, size: 120, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Right - Details
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Chip(label: Text(watch.brand)),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          watch.displayPrice,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${watch.stock} left',
                          style: TextStyle(
                            fontSize: 14,
                            color: watch.isInStock ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  watch.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(watch.category),
                const SizedBox(height: 24),
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(watch.description),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
