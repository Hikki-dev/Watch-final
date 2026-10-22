// lib/views/cart_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../theme/lux_theme.dart';
import '../widgets/lux_widgets.dart';
import '../widgets/universal_image.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final cart = controller.cart;
    final c = context.lux;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your cart'),
        actions: cart.isNotEmpty
            ? [
                TextButton(
                  onPressed: () => controller.cart.clear(),
                  child: const Text('CLEAR'),
                ),
                const SizedBox(width: 8),
              ]
            : null,
      ),
      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 64, color: c.mute),
                  const SizedBox(height: 16),
                  Text('Your cart is empty', style: text.titleLarge),
                  const SizedBox(height: 6),
                  Text('Pieces you add will wait here.', style: text.bodySmall),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              itemCount: cart.items.length,
              separatorBuilder: (_, _) => Divider(color: c.line),
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return Reveal(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LuxStage(
                          height: 92,
                          child: SizedBox(
                            width: 92,
                            child: UniversalImage(
                              imagePath: item.watch.imagePath,
                              fit: BoxFit.cover,
                              errorWidget: Icon(
                                Icons.watch,
                                size: 36,
                                color: c.mute,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Eyebrow(item.watch.brand),
                              const SizedBox(height: 4),
                              Text(
                                item.watch.name,
                                style: text.titleLarge,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              PriceText(
                                '${item.watch.displayPrice} x ${item.quantity}',
                                size: 13,
                              ),
                              const SizedBox(height: 10),
                              _Stepper(
                                quantity: item.quantity,
                                onMinus: () => controller.updateCartQuantity(
                                  item.watch.id,
                                  item.quantity - 1,
                                ),
                                onPlus: () => controller.updateCartQuantity(
                                  item.watch.id,
                                  item.quantity + 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Remove',
                          icon: Icon(Icons.delete_outline, color: c.bad),
                          onPressed: () =>
                              controller.removeFromCart(item.watch.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      // In the Scaffold's bottom bar so snackbars appear above it, not over the button.
      bottomNavigationBar: cart.isEmpty
          ? null
          : _CheckoutBar(
              total: cart.displayTotal,
              onCheckout: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Order Placed'),
                    content: const Text('Thank you for your purchase!'),
                    actions: [
                      FilledButton(
                        onPressed: () {
                          controller.clearCart();
                          Navigator.pop(dialogContext);
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  final String total;
  final VoidCallback onCheckout;
  const _CheckoutBar({required this.total, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    final c = context.lux;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: c.bg,
        border: Border(top: BorderSide(color: c.line)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Eyebrow('Total'),
                Text(total, style: text.headlineSmall),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onCheckout,
                child: const Text('CHECKOUT'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  const _Stepper({
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.lux;
    return Container(
      decoration: BoxDecoration(border: Border.all(color: c.line)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Decrease quantity',
            icon: const Icon(Icons.remove, size: 18),
            onPressed: onMinus,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            padding: EdgeInsets.zero,
          ),
          SizedBox(
            width: 24,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: LuxFonts.mono, fontSize: 14),
            ),
          ),
          IconButton(
            tooltip: 'Increase quantity',
            icon: const Icon(Icons.add, size: 18),
            onPressed: onPlus,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
