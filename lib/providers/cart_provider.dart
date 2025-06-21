import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, int> _items = {}; // productId -> quantity
  final Map<String, Product> _products = {};

  Map<String, int> get items => {..._items};
  Map<String, Product> get products => {..._products};

  void addProduct(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id] = _items[product.id]! + 1;
    } else {
      _items[product.id] = 1;
      _products[product.id] = product;
    }
    notifyListeners();
  }

  void removeProduct(Product product) {
    if (!_items.containsKey(product.id)) return;

    if (_items[product.id]! > 1) {
      _items[product.id] = _items[product.id]! - 1;
    } else {
      _items.remove(product.id);
      _products.remove(product.id);
    }
    notifyListeners();
  }

  double get totalPrice {
    double total = 0;
    _items.forEach((key, quantity) {
      total += (_products[key]?.price ?? 0) * quantity;
    });
    return total;
  }

  void clear() {
    _items.clear();
    _products.clear();
    notifyListeners();
  }
}