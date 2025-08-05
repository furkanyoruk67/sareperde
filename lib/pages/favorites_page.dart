import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_modal.dart';
import 'cart_page.dart';

class FavoritesPage extends StatefulWidget {
  final Set<Product> favoriteProducts;
  final Function(Product) onRemoveFromFavorites;

  const FavoritesPage({
    Key? key, 
    required this.favoriteProducts,
    required this.onRemoveFromFavorites,
  }) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  Product? _selectedProduct;
  bool _isModalOpen = false;
  Map<Product, bool> _hoveredProducts = {};

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.surface,
            surfaceTintColor: AppColors.surface,
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(

                    decoration: BoxDecoration(
                      color: AppColors.primary,

                    ),
                    child: Image.asset('assets/logo1.jpg', height: 28),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Favorilerim',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
            ),
          ),
          body: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                color: AppColors.surfaceVariant,
                width: double.infinity,
                child: Row(
                  children: [
                    Icon(Icons.favorite, color: AppColors.error, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Favorilerim (${widget.favoriteProducts.length})',
                      style: const TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: widget.favoriteProducts.isEmpty
                    ? _buildEmptyState()
                    : _buildFavoritesGrid(),
              ),
            ],
          ),
          floatingActionButton: Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartPage(),
                    ),
                  );
                },
                label: Text(
                  'Sepetim${cartProvider.itemCount > 0 ? ' (${cartProvider.itemCount})' : ''}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                icon: Stack(
                  children: [
                    const Icon(Icons.shopping_cart, size: 20),
                    if (cartProvider.itemCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${cartProvider.itemCount}',
                            style: const TextStyle(
                              color: AppColors.surface,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              );
            },
          ),
        ),
        _buildProductModal(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border,
              size: 64,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Henüz Favori Ürününüz Yok',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Beğendiğiniz ürünleri favorilere ekleyerek\nburada kolayca bulabilirsiniz',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.shopping_bag),
            label: const Text('Anasayfaya Dön'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;
        if (constraints.maxWidth >= 1400) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth < 900) {
          crossAxisCount = 2;
        } else if (constraints.maxWidth < 600) {
          crossAxisCount = 1;
        }

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: GridView.builder(
            itemCount: widget.favoriteProducts.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.70,
            ),
            itemBuilder: (context, index) {
              final product = widget.favoriteProducts.elementAt(index);
              final isHovered = _hoveredProducts[product] ?? false;

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
                  onEnter: (_) => setState(() => _hoveredProducts[product] = true),
                  onExit: (_) => setState(() => _hoveredProducts[product] = false),
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
                                // Remove from favorites button
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      widget.onRemoveFromFavorites(product);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${product.name} favorilerden çıkarıldı'),
                                          backgroundColor: AppColors.success,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.favorite, size: 16, color: AppColors.error),
                                    label: const Text(
                                      'Favorilerden Çıkar',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.error,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.error,
                                      side: const BorderSide(color: AppColors.error),
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
                                        onPressed: () {
                                          cartProvider.addItem(product);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${product.name} sepete eklendi'),
                                              backgroundColor: AppColors.success,
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                        },
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
                                  onTap: () {
                                    setState(() {
                                      _selectedProduct = product;
                                      _isModalOpen = true;
                                    });
                                  },
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
            },
          ),
        );
      },
    );
  }

  // Product Modal
  Widget _buildProductModal() {
    return ProductModal(
      selectedProduct: _selectedProduct,
      isModalOpen: _isModalOpen,
      onClose: () {
        setState(() {
          _isModalOpen = false;
          _selectedProduct = null;
        });
      },
      onToggleFavorite: () {
        if (_selectedProduct != null) {
          widget.onRemoveFromFavorites(_selectedProduct!);
          setState(() {
            _isModalOpen = false;
            _selectedProduct = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_selectedProduct!.name} favorilerden çıkarıldı'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      onAddToCart: () {
        if (_selectedProduct != null) {
          context.read<CartProvider>().addItem(_selectedProduct!);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_selectedProduct!.name} sepete eklendi'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      isFavorite: _selectedProduct != null ? widget.favoriteProducts.contains(_selectedProduct!) : false,
    );
  }
}