import 'package:get/get.dart';

import '../models/menu_item.dart';

class CartLine {
  final MenuItem item;
  final RxInt qty;

  CartLine({required this.item, int quantity = 1}) : qty = quantity.obs;

  double get lineTotal => item.price * qty.value;
}

class CartController extends GetxController {
  final RxList<CartLine> cartLines = <CartLine>[].obs;
  final RxString paymentMode = 'ONLINE'.obs;

  static const double gstRate = 0.05;

  void addItem(MenuItem item) {
    final existingIndex = cartLines.indexWhere((e) => e.item.id == item.id);
    if (existingIndex != -1) {
      cartLines[existingIndex].qty.value++;
      cartLines.refresh();
      return;
    }
    cartLines.add(CartLine(item: item));
  }

  int getQty(String itemId) {
    final idx = cartLines.indexWhere((e) => e.item.id == itemId);
    if (idx == -1) return 0;
    return cartLines[idx].qty.value;
  }

  void removeItem(String itemId) {
    cartLines.removeWhere((e) => e.item.id == itemId);
  }

  void increaseQty(String itemId) {
    final idx = cartLines.indexWhere((e) => e.item.id == itemId);
    if (idx == -1) return;
    cartLines[idx].qty.value++;
    cartLines.refresh();
  }

  void decreaseQty(String itemId) {
    final idx = cartLines.indexWhere((e) => e.item.id == itemId);
    if (idx == -1) return;

    final line = cartLines[idx];
    if (line.qty.value <= 1) {
      cartLines.removeAt(idx);
      return;
    }
    line.qty.value--;
    cartLines.refresh();
  }

  double calculateTotal() {
    return cartLines.fold(0, (sum, e) => sum + e.lineTotal);
  }

  double get subtotal => calculateTotal();
  double get gstAmount => subtotal * gstRate;
  double get total => subtotal + gstAmount;

  int get totalItems => cartLines.fold(0, (sum, e) => sum + e.qty.value);

  void togglePaymentMode() {
    paymentMode.value = paymentMode.value == 'ONLINE' ? 'CASH' : 'ONLINE';
  }

  void clear() {
    cartLines.clear();
    paymentMode.value = 'ONLINE';
  }
}
