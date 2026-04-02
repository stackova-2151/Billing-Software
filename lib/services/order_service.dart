import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pos_order.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'orders';

  Stream<List<PosOrder>> getOrdersStream() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PosOrder.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> addOrder(PosOrder order) async {
    await _firestore.collection(_collection).doc(order.id).set(order.toMap());
  }

  Future<List<PosOrder>> getOrdersForDay(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection(_collection)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThan: Timestamp.fromDate(end))
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => PosOrder.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<List<PosOrder>> getOrdersForLastDays(int days) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));

    final snapshot = await _firestore
        .collection(_collection)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => PosOrder.fromMap(doc.id, doc.data()))
        .toList();
  }
}
