class ReportSummary {
  final double totalSales;
  final int totalOrders;
  final double avgOrderValue;
  final int totalCustomers;

  const ReportSummary({
    required this.totalSales,
    required this.totalOrders,
    required this.avgOrderValue,
    required this.totalCustomers,
  });

  factory ReportSummary.empty() {
    return const ReportSummary(
      totalSales: 0,
      totalOrders: 0,
      avgOrderValue: 0,
      totalCustomers: 0,
    );
  }
}

class SalesTrendData {
  final DateTime date;
  final double amount;

  const SalesTrendData({
    required this.date,
    required this.amount,
  });
}

class PaymentBreakdown {
  final double cashAmount;
  final double onlineAmount;

  const PaymentBreakdown({
    required this.cashAmount,
    required this.onlineAmount,
  });

  double get total => cashAmount + onlineAmount;
  double get cashPercentage => total > 0 ? (cashAmount / total) * 100 : 0;
  double get onlinePercentage => total > 0 ? (onlineAmount / total) * 100 : 0;
}

class TopItemData {
  final String itemName;
  final int quantity;
  final double revenue;

  const TopItemData({
    required this.itemName,
    required this.quantity,
    required this.revenue,
  });
}

enum ReportType { sales, items, payments }

enum DateRangeType { week, month, year }
