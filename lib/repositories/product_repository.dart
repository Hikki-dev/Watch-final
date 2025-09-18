import '../models/product.dart';

/// Simple in-memory repository with CRUD
class ProductRepository {
  final Map<String, Product> _store = {};

  // CREATE
  Product create(Product product) {
    _store[product.id] = product;
    return product;
  }

  // READ
  Product? getById(String id) => _store[id];

  List<Product> getAll({String? brandId}) {
    final list = _store.values.toList();
    if (brandId == null) return list;
    return list.where((p) => p.brandId == brandId).toList();
  }

  // UPDATE
  Product? update(String id, Product updated) {
    if (!_store.containsKey(id)) return null;
    _store[id] = updated;
    return updated;
  }

  // DELETE
  bool delete(String id) => _store.remove(id) != null;
}