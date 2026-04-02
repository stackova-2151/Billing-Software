class MenuItem {
  final String id;
  final String name;
  final double price;
  final String image;
  final String category;
  final bool isVeg;
  final bool isAvailable;
  final double gstPercent;
  final String itemCode;
  final bool isActive;
  final String description;
  final int prepMinutes;
  final double discountPercent;

  const MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    required this.isVeg,
    required this.isAvailable,
    this.gstPercent = 5,
    this.itemCode = '',
    this.isActive = true,
    this.description = '',
    this.prepMinutes = 0,
    this.discountPercent = 0,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'price': price,
        'image': image,
        'category': category,
        'isVeg': isVeg,
        'isAvailable': isAvailable,
        'gstPercent': gstPercent,
        'itemCode': itemCode,
        'isActive': isActive,
        'description': description,
        'prepMinutes': prepMinutes,
        'discountPercent': discountPercent,
      };

  factory MenuItem.fromMap(String docId, Map<String, dynamic> map) => MenuItem(
        id: docId,
        name: map['name'] ?? '',
        price: (map['price'] ?? 0).toDouble(),
        image: map['image'] ?? '',
        category: map['category'] ?? '',
        isVeg: map['isVeg'] ?? true,
        isAvailable: map['isAvailable'] ?? true,
        gstPercent: (map['gstPercent'] ?? 5).toDouble(),
        itemCode: map['itemCode'] ?? '',
        isActive: map['isActive'] ?? true,
        description: map['description'] ?? '',
        prepMinutes: (map['prepMinutes'] ?? 0).toInt(),
        discountPercent: (map['discountPercent'] ?? 0).toDouble(),
      );
}
