// lib/widgets/watch_card.dart
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
          padding: const EdgeInsets.all(12),
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
                  child: Icon(Icons.watch, size: 50, color: Colors.grey),
                ),
              ),
              SizedBox(height: 12),

              // Watch info
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        watch.brand,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),

                    // Watch name
                    Text(
                      watch.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),

                    // Price and buttons row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            watch.displayPrice,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        // Favorite button
                        ListenableBuilder(
                          listenable: controller,
                          builder: (context, child) {
                            final isFav = controller.isFavorite(watch.id);
                            return IconButton(
                              onPressed: () =>
                                  controller.toggleFavorite(watch.id),
                              icon: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? Colors.red : null,
                                size: 20,
                              ),
                              constraints: BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: EdgeInsets.zero,
                            );
                          },
                        ),
                      ],
                    ),

                    // Add to cart button
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: FilledButton(
                        onPressed: () {
                          controller.addToCart(watch);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${watch.displayName} added to cart',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.zero,
                          textStyle: TextStyle(fontSize: 12),
                        ),
                        child: Text('Add to Cart'),
                      ),
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
