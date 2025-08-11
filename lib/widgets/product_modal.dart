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

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

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
                width: isMobile ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width * 0.8,
                height: isMobile ? MediaQuery.of(context).size.height : MediaQuery.of(context).size.height * 0.8,
                constraints: BoxConstraints(
                  maxWidth: isMobile ? double.infinity : 1200,
                  maxHeight: isMobile ? double.infinity : MediaQuery.of(context).size.height * 0.85,
                  minWidth: isMobile ? double.infinity : 300,
                  minHeight: isMobile ? double.infinity : 400,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: isMobile ? BorderRadius.zero : BorderRadius.circular(16),
                  boxShadow: isMobile ? null : [
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
                        padding: EdgeInsets.all(isMobile ? 16 : 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: isMobile ? BorderRadius.zero : const BorderRadius.only(
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
                                  fontSize: isMobile ? 18 : 20,
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
                            if (constraints.maxWidth > 800 && !isMobile) {
                              return Row(
                                children: [
                                  // Left side - Image with zoom
                                  Expanded(
                                    flex: 1,
                                    child: _buildZoomableImage(context),
                                  ),
                                  // Right side - Product details
                                  Expanded(
                                    flex: 1,
                                    child: _buildProductDetails(context),
                                  ),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  // Top - Image with zoom
                                  Expanded(
                                    flex: 1,
                                    child: _buildZoomableImage(context),
                                  ),
                                  // Bottom - Product details
                                  Expanded(
                                    flex: 1,
                                    child: _buildProductDetails(context),
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

  Widget _buildZoomableImage(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
          SizedBox(height: isMobile ? 12 : 16),
          // Zoom controls
          Container(
            padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.zoom_in, color: Colors.grey[600], size: isMobile ? 14 : 16),
                SizedBox(width: isMobile ? 6 : 8),
                Text(
                  'Yakınlaştırmak için kaydırın',
                  style: TextStyle(color: Colors.grey[600], fontSize: isMobile ? 12 : 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name with better styling
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              selectedProduct!.name,
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                height: 1.3,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),

          // Product specifications section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section title
                Text(
                  'Ürün Özellikleri',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: isMobile ? 8 : 12),
                
                // Scrollable specifications
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSpecificationRow(context, 'Kategori', selectedProduct!.category),
                        _buildSpecificationRow(context, 'Ürün Tipi', selectedProduct!.productType),
                        _buildSpecificationRow(context, 'Ebat', selectedProduct!.size),
                        _buildSpecificationRow(context, 'Kalite', selectedProduct!.quality),
                        _buildSpecificationRow(context, 'Renk', selectedProduct!.color),
                        _buildSpecificationRow(context, 'Marka', selectedProduct!.brand),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Action buttons (fixed at bottom)
          Container(
            padding: EdgeInsets.only(top: isMobile ? 12 : 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onToggleFavorite,
                    icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                    label: Text(
                      isFavorite ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
                      style: TextStyle(fontSize: isMobile ? 12 : 14),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 12),
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

  Widget _buildSpecificationRow(BuildContext context, String label, String value) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16, 
        vertical: isMobile ? 8 : 12
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          SizedBox(
            width: isMobile ? 80 : 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
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