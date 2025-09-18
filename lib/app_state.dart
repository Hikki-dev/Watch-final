import 'package:flutter/material.dart';
import 'models/product.dart';
import 'models/cart_item.dart';
import 'repositories/product_repository.dart';
import 'data/seed_data.dart';

class AppState extends ChangeNotifier {
  AppState(this.products);

  final ProductRepository products;

  // Simple cart state
  final List<CartItem> _cart = [];
  List<CartItem> get cart => List.unmodifiable(_cart);

  static AppState bootstrap() {
    final repo = ProductRepository();
    // Seed initial data
    for (final p in seedProducts) {
      repo.create(p);
    }
    return AppState(repo);
  }

  // CART OPERATIONS
  void addToCart(Product product) {
    final idx = _cart.indexWhere((c) => c.product.id == product.id);
    if (idx == -1) {
      _cart.add(CartItem(product: product, quantity: 1));
    } else {
      _cart[idx] = _cart[idx].copyWith(quantity: _cart[idx].quantity + 1);
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cart.removeWhere((c) => c.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({super.key, required super.notifier, required super.child});

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'No AppStateScope found in context');
    return scope!.notifier!;
  }
}