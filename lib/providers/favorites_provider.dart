import 'package:flutter/foundation.dart';
import '../models/product.dart';

class FavoritesProvider extends ChangeNotifier {
  final Set<Product> _favoriteProducts = {};

  Set<Product> get favoriteProducts => Set.unmodifiable(_favoriteProducts);
  Set<Product> get favorites => Set.unmodifiable(_favoriteProducts);

  bool isFavorite(Product product) {
    return _favoriteProducts.contains(product);
  }

  void toggleFavorite(Product product) {
    if (_favoriteProducts.contains(product)) {
      _favoriteProducts.remove(product);
    } else {
      _favoriteProducts.add(product);
    }
    notifyListeners();
  }

  void addToFavorites(Product product) {
    _favoriteProducts.add(product);
    notifyListeners();
  }

  void addFavorite(Product product) {
    _favoriteProducts.add(product);
    notifyListeners();
  }

  void removeFromFavorites(Product product) {
    _favoriteProducts.remove(product);
    notifyListeners();
  }

  void removeFavorite(Product product) {
    _favoriteProducts.remove(product);
    notifyListeners();
  }

  void clearFavorites() {
    _favoriteProducts.clear();
    notifyListeners();
  }

  int get favoritesCount => _favoriteProducts.length;
} 