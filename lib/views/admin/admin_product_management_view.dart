import 'package:flutter/material.dart';
import '../../models/watch.dart';
import 'admin_product_form_view.dart';
import '../../services/data_service.dart';
import '../../widgets/universal_image.dart';

class AdminProductManagementView extends StatefulWidget {
  const AdminProductManagementView({super.key});

  @override
  State<AdminProductManagementView> createState() =>
      _AdminProductManagementViewState();
}

class _AdminProductManagementViewState
    extends State<AdminProductManagementView> {
  late Future<List<Watch>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  void _refreshProducts() {
    setState(() {
      _productsFuture = DataService().fetchWatchesFromApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshProducts,
          ),
        ],
      ),
      body: FutureBuilder<List<Watch>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found.'));
          }

          final watches = snapshot.data!;
          return ListView.builder(
            itemCount: watches.length,
            itemBuilder: (context, index) {
              final watch = watches[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: UniversalImage(
                      imagePath: watch.imagePath,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(watch.name),
                  subtitle: Text(
                    '${watch.brand} - \$${watch.price} (Stock: ${watch.stock})',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) =>
                                  AdminProductFormView(watch: watch),
                            ),
                          );
                          _refreshProducts();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(context, watch.id),
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
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => const AdminProductFormView()),
          );
          _refreshProducts();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteProduct(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete Product?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DataService().deleteWatch(id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Product Deleted')));
        _refreshProducts();
      }
    }
  }
}
