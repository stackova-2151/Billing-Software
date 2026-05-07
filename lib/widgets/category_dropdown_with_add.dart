import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/category_controller.dart';

/// Special value to indicate "Add New Category" option
const String kAddNewCategoryValue = '__ADD_NEW_CATEGORY__';

/// Reusable category dropdown with "Add New Category" option
class CategoryDropdownWithAdd extends StatelessWidget {
  final String value;
  final String label;
  final void Function(String) onChanged;
  final CategoryController categoryController;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final Color? borderColor;
  final Color? backgroundColor;
  final EdgeInsets? contentPadding;

  const CategoryDropdownWithAdd({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
    required this.categoryController,
    this.textStyle,
    this.labelStyle,
    this.borderColor,
    this.backgroundColor,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final categories = categoryController.activeCategoryNames;
      
      // Build dropdown items
      final items = <DropdownMenuItem<String>>[
        // Regular categories
        ...categories.map((cat) => DropdownMenuItem(
              value: cat,
              child: Text(cat),
            )),
        // Add New Category option
        DropdownMenuItem(
          value: kAddNewCategoryValue,
          child: Row(
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 18,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                '+ Add New Category',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ];

      return DropdownButtonFormField<String>(
        value: categories.contains(value) ? value : (categories.isNotEmpty ? categories.first : null),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: labelStyle,
          filled: backgroundColor != null,
          fillColor: backgroundColor,
          contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: borderColor ?? const Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: borderColor ?? const Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: borderColor ?? Theme.of(context).primaryColor, width: 1.8),
          ),
        ),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
        style: textStyle ?? const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500),
        dropdownColor: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(14),
        items: items,
        onChanged: (newValue) {
          if (newValue == kAddNewCategoryValue) {
            _showAddCategoryDialog(context);
          } else if (newValue != null) {
            onChanged(newValue);
          }
        },
      );
    });
  }

  /// Show dialog to add new category
  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    final orderController = TextEditingController();
    final RxBool isLoading = false.obs;

    // Auto-calculate next display order
    final nextOrder = categoryController.categories.isEmpty
        ? 1
        : categoryController.categories.map((c) => c.displayOrder).reduce((a, b) => a > b ? a : b) + 1;
    orderController.text = nextOrder.toString();

    Get.dialog(
      WillPopScope(
        onWillPop: () async => !isLoading.value, // Prevent closing while loading
        child: AlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add_circle, color: Color(0xFF16A34A), size: 24),
              ),
              const SizedBox(width: 12),
              const Text('Add New Category'),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Category Name *',
                    hintText: 'e.g. Beverages',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    prefixIcon: const Icon(Icons.category),
                  ),
                  onSubmitted: (_) => _submitCategory(nameController, orderController, isLoading),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: orderController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Display Order',
                    hintText: 'Order in dropdown',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    prefixIcon: const Icon(Icons.sort),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Category will be active by default',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          actions: [
            Obx(() => TextButton(
                  onPressed: isLoading.value ? null : () => Navigator.of(Get.overlayContext!, rootNavigator: true).pop(),
                  child: const Text('Cancel'),
                )),
            Obx(() => ElevatedButton(
                  onPressed: isLoading.value
                      ? null
                      : () => _submitCategory(nameController, orderController, isLoading),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: isLoading.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Add Category', style: TextStyle(fontWeight: FontWeight.w700)),
                )),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Submit new category
  Future<void> _submitCategory(
    TextEditingController nameController,
    TextEditingController orderController,
    RxBool isLoading,
  ) async {
    final name = nameController.text.trim();
    final order = int.tryParse(orderController.text.trim()) ?? 1;

    // Validation
    if (name.isEmpty) {
      Get.snackbar(
        'Invalid Input',
        'Please enter a category name',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (order <= 0) {
      Get.snackbar(
        'Invalid Input',
        'Display order must be greater than 0',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    isLoading.value = true;

    try {
      // Add category with await
      await categoryController.addCategory(
        name: name,
        displayOrder: order,
        isActive: true,
      );

      // Small delay before closing dialog
      await Future.delayed(const Duration(milliseconds: 50));

      // Close dialog using root navigator
      Navigator.of(Get.overlayContext!, rootNavigator: true).pop();

      // Auto-select the newly added category
      onChanged(name);

      // Show success message
      Get.snackbar(
        'Success',
        'Category "$name" added and selected',
        backgroundColor: const Color(0xFF16A34A),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error adding category: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
