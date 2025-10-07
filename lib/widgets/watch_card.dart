// lib/widgets/watch_card.dart
import 'package:flutter/material.dart';
import '../models/watch.dart';
import '../controllers/app_controller.dart';

class WatchCard extends StatefulWidget {
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
  State<WatchCard> createState() => _WatchCardState();
}

class _WatchCardState extends State<WatchCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
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
                    child: Image.asset(
                      widget.watch.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('❌ Image failed: ${widget.watch.imagePath}');
                        return Center(
                          child: Icon(
                            Icons.watch,
                            size: 40,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),

              // Watch info
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand chip
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.watch.brand,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),

                    // Name
                    Text(
                      widget.watch.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),

                    // Price
                    Text(
                      widget.watch.displayPrice,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Spacer(),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 28,
                            child: FilledButton(
                              onPressed: () {
                                widget.controller.addToCart(widget.watch);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Added to cart'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              style: FilledButton.styleFrom(
                                padding: EdgeInsets.zero,
                                textStyle: TextStyle(fontSize: 11),
                              ),
                              child: Text('Add'),
                            ),
                          ),
                        ),
                        SizedBox(width: 4),
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: IconButton(
                            onPressed: () {
                              widget.controller.toggleFavorite(widget.watch.id);
                              setState(() {});
                            },
                            icon: Icon(
                              widget.controller.isFavorite(widget.watch.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                                  widget.controller.isFavorite(widget.watch.id)
                                  ? Colors.red
                                  : null,
                              size: 18,
                            ),
                            padding: EdgeInsets.zero,
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
