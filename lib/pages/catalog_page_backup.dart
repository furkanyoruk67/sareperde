import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../constants/app_colors.dart';
import '../data/product_data.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/filter_panel.dart';
import '../widgets/footer.dart';

import '../widgets/video_showcase_section.dart';
import '../widgets/sticky_video_player.dart';
import '../widgets/product_card.dart';
import '../widgets/product_modal.dart';
// import 'cart_page.dart'; // Commented out as cart functionality is disabled
import 'favorites_page.dart';
import '../widgets/dimension_dialog.dart';

enum SortOption {
  nameAZ,
  nameZA,
  priceLowHigh,
  priceHighLow,
}

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final Set<String> _selectedCategories = {};
  final Set<String> _selectedProductTypes = {};
  final Set<String> _selectedSizes = {};
  final Set<String> _selectedQualities = {};
  final Set<String> _selectedColors = {};
  final Set<String> _selectedBrands = {};
  RangeValues _priceRange = const RangeValues(0, 5000);
  SortOption _currentSortOption = SortOption.nameAZ;
  bool _isFilterPanelVisible = false;
  late List<Product> _visibleProducts = List<Product>.from(ProductData.allProducts);
  int? _hoveredProductIndex;
  Product? _selectedProduct;
  bool _isModalOpen = false;
  final ScrollController _scrollController = ScrollController();

  bool _hasActiveFilters = false;
  String? _hoveredCategory;

  int get _activeFilterCount {
    int count = 0;
    if (_selectedCategories.isNotEmpty) count++;
    if (_selectedProductTypes.isNotEmpty) count++;
    if (_selectedSizes.isNotEmpty) count++;
    if (_selectedQualities.isNotEmpty) count++;
    if (_selectedColors.isNotEmpty) count++;
    if (_selectedBrands.isNotEmpty) count++;
    // if (_priceRange.start > 0 || _priceRange.end < 5000) count++;
    return count;
  }

  @override
  void initState() {
    super.initState();
    _applySorting();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _visibleProducts = ProductData.allProducts.where((p) {
        final inCategory = _selectedCategories.isEmpty || _selectedCategories.contains(p.category);
        final inType = _selectedProductTypes.isEmpty || _selectedProductTypes.contains(p.productType);
        final inSize = _selectedSizes.isEmpty || _selectedSizes.contains(p.size);
        final inQuality = _selectedQualities.isEmpty || _selectedQualities.contains(p.quality);
        final inColor = _selectedColors.isEmpty || _selectedColors.contains(p.color);
        final inBrand = _selectedBrands.isEmpty || _selectedBrands.contains(p.brand);
        // final inPrice = p.price >= _priceRange.start && p.price <= _priceRange.end;
        return inCategory && inType && inSize && inQuality && inColor && inBrand; // && inPrice;
      }).toList();
      _applySorting();
      
      // Check if any filters are active
      _hasActiveFilters = _activeFilterCount > 0;
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedCategories.clear();
      _selectedProductTypes.clear();
      _selectedSizes.clear();
      _selectedQualities.clear();
      _selectedColors.clear();
      _selectedBrands.clear();
      _priceRange = const RangeValues(0, 5000);
      _visibleProducts = List<Product>.from(ProductData.allProducts);
      _applySorting();
      _hasActiveFilters = false;
    });
  }

  void _applySorting() {
    switch (_currentSortOption) {
      case SortOption.nameAZ:
        _visibleProducts.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case SortOption.nameZA:
        _visibleProducts.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case SortOption.priceLowHigh:
        _visibleProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighLow:
        _visibleProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
    }
  }

  void _changeSortOption(SortOption option) {
    setState(() {
      _currentSortOption = option;
      _applySorting();
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
    final favoritesProvider = context.read<FavoritesProvider>();
    if (favoritesProvider.isFavorite(product)) {
      favoritesProvider.removeFavorite(product);
    } else {
      favoritesProvider.addFavorite(product);
    }
  }

  bool _isFavorite(Product product) {
    return context.read<FavoritesProvider>().isFavorite(product);
  }

  void _showDimensionDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => DimensionDialog(
        product: product,
        onAddToCart: () {},
      ),
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        final width = result['width'] as double;
        final height = result['height'] as double;
        context.read<CartProvider>().addItem(product, width: width, height: height);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} sepete eklendi (${width.toStringAsFixed(0)}x${height.toStringAsFixed(0)} cm)'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    });
  }



  Widget _buildDropdownItem(String title) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title yakında kullanılabilir olacak!'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('URL açılamadı: $url'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
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
               const Flexible(
                 child: Text(
                   'SARE PERDE',
                   style: TextStyle(
                     fontSize: 32,
                     fontWeight: FontWeight.w300,
                     color: Colors.black,
                     letterSpacing: 2.0,
                     fontFamily: 'Candara, sans-serif',
                     fontStyle: FontStyle.italic,
                     shadows: [
                       Shadow(
                         color: AppColors.shadowMedium,
                         blurRadius: 4,
                         offset: Offset(0, 2),
                       ),
                     ],
                   ),
                   overflow: TextOverflow.ellipsis,
                 ),
               ),
             ],
           ),
         ),
                                                                       actions: [
             // TextButton(
             //   onPressed: () {},
             //   style: TextButton.styleFrom(
             //     foregroundColor: AppColors.textSecondary,
             //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
             //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
             //   ),
             //   child: const Text('Sipariş Takibi', style: TextStyle(fontWeight: FontWeight.w600)),
             // ),
             // const SizedBox(width: 8),
             TextButton(
               onPressed: () {
                 // Anasayfa navigation - currently stays on same page
               },
               style: TextButton.styleFrom(
                 foregroundColor: AppColors.textSecondary,
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
               ),
               child: const Text('Anasayfa', style: TextStyle(fontWeight: FontWeight.w600)),
             ),
             const SizedBox(width: 8),
             TextButton(
               onPressed: () {
                 // Tül kategorisi
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(
                     content: Text('Tül kategorisi yakında kullanılabilir olacak!'),
                     duration: Duration(seconds: 2),
                   ),
                 );
               },
               style: TextButton.styleFrom(
                 foregroundColor: AppColors.textSecondary,
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
               ),
               child: const Text('Tül', style: TextStyle(fontWeight: FontWeight.w600)),
             ),
             ),
             const SizedBox(width: 8),
             TextButton(
               onPressed: () {
                 // Stor Perde kategorisi
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(
                     content: Text('Stor Perde kategorisi yakında kullanılabilir olacak!'),
                     duration: Duration(seconds: 2),
                   ),
                 );
               },
               style: TextButton.styleFrom(
                 foregroundColor: AppColors.textSecondary,
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
               ),
               child: const Text('Stor Perde', style: TextStyle(fontWeight: FontWeight.w600)),
             ),
             const SizedBox(width: 8),
             TextButton(
               onPressed: () {
                 // Fon Perde kategorisi
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(
                     content: Text('Fon Perde kategorisi yakında kullanılabilir olacak!'),
                     duration: Duration(seconds: 2),
                   ),
                 );
               },
               style: TextButton.styleFrom(
                 foregroundColor: AppColors.textSecondary,
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
               ),
               child: const Text('Fon Perde', style: TextStyle(fontWeight: FontWeight.w600)),
             ),
             const SizedBox(width: 8),
             TextButton(
               onPressed: () {
                 // Jaluzi kategorisi
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(
                     content: Text('Jaluzi kategorisi yakında kullanılabilir olacak!'),
                     duration: Duration(seconds: 2),
                   ),
                 );
               },
               style: TextButton.styleFrom(
                 foregroundColor: AppColors.textSecondary,
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
               ),
               child: const Text('Jaluzi', style: TextStyle(fontWeight: FontWeight.w600)),
             ),
             const SizedBox(width: 8),
             TextButton(
               onPressed: () {
                 // Pilise kategorisi
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(
                     content: Text('Pilise kategorisi yakında kullanılabilir olacak!'),
                     duration: Duration(seconds: 2),
                   ),
                 );
               },
               style: TextButton.styleFrom(
                 foregroundColor: AppColors.textSecondary,
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
               ),
               child: const Text('Pilise', style: TextStyle(fontWeight: FontWeight.w600)),
             ),
             const SizedBox(width: 8),
             TextButton(
               onPressed: () {
                 // Aksesuar kategorisi
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(
                     content: Text('Aksesuar kategorisi yakında kullanılabilir olacak!'),
                     duration: Duration(seconds: 2),
                   ),
                 );
               },
               style: TextButton.styleFrom(
                 foregroundColor: AppColors.textSecondary,
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
               ),
               child: const Text('Aksesuar', style: TextStyle(fontWeight: FontWeight.w600)),
             ),
             const SizedBox(width: 8),
            // Search and Favorites icons
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: IconButton(
                    onPressed: () {
                      // TODO: Implement search functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Arama özelliği yakında kullanılabilir olacak!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: Icon(Icons.search, color: AppColors.textSecondary, size: 22),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 20),
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
                          builder: (context) => const FavoritesPage(),
                        ),
                      );
                    },
                   icon: Consumer<FavoritesProvider>(
                     builder: (context, favoritesProvider, child) {
                       return Stack(
                         children: [
                           Icon(Icons.favorite_border, color: AppColors.textSecondary, size: 22),
                           if (favoritesProvider.favorites.isNotEmpty)
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
                                 constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                 child: Text(
                                   '${favoritesProvider.favorites.length}',
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
                       );
                     },
                   ),
                 ),
               ),
             ],
           ),

        ],
      ),
             backgroundColor: AppColors.background,
               body: Stack(
          children: [
            // Main Content
                        CustomScrollView(
              controller: _scrollController,
           slivers: [
                                         // Hero Slider Section at the top
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  height: 400,
                  child: PageView.builder(
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              // Background Image
                              Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('assets/hero_slider.jpg'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              // Gradient Overlay
                              Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.black.withOpacity(0.3),
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.4),
                                    ],
                                  ),
                                ),
                              ),
                              // Content
                              Positioned(
                                bottom: 40,
                                left: 40,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'SARE PERDE',
                                      style: TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(0.5),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Kaliteli Perde Çözümleri',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(0.5),
                                            blurRadius: 2,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Koleksiyonlar yakında kullanılabilir olacak!'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'KOLEKSİYONLARI KEŞFET',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Video Section (after slider)
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  height: 300,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: kIsWeb 
                    ? YoutubePlayer(
                        controller: YoutubePlayerController.fromVideoId(
                          videoId: 'rOk0pK6KrCg',
                          params: const YoutubePlayerParams(
                            showControls: true,
                            showFullscreenButton: true,
                            mute: false,
                            enableCaption: false,
                            showVideoAnnotations: false,
                          ),
                        ),
                        aspectRatio: 16 / 9,
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.play_circle_outline,
                                size: 48,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Video Player',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Web platformunda video izleyebilirsiniz',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ),
              ),
               
               // Video and Product Showcase Section
              SliverToBoxAdapter(
                child: VideoShowcaseSection(),
              ),
             
             // Products Section
             SliverToBoxAdapter(
               child: Container(
                 padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                 width: double.infinity,
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           _hasActiveFilters ? 'Katalog' : 'Anasayfa',
                           style: const TextStyle(
                             fontSize: 24,
                             fontWeight: FontWeight.w700,
                             color: AppColors.textPrimary,
                             letterSpacing: -0.5,
                           ),
                         ),
                         const SizedBox(height: 4),
                         if (_hasActiveFilters)
                           Text(
                             '${_visibleProducts.length} ürün bulundu',
                             style: const TextStyle(
                               fontSize: 24,
                               fontWeight: FontWeight.w700,
                               color: AppColors.textPrimary,
                               letterSpacing: -0.5,
                             ),
                           ),
                       ],
                     ),
                    Row(
                      children: [
                                                 SizedBox(
                           height: 40,
                           width: 120,
                           child: PopupMenuButton<SortOption>(
                            onSelected: _changeSortOption,
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: SortOption.nameAZ,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.sort_by_alpha,
                                      size: 16,
                                      color: _currentSortOption == SortOption.nameAZ
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'İsim (A-Z)',
                                      style: TextStyle(
                                        color: _currentSortOption == SortOption.nameAZ
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                        fontWeight: _currentSortOption == SortOption.nameAZ
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: SortOption.nameZA,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.sort_by_alpha,
                                      size: 16,
                                      color: _currentSortOption == SortOption.nameZA
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'İsim (Z-A)',
                                      style: TextStyle(
                                        color: _currentSortOption == SortOption.nameZA
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                        fontWeight: _currentSortOption == SortOption.nameZA
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(),
                              PopupMenuItem(
                                value: SortOption.priceLowHigh,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_upward,
                                      size: 16,
                                      color: _currentSortOption == SortOption.priceLowHigh
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Fiyat (Düşük-Yüksek)',
                                      style: TextStyle(
                                        color: _currentSortOption == SortOption.priceLowHigh
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                        fontWeight: _currentSortOption == SortOption.priceLowHigh
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: SortOption.priceHighLow,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_downward,
                                      size: 16,
                                      color: _currentSortOption == SortOption.priceHighLow
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Fiyat (Yüksek-Düşük)',
                                      style: TextStyle(
                                        color: _currentSortOption == SortOption.priceHighLow
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                        fontWeight: _currentSortOption == SortOption.priceHighLow
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border),
                              ),
                                                             child: Row(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                   Icon(Icons.sort, size: 16, color: AppColors.textSecondary),
                                   const SizedBox(width: 8),
                                   const Text(
                                     'Sırala',
                                     style: TextStyle(
                                       fontSize: 14,
                                       fontWeight: FontWeight.w600,
                                       color: AppColors.textSecondary,
                                     ),
                                   ),
                                   const SizedBox(width: 4),
                                   Icon(Icons.arrow_drop_down, size: 16, color: AppColors.textSecondary),
                                 ],
                               ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 40,
                          width: 120,
                          child: Stack(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _isFilterPanelVisible = !_isFilterPanelVisible;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.filter_list,
                                    size: 16,
                                    color: _isFilterPanelVisible ? AppColors.surface : AppColors.textSecondary,
                                  ),
                                  label: Text(
                                    'Filtrele',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _isFilterPanelVisible ? AppColors.surface : AppColors.textSecondary,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isFilterPanelVisible ? AppColors.primary : AppColors.surface,
                                    foregroundColor: _isFilterPanelVisible ? AppColors.surface : AppColors.textSecondary,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    elevation: _isFilterPanelVisible ? 2 : 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                        color: _isFilterPanelVisible ? AppColors.primary : AppColors.border,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (_activeFilterCount > 0)
                                Positioned(
                                  right: 8,
                                  top: 8,
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
                                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                    child: Text(
                                      '$_activeFilterCount',
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
                      ],
                    ),
                  ],
                ),
               ),
             ),
             
             // Products Grid
             SliverPadding(
               padding: const EdgeInsets.all(8.0),
               sliver: SliverGrid(
                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                   crossAxisCount: 5,
                   crossAxisSpacing: 8,
                   mainAxisSpacing: 8,
                   childAspectRatio: 0.85,
                 ),
                 delegate: SliverChildBuilderDelegate(
                   (context, index) {
                     final p = _visibleProducts[index];
                     final isHovered = _hoveredProductIndex == index;

                     return Consumer<FavoritesProvider>(
                       builder: (context, favoritesProvider, child) {
                         return ProductCard(
                           product: p,
                           isHovered: isHovered,
                           isFavorite: favoritesProvider.isFavorite(p),
                           onHoverEnter: () => setState(() => _hoveredProductIndex = index),
                           onHoverExit: () => setState(() => _hoveredProductIndex = null),
                           onToggleFavorite: () => _toggleFavorite(p),
                           onAddToCart: () {}, // Add to Cart functionality commented out
                           onInspect: () => _openProductModal(p),
                         );
                       },
                     );
                   },
                   childCount: _visibleProducts.length,
                 ),
               ),
             ),
             
             // Footer
             SliverToBoxAdapter(
               child: Footer(),
             ),
           ],
         ),
          if (_isFilterPanelVisible)
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              width: 300,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowStrong,
                      blurRadius: 8,
                      offset: const Offset(-2, 0),
                    ),
                  ],
                ),
                child: FilterPanel(
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
                  onResetFilters: _resetFilters,
                  onClose: () {
                    setState(() {
                      _isFilterPanelVisible = false;
                    });
                  },
                ),
              ),
            ),
                                 Consumer<FavoritesProvider>(
              builder: (context, favoritesProvider, child) {
                return ProductModal(
                  selectedProduct: _selectedProduct,
                  isModalOpen: _isModalOpen,
                  onClose: _closeProductModal,
                  onToggleFavorite: () {
                    if (_selectedProduct != null) {
                      _toggleFavorite(_selectedProduct!);
                    }
                  },
                  onAddToCart: () {
                    // Add to Cart functionality commented out
                    /* if (_selectedProduct != null) {
                      _showDimensionDialog(_selectedProduct!);
                    } */
                  },
                  isFavorite: _selectedProduct != null ? favoritesProvider.isFavorite(_selectedProduct!) : false,
                );
              },
            ),
            

          ],
        ),
      floatingActionButton: _isFilterPanelVisible 
        ? null 
        : null, // Consumer<CartProvider>(
            // builder: (context, cartProvider, child) {
            //   return FloatingActionButton.extended(
            //     onPressed: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(builder: (context) => const CartPage()),
            //       );
            //     },
            //     label: Text(
            //       'Sepetim${cartProvider.itemCount > 0 ? ' (${cartProvider.itemCount})' : ''}',
            //       style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            //     ),
            //     icon: Stack(
            //       children: [
            //         const Icon(Icons.shopping_cart, size: 20),
            //         if (cartProvider.itemCount > 0)
            //           Positioned(
            //             right: 0,
            //             top: 0,
            //             child: Container(
            //               padding: const EdgeInsets.all(4),
            //               decoration: BoxDecoration(
            //                 color: AppColors.error,
            //                 borderRadius: BorderRadius.circular(10),
            //               ),
            //               constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            //               child: Text(
            //                 '${cartProvider.itemCount}',
            //                 style: const TextStyle(
            //                   color: AppColors.surface,
            //                   fontSize: 10,
            //               fontWeight: FontWeight.bold,
            //               ),
            //               textAlign: TextAlign.center,
            //             ),
            //           ),
            //       ],
            //     ),
            //     backgroundColor: AppColors.primary,
            //     foregroundColor: AppColors.surface,
            //     elevation: 8,
            //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            //   );
            // },
            // ),
    );
  }
} 