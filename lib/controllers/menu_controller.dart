import 'package:get/get.dart';

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
  }

  void _syncCategories() {
    final updated = <String>['All', ...categoryController.activeCategoryNames];
    categories.assignAll(updated);

    if (!categories.contains(selectedCategory.value)) {
      selectedCategory.value = 'All';
    }
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
