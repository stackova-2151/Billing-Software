import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/cart_controller.dart';
import '../views/checkout_screen.dart';
import 'cart_item_tile.dart';

class CartSidebar extends StatelessWidget {
  final CartController cartController;

  const CartSidebar({
    super.key,
    required this.cartController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Cart',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Obx(() {
                  return Text(
                    '${cartController.totalItems} items',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF475569),
                    ),
                  );
                }),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (cartController.cartLines.isEmpty) {
                return Center(
                  child: Text(
                    'Tap menu items to add',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: cartController.cartLines.length,
                itemBuilder: (context, index) {
                  final line = cartController.cartLines[index];
                  return Obx(() {
                    return CartItemTile(
                      line: line,
                      onIncrease: () => cartController.increaseQty(line.item.id),
                      onDecrease: () => cartController.decreaseQty(line.item.id),
                      onRemove: () => cartController.removeItem(line.item.id),
                    );
                  });
                },
              );
            }),
          ),
          Obx(() {
            final subtotal = cartController.subtotal;
            final total = cartController.total;

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _TotalRow(
                    label: 'Subtotal',
                    value: '₹${subtotal.toStringAsFixed(0)}',
                  ),
                  const SizedBox(height: 8),
                  _TotalRow(
                    label: 'Total',
                    value: '₹${total.toStringAsFixed(0)}',
                    isEmphasis: true,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: cartController.cartLines.isEmpty
                          ? null
                          : () {
                              Get.to(() => CheckoutScreen(cartController: cartController));
                            },
                      child: const Text(
                        'Checkout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
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

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isEmphasis;

  const _TotalRow({
    required this.label,
    required this.value,
    this.isEmphasis = false,
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
              color: const Color(0xFF334155),
              fontWeight: isEmphasis ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            color: const Color(0xFF0F172A),
            fontWeight: isEmphasis ? FontWeight.w900 : FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
