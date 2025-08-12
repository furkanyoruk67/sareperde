import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../data/product_data.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/filter_panel.dart';
import '../widgets/footer.dart';
import '../widgets/product_card.dart';
import '../widgets/product_modal.dart';
import '../widgets/best_sellers_carousel.dart';

import 'favorites_page.dart';
import '../widgets/dimension_dialog.dart';

// Animated Dropdown Menu Widget
class AnimatedDropdownMenu extends StatefulWidget {
  final String title;
  final List<String> items;
  final void Function(String) onItemSelected;

  const AnimatedDropdownMenu({
    super.key,
    required this.title,
    required this.items,
    required this.onItemSelected,
  });

  @override
  State<AnimatedDropdownMenu> createState() => _AnimatedDropdownMenuState();
}

class _AnimatedDropdownMenuState extends State<AnimatedDropdownMenu>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isOpen = false;
  bool _isHovered = false;
  bool _isDropdownHovered = false;
  String? _hoveredItem;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 250));

    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _handleTap() {
    _toggleDropdown();
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _controller.forward();
    setState(() {
      _isOpen = true;
      _isDropdownHovered = false;
      _hoveredItem = null;
    });
  }

  void _closeDropdown() {
    _controller.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      setState(() {
        _isOpen = false;
        _isDropdownHovered = false;
        _hoveredItem = null;
      });
    });
  }

  void _onHoverEnter() {
    setState(() => _isHovered = true);
    if (!_isOpen) {
      _openDropdown();
    }
  }

  void _onHoverExit() {
    setState(() => _isHovered = false);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!_isHovered && mounted && !_isDropdownHovered) {
        _closeDropdown();
      }
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: Offset(0, size.height),
          showWhenUnlinked: false,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(6),
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: StatefulBuilder(
                  builder: (context, setDropdownState) {
                    return MouseRegion(
                      onEnter: (_) {
                        setState(() => _isDropdownHovered = true);
                      },
                      onExit: (_) {
                        setState(() => _isDropdownHovered = false);
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (!_isHovered && mounted && !_isDropdownHovered) {
                            _closeDropdown();
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: widget.items.map((item) {
                            final isHovered = _hoveredItem == item;
                            return MouseRegion(
                              onEnter: (_) {
                                setDropdownState(() => _hoveredItem = item);
                              },
                              onExit: (_) {
                                setDropdownState(() => _hoveredItem = null);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: isHovered 
                                    ? AppColors.primary.withOpacity(0.12)
                                    : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(6),
                                  onTap: () {
                                    widget.onItemSelected(item);
                                    _closeDropdown();
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 150),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isHovered ? FontWeight.w600 : FontWeight.w500,
                                        color: isHovered
                                            ? AppColors.primary
                                            : AppColors.textPrimary,
                                      ),
                                      child: Text(item),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) => _onHoverEnter(),
        onExit: (_) => _onHoverExit(),
        child: GestureDetector(
          onTap: _handleTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: _isOpen || _isHovered ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title, 
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum SortOption {
  nameAZ,
  nameZA,
  // priceLowHigh, // Fiyat sıralaması kapatıldı
  // priceHighLow, // Fiyat sıralaması kapatıldı
}

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> with TickerProviderStateMixin {
  final Set<String> _selectedCategories = {};
  final Set<String> _selectedProductTypes = {};
  final Set<String> _selectedSizes = {};
  final Set<String> _selectedQualities = {};
  final Set<String> _selectedColors = {};
  final Set<String> _selectedBrands = {};
  RangeValues _priceRange = const RangeValues(0, 5000);
  SortOption _currentSortOption = SortOption.nameAZ;
  bool _isFilterPanelVisible = false;
  bool isFilterOpen = false; // sayfa state'inde
  late List<Product> _visibleProducts = List<Product>.from(ProductData.homepageProducts);
  int? _hoveredProductIndex;
  Product? _selectedProduct;
  bool _isModalOpen = false;
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();
  Timer? _sliderTimer;
  int _currentSliderIndex = 0;
  
  // Expandable menü için state'ler
  final Set<String> _expandedCategories = {};
  bool _isMobileMenuOpen = false;
  OverlayEntry? _mobileMenuOverlayEntry;
  
  // Pagination için state'ler
  int _currentPageSize = 20;
  final int _pageIncrement = 20;
  bool _isLoadingMore = false;

  // List of slider images from the Slider folder
  final List<String> sliderImages = [
    'assets/Slider/Ekran görüntüsü 2025-08-11 233136.png',
    'assets/Slider/Ekran görüntüsü 2025-08-11 233113.png',
    'assets/Slider/Ekran görüntüsü 2025-08-11 232840.png',
    'assets/Slider/Ekran görüntüsü 2025-08-11 232819.png',
    'assets/Slider/Ekran görüntüsü 2025-08-11 232717.png',
  ];

  bool _hasActiveFilters = false;
  String _searchQuery = '';
  bool _isSearching = false;

  Widget _buildAnimatedCategoryButton(String category, List<String> items) {
    return AnimatedDropdownMenu(
      title: category,
      items: items,
      onItemSelected: (String selectedItem) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$selectedItem kategorisi yakında kullanılabilir olacak!'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_expandedCategories.contains(category)) {
        _expandedCategories.remove(category);
      } else {
        _expandedCategories.add(category);
      }
    });
  }

  void _openMobileMenu() {
    if (_isMobileMenuOpen) return;
    
    _mobileMenuOverlayEntry = _createMobileMenuOverlay();
    Overlay.of(context).insert(_mobileMenuOverlayEntry!);
    setState(() {
      _isMobileMenuOpen = true;
    });
  }

  void _closeMobileMenu() {
    if (!_isMobileMenuOpen) return;
    
    _mobileMenuOverlayEntry?.remove();
    _mobileMenuOverlayEntry = null;
    setState(() {
      _isMobileMenuOpen = false;
      _expandedCategories.clear(); // Tüm kategorileri kapat
    });
  }

  void _updateMobileMenu() {
    if (!_isMobileMenuOpen) return;
    
    _mobileMenuOverlayEntry?.remove();
    _mobileMenuOverlayEntry = _createMobileMenuOverlay();
    Overlay.of(context).insert(_mobileMenuOverlayEntry!);
  }

  OverlayEntry _createMobileMenuOverlay() {
    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _closeMobileMenu,
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {}, // Menüye tıklamayı engelle
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    margin: EdgeInsets.only(top: 60, right: 16, left: 16),
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Kategoriler',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: _closeMobileMenu,
                                icon: Icon(Icons.close, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        // Menu Items
                        Flexible(
                          child: SingleChildScrollView(
                            child: Column(
                              children: _buildMobileMenuItems(),
                            ),
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
      ),
    );
  }

  List<Widget> _buildMobileMenuItems() {
    List<Widget> menuItems = [];
    
    // Anasayfa
    menuItems.add(_buildMenuItem('Anasayfa', () {
      _closeMobileMenu();
      // Anasayfa navigation
    }));
    
    // Kategoriler ve alt kategorileri
    final categories = {
      'tul': {'title': 'TÜL', 'items': ['Bambu', 'Keten', 'Krep', 'File']},
      'stor': {'title': 'STOR PERDE', 'items': ['Keten', 'Panama', 'Mat', 'Güneşlik', 'Lazer Kesim', 'Simli']},
      'fon': {'title': 'FON PERDE', 'items': ['Dokuma', 'Keten Doku', 'Saten', 'Örme']},
      'jaluzi': {'title': 'JALUZİ', 'items': ['Plastik', 'Kumaş', 'Alüminyum', 'Ahşap']},
      'plise': {'title': 'PLİSE', 'items': ['Black-out', 'Keten', 'Honeycamp']},
      'aksesuar': {'title': 'AKSESUAR', 'items': ['Rustik', 'Broçal', 'Püskül', 'Korniş', 'Sarkıt', 'Elçek', 'Bordür']},
    };

    categories.forEach((key, categoryData) {
      final title = categoryData['title'] as String;
      final subItems = categoryData['items'] as List<String>;
      final isExpanded = _expandedCategories.contains(key);
      
      // Ana kategori başlığı
      menuItems.add(_buildCategoryHeader(title, isExpanded, () {
        _toggleCategory(key);
        _updateMobileMenu(); // Menüyü yeniden oluştur
      }));
      
      // Alt kategoriler (sadece açıksa göster)
      if (isExpanded) {
        for (String item in subItems) {
          menuItems.add(_buildSubMenuItem(item, () {
            _closeMobileMenu();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$item yakında kullanılabilir olacak!'),
                duration: const Duration(seconds: 2),
              ),
            );
          }));
        }
      }
    });
    
    return menuItems;
  }

  Widget _buildMenuItem(String title, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(String title, bool isExpanded, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: AppColors.primary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubMenuItem(String title, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(left: 32, right: 16, top: 12, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  int get _activeFilterCount {
    int count = 0;
    if (_selectedProductTypes.isNotEmpty) count++;
    if (_selectedSizes.isNotEmpty) count++;
    if (_selectedQualities.isNotEmpty) count++;
    if (_selectedColors.isNotEmpty) count++;
    if (_selectedBrands.isNotEmpty) count++;
    return count;
  }

  @override
  void initState() {
    super.initState();
    _applyFilters();
    _startSliderTimer();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    _sliderTimer?.cancel();
    _mobileMenuOverlayEntry?.remove();
    super.dispose();
  }

  void _startSliderTimer() {
    _sliderTimer?.cancel();
    _sliderTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentSliderIndex = (_currentSliderIndex + 1) % sliderImages.length;
        });
        _pageController.animateToPage(
          _currentSliderIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopSliderTimer() {
    _sliderTimer?.cancel();
  }

  void _resetSliderTimer() {
    _stopSliderTimer();
    _startSliderTimer();
  }

  void _applyFilters() {
    _visibleProducts = ProductData.homepageProducts.where((product) {
      // Arama filtresi
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final productName = product.name.toLowerCase();
        final productType = product.productType.toLowerCase();
        final productColor = product.color.toLowerCase();
        final productBrand = product.brand.toLowerCase();
        
        if (!productName.contains(query) && 
            !productType.contains(query) && 
            !productColor.contains(query) && 
            !productBrand.contains(query)) {
          return false;
        }
      }
      
      // Fiyat filtresi - Kapatıldı
      // if (product.price < _priceRange.start || product.price > _priceRange.end) {
      //   return false;
      // }
      
      // Ürün tipi filtresi
      if (_selectedProductTypes.isNotEmpty && !_selectedProductTypes.contains(product.productType)) {
        return false;
      }
      
      // Boyut filtresi
      if (_selectedSizes.isNotEmpty && !_selectedSizes.contains(product.size)) {
        return false;
      }
      
      // Kalite filtresi
      if (_selectedQualities.isNotEmpty && !_selectedQualities.contains(product.quality)) {
        return false;
      }
      
      // Renk filtresi
      if (_selectedColors.isNotEmpty && !_selectedColors.contains(product.color)) {
        return false;
      }
      
      // Marka filtresi
      if (_selectedBrands.isNotEmpty && !_selectedBrands.contains(product.brand)) {
        return false;
      }
      
      return true;
    }).toList();
    
    _applySorting();
    _resetPagination(); // Reset pagination when filters change
  }

  void _applySorting() {
    switch (_currentSortOption) {
      case SortOption.nameAZ:
        _visibleProducts.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case SortOption.nameZA:
        _visibleProducts.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      // case SortOption.priceLowHigh: // Fiyat sıralaması kapatıldı
      //   _visibleProducts.sort((a, b) => a.price.compareTo(b.price));
      //   break;
      // case SortOption.priceHighLow: // Fiyat sıralaması kapatıldı
      //   _visibleProducts.sort((a, b) => b.price.compareTo(a.price));
      //   break;
    }
  }

  void _changeSortOption(SortOption option) {
    setState(() {
      _currentSortOption = option;
      _applyFilters();
    });
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
      _applyFilters();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _isSearching = false;
      _applyFilters();
    });
  }

  int _getSearchResultsCount(String query) {
    if (query.isEmpty) return ProductData.homepageProducts.length;
    
    return ProductData.homepageProducts.where((product) {
      final queryLower = query.toLowerCase();
      final productName = product.name.toLowerCase();
      final productType = product.productType.toLowerCase();
      final productColor = product.color.toLowerCase();
      final productBrand = product.brand.toLowerCase();
      
      return productName.contains(queryLower) || 
             productType.contains(queryLower) || 
             productColor.contains(queryLower) || 
             productBrand.contains(queryLower);
    }).length;
  }

  void _showSearchDialog() {
    String tempSearchQuery = _searchQuery;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
          children: [
            Icon(Icons.search, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Ürün Ara'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Ürün adı, tip, renk veya marka ara...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: tempSearchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          tempSearchQuery = '';
                          setDialogState(() {});
                        },
                        icon: Icon(Icons.clear, color: AppColors.textSecondary),
                      )
                    : null,
              ),
              onChanged: (value) {
                tempSearchQuery = value;
                setDialogState(() {});
              },
              onSubmitted: (value) {
                Navigator.pop(context);
                _performSearch(value);
              },
            ),
            if (tempSearchQuery.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Arama sonuçları: ${_getSearchResultsCount(tempSearchQuery)} ürün bulundu',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performSearch(tempSearchQuery);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Ara'),
          ),
        ],
        ),
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

  void _openFilter() {
    setState(() {
      isFilterOpen = true;
      _isFilterPanelVisible = true;
    });
  }

  void _closeFilter() {
    setState(() {
      isFilterOpen = false;
      _isFilterPanelVisible = false;
    });
  }

  void _loadMoreProducts() {
    setState(() {
      _isLoadingMore = true;
    });
    
    // Simulate loading delay for UX
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _currentPageSize += _pageIncrement;
          _isLoadingMore = false;
        });
      }
    });
  }

  void _resetPagination() {
    setState(() {
      _currentPageSize = 20;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isMobile ? AppBar(
        backgroundColor: Colors.white.withOpacity(0.95),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.98),
                Colors.grey.shade50.withOpacity(0.95),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: AppColors.primary.withOpacity(0.15),
                width: 1,
              ),
            ),
          ),
        ),
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
                'SARE PERDE',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                  letterSpacing: 1.0,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showSearchDialog(),
            icon: Icon(Icons.search, color: AppColors.textSecondary),
          ),
          Consumer<FavoritesProvider>(
            builder: (context, favoritesProvider, child) {
              final favoriteCount = favoritesProvider.favorites.length;
              return Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FavoritesPage()),
                      );
                    },
                    icon: Icon(
                      Icons.favorite,
                      color: favoriteCount > 0 ? AppColors.error : AppColors.textSecondary,
                    ),
                  ),
                  if (favoriteCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          favoriteCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
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
          IconButton(
            onPressed: _openMobileMenu,
            icon: Icon(Icons.menu, color: AppColors.textSecondary),
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
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.98),
                        Colors.grey.shade50.withOpacity(0.96),
                      ],
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.primary.withOpacity(0.12),
                        width: 1,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                          if (!isTablet) ...[
                            TextButton(
                              onPressed: () {
                                // Anasayfa navigation
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Anasayfa', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(width: 8),
                            _buildAnimatedCategoryButton('Tül', ['Bambu', 'Keten', 'Krep', 'File']),
                            const SizedBox(width: 8),
                            _buildAnimatedCategoryButton('Stor Perde', ['Keten', 'Panama', 'Mat', 'Güneşlik', 'Lazer Kesim', 'Simli']),
                            const SizedBox(width: 8),
                            _buildAnimatedCategoryButton('Fon Perde', ['Dokuma', 'Keten Doku', 'Saten', 'Örme']),
                            const SizedBox(width: 8),
                            _buildAnimatedCategoryButton('Jaluzi', ['Plastik', 'Kumaş', 'Alüminyum', 'Ahşap']),
                            const SizedBox(width: 8),
                            _buildAnimatedCategoryButton('Plise', ['Black-out', 'Keten', 'Honeycamp']),
                            const SizedBox(width: 8),
                            _buildAnimatedCategoryButton('Aksesuar', ['Rustik', 'Broçal', 'Püskül', 'Korniş', 'Sarkıt', 'Elçek', 'Bordür']),
                            const SizedBox(width: 8),
                          ],
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
                                    _showSearchDialog();
                                  },
                                  icon: Icon(Icons.search, color: AppColors.textSecondary, size: 22),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Consumer<FavoritesProvider>(
                                  builder: (context, favoritesProvider, child) {
                                    final favoriteCount = favoritesProvider.favorites.length;
                                    return Stack(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => FavoritesPage()),
                                            );
                                          },
                                          icon: Icon(
                                            Icons.favorite,
                                            color: favoriteCount > 0
                                                ? AppColors.error
                                                : AppColors.textSecondary,
                                            size: 22,
                                          ),
                                        ),
                                        if (favoriteCount > 0)
                                          Positioned(
                                            right: 8,
                                            top: 8,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: AppColors.error,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: AppColors.surface,
                                                  width: 1,
                                                ),
                                              ),
                                              constraints: const BoxConstraints(
                                                minWidth: 12,
                                                minHeight: 12,
                                              ),
                                              child: Text(
                                                favoriteCount.toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 8,
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
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // Main scrollable content
              Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // Hero Slider Section
                    SliverToBoxAdapter(
                      child: Container(
                        width: double.infinity,
                        height: isMobile ? 350 : 500,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: sliderImages.length, // Updated to match the number of slider images
                          onPageChanged: (index) {
                            setState(() {
                              _currentSliderIndex = index;
                            });
                            _resetSliderTimer();
                          },
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.grey[100],
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(sliderImages[index]),
                                          fit: BoxFit.contain,
                                          alignment: Alignment.center,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.black.withValues(alpha: 0.3),
                                            Colors.transparent,
                                            Colors.black.withValues(alpha: 0.4),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: isMobile ? 20 : 40,
                                      left: isMobile ? 20 : 40,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'SARE PERDE',
                                            style: TextStyle(
                                              fontSize: isMobile ? 24 : 48,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black.withValues(alpha: 0.5),
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
                                              fontSize: isMobile ? 14 : 24,
                                              fontWeight: FontWeight.w300,
                                              color: Colors.white,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black.withValues(alpha: 0.5),
                                                  blurRadius: 2,
                                                  offset: const Offset(0, 1),
                                                ),
                                              ],
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
                    
                    // Çok Satanlar Section
                    // Video Section with Stack for Filter Panel
                     SliverToBoxAdapter(
                       child: Container(
                         width: double.infinity,
                         height: isMobile ? 520 : 300, // Mobilde daha yüksek alan
                         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                         child: LayoutBuilder(
                           builder: (context, constraints) {
                             final screenWidth = MediaQuery.of(context).size.width;
                             final isMobile = screenWidth < 768;
                             
                             if (isMobile) {
                               // Mobile layout: Stack vertically
                               return Column(
                                 children: [
                                  // Video Section (Top)
                                  Expanded(
                                    flex: 4, // Video için alan
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 20), // Video ile carousel arası boşluk
                                       child: Stack(
                                         children: [
                                           // Video as background
                                           AbsorbPointer(
                                             absorbing: isFilterOpen,
                                             child: kIsWeb 
                                               ? AspectRatio(
                                                   aspectRatio: 16 / 9,
                                                   child: YoutubePlayer(
                                                     controller: YoutubePlayerController.fromVideoId(
                                                       videoId: 'YEkPpy_hGQM',
                                                       params: const YoutubePlayerParams(
                                                         showControls: true,
                                                         showFullscreenButton: true,
                                                         mute: false,
                                                         enableCaption: false,
                                                         showVideoAnnotations: false,
                                                       ),
                                                     ),
                                                   ),
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
                                         ],
                                       ),
                                     ),
                                   ),
                                   
                                                                     // Best Sellers Section (Bottom)
                                  Expanded(
                                    flex: 6, // Çok Satanlar için daha fazla alan
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 0),
                                      child: BestSellersCarousel(
                                        height: double.infinity,
                                         width: double.infinity,
                                         onProductInspect: (Product product) {
                                           _openProductModal(product);
                                         },
                                       ),
                                     ),
                                   ),
                                 ],
                               );
                             } else {
                               // Desktop layout: Side by side
                                                               return Row(
                                  children: [
                                    // Video Section (Left side) - Daha sola kaydırıldı
                                                                         Expanded(
                                       flex: 1,
                                       child: Container(
                                         margin: const EdgeInsets.only(right: 8),
                                       child: Stack(
                                         children: [
                                           // Video as background
                                           AbsorbPointer(
                                             absorbing: isFilterOpen,
                                             child: kIsWeb 
                                               ? AspectRatio(
                                                   aspectRatio: 16 / 9,
                                                   child: YoutubePlayer(
                                                     controller: YoutubePlayerController.fromVideoId(
                                                       videoId: 'YEkPpy_hGQM',
                                                       params: const YoutubePlayerParams(
                                                         showControls: true,
                                                         showFullscreenButton: true,
                                                         mute: false,
                                                         enableCaption: false,
                                                         showVideoAnnotations: false,
                                                       ),
                                                     ),
                                                   ),
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
                                         ],
                                       ),
                                     ),
                                   ),
                                   
                                                                       // Best Sellers Carousel Section (Right side) - Video ile aynı satırda
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        margin: const EdgeInsets.only(left: 8, top: 8), // Desktop için de üst margin ekledik
                                        child: BestSellersCarousel(
                                          height: 380, // Desktop için de yüksekliği daha da artırdık
                                          width: double.infinity,
                                          onProductInspect: (Product product) {
                                            _openProductModal(product);
                                          },
                                        ),
                                      ),
                                    ),
                                 ],
                               );
                             }
                           },
                         ),
                       ),
                     ),
                     
                    
                    // Products Section
                    SliverToBoxAdapter(
                      child: Container(
                        margin: EdgeInsets.only(top: isMobile ? 24 : 32), // Ürünler bölümünü daha aşağı kaydırdık
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 16 : 32, 
                          vertical: isMobile ? 16 : 20
                        ),
                        width: double.infinity,
                        child: isMobile 
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isSearching ? 'Arama Sonuçları' : (_hasActiveFilters ? 'Katalog' : 'Anasayfa'),
                                  style: TextStyle(
                                    fontSize: isMobile ? 20 : 24,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (_isSearching) ...[
                                  Row(
                                    children: [
                                      Icon(Icons.search, color: AppColors.primary, size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '"$_searchQuery" için ${_visibleProducts.length} sonuç bulundu',
                                          style: TextStyle(
                                            fontSize: isMobile ? 14 : 16,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: _clearSearch,
                                        child: Text(
                                          'Temizle',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else if (_hasActiveFilters)
                                  Text(
                                    '${_visibleProducts.length} ürün bulundu',
                                    style: TextStyle(
                                      fontSize: isMobile ? 16 : 24,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 40,
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
                                            // Fiyat sıralama seçenekleri kapatıldı
                                            // PopupMenuItem(
                                            //   value: SortOption.priceLowHigh,
                                            //   child: Row(
                                            //     children: [
                                            //       Icon(
                                            //         Icons.attach_money,
                                            //         size: 16,
                                            //         color: _currentSortOption == SortOption.priceLowHigh
                                            //             ? AppColors.primary
                                            //             : AppColors.textSecondary,
                                            //       ),
                                            //       const SizedBox(width: 8),
                                            //       Text(
                                            //         'Fiyat (Düşük-Yüksek)',
                                            //         style: TextStyle(
                                            //           color: _currentSortOption == SortOption.priceLowHigh
                                            //               ? AppColors.primary
                                            //               : AppColors.textSecondary,
                                            //           fontWeight: _currentSortOption == SortOption.priceLowHigh
                                            //               ? FontWeight.w600
                                            //               : FontWeight.normal,
                                            //         ),
                                            //       ),
                                            //     ],
                                            //   ),
                                            // ),
                                            // PopupMenuItem(
                                            //   value: SortOption.priceHighLow,
                                            //   child: Row(
                                            //     children: [
                                            //       Icon(
                                            //         Icons.attach_money,
                                            //         size: 16,
                                            //         color: _currentSortOption == SortOption.priceHighLow
                                            //             ? AppColors.primary
                                            //             : AppColors.textSecondary,
                                            //       ),
                                            //       const SizedBox(width: 8),
                                            //       Text(
                                            //         'Fiyat (Yüksek-Düşük)',
                                            //         style: TextStyle(
                                            //           color: _currentSortOption == SortOption.priceHighLow
                                            //               ? AppColors.primary
                                            //               : AppColors.textSecondary,
                                            //           fontWeight: _currentSortOption == SortOption.priceHighLow
                                            //               ? FontWeight.w600
                                            //               : FontWeight.normal,
                                            //         ),
                                            //       ),
                                            //     ],
                                            //   ),
                                            // ),
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
                                                Text(
                                                  'Sırala',
                                                  style: TextStyle(
                                                    fontSize: isMobile ? 12 : 14,
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
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      height: 40,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          if (isFilterOpen) {
                                            _closeFilter();
                                          } else {
                                            _openFilter();
                                          }
                                        },
                                        icon: Icon(
                                          Icons.filter_list,
                                          size: 16,
                                          color: _isFilterPanelVisible ? AppColors.surface : AppColors.textSecondary,
                                        ),
                                        label: Text(
                                          'Filtrele',
                                          style: TextStyle(
                                            fontSize: isMobile ? 12 : 14,
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
                                  ],
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isSearching ? 'Arama Sonuçları' : (_hasActiveFilters ? 'Katalog' : 'Anasayfa'),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (_isSearching) ...[
                                      Row(
                                        children: [
                                          Icon(Icons.search, color: AppColors.primary, size: 16),
                                          const SizedBox(width: 8),
                                          Text(
                                            '"$_searchQuery" için ${_visibleProducts.length} sonuç bulundu',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          TextButton(
                                            onPressed: _clearSearch,
                                            child: Text(
                                              'Temizle',
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ] else if (_hasActiveFilters)
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
                                          // Fiyat sıralama seçenekleri kapatıldı
                                          // PopupMenuItem(
                                          //   value: SortOption.priceLowHigh,
                                          //   child: Row(
                                          //     children: [
                                          //       Icon(
                                          //         Icons.attach_money,
                                          //         size: 16,
                                          //         color: _currentSortOption == SortOption.priceLowHigh
                                          //             ? AppColors.primary
                                          //             : AppColors.textSecondary,
                                          //       ),
                                          //       const SizedBox(width: 8),
                                          //       Text(
                                          //         'Fiyat (Düşük-Yüksek)',
                                          //         style: TextStyle(
                                          //           color: _currentSortOption == SortOption.priceLowHigh
                                          //               ? AppColors.primary
                                          //               : AppColors.textSecondary,
                                          //           fontWeight: _currentSortOption == SortOption.priceLowHigh
                                          //               ? FontWeight.w600
                                          //               : FontWeight.normal,
                                          //         ),
                                          //       ),
                                          //     ],
                                          //   ),
                                          // ),
                                          // PopupMenuItem(
                                          //   value: SortOption.priceHighLow,
                                          //   child: Row(
                                          //     children: [
                                          //       Icon(
                                          //         Icons.attach_money,
                                          //         size: 16,
                                          //         color: _currentSortOption == SortOption.priceHighLow
                                          //             ? AppColors.primary
                                          //             : AppColors.textSecondary,
                                          //       ),
                                          //       const SizedBox(width: 8),
                                          //       Text(
                                          //         'Fiyat (Yüksek-Düşük)',
                                          //         style: TextStyle(
                                          //           color: _currentSortOption == SortOption.priceHighLow
                                          //               ? AppColors.primary
                                          //               : AppColors.textSecondary,
                                          //           fontWeight: _currentSortOption == SortOption.priceHighLow
                                          //               ? FontWeight.w600
                                          //               : FontWeight.normal,
                                          //         ),
                                          //       ),
                                          //     ],
                                          //   ),
                                          // ),
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
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          if (isFilterOpen) {
                                            _closeFilter();
                                          } else {
                                            _openFilter();
                                          }
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
                                  ],
                                ),
                              ],
                            ),
                      ),
                    ),
                    
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
                                  onAddToCart: () {},
                                  onInspect: () => _openProductModal(p),
                                );
                              },
                            );
                          },
                          childCount: math.min(_currentPageSize, _visibleProducts.length),
                        ),
                      ),
                    ),
                    
                    // Load More Button
                    if (_currentPageSize < _visibleProducts.length)
                      SliverToBoxAdapter(
                        child: Container(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: _isLoadingMore
                                ? Column(
                                    children: [
                                      CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'Ürünler yükleniyor...',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  )
                                : ElevatedButton(
                                    onPressed: _loadMoreProducts,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.expand_more, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Daha Fazla Göster',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    
                    // Footer
                    SliverToBoxAdapter(
                      child: Footer(),
                    ),
                  ],
                ),
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
                  onAddToCart: () => _showDimensionDialog(_selectedProduct!),
                  isFavorite: favoritesProvider.isFavorite(_selectedProduct!),
                );
              },
            ),
          
          // Filter Panel - Positioned from right side with overlay
          if (_isFilterPanelVisible) ...[
            // Background overlay
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeFilter,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
            // Filter Panel
            Positioned(
              // On mobile, anchor to both left and right to ensure full-width overlay
              left: isMobile ? 0 : null,
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: isMobile ? double.infinity : 320,
                height: double.infinity,
                child: FilterPanel(
                  selectedProductTypes: _selectedProductTypes,
                  selectedSizes: _selectedSizes,
                  selectedQualities: _selectedQualities,
                  selectedColors: _selectedColors,
                  selectedBrands: _selectedBrands,
                  priceRange: _priceRange,
                  onPriceRangeChanged: (range) {
                    // Fiyat filtresi kapatıldı
                    // setState(() {
                    //   _priceRange = range;
                    //   _applyFilters();
                    // });
                  },
                  onProductTypeChanged: (type, isSelected) {
                    setState(() {
                      if (isSelected) {
                        _selectedProductTypes.add(type);
                      } else {
                        _selectedProductTypes.remove(type);
                      }
                      _applyFilters();
                    });
                  },
                  onSizeChanged: (size, isSelected) {
                    setState(() {
                      if (isSelected) {
                        _selectedSizes.add(size);
                      } else {
                        _selectedSizes.remove(size);
                      }
                      _applyFilters();
                    });
                  },
                  onQualityChanged: (quality, isSelected) {
                    setState(() {
                      if (isSelected) {
                        _selectedQualities.add(quality);
                      } else {
                        _selectedQualities.remove(quality);
                      }
                      _applyFilters();
                    });
                  },
                  onColorChanged: (color, isSelected) {
                    setState(() {
                      if (isSelected) {
                        _selectedColors.add(color);
                      } else {
                        _selectedColors.remove(color);
                      }
                      _applyFilters();
                    });
                  },
                  onBrandChanged: (brand, isSelected) {
                    setState(() {
                      if (isSelected) {
                        _selectedBrands.add(brand);
                      } else {
                        _selectedBrands.remove(brand);
                      }
                      _applyFilters();
                    });
                  },
                  onApplyFilters: () {
                    setState(() {
                      _applyFilters();
                      _hasActiveFilters = _activeFilterCount > 0;
                    });
                  },
                  onClose: () {
                    _closeFilter();
                  },
                  onResetFilters: () {
                    setState(() {
                      _selectedProductTypes.clear();
                      _selectedSizes.clear();
                      _selectedQualities.clear();
                      _selectedColors.clear();
                      _selectedBrands.clear();
                      _priceRange = const RangeValues(0, 5000);
                      _hasActiveFilters = false;
                      _applyFilters();
                    });
                  },
                ),
              ),
            ),
          ],
          
        ],
      ),
    );
  }
}
