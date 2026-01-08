// lib/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. Import Provider
import '../controllers/app_controller.dart';
import '../models/brand.dart';
import 'search_view.dart';
import 'cart_view.dart';
import 'profile_view.dart';
import '../widgets/universal_image.dart';
import 'mysql_products_view.dart';

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
      appBar: AppBar(
        title: const Text('Watch Brands'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dns),
            tooltip: 'SSP Integration (MySQL)',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MysqlProductsView()),
              );
            },
          ),
        ],
      ),
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
                        child: UniversalImage(
                          imagePath: brand.logoPath,
                          fit: BoxFit.contain,
                          errorWidget: const Icon(Icons.watch, size: 60),
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
