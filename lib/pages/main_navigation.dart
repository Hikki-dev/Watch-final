// lib/pages/main_navigation.dart
import 'package:flutter/material.dart';
import '../app_state.dart';
import 'home_page.dart';
import 'search_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';

class MainNavigation extends StatefulWidget {
  final VoidCallback onLogout;

  const MainNavigation({super.key, required this.onLogout});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const SearchPage(),
      const CartPage(),
      ProfilePage(onLogout: widget.onLogout),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onItemTapped,
        elevation: 8,
        destinations: [
          const NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          const NavigationDestination(
            selectedIcon: Icon(Icons.search),
            icon: Icon(Icons.search_outlined),
            label: 'Search',
          ),
          NavigationDestination(
            selectedIcon: const Icon(Icons.shopping_cart),
            icon: Badge(
              label: Text('${appState.cartItemCount}'),
              isLabelVisible: appState.cartItemCount > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            label: 'Cart',
          ),
          const NavigationDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outlined),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
