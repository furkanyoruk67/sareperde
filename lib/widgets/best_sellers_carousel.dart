import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../constants/app_colors.dart';
import '../data/product_data.dart';
import '../models/product.dart';
import '../providers/favorites_provider.dart';

class BestSellersCarousel extends StatefulWidget {
  final double height;
  final double width;
  final Function(Product)? onProductInspect;

  const BestSellersCarousel({
    super.key,
    this.height = 300,
    this.width = 400,
    this.onProductInspect,
  });

  @override
  State<BestSellersCarousel> createState() => _BestSellersCarouselState();
}

class _BestSellersCarouselState extends State<BestSellersCarousel> {
  late List<Product> _bestSellingProducts;
  final ScrollController _scrollController = ScrollController();
  double _currentScrollPosition = 0;
  static const int _autoScrollInterval = 3; // seconds
  static const double _scrollStep = 1.0; // smooth scroll step
  
  Timer? _autoScrollTimer;
  bool _isHovering = false;
  bool _isUserScrolling = false;
  late List<Product> _byHalitProducts;
  int? _hoveredProductIndex;

  @override
  void initState() {
    super.initState();
    // Get best sellers products
    _byHalitProducts = ProductData.bestSellers;
    
    _bestSellingProducts = _getRandomProducts(_byHalitProducts, _byHalitProducts.length);
    // No duplication - show exact number of products
    
    _startAutoScroll();
    _scrollController.addListener(_onScroll);
  }
  
  List<Product> _getRandomProducts(List<Product> sourceList, int count) {
    if (sourceList.length <= count) return List<Product>.from(sourceList);
    
    final random = Random();
    final shuffled = List<Product>.from(sourceList)..shuffle(random);
    return shuffled.take(count).toList().cast<Product>();
  }
  
