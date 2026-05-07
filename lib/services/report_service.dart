import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pos_order.dart';
import '../models/report_data.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'orders';

  Future<List<PosOrder>> getOrdersByDateRange(DateTime start, DateTime end) async {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);

    final snapshot = await _firestore
        .collection(_collection)
        .where('createdAt', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('createdAt', isLessThanOrEqualTo: endDate.toIso8601String())
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => PosOrder.fromMap(doc.id, doc.data()))
        .toList();
  }

  ReportSummary calculateSummary(List<PosOrder> orders) {
    if (orders.isEmpty) return ReportSummary.empty();

    final totalSales = orders.fold<double>(0, (sum, order) => sum + order.total);
    final totalOrders = orders.length;
    final avgOrderValue = totalSales / totalOrders;
    final uniqueCustomers = orders
        .where((o) => o.customerName.isNotEmpty)
        .map((o) => o.customerName)
        .toSet()
        .length;

    return ReportSummary(
      totalSales: totalSales,
      totalOrders: totalOrders,
      avgOrderValue: avgOrderValue,
      totalCustomers: uniqueCustomers,
    );
  }

  List<SalesTrendData> calculateSalesTrend(
    List<PosOrder> orders,
    DateRangeType rangeType,
  ) {
    if (orders.isEmpty) return [];

    switch (rangeType) {
      case DateRangeType.week:
        return _calculateDailySales(orders);
      case DateRangeType.month:
        return _calculateWeeklySales(orders);
      case DateRangeType.year:
        return _calculateMonthlySales(orders);
    }
  }

  List<SalesTrendData> _calculateDailySales(List<PosOrder> orders) {
    final Map<DateTime, double> dailySales = {};

    for (var order in orders) {
      final date = DateTime(
        order.createdAt.year,
        order.createdAt.month,
        order.createdAt.day,
      );
      dailySales[date] = (dailySales[date] ?? 0) + order.total;
    }

    return dailySales.entries
        .map((e) => SalesTrendData(date: e.key, amount: e.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<SalesTrendData> _calculateWeeklySales(List<PosOrder> orders) {
    final Map<int, double> weeklySales = {};
    
    if (orders.isEmpty) return [];
    
    final firstDate = orders.first.createdAt;
    final baseDate = DateTime(firstDate.year, firstDate.month, 1);

    for (var order in orders) {
      final daysDiff = order.createdAt.difference(baseDate).inDays;
      final weekNumber = (daysDiff / 7).floor();
      weeklySales[weekNumber] = (weeklySales[weekNumber] ?? 0) + order.total;
    }

    return weeklySales.entries
        .map((e) => SalesTrendData(
              date: baseDate.add(Duration(days: e.key * 7)),
              amount: e.value,
            ))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<SalesTrendData> _calculateMonthlySales(List<PosOrder> orders) {
    final Map<String, double> monthlySales = {};

    for (var order in orders) {
      final monthKey = '${order.createdAt.year}-${order.createdAt.month.toString().padLeft(2, '0')}';
      monthlySales[monthKey] = (monthlySales[monthKey] ?? 0) + order.total;
    }

    return monthlySales.entries
        .map((e) {
          final parts = e.key.split('-');
          return SalesTrendData(
            date: DateTime(int.parse(parts[0]), int.parse(parts[1]), 1),
            amount: e.value,
          );
        })
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  PaymentBreakdown calculatePaymentBreakdown(List<PosOrder> orders) {
    double cashAmount = 0;
    double onlineAmount = 0;

    for (var order in orders) {
      if (order.paymentMode == PosPaymentMode.cash) {
        cashAmount += order.total;
      } else {
        onlineAmount += order.total;
      }
    }

    return PaymentBreakdown(
      cashAmount: cashAmount,
      onlineAmount: onlineAmount,
    );
  }

  List<TopItemData> calculateTopItems(List<PosOrder> orders, {int limit = 5}) {
    final Map<String, Map<String, dynamic>> itemStats = {};

    for (var order in orders) {
      for (var line in order.lines) {
        if (!itemStats.containsKey(line.itemName)) {
          itemStats[line.itemName] = {'quantity': 0, 'revenue': 0.0};
        }
        itemStats[line.itemName]!['quantity'] += line.qty;
        itemStats[line.itemName]!['revenue'] += line.lineTotal;
      }
    }

    final topItems = itemStats.entries
        .map((e) => TopItemData(
              itemName: e.key,
              quantity: e.value['quantity'] as int,
              revenue: e.value['revenue'] as double,
            ))
        .toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    return topItems.take(limit).toList();
  }
}
