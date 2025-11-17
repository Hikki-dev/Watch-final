// lib/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. Import Provider
import '../controllers/app_controller.dart';
import '../models/brand.dart';
import 'search_view.dart';
import 'cart_view.dart';
import 'profile_view.dart';

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
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (i) => setState(() => _currentIndex = i),
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.search),
                  label: Text('Search'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.shopping_cart),
                  label: Text('Cart'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  label: Text('Profile'),
                ),
              ],
            ),
            const VerticalDivider(width: 1),
            // 4. Use a Consumer to show a loading spinner
            //    while the controller fetches data.
            Consumer<AppController>(
              builder: (context, controller, child) {
                return controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Expanded(child: screens[_currentIndex]);
              },
            ),
          ],
        ),
      );
    }

    // PHONE LAYOUT - Bottom Navigation
    return Scaffold(
      // 4. Use a Consumer here as well for the phone layout
      body: Consumer<AppController>(
        builder: (context, controller, child) {
          return controller.isLoading
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
// 5. This child widget also no longer takes a controller
class BrandGridScreen extends StatelessWidget {
  const BrandGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We can still get the controller here if we need it,
    // but this specific widget only needs the static 'brands' list.
    // final controller = context.watch<AppController>();

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
      appBar: AppBar(title: const Text('Watch Brands')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: brands.length,
        itemBuilder: (context, index) {
          final brand = brands[index];
          return Card(
            child: InkWell(
              onTap: () {
                // 6. Navigate to BrandView. BrandView will get
                //    the controller from Provider itself.
                Navigator.pushNamed(context, '/brand', arguments: brand.name);
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
                        child: Image.asset(
                          brand.logoPath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint('❌ Failed to load: ${brand.logoPath}');
                            debugPrint('Brand: ${brand.name}');
                            return const Icon(Icons.watch, size: 60);
                          },
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
