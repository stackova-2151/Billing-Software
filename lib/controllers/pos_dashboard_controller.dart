import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/pos_order.dart';
import 'orders_controller.dart';

class TopSellingItem {
  final String name;
  final int qty;

  const TopSellingItem({required this.name, required this.qty});
}

class RecentOrderVm {
  final String id;
  final double total;
  final DateTime createdAt;

  const RecentOrderVm({
    required this.id,
    required this.total,
    required this.createdAt,
  });
}

class PosDashboardController extends GetxController {
  final OrdersController ordersController;

  PosDashboardController({required this.ordersController});

  final RxBool isLoading = false.obs;

  // Summary
  final RxDouble todaySales = 0.0.obs;
  final RxInt ordersCount = 0.obs;
  final RxInt itemsSold = 0.obs;
  final RxInt customers = 0.obs;

  // Analytics
  final RxList<double> hourlySales = List<double>.filled(24, 0.0).obs;
  final RxList<double> last7DaysSales = <double>[].obs;

  // Top items + recent orders
  final RxList<TopSellingItem> topSellingItems = <TopSellingItem>[].obs;
  final RxList<RecentOrderVm> recentOrders = <RecentOrderVm>[].obs;

  // Payment breakdown
  final RxDouble cashTotal = 0.0.obs;
  final RxDouble onlineTotal = 0.0.obs;

  void _log(String message) {
    debugPrint('[PosDashboardController] $message');
  }

  @override
  void onInit() {
    super.onInit();
    _log('Lifecycle: onInit');

    // Real-time updates: recompute whenever orders change from Firestore.
    ever<List<PosOrder>>(ordersController.orders, (_) {
      _log('Reactive: orders changed -> recompute dashboard');
      _compute();
    });

    load();
  }

  Future<void> load() async {
    _log('Data: load() called');
    isLoading.value = true;

    try {
      // If later you add API calls, log them here.
      _compute();
      _log('Data: load() success');
    } catch (e, st) {
      _log('ERROR: load() failed: $e');
      _log('ERROR: StackTrace: $st');
    } finally {
      isLoading.value = false;
    }
  }

  void _compute() {
    final now = DateTime.now();
    final todayOrders = ordersController.ordersForDay(now);

    final todayTotal = todayOrders.fold<double>(0.0, (sum, o) => sum + o.total);
    final todayItems = todayOrders.fold<int>(0, (sum, o) => sum + o.itemsCount);

    todaySales.value = todayTotal;
    ordersCount.value = todayOrders.length;
    itemsSold.value = todayItems;

    // Customers: not tracked yet, so approximate as unique customer names if present,
    // otherwise fallback to order count.
    final uniqueCustomers = <String>{};
    for (final o in todayOrders) {
      final name = o.customerName.trim();
      if (name.isNotEmpty) uniqueCustomers.add(name);
    }
    customers.value = uniqueCustomers.isEmpty ? todayOrders.length : uniqueCustomers.length;

    // Hourly sales (today)
    final hourBuckets = List<double>.filled(24, 0.0);
    for (final o in todayOrders) {
      hourBuckets[o.createdAt.hour] += o.total;
    }
    hourlySales.assignAll(hourBuckets);

    // Last 7 days trend
    final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
    final daily = List<double>.filled(7, 0.0);
    for (final o in ordersController.ordersForLastDays(7)) {
      final dayIndex = o.createdAt.difference(start).inDays;
      if (dayIndex >= 0 && dayIndex < 7) {
        daily[dayIndex] += o.total;
      }
    }
    last7DaysSales.assignAll(daily);

    // Top selling items (today)
    final qtyByItem = <String, int>{};
    for (final o in todayOrders) {
      for (final l in o.lines) {
        qtyByItem[l.itemName] = (qtyByItem[l.itemName] ?? 0) + l.qty;
      }
    }
    final top = qtyByItem.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    topSellingItems.assignAll(
      top.take(6).map((e) => TopSellingItem(name: e.key, qty: e.value)).toList(),
    );

    // Recent orders
    final recent = todayOrders.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    recentOrders.assignAll(
      recent.take(8).map((o) => RecentOrderVm(id: o.id, total: o.total, createdAt: o.createdAt)).toList(),
    );

    // Payment breakdown (today)
    double cash = 0;
    double online = 0;
    for (final o in todayOrders) {
      if (o.paymentMode == PosPaymentMode.cash) {
        cash += o.total;
      } else {
        online += o.total;
      }
    }
    cashTotal.value = cash;
    onlineTotal.value = online;

    _log('Compute: todaySales=${todaySales.value.toStringAsFixed(2)} orders=${ordersCount.value} items=${itemsSold.value} cash=${cashTotal.value.toStringAsFixed(2)} online=${onlineTotal.value.toStringAsFixed(2)}');
  }
}
