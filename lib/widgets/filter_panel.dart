import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../data/product_data.dart';

class FilterPanel extends StatelessWidget {
  final Set<String> selectedCategories;
  final Set<String> selectedProductTypes;
  final Set<String> selectedSizes;
  final Set<String> selectedQualities;
  final Set<String> selectedColors;
  final Set<String> selectedBrands;
  final RangeValues priceRange;
  final Function(RangeValues) onPriceRangeChanged;
  final Function(String, bool) onCategoryChanged;
  final Function(String, bool) onProductTypeChanged;
  final Function(String, bool) onSizeChanged;
  final Function(String, bool) onQualityChanged;
  final Function(String, bool) onColorChanged;
  final Function(String, bool) onBrandChanged;
  final VoidCallback onApplyFilters;

  const FilterPanel({
    Key? key,
    required this.selectedCategories,
    required this.selectedProductTypes,
    required this.selectedSizes,
    required this.selectedQualities,
    required this.selectedColors,
    required this.selectedBrands,
    required this.priceRange,
    required this.onPriceRangeChanged,
    required this.onCategoryChanged,
    required this.onProductTypeChanged,
    required this.onSizeChanged,
    required this.onQualityChanged,
    required this.onColorChanged,
    required this.onBrandChanged,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Panel başlığı
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_alt,
                    color: AppColors.surface,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'PERDE FİLTRELERİ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.surface,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Kaydırılabilir filtre alanı
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    _buildFilterCard('Kategori', ProductData.categories, selectedCategories, onCategoryChanged),
                    _buildFilterCard('Ürün Tipi', ProductData.productTypes, selectedProductTypes, onProductTypeChanged),
                    _buildFilterCard('Ebat', ProductData.sizes, selectedSizes, onSizeChanged),
                    _buildFilterCard('Kalite', ProductData.qualities, selectedQualities, onQualityChanged),
                    _buildFilterCard('Renk', ProductData.colors, selectedColors, onColorChanged),
                    _buildFilterCard('Marka', ProductData.brands, selectedBrands, onBrandChanged),
                    _buildPriceCard(),
                    const SizedBox(height: 80), // butondan ayrışsın
                  ],
                ),
              ),
            ),

            // Kaydırılamayan sabit "Filtrele" butonu
            SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: onApplyFilters,
                  icon: const Icon(Icons.filter_alt, size: 20),
                  label: const Text(
                    'Filtrele',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    shadowColor: AppColors.primary.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterCard(String title, List<String> items, Set<String> selection, Function(String, bool) onChanged) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        children: items.map((e) {
          final checked = selection.contains(e);
          return CheckboxListTile(
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            value: checked,
            onChanged: (val) {
              onChanged(e, val == true);
            },
            title: Text(
              e,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            activeColor: AppColors.primary,
            checkColor: AppColors.surface,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        title: const Text(
          'Fiyat',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        children: [
          RangeSlider(
            values: priceRange,
            min: 0,
            max: 5000,
            divisions: 50,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.border,
            labels: RangeLabels(
              '${priceRange.start.toStringAsFixed(0)} ₺',
              '${priceRange.end.toStringAsFixed(0)} ₺',
            ),
            onChanged: onPriceRangeChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Min: ${priceRange.start.toStringAsFixed(0)} ₺',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'Max: ${priceRange.end.toStringAsFixed(0)} ₺',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}