import 'package:flutter/material.dart';
import 'seller_inventory_view.dart';

class SellerDashboardView extends StatelessWidget {
  const SellerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.store, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 16),
            const Text(
              'Welcome, Seller!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Manage your inventory and stock here.'),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SellerInventoryView(),
                  ),
                );
              },
              icon: const Icon(Icons.inventory),
              label: const Text('Manage Inventory'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back to Store'),
            ),
          ],
        ),
      ),
    );
  }
}
