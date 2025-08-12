import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../providers/favorites_provider.dart';
import 'package:provider/provider.dart';

class Navbar extends StatefulWidget {
  final Function(String) onCategorySelected;
  
  const Navbar({
    Key? key,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  String? _hoveredItem;
  String? _expandedDropdown;

  final Map<String, List<String>> _categoryItems = {
    'Home': ['Living Room', 'Bedroom', 'Kitchen', 'Bathroom'],
    'Curtains': ['Sheer Curtains', 'Blackout Curtains', 'Thermal Curtains', 'Decorative Curtains'],
    'Tulle': ['Sheer Tulle', 'Embroidered Tulle', 'Lace Tulle', 'Patterned Tulle'],
    'Cushions': ['Decorative Cushions', 'Floor Cushions', 'Throw Pillows', 'Bolster Cushions'],
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo and brand name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  child: Image.asset('assets/logo1.jpg', height: 32),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Sare Perde',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    color: AppColors.textPrimary,
                    letterSpacing: 1.0,
                    fontFamily: 'Didot',
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 40),
          
          // Navigation items
          Expanded(
            child: Row(
              children: _categoryItems.keys.map((category) {
                return _buildNavItem(category);
              }).toList(),
            ),
          ),
          
          const Spacer(),
          
          // Right side actions
          Row(
            children: [
              // Favorites Icon with Badge
              Consumer<FavoritesProvider>(
                builder: (context, favoritesProvider, child) {
                  final favoriteCount = favoritesProvider.favorites.length;
                  return Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: Stack(
                      children: [
                        IconButton(
                          onPressed: () {
                            // Navigate to favorites page
                            Navigator.pushNamed(context, '/favorites');
                          },
                          icon: Icon(
                            Icons.favorite,
                            color: favoriteCount > 0 ? AppColors.primary : AppColors.textSecondary,
                            size: 24,
                          ),
                          tooltip: 'Favorilerim',
                        ),
                        if (favoriteCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.surface,
                                  width: 1.5,
                                ),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                favoriteCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  'Sipariş Takibi',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  // Login dialog will be handled by parent
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  'Giriş Yap / Üye Ol',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String category) {
    final isHovered = _hoveredItem == category;
    final isExpanded = _expandedDropdown == category;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredItem = category),
      onExit: (_) => setState(() => _hoveredItem = null),
      child: Container(
        child: Column(
          children: [
            // Main nav item
            InkWell(
              onTap: () {
                if (isExpanded) {
                  setState(() => _expandedDropdown = null);
                } else {
                  setState(() => _expandedDropdown = category);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  color: isHovered || isExpanded 
                      ? AppColors.primary.withOpacity(0.1) 
                      : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(
                      color: isHovered || isExpanded 
                          ? AppColors.primary 
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isHovered || isExpanded 
                            ? AppColors.primary 
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 16,
                      color: isHovered || isExpanded 
                          ? AppColors.primary 
                          : AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            
            // Dropdown menu
            if (isExpanded)
              Container(
                width: 200,
                margin: const EdgeInsets.only(top: 0),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: _categoryItems[category]!.map((item) {
                    return InkWell(
                      onTap: () {
                        widget.onCategorySelected(item);
                        setState(() => _expandedDropdown = null);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.border.withOpacity(0.3),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 