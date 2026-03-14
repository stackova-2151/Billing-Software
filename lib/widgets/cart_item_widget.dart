import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/cart_controller.dart';

class CartItemWidget extends StatelessWidget {
  final CartLine line;
  final CartController cartController;

  const CartItemWidget({
    super.key,
    required this.line,
    required this.cartController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E5E5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                line.item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2E2E2E),
                ),
              ),
            ),
            _QtyMini(
              qty: line.qty.value,
              onMinus: () => cartController.decreaseQty(line.item.id),
              onPlus: () => cartController.increaseQty(line.item.id),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 70,
              child: Text(
                '₹${line.lineTotal.toStringAsFixed(0)}',
                textAlign: TextAlign.right,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2E2E2E),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _QtyMini extends StatelessWidget {
  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _QtyMini({
    required this.qty,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TapIcon(icon: Icons.remove, onTap: onMinus),
          SizedBox(
            width: 28,
            child: Center(
              child: Text(
                '$qty',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2E2E2E),
                ),
              ),
            ),
          ),
          _TapIcon(icon: Icons.add, onTap: onPlus),
        ],
      ),
    );
  }
}

class _TapIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TapIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: SizedBox(
        width: 32,
        child: Center(
          child: Icon(icon, size: 16, color: const Color(0xFF2E2E2E)),
        ),
      ),
    );
  }
}
