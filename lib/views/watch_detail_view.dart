// lib/views/watch_detail_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../models/watch.dart';
import '../theme/lux_theme.dart';
import '../widgets/animated_favorite_button.dart';
import '../widgets/lux_widgets.dart';
import '../widgets/spin_viewer.dart';
import '../widgets/universal_image.dart';
import 'cart_view.dart';

class WatchDetailView extends StatefulWidget {
  final String watchId;

  const WatchDetailView({super.key, required this.watchId});

  @override
  State<WatchDetailView> createState() => _WatchDetailViewState();
}

class _WatchDetailViewState extends State<WatchDetailView> {
  final SpinController _spin = SpinController();
  String _view = 'Angle';

  // Fractions of a full turn for the quick-view chips.
  static const _views = <String, double>{
    'Front': 0,
    'Angle': 0.9583,
    'Side': 0.25,
    'Back': 0.5,
  };

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final Watch? watch = controller.getWatchById(widget.watchId);

    if (watch == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Not Found')),
        body: const Center(child: Text('Watch not found')),
      );
    }

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final c = context.lux;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'Cart',
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartView()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: AnimatedFavoriteButton(
              isFavorite: controller.isFavorite(watch.id),
              onToggle: () => controller.toggleFavorite(watch.id),
              size: 24,
            ),
          ),
        ],
      ),
      body: isLandscape
          ? Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _gallery(context, watch),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _info(context, watch),
                  ),
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Reveal(child: _gallery(context, watch)),
                const SizedBox(height: 24),
                Reveal(index: 1, child: _info(context, watch)),
                const SizedBox(height: 24),
              ],
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
        decoration: BoxDecoration(
          color: c.bg,
          border: Border(top: BorderSide(color: c.line)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Eyebrow('Price'),
                  const SizedBox(height: 4),
                  PriceText(watch.displayPrice),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: FilledButton(
                  onPressed: watch.isInStock
                      ? () {
                          controller.addToCart(watch);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added to cart')),
                          );
                        }
                      : null,
                  child: Text(watch.isInStock ? 'ADD TO CART' : 'OUT OF STOCK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gallery(BuildContext context, Watch watch) {
    final c = context.lux;
    final hasSpin = watch.spinFrames.length >= 8;
    return Column(
      children: [
        LuxStage(
          height: 340,
          child: Stack(
            fit: StackFit.expand,
            children: [
              hasSpin
                  ? SpinViewer(
                      frames: watch.spinFrames,
                      controller: _spin,
                      fit: BoxFit.contain,
                    )
                  : UniversalImage(
                      imagePath: watch.imagePath,
                      fit: BoxFit.cover,
                      errorWidget: Center(
                        child: Icon(Icons.watch, size: 120, color: c.mute),
                      ),
                    ),
              if (hasSpin)
                Positioned(
                  left: 16,
                  bottom: 12,
                  child: const Eyebrow('Drag to rotate'),
                ),
            ],
          ),
        ),
        if (hasSpin) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final entry in _views.entries)
                ChoiceChip(
                  label: Text(entry.key),
                  selected: _view == entry.key,
                  onSelected: (_) {
                    setState(() => _view = entry.key);
                    _spin.goToFraction(entry.value);
                  },
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _info(BuildContext context, Watch watch) {
    final c = context.lux;
    final text = Theme.of(context).textTheme;

    Widget row(String label, String value) => Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: c.line)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: text.bodyMedium?.copyWith(color: c.mute)),
              Flexible(
                child: Text(
                  value,
                  style: text.bodyMedium,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BrandLogoPlate(brand: watch.brand, height: 44, width: 120),
        const SizedBox(height: 16),
        Text(watch.name, style: text.displaySmall),
        const SizedBox(height: 10),
        Row(
          children: [
            PriceText(watch.displayPrice, size: 20),
            const SizedBox(width: 14),
            StatusPill(
              watch.isInStock ? '${watch.stock} available' : 'Out of stock',
              kind: watch.isInStock ? PillKind.live : PillKind.rejected,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Description', style: text.titleLarge),
        const SizedBox(height: 8),
        Text(
          watch.description,
          style: text.bodyLarge?.copyWith(color: c.mute, height: 1.6),
        ),
        const SizedBox(height: 20),
        row('Brand', watch.brand),
        row('Availability', watch.isInStock ? 'In stock' : 'Out of stock'),
        Container(height: 1, color: c.line),
      ],
    );
  }
}
