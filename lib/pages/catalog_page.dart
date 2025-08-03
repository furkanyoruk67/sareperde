import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../data/product_data.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/filter_panel.dart';
import '../widgets/product_card.dart';
import '../widgets/product_modal.dart';
import 'cart_page.dart';
import 'favorites_page.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({Key? key}) : super(key: key);

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  // --- Filtre state ---
  final Set<String> _selectedCategories = {};
  final Set<String> _selectedProductTypes = {};
  final Set<String> _selectedSizes = {};
  final Set<String> _selectedQualities = {};
  final Set<String> _selectedColors = {};
  final Set<String> _selectedBrands = {};
  RangeValues _priceRange = const RangeValues(0, 5000);

  // Gösterilen ürünler
  late List<Product> _visibleProducts = List<Product>.from(ProductData.allProducts);

  // --- Hover ve Modal state ---
  int? _hoveredProductIndex;
  Product? _selectedProduct;
  bool _isModalOpen = false;

  // --- Favorites state ---
  final Set<Product> _favoriteProducts = {};

  void _applyFilters() {
    setState(() {
      _visibleProducts = ProductData.allProducts.where((p) {
        final inCategory = _selectedCategories.isEmpty || _selectedCategories.contains(p.category);
        final inType = _selectedProductTypes.isEmpty || _selectedProductTypes.contains(p.productType);
        final inSize = _selectedSizes.isEmpty || _selectedSizes.contains(p.size);
        final inQuality = _selectedQualities.isEmpty || _selectedQualities.contains(p.quality);
        final inColor = _selectedColors.isEmpty || _selectedColors.contains(p.color);
        final inBrand = _selectedBrands.isEmpty || _selectedBrands.contains(p.brand);
        final inPrice = p.price >= _priceRange.start && p.price <= _priceRange.end;
        return inCategory && inType && inSize && inQuality && inColor && inBrand && inPrice;
      }).toList();
    });
  }

  void _openProductModal(Product product) {
    setState(() {
      _selectedProduct = product;
      _isModalOpen = true;
    });
  }

  void _closeProductModal() {
    setState(() {
      _selectedProduct = null;
      _isModalOpen = false;
    });
  }

  void _toggleFavorite(Product product) {
    setState(() {
      if (_favoriteProducts.contains(product)) {
        _favoriteProducts.remove(product);
      } else {
        _favoriteProducts.add(product);
      }
    });
  }

  bool _isFavorite(Product product) {
    return _favoriteProducts.contains(product);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset('assets/logo1.jpg', height: 28),
              ),
              const SizedBox(width: 16),
              const Text(
                'Sare Perde',
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
        actions: [
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Sipariş Takibi',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Giriş Yap / Üye Ol',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 16),
          // Favorites button
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoritesPage(
                      favoriteProducts: _favoriteProducts,
                      onRemoveFromFavorites: (product) {
                        setState(() {
                          _favoriteProducts.remove(product);
                        });
                      },
                    ),
                  ),
                );
              },
              icon: Stack(
                children: [
                  Icon(
                    Icons.favorite_border,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                  if (_favoriteProducts.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowMedium,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '${_favoriteProducts.length}',
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
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  '05325958476',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.surface,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Row(
            children: [
              // --- SOL FİLTRE PANELİ ---
              FilterPanel(
                selectedCategories: _selectedCategories,
                selectedProductTypes: _selectedProductTypes,
                selectedSizes: _selectedSizes,
                selectedQualities: _selectedQualities,
                selectedColors: _selectedColors,
                selectedBrands: _selectedBrands,
                priceRange: _priceRange,
                onPriceRangeChanged: (values) {
                  setState(() {
                    _priceRange = values;
                  });
                },
                onCategoryChanged: (category, isSelected) {
                  setState(() {
                    if (isSelected) {
                      _selectedCategories.add(category);
                    } else {
                      _selectedCategories.remove(category);
                    }
                  });
                },
                onProductTypeChanged: (type, isSelected) {
                  setState(() {
                    if (isSelected) {
                      _selectedProductTypes.add(type);
                    } else {
                      _selectedProductTypes.remove(type);
                    }
                  });
                },
                onSizeChanged: (size, isSelected) {
                  setState(() {
                    if (isSelected) {
                      _selectedSizes.add(size);
                    } else {
                      _selectedSizes.remove(size);
                    }
                  });
                },
                onQualityChanged: (quality, isSelected) {
                  setState(() {
                    if (isSelected) {
                      _selectedQualities.add(quality);
                    } else {
                      _selectedQualities.remove(quality);
                    }
                  });
                },
                onColorChanged: (color, isSelected) {
                  setState(() {
                    if (isSelected) {
                      _selectedColors.add(color);
                    } else {
                      _selectedColors.remove(color);
                    }
                  });
                },
                onBrandChanged: (brand, isSelected) {
                  setState(() {
                    if (isSelected) {
                      _selectedBrands.add(brand);
                    } else {
                      _selectedBrands.remove(brand);
                    }
                  });
                },
                onApplyFilters: _applyFilters,
              ),

              // --- ÜRÜN LİSTESİ ---
              Expanded(
                child: Column(
                  children: [
                    // Üst bilgi çubuğu
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Katalog',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_visibleProducts.length} ürün bulundu',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          // Buraya sıralama vs. eklenebilir
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.sort,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Sırala',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Grid
                    Expanded(
                      child: LayoutBuilder(
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
                              itemCount: _visibleProducts.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.70,
                              ),
                              itemBuilder: (context, index) {
                                final p = _visibleProducts[index];
                                final isHovered = _hoveredProductIndex == index;

                                return ProductCard(
                                  product: p,
                                  isHovered: isHovered,
                                  isFavorite: _isFavorite(p),
                                  onHoverEnter: () => setState(() => _hoveredProductIndex = index),
                                  onHoverExit: () => setState(() => _hoveredProductIndex = null),
                                  onToggleFavorite: () => _toggleFavorite(p),
                                  onAddToCart: () {
                                    context.read<CartProvider>().addItem(p);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${p.name} sepete eklendi'),
                                        backgroundColor: AppColors.success,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    );
                                  },
                                  onInspect: () => _openProductModal(p),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Modal overlay
          ProductModal(
            selectedProduct: _selectedProduct,
            isModalOpen: _isModalOpen,
            onClose: _closeProductModal,
            onToggleFavorite: () {
              if (_selectedProduct != null) {
                _toggleFavorite(_selectedProduct!);
              }
            },
            onAddToCart: () {
              if (_selectedProduct != null) {
                context.read<CartProvider>().addItem(_selectedProduct!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${_selectedProduct!.name} sepete eklendi'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }
            },
            isFavorite: _selectedProduct != null ? _isFavorite(_selectedProduct!) : false,
          ),
        ],
      ),

      // Sağ alt köşe sepet butonu
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
    );
  }
} 