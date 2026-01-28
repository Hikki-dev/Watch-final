// lib/views/profile_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart'; // Still needed for ImageSource enum
import '../controllers/app_controller.dart';
import '../services/auth_service.dart';
import 'favorites_view.dart';
import '../widgets/universal_image.dart';

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

  void _showImageSourceActionSheet(BuildContext parentContext) {
    final controller = parentContext.read<AppController>();
    showModalBottomSheet(
      context: parentContext,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  // Use parentContext here, as 'context' (sheet) is now unmounted
                  _pickAndUploadImage(
                    parentContext,
                    controller,
                    ImageSource.gallery,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  // Use parentContext here
                  _pickAndUploadImage(
                    parentContext,
                    controller,
                    ImageSource.camera,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadImage(
    BuildContext context,
    AppController controller,
    ImageSource source,
  ) async {
    // Determine context safely
    if (!context.mounted) return;

    // Call controller (which now handles everything)
    final String? error = await controller.pickAndUploadProfileImage(
      source: source,
    );

    if (context.mounted) {
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error), // Show specific error from backend
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditNameDialog(
    BuildContext context,
    AppController controller,
    String currentName,
  ) {
    final TextEditingController nameController = TextEditingController(
      text: currentName,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Full Name'),
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  await controller.updateProfile(name: newName);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

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
              onTap: () => _showImageSourceActionSheet(context),
              child: CircleAvatar(
                radius: 50,
                child: ClipOval(
                  child: UniversalImage(
                    imagePath: user.profileImagePath,
                    width: 100, // 2 * radius
                    height: 100,
                    fit: BoxFit.cover,
                    errorWidget: const Icon(Icons.person, size: 40),
                    placeholder: const CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _showEditNameDialog(context, controller, user.name),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.edit, size: 16, color: Colors.grey),
                ],
              ),
            ),
            Text(
              user.email,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // --- Stats Row ---
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onNavigateToCart,
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

            // --- Geolocation Card (FIXED) ---
            Card(
              child: FutureBuilder<String>(
                future: controller.getCurrentLocationAddress(),
                builder: (context, snapshot) {
                  // FIXED: Removed the incorrect battery calculation logic here
                  return ListTile(
                    leading: const Icon(Icons.location_on),
                    title: const Text('Current Location'),
                    subtitle: const Text(
                      'Latitude / Longitude',
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 10000),
                      child: Text(
                        snapshot.connectionState == ConnectionState.waiting
                            ? 'Fetching...'
                            : snapshot.data ?? 'Unavailable',
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // --- Theme Selector ---
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

            // --- Battery Tile ---
            Card(
              child: FutureBuilder<int>(
                future: controller.getBatteryLevel(),
                builder: (context, snapshot) {
                  final level = snapshot.data;
                  // Ensure we handle -1 or null
                  final displayLevel = (level != null && level >= 0)
                      ? '$level%'
                      : 'N/A';

                  return ListTile(
                    leading: const Icon(Icons.battery_std),
                    title: const Text('Battery Level'),
                    trailing: Text(
                      snapshot.connectionState == ConnectionState.waiting
                          ? '...'
                          : displayLevel,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),

            // --- Menu Options ---
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
            // --- Role Based Dashboards ---
            if (user.isAdmin)
              Card(
                color: Colors.red[50],
                child: ListTile(
                  leading: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.red,
                  ),
                  title: const Text('Admin Dashboard'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.pushNamed(context, '/admin');
                  },
                ),
              ),

            if (user.isSeller)
              Card(
                color: Colors.blue[50],
                child: ListTile(
                  leading: const Icon(Icons.store, color: Colors.blue),
                  title: const Text('Seller Dashboard'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.pushNamed(context, '/seller');
                  },
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
