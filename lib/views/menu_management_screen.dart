import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/category_controller.dart';
import '../controllers/product_controller.dart';
import '../models/menu_item.dart';
import '../widgets/add_product_dialog.dart';
import '../widgets/category_management.dart';
import '../widgets/product_table.dart';

class MenuManagementScreen extends StatelessWidget {
  const MenuManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ProductController>();
    final categoryController = Get.find<CategoryController>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Product / Menu Management'),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 1,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7ED957),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Get.dialog(
                    AddProductDialog(
                      productController: productController,
                      categoryController: categoryController,
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('+ Add Product'),
              ),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Products'),
              Tab(text: 'Category Management'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E5E5)),
                ),
                child: ProductTable(
                  productController: productController,
                  onEdit: (MenuItem item) {
                    Get.dialog(
                      AddProductDialog(
                        productController: productController,
                        categoryController: categoryController,
                        existing: item,
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: CategoryManagement(categoryController: categoryController),
            ),
          ],
        ),
      ),
    );
  }
}
