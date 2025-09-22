// lib/models/cart.dart
import 'package:flutter/foundation.dart';
import 'watch.dart';
import 'cart_item.dart';

class Cart extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  String get displayTotal => '\$${totalPrice.toStringAsFixed(2)}';

  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  void addWatch(Watch watch, {int quantity = 1}) {
    final existingIndex = _items.indexWhere(
      (item) => item.watch.id == watch.id,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(watch: watch, quantity: quantity));
    }
    notifyListeners();
  }

  void removeWatch(String watchId) {
    _items.removeWhere((item) => item.watch.id == watchId);
    notifyListeners();
  }

  void updateQuantity(String watchId, int quantity) {
    final index = _items.indexWhere((item) => item.watch.id == watchId);

    if (index >= 0) {
      if (quantity <= 0) {
        removeWatch(watchId);
      } else {
        _items[index].quantity = quantity;
        notifyListeners();
      }
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  bool contains(String watchId) {
    return _items.any((item) => item.watch.id == watchId);
  }
}
