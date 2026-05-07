import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;

import '../controllers/category_controller.dart';
import '../controllers/product_controller.dart';
import '../models/menu_item.dart';

class MenuController extends GetxController {
  final RxList<String> categories = <String>['All'].obs;

  final RxString selectedCategory = 'All'.obs;

  final RxString searchQuery = ''.obs;
  final RxBool vegOnly = false.obs;
  final RxBool nonVegOnly = false.obs;
  final RxBool availableOnly = false.obs;

  final RxString managementSearchQuery = ''.obs;

  late final ProductController productController;
  late final CategoryController categoryController;

  @override
  void onInit() {
    super.onInit();

    productController = Get.find<ProductController>();
    categoryController = Get.find<CategoryController>();

    _syncCategories();

    ever(categoryController.categories, (_) => _syncCategories());
    
    // Check for orphaned items periodically
    ever(productController.products, (_) => _checkOrphanedItems());
  }

  void _syncCategories() {
    final updated = <String>['All', ...categoryController.activeCategoryNames];
    categories.assignAll(updated);

    if (!categories.contains(selectedCategory.value)) {
      selectedCategory.value = 'All';
    }
  }

  /// Check for orphaned items and log warning
  void _checkOrphanedItems() {
    final allCategoryNames = categoryController.allCategoryNames;
    final orphaned = productController.getOrphanedItems(allCategoryNames);
    
    if (orphaned.isNotEmpty) {
      developer.log(
        '⚠️ WARNING: ${orphaned.length} orphaned item(s) detected with invalid categories',
        name: 'MenuController',
      );
    }
  }

  /// Get orphaned items for display
  List<MenuItem> get orphanedItems {
    final allCategoryNames = categoryController.allCategoryNames;
    return productController.getOrphanedItems(allCategoryNames);
  }

  /// Show orphaned items warning dialog
  void showOrphanedItemsWarning() {
    final orphaned = orphanedItems;
    if (orphaned.isEmpty) return;

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber, color: Color(0xFFF59E0B), size: 28),
            const SizedBox(width: 12),
            const Text('Orphaned Items Detected'),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${orphaned.length} item${orphaned.length > 1 ? 's have' : ' has'} invalid categories:',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: orphaned.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '• ${item.name} (Category: "${item.category}")',
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'These items won\'t appear in category filters. Would you like to fix them?',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _fixOrphanedItemsDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
            ),
            child: const Text('Fix Now'),
          ),
        ],
      ),
    );
  }

  /// Show dialog to fix orphaned items
  void _fixOrphanedItemsDialog() {
    final activeCategories = categoryController.activeCategoryNames;
    if (activeCategories.isEmpty) {
      Get.snackbar(
        'Error',
        'No active categories available. Please create a category first.',
        backgroundColor: const Color(0xFFEF4444),
        colorText: const Color(0xFFFFFFFF),
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    String selectedCategory = activeCategories.first;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Fix Orphaned Items'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Assign all orphaned items to:'),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: activeCategories
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedCategory = value);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  productController.fixOrphanedItems(selectedCategory);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                ),
                child: const Text('Fix Items'),
              ),
            ],
          );
        },
      ),
    );
  }

  void setCategory(String category) {
    selectedCategory.value = category;
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
  }

  void searchItems(String value) {
    managementSearchQuery.value = value;
  }

  List<MenuItem> get filteredItems {
    final q = searchQuery.value.trim().toLowerCase();
    return productController.products.where((item) {
      if (!item.isActive) return false;
      final matchesCategory =
          selectedCategory.value == 'All' ||
          item.category == selectedCategory.value;

      final matchesSearch = q.isEmpty || item.name.toLowerCase().contains(q);

      final matchesAvailability = !availableOnly.value || item.isAvailable;

      final veg = vegOnly.value;
      final nonVeg = nonVegOnly.value;
      final matchesVegFilter =
          (!veg && !nonVeg) || (veg && item.isVeg) || (nonVeg && !item.isVeg);

      return matchesCategory &&
          matchesSearch &&
          matchesAvailability &&
          matchesVegFilter;
    }).toList();
  }

  List<MenuItem> get managementItems {
    final q = managementSearchQuery.value.trim().toLowerCase();
    return productController.products.where((item) {
      if (q.isEmpty) return true;
      return item.name.toLowerCase().contains(q);
    }).toList();
  }

  void addItem({
    required String name,
    required String category,
    required double price,
    required double gstPercent,
    required bool isVeg,
    String imageUrl = '',
    List<String> images = const <String>[],
    String description = '',
    int prepMinutes = 0,
    double discountPercent = 0,
  }) {
    productController.createProduct(
      name: name,
      category: category,
      price: price,
      gstPercent: gstPercent,
      isActive: true,
      image: imageUrl,
      images: images,
      isVeg: isVeg,
      isAvailable: true,
      description: description,
      prepMinutes: prepMinutes,
      discountPercent: discountPercent,
    );
  }

  void updateItem({
    required String id,
    required String name,
    required String category,
    required double price,
    required double gstPercent,
    required bool isVeg,
    String imageUrl = '',
    List<String> images = const <String>[],
    String description = '',
    int prepMinutes = 0,
    double discountPercent = 0,
  }) {
    productController.editProduct(
      id: id,
      name: name,
      category: category,
      price: price,
      gstPercent: gstPercent,
      isActive: true,
      image: imageUrl,
      images: images,
      isVeg: isVeg,
      description: description,
      prepMinutes: prepMinutes,
      discountPercent: discountPercent,
    );
  }

  void deleteItem(String id) {
    productController.deleteProduct(id);
  }
}
