// lib/views/watch_detail_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. Import Provider
import '../controllers/app_controller.dart';
import '../models/watch.dart'; // Import the Watch model

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
          IconButton(
            icon: Icon(
              // 4. Logic is the same, but .watch() makes it rebuild
              controller.isFavorite(watch.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: controller.isFavorite(watch.id) ? Colors.red : null,
            ),
            onPressed: () {
              // 5. Call controller (no setState or markNeedsBuild needed)
              controller.toggleFavorite(watch.id);
            },
          ),
        ],
      ),
      body: orientation == Orientation.landscape
          // 6. Pass the non-nullable watch to the build methods
          ? _buildLandscape(context, watch)
          : _buildPortrait(context, watch),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: () {
            controller.addToCart(watch);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Added to cart')));
          },
          child: const Text('Add to Cart'),
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
              child: Image.asset(
                watch.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('❌ Detail view failed: ${watch.imagePath}');
                  debugPrint('Error: $error');
                  return const Center(
                    child: Icon(Icons.watch, size: 120, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Info
          Row(
            children: [
              Chip(label: Text(watch.brand)),
              const Spacer(),
              Text(
                watch.displayPrice,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
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
                child: Image.asset(
                  watch.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('❌ Landscape view failed: ${watch.imagePath}');
                    debugPrint('Error: $error');
                    return const Center(
                      child: Icon(Icons.watch, size: 120, color: Colors.grey),
                    );
                  },
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
                    Text(
                      watch.displayPrice,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
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
