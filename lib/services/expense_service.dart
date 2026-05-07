import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'expenses';

  Future<void> addExpense(Expense expense) async {
    await _firestore.collection(_collection).add(expense.toMap());
  }

  Future<void> updateExpense(Expense expense) async {
    await _firestore.collection(_collection).doc(expense.id).update(expense.toMap());
  }

  Stream<List<Expense>> getExpensesStream() {
    return _firestore
        .collection(_collection)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Expense.fromMap(d.id, d.data()))
            .toList());
  }

  Future<List<Expense>> getExpensesForDateRange(DateTime start, DateTime end) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Expense.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> deleteExpense(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
