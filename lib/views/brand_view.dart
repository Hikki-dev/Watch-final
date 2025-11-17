import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. Import Provider
import '../controllers/app_controller.dart';
import '../widgets/watch_card.dart';
import 'watch_detail_view.dart';

class BrandView extends StatelessWidget {
  // 2. Remove controller from constructor
  final String brandName;

  const BrandView({super.key, required this.brandName});

  @override
  Widget build(BuildContext context) {
    // 3. Get controller from Provider
    final controller = context.watch<AppController>();
    final watches = controller.getWatchesByBrand(brandName);

    return Scaffold(
      appBar: AppBar(title: Text(brandName)),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
            // 4. Remove controller from WatchCard
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                // 5. WatchDetailView will get controller from Provider
                builder: (context) => WatchDetailView(watchId: watch.id),
              ),
            ),
          );
        },
      ),
    );
  }
}
