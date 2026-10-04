import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item.dart';

class StockService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'menu_items';

  Future<void> updateStock({
    required String itemId,
    required int addedQuantity,
    int? lowStockThreshold,
  }) async {
    final docRef = _firestore.collection(_collection).doc(itemId);
    final doc = await docRef.get();
    
    if (!doc.exists) throw Exception('Item not found');
    
    final currentStock = (doc.data()?['stockQuantity'] ?? 0) as int;
    final newStock = currentStock + addedQuantity;
    
    final updateData = <String, dynamic>{
      'stockQuantity': newStock,
    };
    
    if (lowStockThreshold != null) {
      updateData['lowStockThreshold'] = lowStockThreshold;
    }
    
    await docRef.update(updateData);
  }

  Future<void> setStock({
    required String itemId,
    required int stockQuantity,
    required int lowStockThreshold,
  }) async {
    final docRef = _firestore.collection(_collection).doc(itemId);
    final doc = await docRef.get();
    
    if (!doc.exists) throw Exception('Item not found');
    
    await docRef.update({
      'stockQuantity': stockQuantity,
      'lowStockThreshold': lowStockThreshold,
    });
  }

  Future<void> updateStockItem({
    required String itemId,
    required String itemCode,
    required String itemName,
    required String category,
    required int stockQuantity,
    required int lowStockThreshold,
  }) async {
    final docRef = _firestore.collection(_collection).doc(itemId);
    final doc = await docRef.get();
    
    if (!doc.exists) throw Exception('Item not found');
    
    await docRef.update({
      'itemCode': itemCode,
      'name': itemName,
      'category': category,
      'stockQuantity': stockQuantity,
      'lowStockThreshold': lowStockThreshold,
    });
  }

  Future<void> reduceStock(String itemId, int quantity) async {
    final docRef = _firestore.collection(_collection).doc(itemId);
    final doc = await docRef.get();
    
    if (!doc.exists) throw Exception('Item not found');
    
    final currentStock = (doc.data()?['stockQuantity'] ?? 0) as int;
    
    final newStock = (currentStock - quantity).clamp(0, double.maxFinite.toInt());
    await docRef.update({
      'stockQuantity': newStock,
    });
  }

  Future<void> reduceStockBatch(Map<String, int> itemQuantities) async {
    final batch = _firestore.batch();
    
    for (final entry in itemQuantities.entries) {
      final itemId = entry.key;
      final quantity = entry.value;
      
      final docRef = _firestore.collection(_collection).doc(itemId);
      final doc = await docRef.get();
      
      if (!doc.exists) throw Exception('Item $itemId not found');
      
      final currentStock = (doc.data()?['stockQuantity'] ?? 0) as int;
      
      final newStock = (currentStock - quantity).clamp(0, double.maxFinite.toInt());
      batch.update(docRef, {
        'stockQuantity': newStock,
      });
    }
    
    await batch.commit();
  }

  Stream<List<MenuItem>> getStockStream() {
    return _firestore
        .collection(_collection)
        .orderBy('itemCode')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MenuItem.fromMap(d.id, d.data()))
            .toList());
  }
}
