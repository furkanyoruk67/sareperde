import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../constants/app_colors.dart';
import '../data/product_data.dart';
import '../models/product.dart';
import '../providers/favorites_provider.dart';
import 'video_player_widget.dart';
import 'product_card.dart';

class VideoShowcaseSection extends StatefulWidget {
  const VideoShowcaseSection({super.key});

  @override
  State<VideoShowcaseSection> createState() => _VideoShowcaseSectionState();
}

class _VideoShowcaseSectionState extends State<VideoShowcaseSection> {
  late List<Product> _bestSellingProducts;
  final ScrollController _scrollController = ScrollController();
  int _currentIndex = 0;
  static const int _itemsPerView = 3; // Number of items visible at once
  static const int _autoScrollInterval = 5; // seconds
  static const int _autoScrollItems = 3; // items to scroll
  
  Timer? _autoScrollTimer;
  bool _isHovering = false;
  bool _showLeftArrow = false;
  bool _showRightArrow = true;

  @override
  void initState() {
    super.initState();
    // Get best selling products (first 10 products for showcase)
    _bestSellingProducts = ProductData.allProducts.take(10).toList();
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
    final itemWidth = 200.0; // Width of each item
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
    
    if (isMobile) {
      return _buildMobileLayout();
    } else {
      return _buildDesktopLayout();
    }
  }

  Widget _buildMobileLayout() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Video Player (full width)
          Container(
            height: 250,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            child: VideoPlayerWidget(
              videoPath: 'assets/videos/tanitim.mp4',
              height: 250,
              autoPlay: true,
            ),
          ),
          
          // Product Showcase (full width)
          Container(
            height: 300,
            width: double.infinity,
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
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'En Çok Satan Ürünler',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.textSecondary,
                        size: 14,
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
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _bestSellingProducts.length,
                          itemBuilder: (context, index) {
                            final product = _bestSellingProducts[index];
                            return Consumer<FavoritesProvider>(
                              builder: (context, favoritesProvider, child) {
                                return Container(
                                  width: 160,
                                  margin: const EdgeInsets.only(right: 12),
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
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Left Half - Video Player
          Expanded(
            flex: 1,
            child: Container(
              height: 400,
              margin: const EdgeInsets.only(right: 16),
              child: VideoPlayerWidget(
                videoPath: 'assets/videos/tanitim.mp4',
                height: 400,
                autoPlay: true,
              ),
            ),
          ),
          
          // Right Half - Product Showcase
          Expanded(
            flex: 1,
            child: Container(
              height: 400,
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
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'En Çok Satan Ürünler',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.textSecondary,
                          size: 16,
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
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _bestSellingProducts.length,
                            itemBuilder: (context, index) {
                              final product = _bestSellingProducts[index];
                              return Consumer<FavoritesProvider>(
                                builder: (context, favoritesProvider, child) {
                                  return Container(
                                    width: 200,
                                    margin: const EdgeInsets.only(right: 16),
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
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationArrow(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 40,
      height: 40,
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
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: AppColors.textPrimary,
          size: 20,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }
} 