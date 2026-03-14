import 'package:get/get.dart';

import '../models/menu_item.dart';

class ProductController extends GetxController {
  final RxList<MenuItem> products = <MenuItem>[].obs;

  int _nextId = 1;
  int _nextCode = 1001;

  @override
  void onInit() {
    super.onInit();

    final seed = <MenuItem>[
      const MenuItem(
        id: 1,
        name: 'Paneer Tikka',
        price: 180,
        image: '',
        category: 'Starters',
        isVeg: true,
        isAvailable: true,
        gstPercent: 5,
        itemCode: 'ITM1001',
        isActive: true,
      ),
      const MenuItem(
        id: 2,
        name: 'Chicken 65',
        price: 220,
        image: '',
        category: 'Starters',
        isVeg: false,
        isAvailable: true,
        gstPercent: 5,
        itemCode: 'ITM1002',
        isActive: true,
      ),
      const MenuItem(
        id: 3,
        name: 'Veg Fried Rice',
        price: 160,
        image: '',
        category: 'Main Course',
        isVeg: true,
        isAvailable: true,
        gstPercent: 5,
        itemCode: 'ITM1003',
        isActive: true,
      ),
      const MenuItem(
        id: 4,
        name: 'Chicken Biryani',
        price: 260,
        image: '',
        category: 'Main Course',
        isVeg: false,
        isAvailable: true,
        gstPercent: 5,
        itemCode: 'ITM1004',
        isActive: true,
      ),
      const MenuItem(
        id: 5,
        name: 'Butter Naan',
        price: 45,
        image: '',
        category: 'Main Course',
        isVeg: true,
        isAvailable: true,
        gstPercent: 0,
        itemCode: 'ITM1005',
        isActive: true,
      ),
      const MenuItem(
        id: 6,
        name: 'Dal Tadka',
        price: 140,
        image: '',
        category: 'Main Course',
        isVeg: true,
        isAvailable: true,
        gstPercent: 5,
        itemCode: 'ITM1006',
        isActive: false,
      ),
      const MenuItem(
        id: 7,
        name: 'Gulab Jamun',
        price: 90,
        image: '',
        category: 'Desserts',
        isVeg: true,
        isAvailable: true,
        gstPercent: 5,
        itemCode: 'ITM1007',
        isActive: true,
      ),
      const MenuItem(
        id: 8,
        name: 'Ice Cream',
        price: 110,
        image: '',
        category: 'Desserts',
        isVeg: true,
        isAvailable: true,
        gstPercent: 5,
        itemCode: 'ITM1008',
        isActive: true,
      ),
      const MenuItem(
        id: 9,
        name: 'Fresh Lime Soda',
        price: 80,
        image: '',
        category: 'Drinks',
        isVeg: true,
        isAvailable: true,
        gstPercent: 5,
        itemCode: 'ITM1009',
        isActive: true,
      ),
      const MenuItem(
        id: 10,
        name: 'Cold Coffee',
        price: 130,
        image: '',
        category: 'Drinks',
        isVeg: true,
        isAvailable: true,
        gstPercent: 5,
        itemCode: 'ITM1010',
        isActive: true,
      ),
      const MenuItem(
        id: 11,
        name: 'Masala Dosa',
        price: 150,
        image: '',
        category: 'Dosa',
        isVeg: true,
        isAvailable: true,
        gstPercent: 5,
        itemCode: 'ITM1011',
        isActive: true,
      ),
      const MenuItem(
        id: 12,
        name: 'Paneer Roll',
        price: 140,
        image: '',
        category: 'Rolls',
        isVeg: true,
        isAvailable: true,
        gstPercent: 5,
        itemCode: 'ITM1012',
        isActive: true,
      ),
    ];

    products.assignAll(seed);

    _nextId = products.map((e) => e.id).fold(0, (a, b) => a > b ? a : b) + 1;
    _nextCode = 1001 + products.length;
  }

  String generateItemCode() {
    final code = 'ITM$_nextCode';
    _nextCode++;
    return code;
  }

  void addProduct(MenuItem item) {
    products.add(item);
  }

  void createProduct({
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
  }) {
    final id = _nextId++;
    final itemCode = generateItemCode();
    products.add(
      MenuItem(
        id: id,
        name: name,
        price: price,
        image: image,
        category: category,
        isVeg: isVeg,
        isAvailable: isAvailable,
        gstPercent: gstPercent,
        itemCode: itemCode,
        isActive: isActive,
        description: description,
        prepMinutes: prepMinutes,
        discountPercent: discountPercent,
      ),
    );
  }

  void editProduct({
    required int id,
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
  }) {
    final idx = products.indexWhere((e) => e.id == id);
    if (idx == -1) return;

    final current = products[idx];
    products[idx] = MenuItem(
      id: current.id,
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
    );
  }

  void deleteProduct(int id) {
    products.removeWhere((e) => e.id == id);
  }

  void setProductStatus(int id, bool active) {
    final idx = products.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    final current = products[idx];
    products[idx] = MenuItem(
      id: current.id,
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
    );
  }

  List<MenuItem> get activeProducts {
    return products.where((p) => p.isActive).toList();
  }
}
