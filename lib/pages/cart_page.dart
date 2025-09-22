// lib/pages/cart_page.dart
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../widgets/price_text.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final cartItems = appState.cart;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear Cart'),
                    content: const Text(
                      'Are you sure you want to remove all items from your cart?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () {
                          appState.clearCart();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cart cleared')),
                          );
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Clear All'),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart()
          : _buildCartList(context, cartItems, appState),
      bottomNavigationBar: cartItems.isNotEmpty
          ? _buildCheckoutBar(context, appState)
          : null,
    );
  }

  Widget _buildEmptyCart() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 120, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add some beautiful timepieces to get started',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(
    BuildContext context,
    List cartItems,
    AppState appState,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final cartItem = cartItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Product Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  child: const Icon(Icons.watch, size: 40),
                ),
                const SizedBox(width: 12),

                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cartItem.product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      PriceText(cartItem.product.price),
                      const SizedBox(height: 8),

                      // Quantity Controls
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (cartItem.quantity > 1) {
                                appState.updateCartQuantity(
                                  cartItem.product.id,
                                  cartItem.quantity - 1,
                                );
                              }
                            },
                            icon: const Icon(Icons.remove_circle_outline),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${cartItem.quantity}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              appState.updateCartQuantity(
                                cartItem.product.id,
                                cartItem.quantity + 1,
                              );
                            },
                            icon: const Icon(Icons.add_circle_outline),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Remove Button
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        appState.removeFromCart(cartItem.product.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${cartItem.product.name} removed from cart',
                            ),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                appState.addToCart(cartItem.product);
                              },
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red,
                    ),
                    const SizedBox(height: 8),
                    PriceText(cartItem.product.price * cartItem.quantity),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckoutBar(BuildContext context, AppState appState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Order Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal (${appState.cartItemCount} items):',
                  style: const TextStyle(fontSize: 16),
                ),
                PriceText(appState.cartTotal),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Shipping:', style: TextStyle(fontSize: 14)),
                Text(
                  appState.cartTotal > 1000 ? 'FREE' : '\$29.99',
                  style: TextStyle(
                    fontSize: 14,
                    color: appState.cartTotal > 1000
                        ? Colors.green
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                PriceText(
                  appState.cartTotal + (appState.cartTotal > 1000 ? 0 : 29.99),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Checkout Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  _showCheckoutDialog(context, appState);
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Proceed to Checkout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            // Free Shipping Message
            if (appState.cartTotal <= 1000)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Add \$${(1000 - appState.cartTotal + 0.01).toStringAsFixed(2)} more for FREE shipping!',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Confirmation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thank you for your order!'),
            const SizedBox(height: 8),
            Text(
              'Order total: \$${(appState.cartTotal + (appState.cartTotal > 1000 ? 0 : 29.99)).toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            const Text(
              'Your order will be processed and shipped within 2-3 business days.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              appState.clearCart();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Order placed successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Confirm Order'),
          ),
        ],
      ),
    );
  }
}
