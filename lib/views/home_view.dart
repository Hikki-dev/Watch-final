// lib/views/home_view.dart - SIMPLIFIED with responsive layout
import 'package:flutter/material.dart';
import '../controllers/app_controller.dart';
import 'search_view.dart';
import 'cart_view.dart';
import 'profile_view.dart';

class HomeView extends StatefulWidget {
  final AppController controller;

  const HomeView({super.key, required this.controller});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      BrandGridScreen(controller: widget.controller),
      SearchView(controller: widget.controller),
      CartView(controller: widget.controller),
      ProfileView(controller: widget.controller),
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
              destinations: [
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
            VerticalDivider(width: 1),
            Expanded(child: screens[_currentIndex]),
          ],
        ),
      );
    }

    // PHONE LAYOUT - Bottom Navigation
    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// Brand Grid Screen
class BrandGridScreen extends StatelessWidget {
  final AppController controller;

  const BrandGridScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final brands = controller.getBrands();
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
      appBar: AppBar(title: Text('Watch Brands')),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
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
                // VANILLA NAVIGATION
                Navigator.pushNamed(context, '/brand', arguments: brand);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Brand logo image
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Image.asset(
                        'lib/images/brands/${brand.toLowerCase().replaceAll(' ', '_')}.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.watch, size: 60);
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    brand,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
