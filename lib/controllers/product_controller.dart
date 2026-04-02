import 'package:get/get.dart';

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

  Future<void> createProduct({
    required String name,
    required String category,
    required double price,
    required double gstPercent,
    required bool isActive,
    String image = '',
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
    bool? isVeg,
    bool? isAvailable,
    String? description,
    int? prepMinutes,
    double? discountPercent,
  }) async {
    final current = products.firstWhereOrNull((e) => e.id == id);
    if (current == null) return;

    await _service.update(MenuItem(
      id: id,
      name: name,
      price: price,
      image: image ?? current.image,
      category: category,
      isVeg: isVeg ?? current.isVeg,
      isAvailable: isAvailable ?? current.isAvailable,
      gstPercent: gstPercent,
      itemCode: current.itemCode,
      isActive: isActive,
      description: description ?? current.description,
      prepMinutes: prepMinutes ?? current.prepMinutes,
      discountPercent: discountPercent ?? current.discountPercent,
    ));
  }

  Future<void> deleteProduct(String id) async {
    await _service.delete(id);
  }

  Future<void> setProductStatus(String id, bool active) async {
    final current = products.firstWhereOrNull((e) => e.id == id);
    if (current == null) return;
    await _service.update(MenuItem(
      id: id,
      name: current.name,
      price: current.price,
      image: current.image,
      category: current.category,
      isVeg: current.isVeg,
      isAvailable: current.isAvailable,
      gstPercent: current.gstPercent,
      itemCode: current.itemCode,
      isActive: active,
      description: current.description,
      prepMinutes: current.prepMinutes,
      discountPercent: current.discountPercent,
    ));
  }

  List<MenuItem> get activeProducts => products.where((p) => p.isActive).toList();
}
