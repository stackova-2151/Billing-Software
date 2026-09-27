import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/product_controller.dart';
import '../models/menu_item.dart';
import '../utils/responsive_helper.dart';
import 'responsive/responsive_components.dart';

class ProductTable extends StatelessWidget {
  final ProductController productController;
  final void Function(MenuItem item) onEdit;

  const ProductTable({
    super.key,
    required this.productController,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final products = productController.products;

      // Use card layout on mobile/tablet, table on desktop
      if (ResponsiveHelper.shouldUseCardLayout(context)) {
        return _buildCardLayout(context, products, theme);
      }

      return _buildTableLayout(context, products, theme);
    });
  }

  Widget _buildTableLayout(
    BuildContext context,
    List products,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: const Color(0xFF2E2E2E),
        ),
        dataTextStyle: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2E2E2E),
        ),
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Category')),
          DataColumn(label: Text('Price')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: products.map((p) {
          return DataRow(
            cells: [
              DataCell(Text(p.name)),
              DataCell(Text(p.category)),
              DataCell(Text('₹${p.price.toStringAsFixed(0)}')),
              DataCell(
                Switch.adaptive(
                  value: p.isActive,
                  onChanged: (v) => productController.setProductStatus(p.id, v),
                ),
              ),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      onPressed: () => onEdit(p),
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      onPressed: () => productController.deleteProduct(p.id),
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCardLayout(
    BuildContext context,
    List products,
    ThemeData theme,
  ) {
    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.restaurant_menu_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No products yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];
        return ResponsiveCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey[900],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p.category,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '₹${p.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Switch.adaptive(
                          value: p.isActive,
                          onChanged: (v) =>
                              productController.setProductStatus(p.id, v),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          p.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: p.isActive
                                ? const Color(0xFF16A34A)
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  MobileActionRow(
                    actions: [
                      IconButton(
                        onPressed: () => onEdit(p),
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit',
                        color: const Color(0xFF2563EB),
                      ),
                      IconButton(
                        onPressed: () => productController.deleteProduct(p.id),
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Delete',
                        color: const Color(0xFFEF4444),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
