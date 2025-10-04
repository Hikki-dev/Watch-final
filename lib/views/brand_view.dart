// lib/views/brand_view.dart
import 'package:flutter/material.dart';
import '../controllers/app_controller.dart';
import '../widgets/watch_card.dart';
import 'watch_detail_view.dart';

class BrandView extends StatelessWidget {
  final AppController controller;
  final String brandName;

  const BrandView({
    super.key,
    required this.controller,
    required this.brandName,
  });

  @override
  Widget build(BuildContext context) {
    final watches = controller.getWatchesByBrand(brandName);

    return Scaffold(
      appBar: AppBar(title: Text(brandName)),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        itemCount: watches.length,
        itemBuilder: (context, index) {
          final watch = watches[index];
          return WatchCard(
            watch: watch,
            controller: controller,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    WatchDetailView(controller: controller, watchId: watch.id),
              ),
            ),
          );
        },
      ),
    );
  }
}
