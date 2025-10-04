// lib/models/cart_item.dart
import 'watch.dart';

class CartItem {
  final Watch watch;
  int quantity;

  CartItem({required this.watch, this.quantity = 1});

  double get totalPrice => watch.price * quantity;
  String get displayTotalPrice => '\$${totalPrice.toStringAsFixed(2)}';
}
