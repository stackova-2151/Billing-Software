import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

class CategoryModel {
  final String id;
  final String name;
  final int displayOrder;
  final bool isActive;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.displayOrder,
    required this.isActive,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'displayOrder': displayOrder,
        'isActive': isActive,
      };

  factory CategoryModel.fromMap(String docId, Map<String, dynamic> map) =>
      CategoryModel(
        id: docId,
        name: map['name'] ?? '',
        displayOrder: (map['displayOrder'] ?? 0).toInt(),
        isActive: map['isActive'] ?? true,
      );
}

class CategoryService {
  final CollectionReference _col =
      FirebaseFirestore.instance.collection('categories');
  final CollectionReference _menuItemsCol =
      FirebaseFirestore.instance.collection('menu_items');

  Stream<List<CategoryModel>> get stream => _col
      .orderBy('displayOrder')
      .snapshots()
      .map((snap) => snap.docs
          .map((d) =>
              CategoryModel.fromMap(d.id, d.data() as Map<String, dynamic>))
          .toList());

  /// Check if category name already exists (case-insensitive)
  Future<bool> categoryNameExists(String name, {String? excludeId}) async {
    try {
      final normalizedName = name.trim().toLowerCase();
      final snapshot = await _col.get();
      
      for (final doc in snapshot.docs) {
        if (doc.id == excludeId) continue;
        final existingName = (doc.data() as Map<String, dynamic>)['name'] as String;
        if (existingName.trim().toLowerCase() == normalizedName) {
          return true;
        }
      }
      return false;
    } catch (e) {
      developer.log('Error checking category name: $e', name: 'CategoryService');
      rethrow;
    }
  }

  /// Count menu items using this category
  Future<int> countItemsUsingCategory(String categoryName) async {
    try {
      final snapshot = await _menuItemsCol
          .where('category', isEqualTo: categoryName)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      developer.log('Error counting items: $e', name: 'CategoryService');
      rethrow;
    }
  }

  /// Get category by ID
  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      final doc = await _col.doc(id).get();
      if (!doc.exists) return null;
      return CategoryModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    } catch (e) {
      developer.log('Error getting category: $e', name: 'CategoryService');
      rethrow;
    }
  }

  /// Add category with duplicate check
  Future<String> add(CategoryModel category) async {
    try {
      // Validate name is not empty
      if (category.name.trim().isEmpty) {
        throw Exception('Category name cannot be empty');
      }

      // Check for duplicates
      final exists = await categoryNameExists(category.name);
      if (exists) {
        throw Exception('Category "${category.name}" already exists');
      }

      final ref = await _col.add(category.toMap());
      developer.log('Category added: ${category.name} (${ref.id})', name: 'CategoryService');
      return ref.id;
    } catch (e) {
      developer.log('Error adding category: $e', name: 'CategoryService');
      rethrow;
    }
  }

  /// Update category with rename cascade
  Future<void> update(CategoryModel category) async {
    try {
      // Validate name is not empty
      if (category.name.trim().isEmpty) {
        throw Exception('Category name cannot be empty');
      }

      // Get old category data
      final oldCategory = await getCategoryById(category.id);
      if (oldCategory == null) {
        throw Exception('Category not found');
      }

      final oldName = oldCategory.name;
      final newName = category.name.trim();

      // Check for duplicates (excluding current category)
      if (oldName.toLowerCase() != newName.toLowerCase()) {
        final exists = await categoryNameExists(newName, excludeId: category.id);
        if (exists) {
          throw Exception('Category "$newName" already exists');
        }
      }

      // Update category
      await _col.doc(category.id).update(category.toMap());

      // If name changed, cascade update to all menu items
      if (oldName != newName) {
        developer.log('Category renamed: "$oldName" → "$newName"', name: 'CategoryService');
        await _cascadeRenameToMenuItems(oldName, newName);
      }

      developer.log('Category updated: ${category.name}', name: 'CategoryService');
    } catch (e) {
      developer.log('Error updating category: $e', name: 'CategoryService');
      rethrow;
    }
  }

  /// Cascade rename category in all menu items
  Future<void> _cascadeRenameToMenuItems(String oldName, String newName) async {
    try {
      final snapshot = await _menuItemsCol
          .where('category', isEqualTo: oldName)
          .get();

      if (snapshot.docs.isEmpty) {
        developer.log('No items to update for category rename', name: 'CategoryService');
        return;
      }

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'category': newName});
      }

      await batch.commit();
      developer.log('Updated ${snapshot.docs.length} items with new category name', name: 'CategoryService');
    } catch (e) {
      developer.log('Error cascading rename: $e', name: 'CategoryService');
      rethrow;
    }
  }

  /// Delete category with validation
  Future<void> delete(String id) async {
    try {
      // Get category details
      final category = await getCategoryById(id);
      if (category == null) {
        throw Exception('Category not found');
      }

      // Check if any items are using this category
      final itemCount = await countItemsUsingCategory(category.name);
      if (itemCount > 0) {
        throw Exception(
          'Cannot delete category "${category.name}". It is used in $itemCount item${itemCount > 1 ? 's' : ''}.');
      }

      await _col.doc(id).delete();
      developer.log('Category deleted: ${category.name}', name: 'CategoryService');
    } catch (e) {
      developer.log('Error deleting category: $e', name: 'CategoryService');
      rethrow;
    }
  }

  Future<void> seedIfEmpty() async {
    final snap = await _col.limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    final seeds = [
      const CategoryModel(
          id: '', name: 'Starters', displayOrder: 1, isActive: true),
      const CategoryModel(
          id: '', name: 'Main Course', displayOrder: 2, isActive: true),
      const CategoryModel(
          id: '', name: 'Desserts', displayOrder: 3, isActive: true),
      const CategoryModel(
          id: '', name: 'Drinks', displayOrder: 4, isActive: true),
      const CategoryModel(
          id: '', name: 'Dosa', displayOrder: 5, isActive: true),
      const CategoryModel(
          id: '', name: 'Rolls', displayOrder: 6, isActive: true),
    ];

    for (final cat in seeds) {
      batch.set(_col.doc(), cat.toMap());
    }
    await batch.commit();
  }
}
