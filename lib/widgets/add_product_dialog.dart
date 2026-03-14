import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/category_controller.dart';
import '../controllers/product_controller.dart';
import '../models/menu_item.dart';

class AddProductDialog extends StatefulWidget {
  final ProductController productController;
  final CategoryController categoryController;
  final MenuItem? existing;

  const AddProductDialog({
    super.key,
    required this.productController,
    required this.categoryController,
    this.existing,
  });

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  late final TextEditingController nameController;
  late final TextEditingController priceController;

  late String selectedCategory;
  late double selectedGst;
  late bool isActive;

  static const List<double> gstOptions = <double>[0, 5, 12, 18];

  @override
  void initState() {
    super.initState();

    final e = widget.existing;
    nameController = TextEditingController(text: e?.name ?? '');
    priceController = TextEditingController(
      text: e == null ? '' : e.price.toStringAsFixed(0),
    );

    final activeCategories = widget.categoryController.activeCategoryNames;
    selectedCategory = e?.category ?? (activeCategories.isNotEmpty ? activeCategories.first : '');

    selectedGst = e?.gstPercent ?? 5;
    isActive = e?.isActive ?? true;
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  void _save() {
    final name = nameController.text.trim();
    final price = double.tryParse(priceController.text.trim()) ?? -1;

    if (name.isEmpty || selectedCategory.isEmpty || price <= 0) {
      Get.snackbar('Invalid', 'Please enter valid product details');
      return;
    }

    if (widget.existing == null) {
      widget.productController.createProduct(
        name: name,
        category: selectedCategory,
        price: price,
        gstPercent: selectedGst,
        isActive: isActive,
      );
    } else {
      widget.productController.editProduct(
        id: widget.existing!.id,
        name: name,
        category: selectedCategory,
        price: price,
        gstPercent: selectedGst,
        isActive: isActive,
      );
    }

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.existing != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Product' : 'Add Product'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                ),
              ),
              const SizedBox(height: 12),
              Obx(() {
                final categories = widget.categoryController.activeCategoryNames;
                final items = categories
                    .map(
                      (c) => DropdownMenuItem<String>(
                        value: c,
                        child: Text(c),
                      ),
                    )
                    .toList();

                final hasSelected = categories.contains(selectedCategory);
                final value = hasSelected
                    ? selectedCategory
                    : (categories.isNotEmpty ? categories.first : '');

                if (value != selectedCategory) {
                  selectedCategory = value;
                }

                return DropdownButtonFormField<String>(
                  value: value.isEmpty ? null : value,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: items,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => selectedCategory = v);
                  },
                );
              }),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixText: '₹ ',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<double>(
                value: selectedGst,
                decoration: const InputDecoration(labelText: 'GST %'),
                items: gstOptions
                    .map(
                      (g) => DropdownMenuItem<double>(
                        value: g,
                        child: Text('${g.toStringAsFixed(0)}%'),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => selectedGst = v);
                },
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Item Code: ${widget.existing?.itemCode.isNotEmpty == true ? widget.existing!.itemCode : '(auto)'}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active'),
                value: isActive,
                onChanged: (v) => setState(() => isActive = v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save Product'),
        ),
      ],
    );
  }
}
