import 'package:appcounter/pages/cart_page.dart';
import 'package:appcounter/pages/profile_page.dart';
import 'package:appcounter/pages/search_page.dart';
import 'package:appcounter/pages/shop_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Pages for each tab
  final List<Widget> _pages = [
    const ShopPage(),
    const SearchPage(),
    const CartPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getTitle(), // Dynamic title based on tab
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[500],
      ),

      // This is what makes the navigation bar actually change the page
      body: _pages[_selectedIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
            selectedIcon: Icon(Icons.home_filled),
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Search',
            selectedIcon: Icon(Icons.search_rounded),
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
            selectedIcon: Icon(Icons.shopping_cart_checkout),
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
            selectedIcon: Icon(Icons.person_outline),
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Shop';
      case 1:
        return 'Search';
      case 2:
        return 'Cart';
      case 3:
        return 'Profile';
      default:
        return 'Shop';
    }
  }
}
