// lib/views/home_view.dart
import 'package:flutter/material.dart';
import '../controllers/app_controller.dart';
import 'brand_view.dart';
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
      BrandListView(controller: widget.controller),
      SearchView(controller: widget.controller),
      CartView(controller: widget.controller),
      ProfileView(controller: widget.controller),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, child) {
          return NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) =>
                setState(() => _currentIndex = index),
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
              NavigationDestination(
                icon: Badge(
                  label: Text('${widget.controller.cart.itemCount}'),
                  isLabelVisible: widget.controller.cart.isNotEmpty,
                  child: Icon(Icons.shopping_cart_outlined),
                ),
                selectedIcon: Badge(
                  label: Text('${widget.controller.cart.itemCount}'),
                  isLabelVisible: widget.controller.cart.isNotEmpty,
                  child: Icon(Icons.shopping_cart),
                ),
                label: 'Cart',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outlined),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          );
        },
      ),
    );
  }
}

// Brand List View
class BrandListView extends StatelessWidget {
  final AppController controller;

  const BrandListView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final brands = controller.getBrands();

    return Scaffold(
      appBar: AppBar(title: Text('Watch Brands')),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: brands.length,
        itemBuilder: (context, index) {
          final brand = brands[index];
          return Card(
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BrandView(controller: controller, brandName: brand),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.watch, size: 60),
                  SizedBox(height: 12),
                  Text(
                    brand,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
