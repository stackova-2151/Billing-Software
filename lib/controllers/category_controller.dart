import 'package:get/get.dart';

class CategoryModel {
  final int id;
  final RxString name;
  final RxInt displayOrder;
  final RxBool isActive;

  CategoryModel({
    required this.id,
    required String name,
    required int displayOrder,
    required bool isActive,
  })  : name = name.obs,
        displayOrder = displayOrder.obs,
        isActive = isActive.obs;
}

class CategoryController extends GetxController {
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  int _nextId = 1;

  @override
  void onInit() {
    super.onInit();

    categories.addAll([
      CategoryModel(id: _nextId++, name: 'Starters', displayOrder: 1, isActive: true),
      CategoryModel(id: _nextId++, name: 'Main Course', displayOrder: 2, isActive: true),
      CategoryModel(id: _nextId++, name: 'Desserts', displayOrder: 3, isActive: true),
      CategoryModel(id: _nextId++, name: 'Drinks', displayOrder: 4, isActive: true),
      CategoryModel(id: _nextId++, name: 'Dosa', displayOrder: 5, isActive: true),
      CategoryModel(id: _nextId++, name: 'Rolls', displayOrder: 6, isActive: true),
    ]);

    _sort();
  }

  void _sort() {
    categories.sort((a, b) => a.displayOrder.value.compareTo(b.displayOrder.value));
    categories.refresh();
  }

  List<String> get activeCategoryNames {
    final list = categories
        .where((c) => c.isActive.value)
        .toList()
      ..sort((a, b) => a.displayOrder.value.compareTo(b.displayOrder.value));
    return list.map((e) => e.name.value).toList();
  }

  void addCategory({
    required String name,
    required int displayOrder,
    required bool isActive,
  }) {
    categories.add(CategoryModel(
      id: _nextId++,
      name: name,
      displayOrder: displayOrder,
      isActive: isActive,
    ));
    _sort();
  }

  void editCategory({
    required int id,
    required String name,
    required int displayOrder,
    required bool isActive,
  }) {
    final idx = categories.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    categories[idx].name.value = name;
    categories[idx].displayOrder.value = displayOrder;
    categories[idx].isActive.value = isActive;
    _sort();
  }

  void deleteCategory(int id) {
    categories.removeWhere((e) => e.id == id);
  }
}
