import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../controllers/menu_controller.dart' as app;
import '../models/menu_item.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddMenuItemDialog extends StatefulWidget {
  final app.MenuController menuController;
  final MenuItem? existing;

  AddMenuItemDialog({super.key, required this.menuController, this.existing});

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
  File? pickedImage;
  String? pickedImageUrl;
  final ImagePicker picker = ImagePicker();

  late String selectedCategory;
  late double gst;
  late bool isVeg;

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

    selectedCategory =
        e?.category ??
        (widget.menuController.categories.length > 1
            ? widget.menuController.categories[1]
            : '');

    gst = e?.gstPercent ?? 5;
    isVeg = e?.isVeg ?? true;
  }

  void _save() {
    final name = nameController.text.trim();
    final price = double.tryParse(priceController.text.trim()) ?? -1;

    if (name.isEmpty || selectedCategory.isEmpty || price <= 0) {
      Get.snackbar("Invalid", "Enter valid item details");

      return;
    }

    if (widget.existing == null) {
      widget.menuController.addItem(
        name: name,
        category: selectedCategory,
        price: price,
        gstPercent: gst,
        isVeg: isVeg,
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

      setState(() {
        if (kIsWeb) {
          pickedImageUrl = image.path;
        } else {
          pickedImage = File(image.path);
        }
      });
    } catch (e) {
      Get.snackbar(
        "Image Error",
        "Unable to pick image",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  InputDecoration fieldStyle(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5F7F3),

      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

      /// NORMAL BORDER
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFD1D5DB), // normal grey
          width: 1,
        ),
      ),

      /// DEFAULT BORDER
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),

      /// WHEN CLICKED
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF7ED957), width: 1.4),
      ),
    );
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
              "Add New Menu Item",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 26),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// LEFT SIDE IMAGE
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
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFC7C9C0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child:
                                (pickedImage != null || pickedImageUrl != null)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: kIsWeb
                                        ? Image.network(
                                            pickedImageUrl!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return const Center(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.error_outline,
                                                          size: 32,
                                                        ),
                                                        SizedBox(height: 8),
                                                        Text(
                                                          "Failed to load image",
                                                          style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                          )
                                        : Image.file(
                                            pickedImage!,
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
                                          "Tap to upload image",
                                          style: TextStyle(
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: 240,
                      height: 44,
                      child: TextField(
                        controller: imageUrlController,
                        decoration: fieldStyle("Image URL"),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 26),

                /// RIGHT SIDE FORM
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 44,
                          child: TextField(
                            controller: nameController,
                            decoration: fieldStyle("Item Name"),
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
                                  decoration: fieldStyle("Price"),
                                ),
                              ),
                            ),

                            const SizedBox(width: 18),

                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedCategory,
                                decoration: fieldStyle("Category"),
                                items: widget.menuController.categories
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(c),
                                      ),
                                    )
                                    .toList(),

                                onChanged: (v) {
                                  setState(() {
                                    selectedCategory = v!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 26),

                        /// VEG TOGGLE
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Text(
                                isVeg ? "Veg" : "Non Veg",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isVeg
                                      ? const Color(0xFF22C55E)
                                      : Colors.red,
                                ),
                              ),

                              const Spacer(),

                              Switch(
                                value: isVeg,
                                activeColor: const Color(0xFF7ED957),
                                onChanged: (v) {
                                  setState(() {
                                    isVeg = v;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
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
              decoration: fieldStyle("Description"),
            ),
            const SizedBox(height: 20),

            // GST, Discount, Prep Minutes
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: prepController,
                    decoration: fieldStyle("Prep Minutes"),
                  ),
                ),

                const SizedBox(width: 18),

                Expanded(
                  child: TextField(
                    controller: discountController,
                    decoration: fieldStyle("Discount %"),
                  ),
                ),

                const SizedBox(width: 18),

                Expanded(
                  child: DropdownButtonFormField<double>(
                    value: gst,
                    decoration: fieldStyle("GST %"),
                    items: gstOptions
                        .map(
                          (g) => DropdownMenuItem(value: g, child: Text("$g%")),
                        )
                        .toList(),

                    onChanged: (v) {
                      setState(() {
                        gst = v!;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),

            /// BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                ),

                const SizedBox(width: 14),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7ED957),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _save,
                  child: const Text("Save Item"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
