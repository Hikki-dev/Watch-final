import 'package:flutter/material.dart';
import '../../services/data_service.dart';

class AdminUserManagementView extends StatefulWidget {
  const AdminUserManagementView({super.key});

  @override
  State<AdminUserManagementView> createState() =>
      _AdminUserManagementViewState();
}

class _AdminUserManagementViewState extends State<AdminUserManagementView> {
  late Future<List<Map<String, dynamic>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  void _refreshUsers() {
    setState(() {
      _usersFuture = DataService().getAllUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshUsers),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final data = users[index];
              final userId = data['id'].toString();
              final email = data['email'] ?? 'No Email';
              final role = data['role'] ?? 'customer';
              final name = data['name'] ?? 'No Name';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getColorForRole(role),
                    child: Text(
                      role.isNotEmpty ? role[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text('$name ($role)'),
                  subtitle: Text(email),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteUser(context, userId);
                      } else {
                        _updateRole(context, userId, value);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'customer',
                        child: Text('Set as Customer'),
                      ),
                      const PopupMenuItem(
                        value: 'seller',
                        child: Text('Set as Seller'),
                      ),
                      const PopupMenuItem(
                        value: 'admin',
                        child: Text('Set as Admin'),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Delete User',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getColorForRole(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'seller':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  Future<void> _updateRole(
    BuildContext context,
    String userId,
    String newRole,
  ) async {
    try {
      await DataService().updateUserRole(userId, newRole);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Updated role to $newRole')));
        _refreshUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating role: $e')));
      }
    }
  }

  Future<void> _deleteUser(BuildContext context, String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User?'),
        content: const Text(
          'This will remove the user data from the Database.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await DataService().deleteUser(userId);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('User data deleted')));
          _refreshUsers();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting user: $e')));
        }
      }
    }
  }
}
