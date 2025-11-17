// lib/views/cart_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. Import Provider
import '../controllers/app_controller.dart';

// 2. Change to a StatelessWidget
class CartView extends StatelessWidget {
  // 3. Remove controller from constructor
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    // 4. Get controller from Provider using .watch()
    // This will make the view rebuild whenever the cart changes
    final controller = context.watch<AppController>();
    final cart = controller.cart;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: cart.isNotEmpty
            ? [
                TextButton(
                  onPressed: () {
                    // 5. Call controller, no setState() needed
                    controller.cart.clear();
                  },
                  child: const Text('Clear'),
                ),
              ]
            : null,
      ),
      body: cart.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          // 6. Use a placeholder or load the image
                          leading: Image.asset(
                            item.watch.imagePath,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, st) =>
                                const Icon(Icons.watch, size: 40),
                          ),
                          title: Text(item.watch.displayName),
                          subtitle: Text(
                            '${item.watch.displayPrice} x ${item.quantity}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  // 5. Call controller, no setState()
                                  controller.updateCartQuantity(
                                    item.watch.id,
                                    item.quantity - 1,
                                  );
                                },
                              ),
                              Text('${item.quantity}'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  // 5. Call controller, no setState()
                                  controller.updateCartQuantity(
                                    item.watch.id,
                                    item.quantity + 1,
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  // 5. Call controller, no setState()
                                  controller.removeFromCart(item.watch.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            cart.displayTotal,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Order Placed'),
                                content: const Text(
                                  'Thank you for your purchase!',
                                ),
                                actions: [
                                  FilledButton(
                                    onPressed: () {
                                      // 5. Call controller, no setState()
                                      controller.cart.clear();
                                      Navigator.pop(dialogContext);
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text('Checkout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
