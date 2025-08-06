import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../data/product_data.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/filter_panel.dart';
import '../widgets/hero_slider.dart';
import '../widgets/product_card.dart';
import '../widgets/product_modal.dart';
import 'cart_page.dart';
import 'favorites_page.dart';
import '../widgets/login_dialog.dart';
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
  final Set<Product> _favoriteProducts = {};
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchFocused = false;
  bool _hasActiveFilters = false;

  int get _activeFilterCount {
    int count = 0;
    if (_selectedCategories.isNotEmpty) count++;
    if (_selectedProductTypes.isNotEmpty) count++;
    if (_selectedSizes.isNotEmpty) count++;
    if (_selectedQualities.isNotEmpty) count++;
    if (_selectedColors.isNotEmpty) count++;
    if (_selectedBrands.isNotEmpty) count++;
    if (_priceRange.start > 0 || _priceRange.end < 5000) count++;
    return count;
  }

  @override
  void initState() {
    super.initState();
    _applySorting();
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
        final inPrice = p.price >= _priceRange.start && p.price <= _priceRange.end;
        return inCategory && inType && inSize && inQuality && inColor && inBrand && inPrice;
      }).toList();
      _applySorting();
      
      // Check if any filters are active
      _hasActiveFilters = _activeFilterCount > 0 || _searchController.text.isNotEmpty;
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
      _hasActiveFilters = _searchController.text.isNotEmpty;
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

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.contact_phone, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            const Text(
              'İletişim Bilgileri',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildContactItem(
              icon: Icons.phone,
              title: 'Telefon',
              subtitle: '+90 536 495 02 62',
              owner: 'Gülden ÖZDEMİR',
              onTap: () => _launchUrl('tel:+905551234567'),
            ),
            const SizedBox(height: 16),
                         _buildContactItem(
               icon: Icons.chat,
               title: 'WhatsApp',
               subtitle: '+90 536 495 02 62',
               owner: 'Gülden ÖZDEMİR',
               onTap: () => _launchUrl('https://wa.me/905551234567'),
             ),
            const SizedBox(height: 16),
            _buildContactItem(
              icon: Icons.location_on,
              title: 'Adres',
              subtitle: 'İstiklal Mahallesi Şehit Karabaşoğlu No:15',
              owner: 'Serdivan/SAKARYA',
              onTap: () => _launchUrl('https://www.google.com/maps/place/%C4%B0stiklal,+%C5%9Eht.+Mehmet+Karaba%C5%9Fo%C4%9Flu+Cd.+No:15+D:1,+54100+Serdivan%2FSakarya/@40.7716751,30.3613879,1319m/data=!3m1!1e3!4m15!1m8!3m7!1s0x14ccb2be05b7013f:0x3604f00ab8790848!2zxLBzdGlrbGFsLCDFnmh0LiBNZWhtZXQgS2FyYWJhxZ9vxJ9sdSBDZC4gTm86MTUgRDoxLCA1NDEwMCBTZXJkaXZhbi9TYWthcnlh!3b1!8m2!3d40.7714326!4d30.3613183!16s%2Fg%2F11hbq_jkzd!3m5!1s0x14ccb2be05b7013f:0x3604f00ab8790848!8m2!3d40.7714326!4d30.3613183!16s%2Fg%2F11hbq_jkzd?entry=ttu&g_ep=EgoyMDI1MDczMC4wIKXMDSoASAFQAw%3D%3D'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Kapat',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String owner,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
                             decoration: BoxDecoration(
                 color: AppColors.primary.withValues(alpha: 0.1),
                 borderRadius: BorderRadius.circular(8),
               ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    owner,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
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
               const Text(
                 'SARE PERDE',
                 style: TextStyle(
                   fontSize: 32,
                   fontWeight: FontWeight.w700,
                   color: Colors.black,
                   letterSpacing: 1.5,
                   fontFamily: 'Life EF Regular SC',
                   shadows: [
                     Shadow(
                       color: AppColors.shadowMedium,
                       blurRadius: 4,
                       offset: Offset(0, 2),
                     ),
                   ],
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
           Container(
             width: 300,
             height: 40,
             decoration: BoxDecoration(
               color: AppColors.surface,
               borderRadius: BorderRadius.circular(8),
               border: Border.all(color: AppColors.border),
             ),
             child: TextField(
               controller: _searchController,
               decoration: InputDecoration(
                 hintText: 'Ürün ara...',
                 hintStyle: TextStyle(
                   color: AppColors.textSecondary,
                   fontSize: 14,
                 ),
                 prefixIcon: Icon(
                   Icons.search,
                   color: AppColors.textSecondary,
                   size: 20,
                 ),
                 suffixIcon: _searchController.text.isNotEmpty
                     ? IconButton(
                         icon: Icon(
                           Icons.clear,
                           color: AppColors.textSecondary,
                           size: 18,
                         ),
                         onPressed: () {
                           _searchController.clear();
                           setState(() {
                             _visibleProducts = List<Product>.from(ProductData.allProducts);
                             _applySorting();
                             _hasActiveFilters = _activeFilterCount > 0;
                           });
                         },
                       )
                     : null,
                 border: InputBorder.none,
                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
               ),
               style: const TextStyle(
                 fontSize: 14,
                 color: AppColors.textPrimary,
               ),
               onChanged: (value) {
                 setState(() {
                   if (value.isEmpty) {
                     _visibleProducts = List<Product>.from(ProductData.allProducts);
                     _applySorting();
                     _hasActiveFilters = false;
                   } else {
                     // TODO: Implement search functionality
                     // Filter products based on search query
                     _hasActiveFilters = true;
                   }
                 });
               },
               onTap: () {
                 setState(() {
                   _isSearchFocused = true;
                 });
               },
             ),
           ),
           const SizedBox(width: 8),
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
               // Kategoriler dropdown - will be implemented later
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(
                   content: Text('Kategoriler yakında kullanılabilir olacak!'),
                   duration: Duration(seconds: 2),
                 ),
               );
             },
             style: TextButton.styleFrom(
               foregroundColor: AppColors.textSecondary,
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
             ),
             child: const Text('Kategoriler', style: TextStyle(fontWeight: FontWeight.w600)),
           ),
           const SizedBox(width: 8),
                     TextButton(
             onPressed: () {
               showDialog(context: context, builder: (context) => const LoginDialog());
             },
             style: TextButton.styleFrom(
               foregroundColor: AppColors.textSecondary,
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
             ),
             child: const Text('Giriş Yap / Üye Ol', style: TextStyle(fontWeight: FontWeight.w600)),
           ),
           const SizedBox(width: 8),
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
                  Icon(Icons.favorite_border, color: AppColors.textSecondary, size: 22),
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
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
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
                                 color: AppColors.primary.withValues(alpha: 0.3),
                                 blurRadius: 8,
                                 offset: const Offset(0, 2),
                               ),
              ],
            ),
                         child: InkWell(
               onTap: () {
                 _showContactDialog();
               },
               borderRadius: BorderRadius.circular(12),
               child: const Padding(
                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                 child: Text(
                   'İletişim',
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
       body: GestureDetector(
         onTap: () {
           // Clear focus when clicking outside search bar
           FocusScope.of(context).unfocus();
           setState(() {
             _isSearchFocused = false;
           });
         },
         child: Stack(
           children: [
             CustomScrollView(
           slivers: [
             // Sticky Hero Slider
             SliverToBoxAdapter(
               child: Container(
                 padding: const EdgeInsets.all(16),
                 child: HeroSlider(
                   images: [
                     'assets/hero_slider.jpg',
                     'assets/gorsel1.jpg',
                     /*'assets/hero_slider3.jpg',*/
                     // Add more image paths here as needed
                   ],
                   height: 300,
                   autoPlay: true, // Enable auto-play for multiple images
                 ),
               ),
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

                     return ProductCard(
                       product: p,
                       isHovered: isHovered,
                       isFavorite: _isFavorite(p),
                       onHoverEnter: () => setState(() => _hoveredProductIndex = index),
                       onHoverExit: () => setState(() => _hoveredProductIndex = null),
                       onToggleFavorite: () => _toggleFavorite(p),
                       onAddToCart: () => _showDimensionDialog(p),
                       onInspect: () => _openProductModal(p),
                     );
                   },
                   childCount: _visibleProducts.length,
                 ),
               ),
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
                _showDimensionDialog(_selectedProduct!);
              }
            },
            isFavorite: _selectedProduct != null ? _isFavorite(_selectedProduct!) : false,
          ),
        ],
      ),
      ),
      floatingActionButton: _isFilterPanelVisible 
          ? null 
          : Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                return FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CartPage()),
                    );
                  },
                  label: Text(
                    'Sepetim${cartProvider.itemCount > 0 ? ' (${cartProvider.itemCount})' : ''}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
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
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                );
              },
            ),
    );
  }
} 