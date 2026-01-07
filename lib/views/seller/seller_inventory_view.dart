import 'package:flutter/material.dart';
import '../../services/data_service.dart';
import '../../models/watch.dart';
import '../../widgets/universal_image.dart';

class SellerInventoryView extends StatelessWidget {
  const SellerInventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = DataService();

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Management')),
      body: StreamBuilder<List<Watch>>(
        stream: dataService.streamWatches(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final watches = snapshot.data ?? [];
          if (watches.isEmpty) {
            return const Center(child: Text('No products found.'));
          }

          return ListView.builder(
            itemCount: watches.length,
            itemBuilder: (context, index) {
              final watch = watches[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                // Highlight out-of-stock items
                color: watch.stock == 0 ? Colors.red[50] : null,
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
                  title: Text(
                    watch.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Category: ${watch.category}\nStock: ${watch.stock}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.edit_note,
                      size: 30,
                      color: Colors.blue,
                    ),
                    onPressed: () => _showEditStockDialog(context, watch),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditStockDialog(BuildContext context, Watch watch) {
    final stockController = TextEditingController(text: watch.stock.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Stock: ${watch.name}'),
          content: TextField(
            controller: stockController,
            decoration: const InputDecoration(
              labelText: 'Quantity',
              border: OutlineInputBorder(),
              suffixText: 'units',
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final newStock = int.tryParse(stockController.text);
                if (newStock != null && newStock >= 0) {
                  // Valid input
                  final dataService = DataService(); // Or inject
                  await dataService.updateStock(watch.id, newStock);

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Stock updated for ${watch.name}'),
                      ),
                    );
                  }
                } else {
                  // Invalid input
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid non-negative number'),
                    ),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
