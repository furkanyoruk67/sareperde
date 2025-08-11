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
    required this.onAddToCart,
    required this.onToggleFavorite,
    required this.onInspect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
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
                  child: Stack(
                    children: [
                      Image.asset(
                        product.image,
                        fit: BoxFit.cover,
                      ),
                      // Hover overlay with inspect button
                      if (isHovered)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.3),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Center(
                              child: ElevatedButton.icon(
                                onPressed: onInspect,
                                icon: Icon(
                                  Icons.visibility,
                                  size: isMobile ? 16 : 20,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'İncele',
                                  style: TextStyle(
                                    fontSize: isMobile ? 12 : 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 12 : 16,
                                    vertical: isMobile ? 8 : 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(isMobile ? 4.0 : 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: isMobile ? 10 : 11,
                          color: AppColors.textPrimary,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: isMobile ? 1 : 2),
                      Text(
                        '${product.brand} • ${product.color}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: isMobile ? 8 : 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: isMobile ? 2 : 3),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: onToggleFavorite,
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: isMobile ? 12 : 14,
                            color: isFavorite ? AppColors.error : AppColors.textSecondary,
                          ),
                          label: Text(
                            isFavorite ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
                            style: TextStyle(
                              fontSize: isMobile ? 8 : 10,
                              fontWeight: FontWeight.w500,
                              color: isFavorite ? AppColors.error : AppColors.textSecondary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 4 : 8,
                              vertical: isMobile ? 2 : 4,
                            ),
                            side: BorderSide(
                              color: isFavorite ? AppColors.error : AppColors.border,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(isMobile ? 4 : 6),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isMobile ? 2 : 4),
                    ],
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}