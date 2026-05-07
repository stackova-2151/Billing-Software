import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/stock_controller.dart';
import '../controllers/menu_controller.dart' as pos;
import '../models/menu_item.dart';

class StockManagementScreen extends StatelessWidget {
  const StockManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StockController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('Stock Management', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () => _showAddStockDialog(context, controller),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Stock', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('No items found', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.inventory_2, color: Color(0xFF16A34A), size: 24),
                      const SizedBox(width: 12),
                      const Text(
                        'Stock Inventory',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      _buildLegend(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildDataTable(controller),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _buildLegendItem('In Stock', const Color(0xFF16A34A)),
        const SizedBox(width: 16),
        _buildLegendItem('Low Stock', const Color(0xFFF59E0B)),
        const SizedBox(width: 16),
        _buildLegendItem('Out of Stock', const Color(0xFFEF4444)),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildDataTable(StockController controller) {
    return Obx(() {
      return SizedBox(
        width: double.infinity,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
          headingRowHeight: 56,
          dataRowMinHeight: 60,
          dataRowMaxHeight: 60,
          columnSpacing: 24,
          horizontalMargin: 8,
        columns: const [
          DataColumn(label: Text('Item Code', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13))),
          DataColumn(label: Text('Item Name', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13))),
          DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13))),
          DataColumn(label: Text('Stock Qty', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)), numeric: true),
          DataColumn(label: Text('Threshold', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)), numeric: true),
          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13))),
          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13))),
        ],
        rows: controller.items.map((item) => _buildDataRow(item, controller)).toList(),
        ),
      );
    });
  }

  DataRow _buildDataRow(MenuItem item, StockController controller) {
    final status = item.stockStatus;
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);

    return DataRow(
      cells: [
        DataCell(Text(item.itemCode, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        DataCell(
          Row(
            children: [
              if (item.isVeg)
                Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Center(
                    child: Icon(Icons.circle, color: Colors.green, size: 8),
                  ),
                )
              else
                Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Center(
                    child: Icon(Icons.circle, color: Colors.red, size: 8),
                  ),
                ),
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        DataCell(Text(item.category, style: const TextStyle(fontSize: 13))),
        DataCell(
          Text(
            '${item.stockQuantity}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: statusColor,
            ),
          ),
        ),
        DataCell(Text('${item.lowStockThreshold}', style: const TextStyle(fontSize: 13))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Color(0xFF16A34A), size: 20),
                tooltip: 'Add Stock',
                onPressed: () => _showQuickAddDialog(item, controller),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Color(0xFF2563EB), size: 20),
                tooltip: 'Edit Stock',
                onPressed: () => _showEditStockDialog(item, controller),
              ),
              IconButton(
                icon: const Icon(Icons.visibility_outlined, color: Color(0xFF64748B), size: 20),
                tooltip: 'View Details',
                onPressed: () => _showViewDialog(item),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'IN_STOCK':
        return const Color(0xFF16A34A);
      case 'LOW_STOCK':
        return const Color(0xFFF59E0B);
      case 'OUT_OF_STOCK':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'IN_STOCK':
        return 'In Stock';
      case 'LOW_STOCK':
        return 'Low Stock';
      case 'OUT_OF_STOCK':
        return 'Out of Stock';
      default:
        return 'Unknown';
    }
  }

  void _showAddStockDialog(BuildContext context, StockController controller) {
    String? selectedItemId;
    final qtyController = TextEditingController();
    final thresholdController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_circle, color: Color(0xFF16A34A), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text('Add Stock', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 24),
              Obx(() {
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Item *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: controller.items.map((item) {
                    return DropdownMenuItem(
                      value: item.id,
                      child: Text('${item.name} (${item.itemCode})'),
                    );
                  }).toList(),
                  onChanged: (value) => selectedItemId = value,
                );
              }),
              const SizedBox(height: 16),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Quantity to Add *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: const Icon(Icons.add),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: thresholdController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Low Stock Threshold (Optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: const Icon(Icons.warning_amber),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () async {
                      if (selectedItemId == null) {
                        Get.snackbar('Error', 'Please select an item', snackPosition: SnackPosition.BOTTOM);
                        return;
                      }
                      
                      final qty = int.tryParse(qtyController.text);
                      if (qty == null || qty <= 0) {
                        Get.snackbar('Error', 'Please enter valid quantity', snackPosition: SnackPosition.BOTTOM);
                        return;
                      }

                      final threshold = thresholdController.text.isEmpty ? null : int.tryParse(thresholdController.text);

                      await controller.updateStock(
                        itemId: selectedItemId!,
                        addedQuantity: qty,
                        lowStockThreshold: threshold,
                      );
                    },
                    child: const Text('Add Stock', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickAddDialog(MenuItem item, StockController controller) {
    final qtyController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_circle, color: Color(0xFF16A34A), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Quick Add Stock', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        Text(item.name, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Quantity to Add *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: const Icon(Icons.add),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () async {
                      final qty = int.tryParse(qtyController.text);
                      if (qty == null || qty <= 0) {
                        Get.snackbar('Error', 'Please enter valid quantity', snackPosition: SnackPosition.BOTTOM);
                        return;
                      }

                      await controller.updateStock(
                        itemId: item.id,
                        addedQuantity: qty,
                      );
                    },
                    child: const Text('Add', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditStockDialog(MenuItem item, StockController controller) {
    final itemCodeController = TextEditingController(text: item.itemCode);
    final itemNameController = TextEditingController(text: item.name);
    final qtyController = TextEditingController(text: item.stockQuantity.toString());
    final thresholdController = TextEditingController(text: item.lowStockThreshold.toString());
    
    // Get categories
    final categoryController = Get.find<pos.MenuController>();
    
    // Get available categories (exclude 'All')
    final availableCategories = categoryController.categories
        .where((cat) => cat != 'All')
        .toList();
    
    // Validate and set selected category
    String selectedCategory = item.category;
    if (!availableCategories.contains(selectedCategory)) {
      // If current category doesn't exist, use first available or empty
      selectedCategory = availableCategories.isNotEmpty ? availableCategories.first : '';
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 550,
          padding: const EdgeInsets.all(24),
          child: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.edit, color: Color(0xFF2563EB), size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Edit Stock Item',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: itemCodeController,
                      decoration: InputDecoration(
                        labelText: 'Item Code *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.grey[50],
                        prefixIcon: const Icon(Icons.qr_code),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: itemNameController,
                      decoration: InputDecoration(
                        labelText: 'Item Name *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.grey[50],
                        prefixIcon: const Icon(Icons.restaurant_menu),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (availableCategories.isNotEmpty)
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Colors.grey[50],
                          prefixIcon: const Icon(Icons.category),
                        ),
                        items: availableCategories.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedCategory = value);
                          }
                        },
                      )
                    else
                      TextField(
                        controller: TextEditingController(text: selectedCategory),
                        decoration: InputDecoration(
                          labelText: 'Category *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Colors.grey[50],
                          prefixIcon: const Icon(Icons.category),
                          helperText: 'No categories available. Please add categories first.',
                          helperStyle: const TextStyle(color: Colors.orange),
                        ),
                        onChanged: (value) => selectedCategory = value,
                      ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: qtyController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Stock Quantity *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.grey[50],
                        prefixIcon: const Icon(Icons.inventory),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: thresholdController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Low Stock Threshold *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.grey[50],
                        prefixIcon: const Icon(Icons.warning_amber),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          onPressed: () async {
                            final itemCode = itemCodeController.text.trim();
                            final itemName = itemNameController.text.trim();
                            final qty = int.tryParse(qtyController.text);
                            final threshold = int.tryParse(thresholdController.text);

                            if (itemCode.isEmpty) {
                              Get.snackbar('Error', 'Please enter item code', snackPosition: SnackPosition.BOTTOM);
                              return;
                            }

                            if (itemName.isEmpty) {
                              Get.snackbar('Error', 'Please enter item name', snackPosition: SnackPosition.BOTTOM);
                              return;
                            }

                            if (selectedCategory.isEmpty) {
                              Get.snackbar('Error', 'Please select or enter a category', snackPosition: SnackPosition.BOTTOM);
                              return;
                            }

                            if (qty == null || qty < 0) {
                              Get.snackbar('Error', 'Please enter valid stock quantity', snackPosition: SnackPosition.BOTTOM);
                              return;
                            }

                            if (threshold == null || threshold < 0) {
                              Get.snackbar('Error', 'Please enter valid threshold', snackPosition: SnackPosition.BOTTOM);
                              return;
                            }

                            await controller.updateStockItem(
                              itemId: item.id,
                              itemCode: itemCode,
                              itemName: itemName,
                              category: selectedCategory,
                              stockQuantity: qty,
                              lowStockThreshold: threshold,
                            );
                          },
                          child: const Text('Update Item', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showViewDialog(MenuItem item) {
    final status = item.stockStatus;
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF64748B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.info_outline, color: Color(0xFF64748B), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text('Stock Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Item Code', item.itemCode),
              _buildDetailRow('Item Name', item.name),
              _buildDetailRow('Category', item.category),
              _buildDetailRow('Price', '₹${item.price.toStringAsFixed(2)}'),
              _buildDetailRow('Stock Quantity', '${item.stockQuantity}'),
              _buildDetailRow('Low Stock Threshold', '${item.lowStockThreshold}'),
              _buildDetailRow('Type', item.isVeg ? 'Vegetarian' : 'Non-Vegetarian'),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Status: ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF64748B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
