import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String note;
  final DateTime createdAt;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.note = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'amount': amount,
    'date': Timestamp.fromDate(date),
    'note': note,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory Expense.fromMap(String docId, Map<String, dynamic> map) => Expense(
    id: docId,
    title: map['title'] ?? '',
    amount: (map['amount'] ?? 0).toDouble(),
    date: (map['date'] as Timestamp).toDate(),
    note: map['note'] ?? '',
    createdAt: (map['createdAt'] as Timestamp).toDate(),
  );
}
