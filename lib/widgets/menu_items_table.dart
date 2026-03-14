import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/menu_controller.dart' as app;
import '../models/menu_item.dart';
import 'add_menu_item_dialog.dart';

class MenuItemsTable extends StatelessWidget {
  final app.MenuController menuController;

  const MenuItemsTable({super.key, required this.menuController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final items = menuController.managementItems;

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeaderRow(theme: theme),
            const SizedBox(height: 6),
            ...items.map(
              (e) => _ItemRow(item: e, menuController: menuController),
            ),
          ],
        ),
      );
    });
  }
}

class _HeaderRow extends StatelessWidget {
  final ThemeData theme;

  const _HeaderRow({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Row(
        children:
            [
              const SizedBox(width: 64, child: Text('Image')),
              const SizedBox(width: 250, child: Text('Item Name')),
              const SizedBox(width: 160, child: Text('Category')),
              const SizedBox(width: 120, child: Text('Price')),
              const SizedBox(width: 120, child: Text('Status')),
              const Spacer(),
              const SizedBox(width: 50, child: Text('Actions')),
            ].map((w) {
              if (w is SizedBox) {
                final child = w.child;
                if (child is Text) {
                  return SizedBox(
                    width: w.width,
                    child: Text(
                      child.data ?? '',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF2E2E2E),
                      ),
                    ),
                  );
                }
              }
              return w;
            }).toList(),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final MenuItem item;
  final app.MenuController menuController;

  const _ItemRow({required this.item, required this.menuController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Row(
        children: [
          SizedBox(width: 64, child: _ItemAvatar(url: item.image)),
          SizedBox(
            width: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2E2E2E),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.isVeg ? 'Veg' : 'Non-Veg',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: 160,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7F4),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFE5E5E5)),
                ),
                child: Text(
                  item.category,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2E2E2E),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              '₹${item.price.toStringAsFixed(0)}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2E2E2E),
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDFF5D8),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.isAvailable ? 'In Stock' : 'Out',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF166534),
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 50,
            child: Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<String>(
                tooltip: 'Actions',
                onSelected: (v) {
                  if (v == 'edit') {
                    Get.dialog(
                      AddMenuItemDialog(
                        menuController: menuController,
                        existing: item,
                      ),
                    );
                    return;
                  }
                  if (v == 'delete') {
                    menuController.deleteItem(item.id);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit Item')),
                  PopupMenuItem(value: 'delete', child: Text('Delete Item')),
                ],
                child: const Icon(Icons.more_vert),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemAvatar extends StatelessWidget {
  final String url;

  const _ItemAvatar({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) {
      return const CircleAvatar(
        radius: 18,
        backgroundColor: Color(0xFFF1F5F9),
        child: Icon(Icons.fastfood, size: 18, color: Color(0xFF64748B)),
      );
    }

    return CircleAvatar(
      radius: 18,
      backgroundColor: const Color(0xFFF1F5F9),
      backgroundImage: NetworkImage(url),
      onBackgroundImageError: (_, __) {},
    );
  }
}
