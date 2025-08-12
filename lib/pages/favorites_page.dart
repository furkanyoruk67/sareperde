import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../models/product.dart';
import '../providers/favorites_provider.dart';
import '../widgets/product_modal.dart';
import '../widgets/product_card.dart';

import '../widgets/footer.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  Product? _selectedProduct;
  bool _isModalOpen = false;
  int? _hoveredProductIndex;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        final favoriteProducts = favoritesProvider.favorites.toList();
        
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: isMobile ? AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset('assets/logo1.jpg', height: 32),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'FAVORİLERİM',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      letterSpacing: 1.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite, color: AppColors.surface, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${favoriteProducts.length}',
                        style: TextStyle(
                          color: AppColors.surface,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ) : null,
          body: Stack(
            children: [
              // Main Content with Navbar
              Column(
                children: [
                  // Desktop Navbar
                  if (!isMobile)
                    Container(
                      color: AppColors.surface,
                      child: SafeArea(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 12 : 20, 
                            vertical: isMobile ? 6 : 8
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shadowMedium,
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Image.asset('assets/logo1.jpg', height: 50),
                              ),
                              const SizedBox(width: 16),
                              Flexible(
                                child: Text(
                                  'SARE PERDE',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.black,
                                    letterSpacing: 2.0,
                                    fontStyle: FontStyle.italic,
                                    shadows: [
                                      Shadow(
                                        color: AppColors.shadowMedium,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.textSecondary,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Anasayfa', style: TextStyle(fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.favorite, color: AppColors.surface, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Favorilerim (${favoriteProducts.length})',
                                        style: TextStyle(
                                          color: AppColors.surface,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
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
                  
                  // Content Area
                  Expanded(
                    child: favoriteProducts.isEmpty
                        ? _buildEmptyState()
                        : _buildFavoritesContent(favoriteProducts, favoritesProvider),
                  ),
                ],
              ),
              
              // Product Modal
              if (_isModalOpen && _selectedProduct != null)
                Consumer<FavoritesProvider>(
                  builder: (context, favoritesProvider, child) {
                    return ProductModal(
                      selectedProduct: _selectedProduct,
                      isModalOpen: _isModalOpen,
                      onClose: _closeProductModal,
                      onToggleFavorite: () => _toggleFavorite(_selectedProduct!),
                      onAddToCart: () {},
                      isFavorite: favoritesProvider.isFavorite(_selectedProduct!),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border,
                size: isMobile ? 48 : 64,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: isMobile ? 16 : 24),
            Text(
              'Henüz Favori Ürününüz Yok',
              style: GoogleFonts.playfairDisplay(
                fontSize: isMobile ? 18 : 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 6 : 8),
            Text(
              'Beğendiğiniz ürünleri favorilere ekleyerek\nburada kolayca bulabilirsiniz',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: isMobile ? 24 : 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.shopping_bag, size: isMobile ? 16 : 20),
              label: Text(
                'Anasayfaya Dön',
                style: TextStyle(fontSize: isMobile ? 14 : 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 24, 
                  vertical: isMobile ? 10 : 12
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesContent(List<Product> favoriteProducts, FavoritesProvider favoritesProvider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    
    return CustomScrollView(
      slivers: [
        // Products Grid
        SliverPadding(
          padding: EdgeInsets.all(isMobile ? 4.0 : 8.0),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 2 : (isTablet ? 3 : 5),
              crossAxisSpacing: isMobile ? 4 : 8,
              mainAxisSpacing: isMobile ? 4 : 8,
              childAspectRatio: isMobile ? 0.75 : 0.85,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = favoriteProducts[index];
                final isHovered = _hoveredProductIndex == index;

                return Consumer<FavoritesProvider>(
                  builder: (context, favoritesProvider, child) {
                    return ProductCard(
                      product: product,
                      isHovered: isHovered,
                      isFavorite: favoritesProvider.isFavorite(product),
                      onHoverEnter: () => setState(() => _hoveredProductIndex = index),
                      onHoverExit: () => setState(() => _hoveredProductIndex = null),
                      onToggleFavorite: () => _toggleFavorite(product),
                      onAddToCart: () {},
                      onInspect: () => _openProductModal(product),
                    );
                  },
                );
              },
              childCount: favoriteProducts.length,
            ),
          ),
        ),
        
        // Footer
        SliverToBoxAdapter(
          child: Footer(),
        ),
      ],
    );
  }

  void _toggleFavorite(Product product) {
    final favoritesProvider = context.read<FavoritesProvider>();
    favoritesProvider.toggleFavorite(product);
    
    final isFavorite = favoritesProvider.isFavorite(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite 
            ? '${product.name} favorilere eklendi' 
            : '${product.name} favorilerden çıkarıldı',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: isFavorite ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }

  void _openProductModal(Product product) {
    setState(() {
      _selectedProduct = product;
      _isModalOpen = true;
    });
  }

  void _closeProductModal() {
    setState(() {
      _isModalOpen = false;
      _selectedProduct = null;
    });
  }
}