// lib/views/profile_view.dart
import 'package:flutter/material.dart';
import '../controllers/app_controller.dart';
import 'favorites_view.dart';

class ProfileView extends StatelessWidget {
  final AppController controller;
  final Function(ThemeMode)? onThemeChanged;
  final ThemeMode? currentThemeMode;
  final VoidCallback? onNavigateToCart;

  const ProfileView({
    super.key,
    required this.controller,
    this.onThemeChanged,
    this.currentThemeMode,
    this.onNavigateToCart,
  });

  @override
  Widget build(BuildContext context) {
    final user = controller.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              controller.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.email,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // Stats - Clickable and Auto-updating
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap:
                            onNavigateToCart ??
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Navigate to Home and tap Cart tab',
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  '${controller.cart.itemCount}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Cart Items',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FavoritesView(controller: controller),
                            ),
                          );
                        },
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  '${controller.getFavoriteWatches().length}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Favorites',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Theme Selector
                if (onThemeChanged != null && currentThemeMode != null) ...[
                  const Text(
                    'Theme',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text('Light'),
                          icon: Icon(Icons.light_mode),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text('Dark'),
                          icon: Icon(Icons.dark_mode),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text('System'),
                          icon: Icon(Icons.phone_android),
                        ),
                      ],
                      selected: {currentThemeMode!},
                      onSelectionChanged: (selected) {
                        if (selected.isNotEmpty) {
                          onThemeChanged?.call(selected.first);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Options
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.shopping_bag),
                    title: const Text('Order History'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Show coming soon message for now
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Order history coming soon'),
                        ),
                      );
                    },
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Show coming soon message for now
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Settings coming soon')),
                      );
                    },
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text('Help'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Show help dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Help & Support'),
                          content: const Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Contact us:'),
                              SizedBox(height: 8),
                              Text('Email: support@watchstore.com'),
                              Text('Phone: 1-800-WATCHES'),
                              SizedBox(height: 16),
                              Text('Hours: 9 AM - 5 PM EST'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
