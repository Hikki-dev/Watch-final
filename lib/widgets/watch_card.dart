// lib/widgets/watch_card.dart - FIXED VERSION
import 'package:flutter/material.dart';
import '../models/watch.dart';
import '../controllers/app_controller.dart';

class WatchCard extends StatelessWidget {
  final Watch watch;
  final AppController controller;
  final VoidCallback onTap;

  const WatchCard({
    super.key,
    required this.watch,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.watch, size: 40, color: Colors.grey),
                ),
              ),
              SizedBox(height: 8),

              // Watch info
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Brand badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        watch.brand,
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),

                    // Watch name - CONSTRAINED
                    Flexible(
                      child: Text(
                        watch.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 8,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 4),

                    // Price - SMALLER
                    Text(
                      watch.displayPrice,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 4),

                    // Buttons row - COMPACT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Add to cart button - SMALLER
                        Expanded(
                          child: SizedBox(
                            height: 24,
                            child: FilledButton(
                              onPressed: () {
                                controller.addToCart(watch);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${watch.displayName} added to cart',
                                    ),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              style: FilledButton.styleFrom(
                                padding: EdgeInsets.zero,
                                textStyle: TextStyle(fontSize: 10),
                              ),
                              child: Text('Add'),
                            ),
                          ),
                        ),
                        SizedBox(width: 4),
                        // Favorite button - SMALLER
                        ListenableBuilder(
                          listenable: controller,
                          builder: (context, child) {
                            final isFav = controller.isFavorite(watch.id);
                            return SizedBox(
                              width: 24,
                              height: 24,
                              child: IconButton(
                                onPressed: () =>
                                    controller.toggleFavorite(watch.id),
                                icon: Icon(
                                  isFav
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFav ? Colors.red : null,
                                  size: 20,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
