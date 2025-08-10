import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../data/product_data.dart';

class FilterPanel extends StatelessWidget {
  final Set<String> selectedProductTypes;
  final Set<String> selectedSizes;
  final Set<String> selectedQualities;
  final Set<String> selectedColors;
  final Set<String> selectedBrands;
  final RangeValues priceRange;
  final Function(RangeValues) onPriceRangeChanged;
  final Function(String, bool) onProductTypeChanged;
  final Function(String, bool) onSizeChanged;
  final Function(String, bool) onQualityChanged;
  final Function(String, bool) onColorChanged;
  final Function(String, bool) onBrandChanged;
  final VoidCallback onApplyFilters;
  final VoidCallback? onClose;
  final VoidCallback? onResetFilters;

  const FilterPanel({
    Key? key,
    required this.selectedProductTypes,
    required this.selectedSizes,
    required this.selectedQualities,
    required this.selectedColors,
    required this.selectedBrands,
    required this.priceRange,
    required this.onPriceRangeChanged,
    required this.onProductTypeChanged,
    required this.onSizeChanged,
    required this.onQualityChanged,
    required this.onColorChanged,
    required this.onBrandChanged,
    required this.onApplyFilters,
    this.onClose,
    this.onResetFilters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 99999,
      color: Colors.transparent,
      child: Container(
        width: 280,
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            left: BorderSide(color: AppColors.border, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 16,
              spreadRadius: 4,
              offset: const Offset(-4, 0),
            ),
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.3),
              blurRadius: 24,
              spreadRadius: 8,
              offset: const Offset(-8, 0),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              // Panel başlığı
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_alt,
                      color: AppColors.surface,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'FİLTRELER',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.surface,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (onClose != null)
                      IconButton(
                        onPressed: onClose,
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.surface,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surface.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Kaydırılabilir filtre alanı
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    children: [
                      _buildFilterCard('Ürün Tipi', ProductData.productTypes, selectedProductTypes, onProductTypeChanged),
                      _buildFilterCard('Ebat', ProductData.sizes, selectedSizes, onSizeChanged),
                      _buildFilterCard('Kalite', ProductData.qualities, selectedQualities, onQualityChanged),
                      _buildFilterCard('Renk', ProductData.colors, selectedColors, onColorChanged),
                      _buildFilterCard('Marka', ProductData.brands, selectedBrands, onBrandChanged),
                      _buildPriceCard(),
                      const SizedBox(height: 60), // butondan ayrışsın
                    ],
                  ),
                ),
              ),

              // Kaydırılamayan sabit butonlar
              SafeArea(
                top: false,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // Filtrele butonu
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: onApplyFilters,
                          icon: const Icon(Icons.filter_alt, size: 18),
                          label: const Text(
                            'Filtrele',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.surface,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                            shadowColor: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Filtreyi Sıfırla butonu
                      if (onResetFilters != null)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: onResetFilters,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text(
                              'Filtreyi Sıfırla',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.surface,
                              foregroundColor: AppColors.textSecondary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: AppColors.border),
                              ),
                              elevation: 0,
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
  }

  Widget _buildFilterCard(String title, List<String> items, Set<String> selection, Function(String, bool) onChanged) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        children: items.map((e) {
          final checked = selection.contains(e);
          return CheckboxListTile(
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            value: checked,
            onChanged: (val) {
              onChanged(e, val == true);
            },
            title: Text(
              e,
              style: const TextStyle(
                fontSize: 13,
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: const Text(
          'Fiyat',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
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
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'Max: ${priceRange.end.toStringAsFixed(0)} ₺',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
        ],
      ),
    );
  }
}