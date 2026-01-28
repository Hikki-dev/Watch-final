// lib/widgets/watch_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/watch.dart';
import '../controllers/app_controller.dart';
import 'universal_image.dart';
import 'animated_favorite_button.dart';

// 1. Changed to a StatelessWidget
class WatchCard extends StatelessWidget {
  final Watch watch;
  final VoidCallback onTap;

  const WatchCard({
    super.key,
    required this.watch,
    required this.onTap,
    // 2. The 'controller' parameter is removed
  });

  @override
  Widget build(BuildContext context) {
    // 3. Get the controller via context.read for actions
    final controller = context.read<AppController>();

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image (No change needed)
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: UniversalImage(
                      imagePath: watch.imagePath,
                      fit: BoxFit.cover,
                      errorWidget: const Center(
                        child: Icon(Icons.watch, size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Watch info (No change needed)
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        watch.brand,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Name
                    Text(
                      watch.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Price
                    Text(
                      watch.displayPrice,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const Spacer(),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 28,
                            child: FilledButton(
                              onPressed: () {
                                // 3. Use controller from context.read
                                controller.addToCart(watch);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Added to cart'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              style: FilledButton.styleFrom(
                                padding: EdgeInsets.zero,
                                textStyle: const TextStyle(fontSize: 11),
                              ),
                              child: const Text('Add'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 28,
                          height: 28,
                          // 4. Wrap the icon button in a Consumer
                          child: Consumer<AppController>(
                            builder: (context, appController, child) {
                              // 'appController' is the instance from Provider
                              final isFav = appController.isFavorite(watch.id);
                              return AnimatedFavoriteButton(
                                isFavorite: isFav,
                                onToggle: () =>
                                    appController.toggleFavorite(watch.id),
                                size: 18,
                              );
                            },
                          ),
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
