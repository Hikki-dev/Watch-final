import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../theme/lux_theme.dart';
import '../../widgets/lux_widgets.dart';
import 'admin_mysql_product_management_view.dart';
import 'mysql_user_management_view.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.lux;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthService>().signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Reveal(child: Eyebrow('Administration')),
              const SizedBox(height: 8),
              Reveal(index: 1, child: Text('Overview', style: text.displaySmall)),
              const SizedBox(height: 8),
              Reveal(
                index: 2,
                child: Text(
                  'Manage your store efficiently.',
                  style: text.bodyLarge?.copyWith(color: c.mute),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.count(
                  crossAxisCount: MediaQuery.of(context).size.width > 700 ? 4 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    Reveal(
                      index: 3,
                      child: _DashboardCard(
                        title: 'Products (SSP)',
                        subtitle: 'MySQL Database',
                        icon: Icons.watch_later_outlined,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const AdminMysqlProductManagementView(),
                          ),
                        ),
                      ),
                    ),
                    Reveal(
                      index: 4,
                      child: _DashboardCard(
                        title: 'Users (SSP)',
                        subtitle: 'MySQL Database',
                        icon: Icons.people_outline,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const MysqlUserManagementView(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.lux;
    final text = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: c.accent),
              const SizedBox(height: 18),
              Text(title, textAlign: TextAlign.center, style: text.titleLarge),
              const SizedBox(height: 4),
              Text(subtitle, textAlign: TextAlign.center, style: text.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
