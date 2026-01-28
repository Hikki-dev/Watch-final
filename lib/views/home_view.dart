// lib/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. Import Provider
import '../controllers/app_controller.dart';
import '../models/brand.dart';
import 'search_view.dart';
import 'cart_view.dart';
import 'profile_view.dart';
import '../widgets/universal_image.dart';

class HomeView extends StatefulWidget {
  // 2. The controller is no longer passed in
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

  @override
  Widget build(BuildContext context) {
    // 3. The list of screens no longer passes the controller
    final screens = [
      const BrandGridScreen(), // No controller needed
      const SearchView(), // No controller needed
      const CartView(), // No controller needed
      ProfileView(
        // ProfileView gets its controller from Provider,
        // but we still pass the theme/navigation callbacks
        onThemeChanged: widget.onThemeChanged,
        currentThemeMode: widget.currentThemeMode,
        onNavigateToCart: () {
          // Switch to cart tab
          setState(() {
            _currentIndex = 2; // Cart is at index 2
          });
        },
      ),
    ];

    // Check if tablet/landscape mode
    final isWide = MediaQuery.of(context).size.width > 600;

    if (isWide) {
      // TABLET LAYOUT - Navigation Rail (side)
      // TABLET/DESKTOP LAYOUT - Top Navigation Bar
      return Scaffold(
        appBar: AppBar(
          title: const Text('Watch Store'),
          actions: [
            TextButton.icon(
              onPressed: () => setState(() => _currentIndex = 0),
              icon: Icon(
                Icons.home,
                color: _currentIndex == 0
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
              label: Text(
                'Home',
                style: TextStyle(
                  color: _currentIndex == 0
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                  fontWeight: _currentIndex == 0
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () => setState(() => _currentIndex = 1),
              icon: Icon(
                Icons.search,
                color: _currentIndex == 1
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
              label: Text(
                'Search',
                style: TextStyle(
                  color: _currentIndex == 1
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                  fontWeight: _currentIndex == 1
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () => setState(() => _currentIndex = 2),
              icon: Icon(
                Icons.shopping_cart,
                color: _currentIndex == 2
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
              label: Text(
                'Cart',
                style: TextStyle(
                  color: _currentIndex == 2
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                  fontWeight: _currentIndex == 2
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () => setState(() => _currentIndex = 3),
              icon: Icon(
                Icons.person,
                color: _currentIndex == 3
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
              label: Text(
                'Profile',
                style: TextStyle(
                  color: _currentIndex == 3
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                  fontWeight: _currentIndex == 3
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: Selector<AppController, bool>(
          selector: (context, controller) => controller.isLoading,
          builder: (context, isLoading, child) {
            return isLoading
                ? const Center(child: CircularProgressIndicator())
                : screens[_currentIndex];
          },
        ),
      );
    }

    // PHONE LAYOUT - Bottom Navigation
    return Scaffold(
      // 4. Use Selector to only rebuild when isLoading changes
      body: Selector<AppController, bool>(
        selector: (context, controller) => controller.isLoading,
        builder: (context, isLoading, child) {
          return isLoading
              ? const Center(child: CircularProgressIndicator())
              : screens[_currentIndex];
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// Brand Grid Screen - FIXED
class BrandGridScreen extends StatelessWidget {
  const BrandGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We need the controller to check for available products
    final controller = context.watch<AppController>();

    // Dynamic Brand Generation:
    // 1. Get all unique brand names from the actual database products
    final Set<String> dbBrandNames = controller.allWatches
        .map((w) => w.brand.trim())
        .where((name) => name.isNotEmpty)
        .toSet();

    // 2. Build the final display list
    final List<Brand> visibleBrands = [];

    // Prioritize the Static "Known" Brands (so they have nice logos)
    for (var name in dbBrandNames) {
      // Check if we have a static definition for this brand (case-insensitive)
      try {
        final knownBrand = brands.firstWhere(
          (b) => b.name.toLowerCase() == name.toLowerCase(),
        );
        visibleBrands.add(knownBrand);
      } catch (e) {
        // This is a NEW brand added by a seller (e.g. "Breitling")
        // We don't have a logo asset for it, so we create a dynamic placeholder
        visibleBrands.add(
          Brand(
            id: name.toLowerCase().replaceAll(' ', '_'),
            name: name,
            logoPath: '', // Empty path signals "Use Icon"
          ),
        );
      }
    }

    // Sort alphabetically for meaningful order
    visibleBrands.sort((a, b) => a.name.compareTo(b.name));

    // Use the brands constant from brand.dart
    final orientation = MediaQuery.of(context).orientation;
    final width = MediaQuery.of(context).size.width;

    // Responsive columns
    int columns = 2; // default
    if (width > 600) {
      columns = 4; // tablet
    } else if (orientation == Orientation.landscape) {
      columns = 3; // phone landscape
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Watch Brands'), actions: const []),
      body: visibleBrands.isEmpty
          ? const Center(child: Text('No brands available'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: visibleBrands.length,
              itemBuilder: (context, index) {
                final brand = visibleBrands[index];
                return Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/brand',
                        arguments: brand.name,
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Brand logo image
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Hero(
                              tag: 'brand-${brand.name}',
                              child: brand.logoPath.isEmpty
                                  ? CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.1),
                                      child: Text(
                                        brand.name[0].toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    )
                                  : UniversalImage(
                                      imagePath: brand.logoPath,
                                      fit: BoxFit.contain,
                                      errorWidget: const Icon(
                                        Icons.watch,
                                        size: 60,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          brand.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
