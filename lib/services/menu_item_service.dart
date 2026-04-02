import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/menu_item.dart';

class MenuItemService {
  final CollectionReference _col =
      FirebaseFirestore.instance.collection('menu_items');

  /// Real-time stream of all menu items
  Stream<List<MenuItem>> get stream => _col
      .orderBy('itemCode')
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => MenuItem.fromMap(d.id, d.data() as Map<String, dynamic>))
          .toList());

  /// Add a new item — Firestore auto-generates the doc ID
  Future<String> add(MenuItem item) async {
    final ref = await _col.add(item.toMap());
    return ref.id;
  }

  /// Update an existing item by doc ID
  Future<void> update(MenuItem item) async {
    await _col.doc(item.id).update(item.toMap());
  }

  /// Delete an item by doc ID
  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }

  /// Seed initial data only if the collection is empty
  Future<void> seedIfEmpty() async {
    final snap = await _col.limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    final seeds = _seedData();
    for (final item in seeds) {
      batch.set(_col.doc(), item.toMap());
    }
    await batch.commit();
  }

  List<MenuItem> _seedData() => [
        const MenuItem(id: '', name: 'Paneer Tikka', price: 180, image: '', category: 'Starters', isVeg: true, isAvailable: true, gstPercent: 5, itemCode: 'ITM1001', isActive: true),
        const MenuItem(id: '', name: 'Chicken 65', price: 220, image: '', category: 'Starters', isVeg: false, isAvailable: true, gstPercent: 5, itemCode: 'ITM1002', isActive: true),
        const MenuItem(id: '', name: 'Veg Fried Rice', price: 160, image: '', category: 'Main Course', isVeg: true, isAvailable: true, gstPercent: 5, itemCode: 'ITM1003', isActive: true),
        const MenuItem(id: '', name: 'Chicken Biryani', price: 260, image: '', category: 'Main Course', isVeg: false, isAvailable: true, gstPercent: 5, itemCode: 'ITM1004', isActive: true),
        const MenuItem(id: '', name: 'Butter Naan', price: 45, image: '', category: 'Main Course', isVeg: true, isAvailable: true, gstPercent: 0, itemCode: 'ITM1005', isActive: true),
        const MenuItem(id: '', name: 'Gulab Jamun', price: 90, image: '', category: 'Desserts', isVeg: true, isAvailable: true, gstPercent: 5, itemCode: 'ITM1007', isActive: true),
        const MenuItem(id: '', name: 'Ice Cream', price: 110, image: '', category: 'Desserts', isVeg: true, isAvailable: true, gstPercent: 5, itemCode: 'ITM1008', isActive: true),
        const MenuItem(id: '', name: 'Fresh Lime Soda', price: 80, image: '', category: 'Drinks', isVeg: true, isAvailable: true, gstPercent: 5, itemCode: 'ITM1009', isActive: true),
        const MenuItem(id: '', name: 'Cold Coffee', price: 130, image: '', category: 'Drinks', isVeg: true, isAvailable: true, gstPercent: 5, itemCode: 'ITM1010', isActive: true),
        const MenuItem(id: '', name: 'Masala Dosa', price: 150, image: '', category: 'Dosa', isVeg: true, isAvailable: true, gstPercent: 5, itemCode: 'ITM1011', isActive: true),
        const MenuItem(id: '', name: 'Paneer Roll', price: 140, image: '', category: 'Rolls', isVeg: true, isAvailable: true, gstPercent: 5, itemCode: 'ITM1012', isActive: true),
      ];
}
