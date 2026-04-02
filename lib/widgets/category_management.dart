import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/category_controller.dart';

class CategoryManagement extends StatefulWidget {
  final CategoryController categoryController;

  const CategoryManagement({super.key, required this.categoryController});

  @override
  State<CategoryManagement> createState() => _CategoryManagementState();
}

class _CategoryManagementState extends State<CategoryManagement> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController orderController = TextEditingController();

  final RxBool active = true.obs;
  final RxnInt editingId = RxnInt();

  @override
  void dispose() {
    nameController.dispose();
    orderController.dispose();
    super.dispose();
  }

  void _reset() {
    editingId.value = null;
    nameController.text = '';
    orderController.text = '';
    active.value = true;
  }

  void _save() {
    final name = nameController.text.trim();
    final order = int.tryParse(orderController.text.trim()) ?? -1;

    if (name.isEmpty || order <= 0) {
      Get.snackbar('Invalid', 'Enter valid category details');
      return;
    }

    if (editingId.value == null) {
      widget.categoryController.addCategory(
        name: name,
        displayOrder: order,
        isActive: active.value,
      );
    } else {
      widget.categoryController.editCategory(
        id: editingId.value!,
        name: name,
        displayOrder: order,
        isActive: active.value,
      );
    }

    _reset();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E5E5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Obx(() => Text(
                    editingId.value == null ? 'Add Category' : 'Edit Category',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  )),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Category Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: orderController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Display Order'),
              ),
              const SizedBox(height: 12),
              Obx(() => SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Active'),
                    value: active.value,
                    onChanged: (v) => active.value = v,
                  )),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton(onPressed: _reset, child: const Text('Cancel')),
                  const Spacer(),
                  Obx(() => ElevatedButton(
                        onPressed: _save,
                        child: Text(
                            editingId.value == null ? 'Add' : 'Save'),
                      )),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Obx(() {
            final list = widget.categoryController.categories;
            return ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final c = list[index];
                return Obx(() => Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E5E5)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              c.name.value,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 110,
                            child: Text(
                              'Order: ${c.displayOrder.value}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Switch.adaptive(
                            value: c.isActive.value,
                            onChanged: (v) {
                              widget.categoryController.editCategory(
                                id: c.id,
                                name: c.name.value,
                                displayOrder: c.displayOrder.value,
                                isActive: v,
                              );
                            },
                          ),
                          IconButton(
                            onPressed: () {
                              editingId.value = c.id;
                              nameController.text = c.name.value;
                              orderController.text =
                                  c.displayOrder.value.toString();
                              active.value = c.isActive.value;
                            },
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            onPressed: () => widget.categoryController
                                .deleteCategory(c.id),
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                    ));
              },
            );
          }),
        ),
      ],
    );
  }
}
