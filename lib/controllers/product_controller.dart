import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;

import '../models/menu_item.dart';
import '../services/menu_item_service.dart';

class ProductController extends GetxController {
  final MenuItemService _service = MenuItemService();

  final RxList<MenuItem> products = <MenuItem>[].obs;
  final RxBool isLoading = true.obs;

  int _nextCode = 1001;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    // Seed Firestore only on first run
    await _service.seedIfEmpty();
    // Listen to real-time updates
    _service.stream.listen((items) {
      products.assignAll(items);
      if (items.isNotEmpty) {
        _nextCode = items.length + 1001;
      }
      isLoading.value = false;
    });
  }

  String _generateItemCode() => 'ITM${_nextCode++}';

  /// Get orphaned items (items with non-existent categories)
  List<MenuItem> getOrphanedItems(List<String> validCategoryNames) {
    final validSet = validCategoryNames.map((n) => n.toLowerCase()).toSet();
    final orphaned = products
        .where((item) => !validSet.contains(item.category.toLowerCase()))
        .toList();
    
    if (orphaned.isNotEmpty) {
      developer.log(
        'Found ${orphaned.length} orphaned items: ${orphaned.map((i) => i.name).join(", ")}',
        name: 'ProductController',
      );
    }
    
    return orphaned;
  }

  /// Fix orphaned items by assigning them to a default category
  Future<void> fixOrphanedItems(String defaultCategory) async {
    try {
      final orphaned = getOrphanedItems([defaultCategory]);
      if (orphaned.isEmpty) return;

      developer.log(
        'Fixing ${orphaned.length} orphaned items, assigning to "$defaultCategory"',
        name: 'ProductController',
      );

      for (final item in orphaned) {
        await editProduct(
          id: item.id,
          name: item.name,
          category: defaultCategory,
          price: item.price,
          gstPercent: item.gstPercent,
          isActive: item.isActive,
        );
      }

      Get.snackbar(
        'Success',
        'Fixed ${orphaned.length} orphaned item${orphaned.length > 1 ? 's' : ''}',
        backgroundColor: const Color(0xFF16A34A),
        colorText: const Color(0xFFFFFFFF),
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      developer.log('Error fixing orphaned items: $e', name: 'ProductController');
      Get.snackbar(
        'Error',
        'Failed to fix orphaned items',
        backgroundColor: const Color(0xFFEF4444),
        colorText: const Color(0xFFFFFFFF),
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> createProduct({
    required String name,
    required String category,
    required double price,
    required double gstPercent,
    required bool isActive,
    String image = '',
    List<String> images = const <String>[],
    bool isVeg = true,
    bool isAvailable = true,
    String description = '',
    int prepMinutes = 0,
    double discountPercent = 0,
  }) async {
    final item = MenuItem(
      id: '',
      name: name,
      price: price,
      image: image,
      images: images,
      category: category,
      isVeg: isVeg,
      isAvailable: isAvailable,
      gstPercent: gstPercent,
      itemCode: _generateItemCode(),
      isActive: isActive,
      description: description,
      prepMinutes: prepMinutes,
      discountPercent: discountPercent,
    );
    await _service.add(item);
  }

  Future<void> editProduct({
    required String id,
    required String name,
    required String category,
    required double price,
    required double gstPercent,
    required bool isActive,
    String? image,
    List<String>? images,
    bool? isVeg,
    bool? isAvailable,
    String? description,
    int? prepMinutes,
    double? discountPercent,
  }) async {
    final current = products.firstWhereOrNull((e) => e.id == id);
    if (current == null) return;

    await _service.update(
      MenuItem(
        id: id,
        name: name,
        price: price,
        image: image ?? current.image,
        images: images ?? current.images,
        category: category,
        isVeg: isVeg ?? current.isVeg,
        isAvailable: isAvailable ?? current.isAvailable,
        gstPercent: gstPercent,
        itemCode: current.itemCode,
        isActive: isActive,
        description: description ?? current.description,
        prepMinutes: prepMinutes ?? current.prepMinutes,
        discountPercent: discountPercent ?? current.discountPercent,
      ),
    );
  }

  Future<void> deleteProduct(String id) async {
    await _service.delete(id);
  }

  Future<void> setProductStatus(String id, bool active) async {
    final current = products.firstWhereOrNull((e) => e.id == id);
    if (current == null) return;
    await _service.update(
      MenuItem(
        id: id,
        name: current.name,
        price: current.price,
        image: current.image,
        images: current.images,
        category: current.category,
        isVeg: current.isVeg,
        isAvailable: current.isAvailable,
        gstPercent: current.gstPercent,
        itemCode: current.itemCode,
        isActive: active,
        description: current.description,
        prepMinutes: current.prepMinutes,
        discountPercent: current.discountPercent,
      ),
    );
  }

  List<MenuItem> get activeProducts =>
      products.where((p) => p.isActive).toList();
}
