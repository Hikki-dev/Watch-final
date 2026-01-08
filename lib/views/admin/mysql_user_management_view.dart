import 'package:flutter/material.dart';
import 'package:watch_store/models/mysql_user.dart';
import 'package:watch_store/services/api_service.dart';

class MysqlUserManagementView extends StatefulWidget {
  const MysqlUserManagementView({super.key});

  @override
  State<MysqlUserManagementView> createState() =>
      _MysqlUserManagementViewState();
}

class _MysqlUserManagementViewState extends State<MysqlUserManagementView> {
  late Future<List<MysqlUser>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();
  }

  Future<List<MysqlUser>> _fetchUsers() async {
    try {
      final data = await ApiService.getUsers();
      return data.map((json) => MysqlUser.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading MySQL users: $e');
      throw Exception('Failed to load users');
    }
  }

  Future<void> _deleteUser(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User?'),
        content: const Text(
          'This will permanently delete the user from the MySQL database.',
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
        await ApiService.deleteUser(id);
        setState(() {
          _usersFuture = _fetchUsers();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User deleted successfully')),
          );
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

  Future<void> _showUserDialog({MysqlUser? user}) async {
    final isEditing = user != null;
    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final passwordController = TextEditingController();
    String role = user?.role ?? 'customer';

    // Normalize role string to ensure it matches dropdown items
    if (!['admin', 'seller', 'customer'].contains(role.toLowerCase())) {
      role = 'customer';
    } else {
      role = role.toLowerCase();
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(isEditing ? 'Edit User' : 'Add User'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  if (!isEditing)
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: ['admin', 'seller', 'customer'].map((r) {
                      return DropdownMenuItem(
                        value: r,
                        child: Text(r.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => role = val!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final data = {
                    'name': nameController.text,
                    'email': emailController.text,
                    'role': role,
                  };
                  if (!isEditing) {
                    data['password'] = passwordController.text;
                  }

                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);

                  try {
                    if (isEditing) {
                      await ApiService.updateUser(user.id, data);
                    } else {
                      await ApiService.createUser(data);
                    }
                    if (mounted) {
                      navigator.pop();
                      setState(() {
                        // This doesn't refresh the parent directly, handled by .then
                      });
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing ? 'User updated' : 'User created',
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: Text(isEditing ? 'Save' : 'Create'),
              ),
            ],
          );
        },
      ),
    ).then(
      (_) => setState(() {
        _usersFuture = _fetchUsers();
      }),
    );
  }

  Color _getColorForRole(String role) {
    if (role.toLowerCase().contains('admin')) return Colors.red;
    if (role.toLowerCase().contains('seller')) return Colors.blue;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage MySQL Users'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _usersFuture = _fetchUsers();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<MysqlUser>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading users. \nEnsure "api/users" route exists on Laravel.\n\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        setState(() => _usersFuture = _fetchUsers()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found in MySQL.'));
          }

          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getColorForRole(user.role),
                    child: Text(
                      user.role.isNotEmpty ? user.role[0].toUpperCase() : 'U',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    user.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${user.email}\nID: ${user.id}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showUserDialog(user: user),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteUser(user.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserDialog(),
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
      ),
    );
  }
}
