import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/pos_order.dart';

class OrdersController extends GetxController {
  final RxList<PosOrder> orders = <PosOrder>[].obs;

  void _log(String message) {
    debugPrint('[OrdersController] $message');
  }

  void seedIfEmpty() {
    if (orders.isNotEmpty) return;
    _log('Data: Seeding sample orders for dashboard');

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    // Seed a few orders spread across today for analytics.
    orders.addAll([
      PosOrder(
        id: 'ORD-1001',
        createdAt: todayStart.add(const Duration(hours: 9, minutes: 12)),
        lines: const [
          PosOrderLine(
            itemId: 1,
            itemName: 'Margherita Pizza',
            qty: 2,
            unitPrice: 249,
          ),
          PosOrderLine(
            itemId: 2,
            itemName: 'Dosa',
            qty: 1,
            unitPrice: 99,
          ),
        ],
        subtotal: 597,
        gstAmount: 29.85,
        total: 626.85,
        paymentMode: PosPaymentMode.online,
      ),
      PosOrder(
        id: 'ORD-1002',
        createdAt: todayStart.add(const Duration(hours: 12, minutes: 40)),
        lines: const [
          PosOrderLine(
            itemId: 3,
            itemName: 'Cheese Palak Dosa',
            qty: 1,
            unitPrice: 159,
          ),
          PosOrderLine(
            itemId: 2,
            itemName: 'Dosa',
            qty: 2,
            unitPrice: 99,
          ),
        ],
        subtotal: 357,
        gstAmount: 17.85,
        total: 374.85,
        paymentMode: PosPaymentMode.cash,
      ),
      PosOrder(
        id: 'ORD-1003',
        createdAt: todayStart.add(const Duration(hours: 14, minutes: 20)),
        lines: const [
          PosOrderLine(
            itemId: 4,
            itemName: 'Burger',
            qty: 3,
            unitPrice: 129,
          ),
        ],
        subtotal: 387,
        gstAmount: 19.35,
        total: 406.35,
        paymentMode: PosPaymentMode.online,
      ),
    ]);

    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _log('Data: Seed complete. orders=${orders.length}');
  }

  void addOrder(PosOrder order) {
    _log('Data: Adding order id=${order.id} total=${order.total.toStringAsFixed(2)} payment=${order.paymentMode}');
    orders.insert(0, order);
    // Trigger any derived UI computations.
    orders.refresh();
  }

  List<PosOrder> ordersForDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return orders
        .where((o) => !o.createdAt.isBefore(start) && o.createdAt.isBefore(end))
        .toList();
  }

  List<PosOrder> ordersForLastDays(int days) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));
    return orders.where((o) => !o.createdAt.isBefore(start)).toList();
  }
}
