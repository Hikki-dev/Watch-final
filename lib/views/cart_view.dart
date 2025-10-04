// lib/views/cart_view.dart
import 'package:flutter/material.dart';
import '../controllers/app_controller.dart';

class CartView extends StatefulWidget {
  final AppController controller;

  const CartView({super.key, required this.controller});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  @override
  Widget build(BuildContext context) {
    final cart = widget.controller.cart;

    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart'),
        actions: cart.isNotEmpty
            ? [
                TextButton(
                  onPressed: () {
                    cart.clear();
                    setState(() {});
                  },
                  child: Text('Clear'),
                ),
              ]
            : null,
      ),
      body: cart.isEmpty
          ? Center(
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
                        margin: EdgeInsets.all(8),
                        child: ListTile(
                          leading: Icon(Icons.watch, size: 40),
                          title: Text(item.watch.displayName),
                          subtitle: Text(
                            '${item.watch.displayPrice} x ${item.quantity}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  widget.controller.updateCartQuantity(
                                    item.watch.id,
                                    item.quantity - 1,
                                  );
                                  setState(() {});
                                },
                              ),
                              Text('${item.quantity}'),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  widget.controller.updateCartQuantity(
                                    item.watch.id,
                                    item.quantity + 1,
                                  );
                                  setState(() {});
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  widget.controller.removeFromCart(
                                    item.watch.id,
                                  );
                                  setState(() {});
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
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            cart.displayTotal,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Order Placed'),
                                content: Text('Thank you for your purchase!'),
                                actions: [
                                  FilledButton(
                                    onPressed: () {
                                      cart.clear();
                                      Navigator.pop(context);
                                      setState(() {});
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Text('Checkout'),
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
