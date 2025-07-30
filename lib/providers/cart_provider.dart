import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.length;

  double get totalPrice {
    return _items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  void addItem(Product product) {
    final existingIndex = _items.indexWhere((item) => item.product == product);
    
    if (existingIndex >= 0) {
      // Item already exists, increase quantity
      _items[existingIndex].quantity++;
    } else {
      // Add new item
      _items.add(CartItem(product: product));
    }
    
    notifyListeners();
  }

  void removeItem(Product product) {
    _items.removeWhere((item) => item.product == product);
    notifyListeners();
  }

  void updateQuantity(Product product, int quantity) {
    if (quantity <= 0) {
      removeItem(product);
      return;
    }

    final existingIndex = _items.indexWhere((item) => item.product == product);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity = quantity;
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  bool isInCart(Product product) {
    return _items.any((item) => item.product == product);
  }

  int getQuantity(Product product) {
    final item = _items.firstWhere(
      (item) => item.product == product,
      orElse: () => CartItem(product: product, quantity: 0),
    );
    return item.quantity;
  }
} 