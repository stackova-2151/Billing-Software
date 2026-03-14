import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/cart_controller.dart';
import 'cart_item_widget.dart';

class CartWidget extends StatefulWidget {
  final CartController cartController;

  const CartWidget({
    super.key,
    required this.cartController,
  });

  @override
  State<CartWidget> createState() => _CartWidgetState();
}

class _CartWidgetState extends State<CartWidget> {
  late final TextEditingController tableController;
  late final TextEditingController customerController;

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
                Obx(() {
                  return Text(
                    '${widget.cartController.totalItems} items',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF64748B),
                    ),
                  );
                }),
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
                if (widget.cartController.cartLines.isEmpty) {
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
                  itemCount: widget.cartController.cartLines.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final line = widget.cartController.cartLines[index];
                    return CartItemWidget(
                      line: line,
                      cartController: widget.cartController,
                    );
                  },
                );
              }),
            ),
          ),
          Obx(() {
            final subtotal = widget.cartController.subtotal;
            final gst = widget.cartController.gstAmount;
            final total = widget.cartController.total;

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
                  _TotalRow(label: 'Subtotal', value: '₹${subtotal.toStringAsFixed(0)}'),
                  const SizedBox(height: 8),
                  _TotalRow(label: 'GST (5%)', value: '₹${gst.toStringAsFixed(0)}'),
                  const SizedBox(height: 10),
                  _TotalRow(
                    label: 'Total',
                    value: '₹${total.toStringAsFixed(0)}',
                    emphasis: true,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2E2E2E),
                            side: const BorderSide(color: Color(0xFFE5E5E5)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {},
                          child: const Text(
                            'Hold',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFDC2626),
                            side: const BorderSide(color: Color(0xFFFECACA)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: widget.cartController.cartLines.isEmpty
                              ? null
                              : () => widget.cartController.clear(),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _PayButton(
                          label: 'CASH PAY',
                          icon: Icons.payments_outlined,
                          onTap: widget.cartController.cartLines.isEmpty ? null : () {},
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _PayButton(
                          label: 'UPI QR',
                          icon: Icons.qr_code_2,
                          onTap: widget.cartController.cartLines.isEmpty ? null : () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _PayButton(
                    label: 'CARD SWIPE',
                    icon: Icons.credit_card,
                    onTap: widget.cartController.cartLines.isEmpty ? null : () {},
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
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
