import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/menu_controller.dart' as app;
import '../models/menu_item.dart';

class AddMenuItemDialog extends StatefulWidget {
  final app.MenuController menuController;
  final MenuItem? existing;

  const AddMenuItemDialog({
    super.key,
    required this.menuController,
    this.existing,
  });

  @override
  State<AddMenuItemDialog> createState() => _AddMenuItemDialogState();
}

class _AddMenuItemDialogState extends State<AddMenuItemDialog> {
  late final TextEditingController imageUrlController;
  late final TextEditingController nameController;
  late final TextEditingController priceController;
  late final TextEditingController descController;
  late final TextEditingController prepController;
  late final TextEditingController discountController;

  final ImagePicker picker = ImagePicker();

  late final RxString selectedCategory;
  late final RxDouble gst;
  late final RxBool isVeg;
  final Rx<File?> pickedImage = Rx<File?>(null);
  final RxString pickedImageUrl = ''.obs;

  static const List<double> gstOptions = [0, 5, 12, 18];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;

    imageUrlController = TextEditingController(text: e?.image ?? '');
    nameController = TextEditingController(text: e?.name ?? '');
    priceController = TextEditingController(
      text: e == null ? '' : e.price.toStringAsFixed(0),
    );
    descController = TextEditingController(text: e?.description ?? '');
    prepController = TextEditingController(
      text: e == null ? '' : e.prepMinutes.toString(),
    );
    discountController = TextEditingController(
      text: e == null ? '' : e.discountPercent.toString(),
    );

    selectedCategory = (e?.category ??
            (widget.menuController.categories.length > 1
                ? widget.menuController.categories[1]
                : ''))
        .obs;
    gst = (e?.gstPercent ?? 5.0).obs;
    isVeg = (e?.isVeg ?? true).obs;
  }

  @override
  void dispose() {
    imageUrlController.dispose();
    nameController.dispose();
    priceController.dispose();
    descController.dispose();
    prepController.dispose();
    discountController.dispose();
    super.dispose();
  }

  void _save() {
    final name = nameController.text.trim();
    final price = double.tryParse(priceController.text.trim()) ?? -1;

    if (name.isEmpty || selectedCategory.value.isEmpty || price <= 0) {
      Get.snackbar('Invalid', 'Enter valid item details');
      return;
    }

    if (widget.existing == null) {
      widget.menuController.addItem(
        name: name,
        category: selectedCategory.value,
        price: price,
        gstPercent: gst.value,
        isVeg: isVeg.value,
        imageUrl: imageUrlController.text.trim(),
        description: descController.text.trim(),
        prepMinutes: int.tryParse(prepController.text) ?? 0,
        discountPercent: double.tryParse(discountController.text) ?? 0,
      );
    } else {
      widget.menuController.updateItem(
        id: widget.existing!.id,
        name: name,
        category: selectedCategory.value,
        price: price,
        gstPercent: gst.value,
        isVeg: isVeg.value,
        imageUrl: imageUrlController.text.trim(),
        description: descController.text.trim(),
        prepMinutes: int.tryParse(prepController.text) ?? 0,
        discountPercent: double.tryParse(discountController.text) ?? 0,
      );
    }

    Get.back();
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image == null) return;
      if (kIsWeb) {
        pickedImageUrl.value = image.path;
      } else {
        pickedImage.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar('Image Error', 'Unable to pick image',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  InputDecoration fieldStyle(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5F7F3),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF7ED957), width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 630, maxHeight: 700),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7F3),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Menu Item',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 26),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT — image picker
                Column(
                  children: [
                    InkWell(
                      onTap: pickImage,
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 240,
                        height: 210,
                        child: DottedBorder(
                          color: const Color(0xFFB0B7C3),
                          strokeWidth: 1.5,
                          dashPattern: const [6, 4],
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(12),
                          child: Obx(() {
                            final hasImage = kIsWeb
                                ? pickedImageUrl.value.isNotEmpty
                                : pickedImage.value != null;
                            return Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFC7C9C0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: hasImage
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: kIsWeb
                                          ? Image.network(
                                              pickedImageUrl.value,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                              errorBuilder:
                                                  (_, __, ___) => const Center(
                                                child: Icon(Icons.error_outline,
                                                    size: 32),
                                              ),
                                            )
                                          : Image.file(
                                              pickedImage.value!,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                            ),
                                    )
                                  : const Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.upload_file, size: 32),
                                          SizedBox(height: 8),
                                          Text(
                                            'Tap to upload image',
                                            style: TextStyle(
                                                color: Colors.black54),
                                          ),
                                        ],
                                      ),
                                    ),
                            );
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: 240,
                      height: 44,
                      child: TextField(
                        controller: imageUrlController,
                        decoration: fieldStyle('Image URL'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 26),
                // RIGHT — form fields
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 44,
                          child: TextField(
                            controller: nameController,
                            decoration: fieldStyle('Item Name'),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: TextField(
                                  controller: priceController,
                                  keyboardType: TextInputType.number,
                                  decoration: fieldStyle('Price'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Obx(() => DropdownButtonFormField<String>(
                                    value: selectedCategory.value,
                                    decoration: fieldStyle('Category'),
                                    items: widget.menuController.categories
                                        .map((c) => DropdownMenuItem(
                                            value: c, child: Text(c)))
                                        .toList(),
                                    onChanged: (v) {
                                      if (v != null) selectedCategory.value = v;
                                    },
                                  )),
                            ),
                          ],
                        ),
                        const SizedBox(height: 26),
                        Obx(() => Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    isVeg.value ? 'Veg' : 'Non Veg',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isVeg.value
                                          ? const Color(0xFF22C55E)
                                          : Colors.red,
                                    ),
                                  ),
                                  const Spacer(),
                                  Switch(
                                    value: isVeg.value,
                                    activeColor: const Color(0xFF7ED957),
                                    onChanged: (v) => isVeg.value = v,
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: descController,
              maxLines: 4,
              decoration: fieldStyle('Description'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: prepController,
                    decoration: fieldStyle('Prep Minutes'),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: TextField(
                    controller: discountController,
                    decoration: fieldStyle('Discount %'),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Obx(() => DropdownButtonFormField<double>(
                        value: gst.value,
                        decoration: fieldStyle('GST %'),
                        items: gstOptions
                            .map((g) => DropdownMenuItem(
                                value: g, child: Text('$g%')))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) gst.value = v;
                        },
                      )),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Cancel',
                      style: TextStyle(color: Color(0xFF6B7280))),
                ),
                const SizedBox(width: 14),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7ED957),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _save,
                  child: const Text('Save Item'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
