import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../controllers/cart_controller.dart';
import '../controllers/orders_controller.dart';
import '../http_client_factory.dart';
import '../models/pos_order.dart';
import 'cart_item_widget.dart';

class CartWidget extends StatefulWidget {
  final CartController cartController;

  const CartWidget({super.key, required this.cartController});

  @override
  State<CartWidget> createState() => _CartWidgetState();
}

class _CartWidgetState extends State<CartWidget> {
  late final TextEditingController tableController;
  late final TextEditingController customerController;

  OrdersController get _ordersController => Get.find<OrdersController>();

  void _log(String message) => debugPrint('[CartWidget] $message');

  Uri _getPrintApiUri() {
    const path = '/print';
    const port = 3000;
    if (kIsWeb) return Uri.parse('http://localhost:$port$path');
    if (defaultTargetPlatform == TargetPlatform.android) {
      return Uri.parse('http://10.0.2.2:$port$path');
    }
    return Uri.parse('http://localhost:$port$path');
  }

  void _showSnackBar(BuildContext context,
      {required String message, bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  String _generateReceiptText() {
    final cart = widget.cartController;
    final buffer = StringBuffer();
    buffer.writeln('=========== RECEIPT ===========');

    final tableNo = tableController.text.trim();
    final customerName = customerController.text.trim();
    if (tableNo.isNotEmpty) buffer.writeln('Table: $tableNo');
    if (customerName.isNotEmpty) buffer.writeln('Customer: $customerName');
    buffer.writeln('Payment: ${cart.paymentMode.value}');
    buffer.writeln('--------------------------------');

    for (final line in cart.cartLines) {
      buffer.writeln(line.item.name);
      buffer.writeln(
        '  ${line.qty.value} x ₹${line.item.price.toStringAsFixed(0)} = ₹${line.lineTotal.toStringAsFixed(0)}',
      );
    }

    buffer.writeln('--------------------------------');
    buffer.writeln('Subtotal: ₹${cart.subtotal.toStringAsFixed(0)}');
    buffer.writeln('GST (5%): ₹${cart.gstAmount.toStringAsFixed(0)}');
    buffer.writeln('TOTAL: ₹${cart.total.toStringAsFixed(0)}');
    buffer.writeln('================================');
    return buffer.toString();
  }

  Future<void> printBill() async {
    final cart = widget.cartController;
    if (cart.cartLines.isEmpty) {
      _showSnackBar(context, message: 'Cart is empty', isError: true);
      return;
    }

    final payload = <String, dynamic>{
      'text': _generateReceiptText(),
      'paymentMode': cart.paymentMode.value,
    };

    final uri = _getPrintApiUri();
    _log('API: URL=$uri payload=${jsonEncode(payload)}');

    try {
      final http.Client client = createHttpClient();
      try {
        final response = await client.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        _log('API: status=${response.statusCode} body=${response.body}');
        if (!mounted) return;

        final ok = response.statusCode >= 200 && response.statusCode < 300;
        if (ok) {
          _showSnackBar(context, message: 'Printed successfully');

          final now = DateTime.now();
          final payment = cart.paymentMode.value == 'CASH'
              ? PosPaymentMode.cash
              : PosPaymentMode.online;

          final order = PosOrder(
            id: 'ORD-${now.millisecondsSinceEpoch}',
            createdAt: now,
            lines: cart.cartLines
                .map((l) => PosOrderLine(
                      itemId: l.item.id,
                      itemName: l.item.name,
                      qty: l.qty.value,
                      unitPrice: l.item.price,
                    ))
                .toList(),
            subtotal: cart.subtotal,
            gstAmount: cart.gstAmount,
            total: cart.total,
            paymentMode: payment,
            customerName: customerController.text.trim(),
          );

          _ordersController.addOrder(order);
          cart.clear();
        } else {
          _showSnackBar(
            context,
            message: 'Print failed (HTTP ${response.statusCode})',
            isError: true,
          );
        }
      } finally {
        client.close();
      }
    } catch (e, st) {
      _log('ERROR: $e\n$st');
      if (!mounted) return;
      _showSnackBar(context, message: 'Print error: $e', isError: true);
    }
  }

  @override
  void initState() {
    super.initState();
    tableController = TextEditingController();
    customerController = TextEditingController();
  }

  @override
  void dispose() {
    tableController.dispose();
    customerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = widget.cartController;

    return Container(
      width: 360,
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Current Order',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF2E2E2E),
                    ),
                  ),
                ),
                Obx(() => Text(
                      '${cart.totalItems} items',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF64748B),
                      ),
                    )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _InputField(
                  controller: tableController,
                  hint: 'Table No',
                  icon: Icons.table_bar_outlined,
                ),
                const SizedBox(height: 10),
                _InputField(
                  controller: customerController,
                  hint: 'Customer Name',
                  icon: Icons.person_outline,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() {
                if (cart.cartLines.isEmpty) {
                  return Center(
                    child: Text(
                      'No items yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: cart.cartLines.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final line = cart.cartLines[index];
                    return CartItemWidget(
                      line: line,
                      cartController: cart,
                    );
                  },
                );
              }),
            ),
          ),
          Obx(() {
            final hasItems = cart.cartLines.isNotEmpty;
            return Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 12,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _TotalRow(
                    label: 'Subtotal',
                    value: '₹${cart.subtotal.toStringAsFixed(0)}',
                  ),
                  const SizedBox(height: 8),
                  _TotalRow(
                    label: 'GST (5%)',
                    value: '₹${cart.gstAmount.toStringAsFixed(0)}',
                  ),
                  const SizedBox(height: 10),
                  _TotalRow(
                    label: 'Total',
                    value: '₹${cart.total.toStringAsFixed(0)}',
                    emphasis: true,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Payment Mode: ${cart.paymentMode.value}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _PayButton(
                          label: cart.paymentMode.value == 'ONLINE'
                              ? 'CASH PAY'
                              : 'ONLINE PAY',
                          icon: Icons.payments_outlined,
                          onTap: hasItems ? cart.togglePaymentMode : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _PayButton(
                          label: 'Print Bill',
                          icon: Icons.print,
                          onTap: hasItems ? printBill : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasis;

  const _TotalRow({
    required this.label,
    required this.value,
    this.emphasis = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: const Color(0xFF475569),
              fontWeight: emphasis ? FontWeight.w900 : FontWeight.w800,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            color: const Color(0xFF2E2E2E),
            fontWeight: emphasis ? FontWeight.w900 : FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _PayButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _PayButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7ED957),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }
}