  void _onScroll() {
    if (_scrollController.hasClients) {
      setState(() {
        _currentScrollPosition = _scrollController.offset;
      });
    }
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
      const Duration(milliseconds: 50), // Smooth continuous scroll
      (timer) {
        if (!_isHovering && !_isUserScrolling && mounted && _scrollController.hasClients) {
          _autoScrollToNext();
        }
      },
    );
  }

  void _autoScrollToNext() {
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    final currentPosition = _scrollController.offset;
    
    if (currentPosition >= maxScrollExtent / 2) {
      // Reset to beginning for infinite loop effect
      _scrollController.jumpTo(0);
    } else {
      // Smooth auto-scroll
      _scrollController.animateTo(
        currentPosition + _scrollStep,
        duration: const Duration(milliseconds: 50),
        curve: Curves.linear,
      );
    }
  }

  void _scrollToPrevious() {
    if (_scrollController.hasClients) {
      final itemWidth = _getItemWidth();
      final newPosition = (_currentScrollPosition - itemWidth * 2).clamp(0.0, _scrollController.position.maxScrollExtent);
      
      setState(() => _isUserScrolling = true);
      _scrollController.animateTo(
        newPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      ).then((_) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) setState(() => _isUserScrolling = false);
        });
      });
    }
  }

  void _scrollToNext() {
    if (_scrollController.hasClients) {
      final itemWidth = _getItemWidth();
      final maxScrollExtent = _scrollController.position.maxScrollExtent;
      final newPosition = (_currentScrollPosition + itemWidth * 2).clamp(0.0, maxScrollExtent);
      
      setState(() => _isUserScrolling = true);
      _scrollController.animateTo(
        newPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      ).then((_) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) setState(() => _isUserScrolling = false);
        });
      });
    }
  }

  double _getItemWidth() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    return isMobile ? 180.0 : 220.0; // Mobil için kart genişliğini optimize ettik
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16, 
              vertical: isMobile ? 8 : 12
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.star,
                  color: AppColors.surface,
                  size: isMobile ? 16 : 18,
                ),
                SizedBox(width: isMobile ? 6 : 8),
                Text(
                  'ÇOK SATANLAR',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.surface,
                  ),
                ),
                SizedBox(width: isMobile ? 6 : 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_byHalitProducts.length} Ürün',
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
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
                  GestureDetector(
                    onPanUpdate: (details) {
                      setState(() => _isUserScrolling = true);
                      Future.delayed(const Duration(milliseconds: 1000), () {
                        if (mounted) setState(() => _isUserScrolling = false);
                      });
                    },
                    child: ListView.builder(
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
                              width: isMobile ? 180 : 160, // Mobil için kart genişliğini optimize ettik
                              margin: EdgeInsets.only(right: isMobile ? 12 : 12),
                              child: AspectRatio(
                                aspectRatio: isMobile ? 0.7 : 0.85, // Mobil için daha iyi oran
                                child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Product Image
                                    Expanded(
                                      flex: isMobile ? 4 : 3, // Mobil için resim alanını dengeledik
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(12),
                                        ),
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    AppColors.surfaceVariant,
                                                    AppColors.surface,
                                                  ],
                                                ),
                                              ),
                                              child: Image.asset(
                                                product.image,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    color: AppColors.surfaceVariant,
                                                    child: Icon(
                                                      Icons.image_not_supported,
                                                      color: AppColors.textSecondary,
                                                      size: 40,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            // Hover overlay with inspect button
                                            Positioned.fill(
                                              child: MouseRegion(
                                                onEnter: (_) => setState(() => _hoveredProductIndex = index),
                                                onExit: (_) => setState(() => _hoveredProductIndex = null),
                                                child: AnimatedOpacity(
                                                  opacity: _hoveredProductIndex == index ? 1.0 : 0.0,
                                                  duration: const Duration(milliseconds: 200),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary.withOpacity(0.3),
                                                    ),
                                                    child: Center(
                                                                                                              child: ElevatedButton.icon(
                                                          onPressed: () {
                                                            if (widget.onProductInspect != null) {
                                                              widget.onProductInspect!(product);
                                                            }
                                                          },
                                                        icon: Icon(
                                                          Icons.visibility,
                                                          size: isMobile ? 14 : 14, // Mobil için ikon boyutunu artırdık
                                                          color: Colors.white,
                                                        ),
                                                        label: Text(
                                                          'İncele',
                                                          style: TextStyle(
                                                            fontSize: isMobile ? 10 : 10, // Mobil için yazı boyutunu artırdık
                                                            fontWeight: FontWeight.w600,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: AppColors.primary,
                                                          foregroundColor: Colors.white,
                                                          padding: EdgeInsets.symmetric(
                                                            horizontal: isMobile ? 10 : 10, // Mobil için padding artırdık
                                                            vertical: isMobile ? 6 : 6, // Mobil için padding artırdık
                                                          ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
                                                          ),
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
                                    ),
                                    
                                                                         // Product Info
                                     Expanded(
                                       flex: isMobile ? 3 : 1, // Mobil için bilgi alanını optimize ettik
                                       child: Container(
                                         padding: EdgeInsets.all(isMobile ? 8 : 6), // Mobil için padding optimize edildi
                                         child: Column(
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                           children: [
                                             // Product Name
                                              SizedBox(
                                                height: isMobile ? 36 : 24,
                                                child: Text(
                                                  product.name,
                                                  style: TextStyle(
                                                    fontSize: isMobile ? 13 : 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.textPrimary,
                                                    height: 1.2,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                             
                                                                                           // Favorilere Ekle Button - At the bottom
                                               SizedBox(
                                                 width: double.infinity,
                                                 height: isMobile ? 34 : 24,
                                                 child: ElevatedButton.icon(
                                                  onPressed: () {
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
                                                                                                      icon: Icon(
                                                      favoritesProvider.isFavorite(product)
                                                          ? Icons.favorite
                                                          : Icons.favorite_border,
                                                      size: isMobile ? 16 : 10, // Mobil için ikon boyutunu optimize ettik
                                                    ),
                                                  label: Text(
                                                    favoritesProvider.isFavorite(product)
                                                        ? 'Favorilerden Çıkar'
                                                        : 'Favorilere Ekle',
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: favoritesProvider.isFavorite(product)
                                                        ? AppColors.error.withValues(alpha: 0.1)
                                                        : AppColors.primary.withValues(alpha: 0.1),
                                                    foregroundColor: favoritesProvider.isFavorite(product)
                                                        ? AppColors.error
                                                        : AppColors.primary,
                                                    elevation: 0,
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: isMobile ? 1 : 2,
                                                      vertical: isMobile ? 0 : 1,
                                                    ),
                                                    textStyle: TextStyle(
                                                      fontSize: isMobile ? 11 : 7, // Mobil için yazı boyutunu optimize ettik
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(3),
                                                    ),
                                                  ),
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
                            );
                          },
                        );
                      },
                    ),
                  ),
                  
                  // Navigation arrows - Always visible
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _buildNavigationArrow(Icons.chevron_left, _scrollToPrevious),
                    ),
                  ),
                  
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
