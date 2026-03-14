class MenuItem {
  final int id;
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
}
