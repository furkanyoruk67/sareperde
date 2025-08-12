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
                  child: Stack(
                    children: [
                      // Centered image
                      Center(
                        child: Container(
                          padding: EdgeInsets.all(24),
                          child: InteractiveViewer(
                            minScale: 0.5,
                            maxScale: 4.0,
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.9,
                                maxHeight: MediaQuery.of(context).size.height * 0.8,
                              ),
                              child: Image.asset(
                                selectedProduct!.image,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 300,
                                    height: 300,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Görsel yüklenemedi',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Close button
                      Positioned(
                        top: 16,
                        right: 16,
                        child: IconButton(
                          onPressed: onClose,
                          icon: const Icon(Icons.close, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.6),
                            shape: const CircleBorder(),
                            padding: EdgeInsets.all(12),
                          ),
                        ),
                      ),
                      // Zoom hint at bottom
                      Positioned(
                        bottom: 32,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.zoom_in, color: Colors.white, size: 16),
                                    SizedBox(width: 8),
                                    Text(
                                      'Yakınlaştırmak için kaydırın',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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

  // Commented out methods - not needed for simplified modal
  /*
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
                  child: Container(), // Placeholder for commented out Add to Cart button
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
  */
}