import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../models/product.dart';

class EditDimensionDialog extends StatefulWidget {
  final Product product;
  final double currentWidth;
  final double currentHeight;
  final VoidCallback onUpdateDimensions;

  const EditDimensionDialog({
    Key? key,
    required this.product,
    required this.currentWidth,
    required this.currentHeight,
    required this.onUpdateDimensions,
  }) : super(key: key);

  @override
  State<EditDimensionDialog> createState() => _EditDimensionDialogState();
}

class _EditDimensionDialogState extends State<EditDimensionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _widthController;
  late final TextEditingController _heightController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _widthController = TextEditingController(text: widget.currentWidth.toStringAsFixed(0));
    _heightController = TextEditingController(text: widget.currentHeight.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _handleUpdateDimensions() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Parse dimensions
      final width = double.tryParse(_widthController.text);
      final height = double.tryParse(_heightController.text);

      if (width != null && height != null) {
        // Call the onUpdateDimensions callback with new dimensions
        widget.onUpdateDimensions();
        
        // Close dialog
        Navigator.of(context).pop({
          'width': width,
          'height': height,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.edit, color: AppColors.primary),
          const SizedBox(width: 8),
          const Text(
            'Boyutları Düzenle',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      widget.product.image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.product.price.toStringAsFixed(0)} ₺',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Current dimensions display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.straighten,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mevcut boyutlar: ${widget.currentWidth.toStringAsFixed(0)} x ${widget.currentHeight.toStringAsFixed(0)} cm',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Dimensions form
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _widthController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'En (cm)',
                      hintText: 'Örn: 150',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.width_normal),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'En değeri gerekli';
                      }
                      final width = double.tryParse(value);
                      if (width == null || width <= 0) {
                        return 'Geçerli bir en değeri girin';
                      }
                      if (width > 1000) {
                        return 'En değeri 1000 cm\'den küçük olmalı';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Boy (cm)',
                      hintText: 'Örn: 200',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.height),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Boy değeri gerekli';
                      }
                      final height = double.tryParse(value);
                      if (height == null || height <= 0) {
                        return 'Geçerli bir boy değeri girin';
                      }
                      if (height > 1000) {
                        return 'Boy değeri 1000 cm\'den küçük olmalı';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Info text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Yeni boyutları girin ve "Güncelle" butonuna tıklayın.',
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
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleUpdateDimensions,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
                  ),
                )
              : const Text('Güncelle'),
        ),
      ],
    );
  }
} 