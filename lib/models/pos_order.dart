class PosOrderLine {
  final int itemId;
  final String itemName;
  final int qty;
  final double unitPrice;

  const PosOrderLine({
    required this.itemId,
    required this.itemName,
    required this.qty,
    required this.unitPrice,
  });

  double get lineTotal => unitPrice * qty;
}

enum PosPaymentMode { cash, online }

class PosOrder {
  final String id;
  final DateTime createdAt;
  final List<PosOrderLine> lines;
  final double subtotal;
  final double gstAmount;
  final double total;
  final PosPaymentMode paymentMode;
  final String customerName;

  const PosOrder({
    required this.id,
    required this.createdAt,
    required this.lines,
    required this.subtotal,
    required this.gstAmount,
    required this.total,
    required this.paymentMode,
    this.customerName = '',
  });

  int get itemsCount => lines.fold(0, (sum, e) => sum + e.qty);
}
