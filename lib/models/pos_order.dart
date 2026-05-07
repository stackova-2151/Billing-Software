class PosOrderLine {
  final String itemId;
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

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'qty': qty,
      'unitPrice': unitPrice,
    };
  }

  factory PosOrderLine.fromMap(Map<String, dynamic> map) {
    return PosOrderLine(
      itemId: map['itemId'] ?? '',
      itemName: map['itemName'] ?? '',
      qty: map['qty'] ?? 0,
      unitPrice: (map['unitPrice'] ?? 0).toDouble(),
    );
  }
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
  final String tableNo;

  const PosOrder({
    required this.id,
    required this.createdAt,
    required this.lines,
    required this.subtotal,
    required this.gstAmount,
    required this.total,
    required this.paymentMode,
    this.customerName = '',
    this.tableNo = '',
  });

  int get itemsCount => lines.fold(0, (sum, e) => sum + e.qty);

  Map<String, dynamic> toMap() {
    return {
      'createdAt': createdAt.toIso8601String(),
      'lines': lines.map((line) => line.toMap()).toList(),
      'subtotal': subtotal,
      'gstAmount': gstAmount,
      'total': total,
      'paymentMode': paymentMode.name,
      'customerName': customerName,
      'tableNo': tableNo,
    };
  }

  factory PosOrder.fromMap(String docId, Map<String, dynamic> map) {
    return PosOrder(
      id: docId,
      createdAt: DateTime.parse(map['createdAt']),
      lines: (map['lines'] as List)
          .map((line) => PosOrderLine.fromMap(line))
          .toList(),
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      gstAmount: (map['gstAmount'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      paymentMode: PosPaymentMode.values.firstWhere(
        (e) => e.name == map['paymentMode'],
        orElse: () => PosPaymentMode.cash,
      ),
      customerName: map['customerName'] ?? '',
      tableNo: map['tableNo'] ?? '',
    );
  }
}
