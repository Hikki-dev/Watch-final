import 'package:flutter/material.dart';
import '../../theme/lux_theme.dart';
import '../../widgets/lux_widgets.dart';
import 'seller_inventory_view.dart';

class SellerDashboardView extends StatelessWidget {
  const SellerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.lux;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Seller Dashboard')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Reveal(child: Eyebrow('Seller')),
                const SizedBox(height: 10),
                Reveal(
                  index: 1,
                  child: Text('Welcome, Seller!', style: text.displaySmall),
                ),
                const SizedBox(height: 12),
                Reveal(
                  index: 2,
                  child: Text(
                    'Manage your inventory and stock here.',
                    style: text.bodyLarge?.copyWith(color: c.mute),
                  ),
                ),
                const SizedBox(height: 36),
                Reveal(
                  index: 3,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SellerInventoryView(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.inventory_2_outlined),
                    label: const Text('MANAGE INVENTORY'),
                  ),
                ),
                const SizedBox(height: 12),
                Reveal(
                  index: 4,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('BACK TO STORE'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
