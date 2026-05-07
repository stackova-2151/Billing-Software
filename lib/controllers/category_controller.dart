import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;

import '../services/category_service.dart';

class CategoryController extends GetxController {
  final CategoryService _service = CategoryService();

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    await _service.seedIfEmpty();
    _service.stream.listen((cats) {
      categories.assignAll(cats);
      isLoading.value = false;
    });
  }

  List<String> get activeCategoryNames {
    return categories
        .where((c) => c.isActive)
        .map((e) => e.name)
        .toList();
  }

  /// Get all category names (including inactive)
  List<String> get allCategoryNames {
    return categories.map((e) => e.name).toList();
  }

  /// Check if category name exists
  Future<bool> categoryExists(String name) async {
    return await _service.categoryNameExists(name);
  }

  /// Get count of items using a category
  Future<int> getItemCountForCategory(String categoryName) async {
    return await _service.countItemsUsingCategory(categoryName);
  }

  /// Add category with validation
  Future<void> addCategory({
    required String name,
    required int displayOrder,
    required bool isActive,
  }) async {
    // Trim and validate
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      Get.snackbar(
        'Invalid Input',
        'Category name cannot be empty',
        backgroundColor: const Color(0xFFEF4444),
        colorText: const Color(0xFFFFFFFF),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      throw Exception('Category name cannot be empty');
    }

    if (displayOrder <= 0) {
      Get.snackbar(
        'Invalid Input',
        'Display order must be greater than 0',
        backgroundColor: const Color(0xFFEF4444),
        colorText: const Color(0xFFFFFFFF),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      throw Exception('Display order must be greater than 0');
    }

    try {
      await _service.add(CategoryModel(
        id: '',
        name: trimmedName,
        displayOrder: displayOrder,
        isActive: isActive,
      ));

      Get.snackbar(
        'Success',
        'Category "$trimmedName" added successfully',
        backgroundColor: const Color(0xFF16A34A),
        colorText: const Color(0xFFFFFFFF),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      developer.log('Error adding category: $e', name: 'CategoryController');
      
      // User-friendly error message
      String errorMessage = 'Failed to add category';
      if (e.toString().contains('already exists')) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: const Color(0xFFEF4444),
        colorText: const Color(0xFFFFFFFF),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
      
      // Re-throw to let caller handle it
      rethrow;
    }
  }

  /// Edit category with validation and cascade rename
  Future<void> editCategory({
    required String id,
    required String name,
    required int displayOrder,
    required bool isActive,
  }) async {
    try {
      // Trim and validate
      final trimmedName = name.trim();
      if (trimmedName.isEmpty) {
        Get.snackbar(
          'Invalid Input',
          'Category name cannot be empty',
          backgroundColor: const Color(0xFFEF4444),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      if (displayOrder <= 0) {
        Get.snackbar(
          'Invalid Input',
          'Display order must be greater than 0',
          backgroundColor: const Color(0xFFEF4444),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // Get old category to check if name changed
      final oldCategory = categories.firstWhereOrNull((c) => c.id == id);
      final nameChanged = oldCategory != null && oldCategory.name != trimmedName;

      await _service.update(CategoryModel(
        id: id,
        name: trimmedName,
        displayOrder: displayOrder,
        isActive: isActive,
      ));

      if (nameChanged) {
        Get.snackbar(
          'Success',
          'Category renamed to "$trimmedName" and all items updated',
          backgroundColor: const Color(0xFF16A34A),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Success',
          'Category updated successfully',
          backgroundColor: const Color(0xFF16A34A),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      developer.log('Error editing category: $e', name: 'CategoryController');
      
      // User-friendly error message
      String errorMessage = 'Failed to update category';
      if (e.toString().contains('already exists')) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: const Color(0xFFEF4444),
        colorText: const Color(0xFFFFFFFF),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    }
  }

  /// Delete category with validation
  Future<void> deleteCategory(String id) async {
    try {
      // Get category name for confirmation
      final category = categories.firstWhereOrNull((c) => c.id == id);
      if (category == null) {
        Get.snackbar(
          'Error',
          'Category not found',
          backgroundColor: const Color(0xFFEF4444),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Category'),
          content: Text(
            'Are you sure you want to delete "${category.name}"?\n\nThis action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: const Color(0xFFFFFFFF),
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      await _service.delete(id);

      Get.snackbar(
        'Success',
        'Category "${category.name}" deleted successfully',
        backgroundColor: const Color(0xFF16A34A),
        colorText: const Color(0xFFFFFFFF),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      developer.log('Error deleting category: $e', name: 'CategoryController');
      
      // User-friendly error message
      String errorMessage = 'Failed to delete category';
      if (e.toString().contains('is used in')) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      Get.snackbar(
        'Cannot Delete',
        errorMessage,
        backgroundColor: const Color(0xFFEF4444),
        colorText: const Color(0xFFFFFFFF),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
      );
    }
  }

  /// Toggle category active status with warning if items exist
  Future<void> toggleCategoryStatus(String id, bool newStatus) async {
    try {
      final category = categories.firstWhereOrNull((c) => c.id == id);
      if (category == null) return;

      // If deactivating, check for items
      if (!newStatus) {
        final itemCount = await getItemCountForCategory(category.name);
        if (itemCount > 0) {
          final confirmed = await Get.dialog<bool>(
            AlertDialog(
              title: const Text('Deactivate Category'),
              content: Text(
                'This category has $itemCount item${itemCount > 1 ? 's' : ''}. '
                'Deactivating will hide it from dropdowns, but items will remain.\n\n'
                'Continue?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                  ),
                  child: const Text('Deactivate'),
                ),
              ],
            ),
          );

          if (confirmed != true) return;
        }
      }

      await editCategory(
        id: id,
        name: category.name,
        displayOrder: category.displayOrder,
        isActive: newStatus,
      );
    } catch (e) {
      developer.log('Error toggling category status: $e', name: 'CategoryController');
    }
  }
}
