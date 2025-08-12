import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  final double? width;
  final double? height;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.width,
    this.height,
  });

  double get totalPrice => product.price * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
    double? width,
    double? height,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.product == product;
  }

  @override
  int get hashCode => product.hashCode;
} 