import 'package:flutter/material.dart';
import '../../services/data_service.dart';
import '../../models/watch.dart';
import '../../theme/lux_theme.dart';
import '../../widgets/lux_widgets.dart';
import '../../widgets/universal_image.dart';

class SellerInventoryView extends StatelessWidget {
  const SellerInventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = DataService();

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
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

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: watches.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final watch = watches[index];
              final c = context.lux;
              final soldOut = watch.stock == 0;
              return Reveal(
                index: index % 6,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        LuxStage(
                          height: 64,
                          child: SizedBox(
                            width: 64,
                            child: UniversalImage(
                              imagePath: watch.imagePath,
                              fit: BoxFit.cover,
                              errorWidget: Icon(Icons.watch, color: c.mute),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Eyebrow(watch.brand),
                              const SizedBox(height: 3),
                              Text(
                                watch.name,
                                style: Theme.of(context).textTheme.titleLarge,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Category: ${watch.category}  ·  Stock: ${watch.stock}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusPill(
                          soldOut ? 'Sold out' : 'Live',
                          kind: soldOut ? PillKind.rejected : PillKind.live,
                        ),
                        IconButton(
                          tooltip: 'Edit stock',
                          icon: Icon(Icons.edit_note, size: 28, color: c.accent),
                          onPressed: () => _showEditStockDialog(context, watch),
                        ),
                      ],
                    ),
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
