import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/cart_controller.dart';
import '../models/menu_item.dart';

class ItemCardWidget extends StatelessWidget {
  final MenuItem item;
  final CartController cartController;
  final int index;

  const ItemCardWidget({
    super.key,
    required this.item,
    required this.cartController,
    required this.index,
  });

  static const Color textColor = Color(0xFF2E2E2E);

  static const List<Color> pastelColors = <Color>[
    Color(0xFFE6E1FF),
    Color(0xFFF9DCDC),
    Color(0xFFDDE7FF),
  ];

  void _handleTap() {
    final qty = cartController.getQty(item.id);
    if (qty <= 0) {
      cartController.addItem(item);
    } else {
      cartController.increaseQty(item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = pastelColors[index % pastelColors.length];

    return Obx(() {
      cartController.getQty(item.id);

      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _handleTap,
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 20,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: Text(
                        item.name.toUpperCase(),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          letterSpacing: 0.3,
                          color: textColor,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      child: Text(
                        '₹${item.price.toStringAsFixed(0)}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: -54,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.ramen_dining,
                          size: 54,
                          color: Color(0xFF2E2E2E),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
