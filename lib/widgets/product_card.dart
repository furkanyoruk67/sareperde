import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/product.dart';

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
    return Card(
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
      child: MouseRegion(
        onEnter: (_) => onHoverEnter(),
        onExit: (_) => onHoverExit(),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Image.asset(
                    product.image,
                    fit: BoxFit.cover,
                  ),
                ),
                                 Padding(
                   padding: const EdgeInsets.all(6.0),
                   child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                                                 style: const TextStyle(
                           fontWeight: FontWeight.w600,
                           fontSize: 11,
                           color: AppColors.textPrimary,
                           height: 1.1,
                         ),
                      ),
                                             const SizedBox(height: 2),
                       Text(
                         '${product.brand} • ${product.color}',
                         style: const TextStyle(
                           color: AppColors.textSecondary,
                           fontSize: 9,
                           fontWeight: FontWeight.w500,
                         ),
                       ),
                       const SizedBox(height: 3),
                       // Text(
                       //   '${product.price.toStringAsFixed(0)} ₺',
                       //   style: const TextStyle(
                       //     fontWeight: FontWeight.bold,
                       //     fontSize: 12,
                       //     color: AppColors.primary,
                       //   ),
                       // ),
                       const SizedBox(height: 4),
                      // Add to Favorites button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: onToggleFavorite,
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 14,
                            color: isFavorite ? AppColors.error : AppColors.textSecondary,
                          ),
                          label: Text(
                            isFavorite ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isFavorite ? AppColors.error : AppColors.textSecondary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isFavorite ? AppColors.error : AppColors.textSecondary,
                            side: BorderSide(
                              color: isFavorite ? AppColors.error : AppColors.border,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                                             ),
                       const SizedBox(height: 4),
                       // Add to Cart button
                      /* Consumer<CartProvider>(
                        builder: (context, cartProvider, child) {
                          final isInCart = cartProvider.isInCart(product);
                          final quantity = cartProvider.getQuantity(product);
                          
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: onAddToCart,
                              icon: Icon(
                                isInCart ? Icons.check : Icons.shopping_cart,
                                size: 14,
                              ),
                              label: Text(
                                isInCart ? 'Sepette (${quantity})' : 'Sepete Ekle',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isInCart ? AppColors.success : AppColors.primary,
                                foregroundColor: AppColors.surface,
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          );
                        },
                      ), */
                    ],
                  ),
                ),
              ],
            ),
            // View Product button positioned in upper half of the image
            if (isHovered)
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowStrong,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onInspect,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.zoom_in,
                                color: AppColors.surface,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Ürünü İncele',
                                style: TextStyle(
                                  color: AppColors.surface,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}