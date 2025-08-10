import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductModal extends StatelessWidget {
  final Product? selectedProduct;
  final bool isModalOpen;
  final VoidCallback onClose;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAddToCart;
  final bool isFavorite;

  const ProductModal({
    Key? key,
    required this.selectedProduct,
    required this.isModalOpen,
    required this.onClose,
    required this.onToggleFavorite,
    required this.onAddToCart,
    required this.isFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (selectedProduct == null) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: isModalOpen
          ? Container(
        color: Colors.black.withOpacity(0.5),
        child: Stack(
          children: [
            // Backdrop click to close
            Positioned.fill(
              child: GestureDetector(
                onTap: onClose,
                child: Container(color: Colors.transparent),
              ),
            ),
            // Modal content
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.8,
                constraints: BoxConstraints(
                  maxWidth: 1200,
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                  minWidth: 300,
                  minHeight: 400,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Header with close button
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Ürün Detayı',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: onClose,
                              icon: const Icon(Icons.close),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.grey[100],
                                shape: const CircleBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Content
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // Responsive layout: side-by-side on large screens, stacked on small screens
                            if (constraints.maxWidth > 800) {
                              return Row(
                                children: [
                                  // Left side - Image with zoom
                                  Expanded(
                                    flex: 1,
                                    child: _buildZoomableImage(),
                                  ),
                                  // Right side - Product details
                                  Expanded(
                                    flex: 1,
                                    child: _buildProductDetails(),
                                  ),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  // Top - Image with zoom
                                  Expanded(
                                    flex: 1,
                                    child: _buildZoomableImage(),
                                  ),
                                  // Bottom - Product details
                                  Expanded(
                                    flex: 1,
                                    child: _buildProductDetails(),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildZoomableImage() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    selectedProduct!.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Zoom controls
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.zoom_in, color: Colors.grey[600], size: 16),
                const SizedBox(width: 8),
                Text(
                  'Yakınlaştırmak için kaydırın',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                     // Product name with better styling
           Container(
             width: double.infinity,
             padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(
               color: Colors.white,
               borderRadius: BorderRadius.circular(8),
               border: Border.all(color: Colors.grey[200]!),
             ),
             child: Text(
               selectedProduct!.name,
               style: TextStyle(
                 fontSize: 18,
                 fontWeight: FontWeight.w700,
                 color: Colors.black,
                 height: 1.3,
               ),
             ),
           ),
          const SizedBox(height: 20),

          // Product specifications section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                                 // Section title
                 Text(
                   'Ürün Özellikleri',
                   style: TextStyle(
                     fontSize: 18,
                     fontWeight: FontWeight.w700,
                     color: Colors.black,
                   ),
                 ),
                const SizedBox(height: 12),
                
                // Scrollable specifications
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSpecificationRow('Kategori', selectedProduct!.category),
                        _buildSpecificationRow('Ürün Tipi', selectedProduct!.productType),
                        _buildSpecificationRow('Ebat', selectedProduct!.size),
                        _buildSpecificationRow('Kalite', selectedProduct!.quality),
                        _buildSpecificationRow('Renk', selectedProduct!.color),
                        _buildSpecificationRow('Marka', selectedProduct!.brand),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Action buttons (fixed at bottom)
          Container(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onToggleFavorite,
                    icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                    label: Text(
                      isFavorite ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
                      style: const TextStyle(fontSize: 14),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: /* Consumer<CartProvider>(
                    builder: (context, cartProvider, child) {
                      final isInCart = selectedProduct != null && cartProvider.isInCart(selectedProduct!);
                      final quantity = selectedProduct != null ? cartProvider.getQuantity(selectedProduct!) : 0;
                      
                      return ElevatedButton.icon(
                        onPressed: onAddToCart,
                        icon: Icon(isInCart ? Icons.check : Icons.shopping_cart),
                        label: Text(isInCart ? 'Sepette (${quantity})' : 'Sepete Ekle'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: isInCart ? AppColors.success : AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ), */
                  Container(), // Placeholder for commented out Add to Cart button
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}