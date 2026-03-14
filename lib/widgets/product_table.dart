import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/product_controller.dart';
import '../models/menu_item.dart';

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
    });
  }
}
