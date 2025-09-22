// lib/views/profile_view.dart
import 'package:flutter/material.dart';
import '../controllers/app_controller.dart';
import '../widgets/watch_card.dart';
import 'watch_detail_view.dart';

class ProfileView extends StatelessWidget {
  final AppController controller;

  const ProfileView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => controller.logout(),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Account', icon: Icon(Icons.person)),
              Tab(text: 'Favorites', icon: Icon(Icons.favorite)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAccountTab(),
            _buildFavoritesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTab() {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final user = controller.currentUser!;
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              SizedBox(height: 16),
              Text(user.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(user.email, style: TextStyle(fontSize: 16, color: Colors.grey)),
              SizedBox(height: 32),
              
              // Stats Cards
              Row(
                children: [
                  Expanded(child: _buildStatCard('Cart Items', '${controller.cart.itemCount}')),
                  SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Favorites', '${controller.getFavoriteWatches().length}')),
                ],
              ),
              SizedBox(height: 24),
              
              // Action Cards
              Card(
                child: ListTile(
                  leading: Icon(Icons.shopping_bag),
                  title: Text('Order History'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {},
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {},
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.help),
                  title: Text('Help & Support'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {},
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFavoritesTab() {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final favorites = controller.getFavoriteWatches();
        
        if (favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('No favorites yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.7,
          ),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final watch = favorites[index];
            return WatchCard(
              watch: watch,
              controller: controller,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WatchDetailView(controller: controller, watchId: watch.id),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
