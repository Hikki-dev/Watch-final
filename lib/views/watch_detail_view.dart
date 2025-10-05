// lib/views/watch_detail_view.dart - SIMPLIFIED with orientation support
import 'package:flutter/material.dart';
import '../controllers/app_controller.dart';

class WatchDetailView extends StatelessWidget {
  final AppController controller;
  final String watchId;

  const WatchDetailView({
    super.key,
    required this.controller,
    required this.watchId,
  });

  @override
  Widget build(BuildContext context) {
    final watch = controller.getWatchById(watchId);
    if (watch == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Not Found')),
        body: Center(child: Text('Watch not found')),
      );
    }

    final orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: AppBar(
        title: Text(watch.name),
        actions: [
          IconButton(
            icon: Icon(
              controller.isFavorite(watch.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: controller.isFavorite(watch.id) ? Colors.red : null,
            ),
            onPressed: () {
              controller.toggleFavorite(watch.id);
              (context as Element).markNeedsBuild(); // Simple rebuild
            },
          ),
        ],
      ),
      body: orientation == Orientation.landscape
          ? _buildLandscape(context, watch)
          : _buildPortrait(context, watch),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: FilledButton(
          onPressed: () {
            controller.addToCart(watch);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Added to cart')));
          },
          child: Text('Add to Cart'),
        ),
      ),
    );
  }

  // PORTRAIT LAYOUT
  Widget _buildPortrait(BuildContext context, watch) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
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
              child: watch.imagePath != null && watch.imagePath!.isNotEmpty
                  ? Image.asset(
                      watch.imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('❌ Detail view failed: ${watch.imagePath}');
                        debugPrint('Error: $error');
                        return Center(
                          child: Icon(
                            Icons.watch,
                            size: 120,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Icon(Icons.watch, size: 120, color: Colors.grey),
                    ),
            ),
          ),
          SizedBox(height: 24),

          // Info
          Row(
            children: [
              Chip(label: Text(watch.brand)),
              Spacer(),
              Text(
                watch.displayPrice,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            watch.name,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(watch.category),
          SizedBox(height: 24),

          // Description
          Text(
            'Description',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(watch.description),
          SizedBox(height: 80),
        ],
      ),
    );
  }

  // LANDSCAPE LAYOUT - Side by side
  Widget _buildLandscape(BuildContext context, watch) {
    return Row(
      children: [
        // Left - Image
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: watch.imagePath != null && watch.imagePath!.isNotEmpty
                    ? Image.asset(
                        watch.imagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint(
                            '❌ Landscape view failed: ${watch.imagePath}',
                          );
                          debugPrint('Error: $error');
                          return Center(
                            child: Icon(
                              Icons.watch,
                              size: 120,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Icon(Icons.watch, size: 120, color: Colors.grey),
                      ),
              ),
            ),
          ),
        ),
        // Right - Details
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Chip(label: Text(watch.brand)),
                    Spacer(),
                    Text(
                      watch.displayPrice,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  watch.name,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(watch.category),
                SizedBox(height: 24),
                Text(
                  'Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(watch.description),
                SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
