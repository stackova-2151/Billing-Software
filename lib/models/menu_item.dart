class MenuItem {
  final String id;
  final String name;
  final double price;
  final String image;
  final List<String> images;
  final String category;
  final bool isVeg;
  final bool isAvailable;
  final double gstPercent;
  final String itemCode;
  final bool isActive;
  final String description;
  final int prepMinutes;
  final double discountPercent;
  final int stockQuantity;
  final int lowStockThreshold;

  const MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    this.images = const <String>[],
    required this.category,
    required this.isVeg,
    required this.isAvailable,
    this.gstPercent = 5,
    this.itemCode = '',
    this.isActive = true,
    this.description = '',
    this.prepMinutes = 0,
    this.discountPercent = 0,
    this.stockQuantity = 0,
    this.lowStockThreshold = 10,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'price': price,
    'image': image,
    'images': images,
    'category': category,
    'isVeg': isVeg,
    'isAvailable': isAvailable,
    'gstPercent': gstPercent,
    'itemCode': itemCode,
    'isActive': isActive,
    'description': description,
    'prepMinutes': prepMinutes,
    'discountPercent': discountPercent,
    'stockQuantity': stockQuantity,
    'lowStockThreshold': lowStockThreshold,
  };

  factory MenuItem.fromMap(String docId, Map<String, dynamic> map) => MenuItem(
    id: docId,
    name: map['name'] ?? '',
    price: (map['price'] ?? 0).toDouble(),
    image: map['image'] ?? '',
    images: ((map['images'] ?? const <dynamic>[]) as List)
        .map((e) => e.toString())
        .toList(),
    category: map['category'] ?? '',
    isVeg: map['isVeg'] ?? true,
    isAvailable: map['isAvailable'] ?? true,
    gstPercent: (map['gstPercent'] ?? 5).toDouble(),
    itemCode: map['itemCode'] ?? '',
    isActive: map['isActive'] ?? true,
    description: map['description'] ?? '',
    prepMinutes: (map['prepMinutes'] ?? 0).toInt(),
    discountPercent: (map['discountPercent'] ?? 0).toDouble(),
    stockQuantity: (map['stockQuantity'] ?? 0).toInt(),
    lowStockThreshold: (map['lowStockThreshold'] ?? 10).toInt(),
  );

  String get stockStatus {
    if (stockQuantity <= 0) return 'OUT_OF_STOCK';
    if (stockQuantity <= lowStockThreshold) return 'LOW_STOCK';
    return 'IN_STOCK';
  }

  MenuItem copyWith({
    String? id,
    String? name,
    double? price,
    String? image,
    List<String>? images,
    String? category,
    bool? isVeg,
    bool? isAvailable,
    double? gstPercent,
    String? itemCode,
    bool? isActive,
    String? description,
    int? prepMinutes,
    double? discountPercent,
    int? stockQuantity,
    int? lowStockThreshold,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      images: images ?? this.images,
      category: category ?? this.category,
      isVeg: isVeg ?? this.isVeg,
      isAvailable: isAvailable ?? this.isAvailable,
      gstPercent: gstPercent ?? this.gstPercent,
      itemCode: itemCode ?? this.itemCode,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
      prepMinutes: prepMinutes ?? this.prepMinutes,
      discountPercent: discountPercent ?? this.discountPercent,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
    );
  }
}
