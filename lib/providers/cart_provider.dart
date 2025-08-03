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

  void addItem(Product product, {double? width, double? height}) {
    // Always add as a new item since curtains can have different dimensions for different rooms
    _items.add(CartItem(
      product: product,
      width: width,
      height: height,
    ));
    
    notifyListeners();
  }

  // Method to check if all items have dimensions
  bool get allItemsHaveDimensions {
    return _items.every((item) => item.width != null && item.height != null);
  }

  // Method to get items without dimensions
  List<CartItem> get itemsWithoutDimensions {
    return _items.where((item) => item.width == null || item.height == null).toList();
  }

  void removeItem(Product product) {
    // Remove the first occurrence of the product
    final index = _items.indexWhere((item) => item.product == product);
    if (index >= 0) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void removeItemAtIndex(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
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

  void updateQuantityAtIndex(int index, int quantity) {
    if (index >= 0 && index < _items.length) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void updateDimensions(Product product, double width, double height) {
    final existingIndex = _items.indexWhere((item) => item.product == product);
    if (existingIndex >= 0) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        width: width,
        height: height,
      );
      notifyListeners();
    }
  }

  void updateDimensionsAtIndex(int index, double width, double height) {
    if (index >= 0 && index < _items.length) {
      _items[index] = _items[index].copyWith(
        width: width,
        height: height,
      );
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