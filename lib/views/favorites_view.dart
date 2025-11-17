// lib/views/favorites_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. Import Provider
import '../controllers/app_controller.dart';
import '../widgets/watch_card.dart';
import 'watch_detail_view.dart';

// 2. Change to a StatelessWidget
class FavoritesView extends StatelessWidget {
  // 3. Remove controller from constructor
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    // 4. Get controller from Provider using .watch()
    final controller = context.watch<AppController>();
    final favoriteWatches = controller.getFavoriteWatches();

    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: favoriteWatches.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the heart icon on watches you like',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemCount: favoriteWatches.length,
              itemBuilder: (context, index) {
                final watch = favoriteWatches[index];
                return WatchCard(
                  watch: watch,
                  // 5. Remove controller from WatchCard
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // 6. Remove controller from WatchDetailView
                        builder: (context) =>
                            WatchDetailView(watchId: watch.id),
                      ),
                    );
                    // 7. No .then((_) => setState(() {})) needed
                  },
                );
              },
            ),
    );
  }
}
