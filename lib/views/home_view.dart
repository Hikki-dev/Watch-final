// lib/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../models/brand.dart';
import '../models/watch.dart';
import '../theme/lux_theme.dart';
import '../widgets/lux_widgets.dart';
import '../widgets/universal_image.dart';
import 'search_view.dart';
import 'cart_view.dart';
import 'profile_view.dart';
import 'watch_detail_view.dart';

class HomeView extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final ThemeMode currentThemeMode;

  const HomeView({
    super.key,
    required this.onThemeChanged,
    required this.currentThemeMode,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  static const _tabs = <({IconData icon, String label})>[
    (icon: Icons.watch_later_outlined, label: 'Discover'),
    (icon: Icons.search, label: 'Search'),
    (icon: Icons.shopping_bag_outlined, label: 'Cart'),
    (icon: Icons.person_outline, label: 'Account'),
  ];

  @override
  Widget build(BuildContext context) {
    final screens = [
      BrandGridScreen(
        onThemeChanged: widget.onThemeChanged,
        currentThemeMode: widget.currentThemeMode,
      ),
      const SearchView(),
      const CartView(),
      ProfileView(
        onThemeChanged: widget.onThemeChanged,
        currentThemeMode: widget.currentThemeMode,
        onNavigateToCart: () => setState(() => _currentIndex = 2),
      ),
    ];

    final body = Selector<AppController, bool>(
      selector: (context, controller) => controller.isLoading,
      builder: (context, isLoading, child) {
        return isLoading
            ? const Center(child: CircularProgressIndicator())
            : AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: KeyedSubtree(
                  key: ValueKey(_currentIndex),
                  child: screens[_currentIndex],
                ),
              );
      },
    );

    // Tablet / desktop: top navigation bar
    if (MediaQuery.of(context).size.width > 600) {
      final c = context.lux;
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'LUXWATCH',
            style: TextStyle(letterSpacing: 6, fontSize: 22),
          ),
          actions: [
            for (var i = 0; i < _tabs.length; i++) ...[
              TextButton.icon(
                onPressed: () => setState(() => _currentIndex = i),
                icon: Icon(
                  _tabs[i].icon,
                  size: 20,
                  color: _currentIndex == i ? c.accent : c.mute,
                ),
                label: Text(
                  _tabs[i].label,
                  style: TextStyle(
                    color: _currentIndex == i ? c.accent : c.mute,
                    fontWeight:
                        _currentIndex == i ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            const SizedBox(width: 8),
            ThemeToggleButton(
              mode: widget.currentThemeMode,
              onChanged: widget.onThemeChanged,
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: body,
      );
    }

    // Phone: bottom navigation
    return Scaffold(
      body: body,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.lux.line)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          destinations: [
            for (final t in _tabs)
              NavigationDestination(icon: Icon(t.icon), label: t.label),
          ],
        ),
      ),
    );
  }
}

/// Discover: a featured piece, then the maisons.
class BrandGridScreen extends StatelessWidget {
  final Function(ThemeMode)? onThemeChanged;
  final ThemeMode? currentThemeMode;

  const BrandGridScreen({super.key, this.onThemeChanged, this.currentThemeMode});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final c = context.lux;
    final text = Theme.of(context).textTheme;

    // Brands that actually have products, known logos first.
    final Set<String> dbBrandNames = controller.allWatches
        .map((w) => w.brand.trim())
        .where((name) => name.isNotEmpty)
        .toSet();

    final List<Brand> visibleBrands = [];
    for (var name in dbBrandNames) {
      try {
        visibleBrands.add(
          brands.firstWhere((b) => b.name.toLowerCase() == name.toLowerCase()),
        );
      } catch (e) {
        // A brand added by a seller that has no bundled logo asset.
        visibleBrands.add(
          Brand(
            id: name.toLowerCase().replaceAll(' ', '_'),
            name: name,
            logoPath: '',
          ),
        );
      }
    }
    visibleBrands.sort((a, b) => a.name.compareTo(b.name));

    final Watch? featured = controller.allWatches.isEmpty
        ? null
        : controller.allWatches.firstWhere(
            (w) => w.isInStock,
            orElse: () => controller.allWatches.first,
          );

    final width = MediaQuery.of(context).size.width;
    final wide = width > 600;
    final columns = width > 900 ? 4 : (wide ? 3 : 2);

    return Scaffold(
      appBar: wide
          ? null
          : AppBar(
              title: const Text(
                'LUXWATCH',
                style: TextStyle(letterSpacing: 6, fontSize: 22),
              ),
              actions: [
                if (onThemeChanged != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: ThemeToggleButton(
                      mode: currentThemeMode ?? ThemeMode.light,
                      onChanged: onThemeChanged!,
                    ),
                  ),
              ],
            ),
      body: visibleBrands.isEmpty
          ? const Center(child: Text('No brands available'))
          : CustomScrollView(
              slivers: [
                if (featured != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, wide ? 16 : 20, 16, 8),
                      child: Reveal(child: _FeaturedWatch(watch: featured)),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, wide ? 20 : 28, 16, 12),
                    child: Reveal(
                      index: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Eyebrow('Maisons'),
                          const SizedBox(height: 6),
                          Text('Shop by brand', style: text.headlineMedium),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverGrid.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.05,
                    ),
                    itemCount: visibleBrands.length,
                    itemBuilder: (context, index) {
                      final brand = visibleBrands[index];
                      return Reveal(
                        index: 3 + index % 4,
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/brand',
                              arguments: brand.name,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(color: c.line),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: brand.logoPath.isEmpty
                                          ? Center(
                                              child: Icon(
                                                Icons.watch,
                                                size: 36,
                                                color: c.mute,
                                              ),
                                            )
                                          : UniversalImage(
                                              imagePath: brand.logoPath,
                                              fit: BoxFit.contain,
                                              errorWidget: Icon(
                                                Icons.watch,
                                                size: 36,
                                                color: c.mute,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    brand.name,
                                    style: text.titleLarge?.copyWith(
                                      fontSize: 19,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _FeaturedWatch extends StatelessWidget {
  final Watch watch;
  const _FeaturedWatch({required this.watch});

  @override
  Widget build(BuildContext context) {
    final c = context.lux;
    final text = Theme.of(context).textTheme;
    final wide = MediaQuery.of(context).size.width > 600;

    final photo = LuxStage(
      height: wide ? 180 : 260,
      child: Stack(
        fit: StackFit.expand,
        children: [
          UniversalImage(
            imagePath: watch.imagePath,
            fit: BoxFit.cover,
            errorWidget: Center(
              child: Icon(Icons.watch, size: 80, color: c.mute),
            ),
          ),
          Positioned(
            left: 16,
            top: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              color: c.panel.withValues(alpha: 0.9),
              child: Eyebrow('New arrival', color: c.accent),
            ),
          ),
        ],
      ),
    );

    final info = Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Eyebrow(watch.brand),
                const SizedBox(height: 4),
                Text(
                  watch.name,
                  style: text.headlineSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          PriceText(watch.displayPrice),
        ],
      ),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WatchDetailView(watchId: watch.id),
          ),
        ),
        child: wide
            ? SizedBox(
                height: 180,
                child: Row(
                  children: [
                    SizedBox(width: 360, child: photo),
                    Expanded(child: Center(child: info)),
                  ],
                ),
              )
            : Column(children: [photo, info]),
      ),
    );
  }
}
