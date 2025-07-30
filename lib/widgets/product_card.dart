import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool isHovered;
  final bool isFavorite;
  final VoidCallback onHoverEnter;
  final VoidCallback onHoverExit;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAddToCart;
  final VoidCallback onInspect;

  const ProductCard({
    Key? key,
    required this.product,
    required this.isHovered,
    required this.isFavorite,
    required this.onHoverEnter,
    required this.onHoverExit,
    required this.onToggleFavorite,
    required this.onAddToCart,
    required this.onInspect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHoverEnter(),
      onExit: (_) => onHoverExit(),
      child: Stack(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isHovered ? AppColors.primary : AppColors.border,
                width: isHovered ? 2 : 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            elevation: isHovered ? 8 : 2,
            shadowColor: AppColors.shadowStrong,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Image.asset(
                    product.image,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${product.brand} • ${product.color}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${product.price.toStringAsFixed(0)} ₺',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Add to Favorites button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: onToggleFavorite,
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: isFavorite ? AppColors.error : AppColors.textSecondary,
                          ),
                          label: Text(
                            isFavorite ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isFavorite ? AppColors.error : AppColors.textSecondary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isFavorite ? AppColors.error : AppColors.textSecondary,
                            side: BorderSide(
                              color: isFavorite ? AppColors.error : AppColors.border,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Add to Cart button
                      Consumer<CartProvider>(
                        builder: (context, cartProvider, child) {
                          final isInCart = cartProvider.isInCart(product);
                          final quantity = cartProvider.getQuantity(product);
                          
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: onAddToCart,
                              icon: Icon(
                                isInCart ? Icons.check : Icons.shopping_cart,
                                size: 16,
                              ),
                              label: Text(
                                isInCart ? 'Sepette (${quantity})' : 'Sepete Ekle',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isInCart ? AppColors.success : AppColors.primary,
                                foregroundColor: AppColors.surface,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Inspect icon that appears on hover at the bottom of the image
          if (isHovered)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.shadowStrong,
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowStrong,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: onInspect,
                      icon: const Icon(
                        Icons.zoom_in,
                        color: AppColors.surface,
                        size: 20,
                      ),
                      padding: const EdgeInsets.all(10),
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}