// lib/widgets/watch_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/watch.dart';
import '../controllers/app_controller.dart';
import '../theme/lux_theme.dart';
import 'lux_widgets.dart';
import 'universal_image.dart';
import 'animated_favorite_button.dart';

/// Catalogue card: photograph on a studio backdrop, then brand, name and price.
class WatchCard extends StatelessWidget {
  final Watch watch;
  final VoidCallback onTap;

  const WatchCard({super.key, required this.watch, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<AppController>();
    final c = context.lux;
    final text = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: LuxStage(
                  child: SizedBox.expand(
                    child: UniversalImage(
                      imagePath: watch.imagePath,
                      fit: BoxFit.cover,
                      errorWidget: Center(
                        child: Icon(Icons.watch, size: 40, color: c.mute),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Eyebrow(watch.brand),
                    const SizedBox(height: 4),
                    Text(
                      watch.name,
                      style: text.titleLarge?.copyWith(fontSize: 20),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    PriceText(watch.displayPrice, size: 13),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 30,
                            child: OutlinedButton(
                              onPressed: () {
                                controller.addToCart(watch);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Added to cart'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 30),
                                padding: EdgeInsets.zero,
                                textStyle: const TextStyle(
                                  fontFamily: LuxFonts.sans,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.4,
                                ),
                              ),
                              child: const Text('ADD'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: Consumer<AppController>(
                            builder: (context, appController, child) {
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
