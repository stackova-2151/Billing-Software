import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/pos_order.dart';
import '../services/order_service.dart';

class OrdersController extends GetxController {
  final OrderService _orderService = OrderService();
  final RxList<PosOrder> orders = <PosOrder>[].obs;
  final RxBool isLoading = true.obs;

  void _log(String message) {
    debugPrint('[OrdersController] $message');
  }

  @override
  void onInit() {
    super.onInit();
    _listenToOrders();
  }

  void _listenToOrders() {
    _orderService.getOrdersStream().listen((ordersList) {
      orders.value = ordersList;
      isLoading.value = false;
      _log('Orders updated: ${orders.length}');
    });
  }

  Future<void> addOrder(PosOrder order) async {
    _log('Adding order id=${order.id} total=${order.total.toStringAsFixed(2)}');
    await _orderService.addOrder(order);
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

  Future<void> loadOrders() async {
    _log('Manually loading orders');
    isLoading.value = true;
    await _orderService.refreshOrders();
  }
}
