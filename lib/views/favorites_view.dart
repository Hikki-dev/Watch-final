// lib/views/favorites_view.dart
import 'package:flutter/material.dart';
import '../controllers/app_controller.dart';
import '../widgets/watch_card.dart';
import 'watch_detail_view.dart';

class FavoritesView extends StatefulWidget {
  final AppController controller;

  const FavoritesView({super.key, required this.controller});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  @override
  Widget build(BuildContext context) {
    final favoriteWatches = widget.controller.getFavoriteWatches();

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
                  controller: widget.controller,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WatchDetailView(
                          controller: widget.controller,
                          watchId: watch.id,
                        ),
                      ),
                    ).then((_) => setState(() {})); // Refresh when returning
                  },
                );
              },
            ),
    );
  }
}
