// lib/views/profile_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../services/auth_service.dart';
import 'favorites_view.dart';

class ProfileView extends StatelessWidget {
  final Function(ThemeMode)? onThemeChanged;
  final ThemeMode? currentThemeMode;
  final VoidCallback? onNavigateToCart;

  const ProfileView({
    super.key,
    this.onThemeChanged,
    this.currentThemeMode,
    this.onNavigateToCart,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final authService = context.read<AuthService>();

    if (controller.currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = controller.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();

              // --- 1. FIX: Add mounted check ---
              if (!context.mounted) return;

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InkWell(
              onTap: () async {
                final file = await controller.pickProfileImage();

                // --- 2. FIX: Add mounted check ---
                if (!context.mounted) return;

                if (file != null) {
                  // 1. Call the new DB upload/save method
                  controller.updateProfilePicture(file);

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image upload started...')),
                  );
                }
              },
              child: CircleAvatar(
                // <-- MODIFIED: To display the image from the URL
                radius: 50,
                // Display network image if URL is present
                backgroundImage: user.profileImagePath != null
                    ? NetworkImage(user.profileImagePath!)
                    : null,
                // Show placeholder icons only if no image URL is present
                child: user.profileImagePath == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person, size: 40),
                          Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.black45,
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              user.email,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // ... (Stats Row - No async calls here, no change needed) ...
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onNavigateToCart, // Use the passed-in callback
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
                          // This is now fixed because FavoritesView is updated
                          builder: (context) => const FavoritesView(),
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

            // --- GEOLOCATION TILE (NEW) ---
            Card(
              child: FutureBuilder<String>(
                // Fetch the current location address
                future: controller.getCurrentLocationAddress(),
                builder: (context, snapshot) {
                  return ListTile(
                    leading: const Icon(Icons.location_on),
                    title: const Text('Current Location (Geolocation)'),
                    trailing: Text(
                      snapshot.connectionState == ConnectionState.waiting
                          ? 'Fetching...'
                          : snapshot.data ?? 'N/A',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // --- END GEOLOCATION TILE ---

            // ... (Theme Selector - No async calls, no change) ...
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

            // ... (Battery Tile - No async calls, no change) ...
            Card(
              child: FutureBuilder<int>(
                future: controller.getBatteryLevel(),
                builder: (context, snapshot) {
                  final level = snapshot.data;
                  return ListTile(
                    leading: const Icon(Icons.battery_std),
                    title: const Text('Battery Level'),
                    trailing: Text(
                      snapshot.connectionState == ConnectionState.waiting
                          ? '...'
                          : (level != null ? '$level%' : 'N/A'),
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),

            // ... (Options ListTiles - No async calls, no change) ...
            Card(
              child: ListTile(
                leading: const Icon(Icons.shopping_bag),
                title: const Text('Order History'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order history coming soon')),
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
      ),
    );
  }
}
