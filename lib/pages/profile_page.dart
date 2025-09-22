// lib/pages/profile_page.dart
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback onLogout;

  const ProfilePage({super.key, required this.onLogout});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Profile'),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primaryContainer,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          appState.currentUser ?? 'Watch Enthusiast',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Premium Member',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () => _showEditProfile(context),
                      child: const Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit Profile'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      onTap: () => _showSettings(context),
                      child: const Row(
                        children: [
                          Icon(Icons.settings),
                          SizedBox(width: 8),
                          Text('Settings'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      onTap: () => _showLogoutDialog(context),
                      child: const Row(
                        children: [
                          Icon(Icons.logout, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Logout', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
                  Tab(text: 'Favorites', icon: Icon(Icons.favorite)),
                  Tab(text: 'Orders', icon: Icon(Icons.shopping_bag)),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(context, appState, isTablet),
            _buildFavoritesTab(context, appState, isTablet),
            _buildOrdersTab(context, appState),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    AppState appState,
    bool isTablet,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isTablet ? 4 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildStatCard(
                'Total Orders',
                '12',
                Icons.shopping_bag,
                Theme.of(context).colorScheme.primary,
              ),
              _buildStatCard(
                'Favorites',
                '${appState.favorites.length}',
                Icons.favorite,
                Colors.red,
              ),
              _buildStatCard(
                'Cart Items',
                '${appState.cartItemCount}',
                Icons.shopping_cart,
                Colors.orange,
              ),
              _buildStatCard(
                'Spent Total',
                '\$24,599',
                Icons.monetization_on,
                Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _buildQuickAction(
                  'Order History',
                  'View your past orders',
                  Icons.history,
                  () => _tabController.animateTo(2),
                ),
                const Divider(height: 1),
                _buildQuickAction(
                  'Wishlist',
                  'Manage your favorite watches',
                  Icons.favorite_border,
                  () => _tabController.animateTo(1),
                ),
                const Divider(height: 1),
                _buildQuickAction(
                  'Track Order',
                  'Track your current orders',
                  Icons.local_shipping,
                  () => _showTrackingDialog(context),
                ),
                const Divider(height: 1),
                _buildQuickAction(
                  'Support',
                  'Get help with your account',
                  Icons.help_outline,
                  () => _showSupportDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recent Activity
          Text(
            'Recent Activity',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _buildActivityItem(
                  'Added Rolex Submariner to favorites',
                  '2 hours ago',
                  Icons.favorite,
                  Colors.red,
                ),
                const Divider(height: 1),
                _buildActivityItem(
                  'Viewed Omega Speedmaster',
                  '1 day ago',
                  Icons.visibility,
                  Colors.blue,
                ),
                const Divider(height: 1),
                _buildActivityItem(
                  'Order #12345 shipped',
                  '3 days ago',
                  Icons.local_shipping,
                  Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab(
    BuildContext context,
    AppState appState,
    bool isTablet,
  ) {
    final favoriteProducts = appState.favoriteProducts;

    if (favoriteProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Favorites Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start adding watches to your favorites',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 3 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: favoriteProducts.length,
      itemBuilder: (context, index) {
        final product = favoriteProducts[index];
        return ProductCard(
          product: product,
          onAddToCart: () => appState.addToCart(product),
          onOpen: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailPage(productId: product.id),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrdersTab(BuildContext context, AppState appState) {
    // Mock order data
    final orders = [
      {
        'id': '12345',
        'date': '2024-01-15',
        'total': 15999.0,
        'status': 'Shipped',
      },
      {
        'id': '12344',
        'date': '2024-01-10',
        'total': 5999.0,
        'status': 'Delivered',
      },
      {
        'id': '12343',
        'date': '2024-01-05',
        'total': 299.0,
        'status': 'Delivered',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(order['status'] as String),
              child: const Icon(Icons.shopping_bag, color: Colors.white),
            ),
            title: Text('Order #${order['id']}'),
            subtitle: Text('${order['date']} • \$${order['total']}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(
                  order['status'] as String,
                ).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                order['status'] as String,
                style: TextStyle(
                  color: _getStatusColor(order['status'] as String),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () => _showOrderDetails(context, order),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildActivityItem(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, size: 16, color: color),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: Text(
        time,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Shipped':
        return Colors.orange;
      case 'Delivered':
        return Colors.green;
      case 'Processing':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showEditProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: const Text(
          'Profile editing functionality would be implemented here.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const Text(
          'Settings page would be implemented here with options for notifications, privacy, etc.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onLogout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showTrackingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Track Order'),
        content: const Text('Enter your order number to track its status.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Customer Support'),
        content: const Text(
          'Contact our support team at support@timepiececollection.com or call 1-800-WATCHES',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(BuildContext context, Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${order['date']}'),
            Text('Total: \$${order['total']}'),
            Text('Status: ${order['status']}'),
            const SizedBox(height: 16),
            const Text('Items in this order:'),
            const Text('• Rolex Daytona'),
            if (order['status'] == 'Shipped')
              const Text('\nTracking: 1Z999AA1234567890'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (order['status'] == 'Shipped')
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tracking information sent to your email'),
                  ),
                );
              },
              child: const Text('Track'),
            ),
        ],
      ),
    );
  }
}
