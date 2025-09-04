import 'package:flutter/material.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: Icon(Icons.watch, size: 40, color: Colors.grey[700]),
            title: Text('Item ${index + 1}'),
            subtitle: Text('Description of item ${index + 1}'),
            trailing: Text('\$${(index + 1) * 100}'),
          ),
        );
      },
    );
  }
}
