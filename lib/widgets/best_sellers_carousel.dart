import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../constants/app_colors.dart';
import '../data/product_data.dart';
import '../models/product.dart';
import '../providers/favorites_provider.dart';
import 'product_card.dart';

class BestSellersCarousel extends StatefulWidget {
  final double height;
  final double width;

  const BestSellersCarousel({
    super.key,
    this.height = 300,
    this.width = 400,
  });

  @override
  State<BestSellersCarousel> createState() => _BestSellersCarouselState();
}

class _BestSellersCarouselState extends State<BestSellersCarousel> {
  late List<Product> _bestSellingProducts;
  final ScrollController _scrollController = ScrollController();
  int _currentIndex = 0;
  int get _itemsPerView {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    return isMobile ? 1 : 2; // Number of items visible at once
  }
  static const int _autoScrollInterval = 4; // seconds
  static const int _autoScrollItems = 1; // items to scroll
  
  Timer? _autoScrollTimer;
  bool _isHovering = false;
  bool _showLeftArrow = false;
  bool _showRightArrow = true;

  @override
  void initState() {
    super.initState();
    // Get best selling products (first 8 products for showcase)
    _bestSellingProducts = ProductData.allProducts.take(8).toList();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(
      const Duration(seconds: _autoScrollInterval),
      (timer) {
        if (!_isHovering && mounted) {
          _autoScrollToNext();
        }
      },
    );
  }

  void _autoScrollToNext() {
    if (_currentIndex >= _bestSellingProducts.length - _itemsPerView) {
      // Loop back to the beginning
      _currentIndex = 0;
    } else {
      _currentIndex = (_currentIndex + _autoScrollItems).clamp(0, _bestSellingProducts.length - _itemsPerView);
    }
    
    _scrollToIndex(_currentIndex);
    _updateArrowVisibility();
  }

  void _scrollToIndex(int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final itemWidth = isMobile ? 148.0 : 172.0; // Width of each item (including margin)
    final scrollPosition = index * itemWidth;
    
    _scrollController.animateTo(
      scrollPosition,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToPrevious() {
    if (_currentIndex > 0) {
      _currentIndex = (_currentIndex - _itemsPerView).clamp(0, _bestSellingProducts.length - _itemsPerView);
      _scrollToIndex(_currentIndex);
      _updateArrowVisibility();
    }
  }

  void _scrollToNext() {
    if (_currentIndex < _bestSellingProducts.length - _itemsPerView) {
      _currentIndex = (_currentIndex + _itemsPerView).clamp(0, _bestSellingProducts.length - _itemsPerView);
      _scrollToIndex(_currentIndex);
      _updateArrowVisibility();
    }
  }

  void _updateArrowVisibility() {
    setState(() {
      _showLeftArrow = _currentIndex > 0;
      _showRightArrow = _currentIndex < _bestSellingProducts.length - _itemsPerView;
    });
  }

  void _onHoverEnter() {
    setState(() {
      _isHovering = true;
    });
  }

  void _onHoverExit() {
    setState(() {
      _isHovering = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.surfaceVariant,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Row(
              children: [
                Icon(
                  Icons.star,
                  color: AppColors.primary,
                  size: isMobile ? 16 : 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'En Çok Satan Ürünler',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textSecondary,
                  size: isMobile ? 12 : 14,
                ),
              ],
            ),
          ),
          
          // Horizontal Scrollable Products with Navigation
          Expanded(
            child: MouseRegion(
              onEnter: (_) => _onHoverEnter(),
              onExit: (_) => _onHoverExit(),
              child: Stack(
                children: [
                  ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                                         padding: EdgeInsets.only(
                       left: isMobile ? 0 : 1,
                       right: isMobile ? 8 : 12,
                     ),
                    itemCount: _bestSellingProducts.length,
                    itemBuilder: (context, index) {
                      final product = _bestSellingProducts[index];
                      return Consumer<FavoritesProvider>(
                        builder: (context, favoritesProvider, child) {
                          return Container(
                            width: isMobile ? 140 : 160,
                            margin: EdgeInsets.only(right: isMobile ? 8 : 12),
                            child: ProductCard(
                              product: product,
                              isHovered: false,
                              isFavorite: favoritesProvider.isFavorite(product),
                              onHoverEnter: () {},
                              onHoverExit: () {},
                              onToggleFavorite: () {
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
                              },
                              onAddToCart: () {},
                              onInspect: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product.name} seçildi'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                  
                  // Navigation arrows
                  if (_showLeftArrow)
                    Positioned(
                      left: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _buildNavigationArrow(Icons.chevron_left, _scrollToPrevious),
                      ),
                    ),
                  
                  if (_showRightArrow)
                    Positioned(
                      right: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _buildNavigationArrow(Icons.chevron_right, _scrollToNext),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildNavigationArrow(IconData icon, VoidCallback onTap) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
          child: Container(
            width: isMobile ? 32 : 40,
            height: isMobile ? 32 : 40,
            child: Icon(
              icon,
              color: AppColors.primary,
              size: isMobile ? 16 : 20,
            ),
          ),
        ),
      ),
    );
  }
}
