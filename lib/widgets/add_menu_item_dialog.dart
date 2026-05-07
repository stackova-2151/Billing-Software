import 'dart:io';
import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../controllers/menu_controller.dart' as app;
import '../controllers/category_controller.dart';
import '../models/menu_item.dart';
import '../services/r2_upload_service.dart';
import 'category_dropdown_with_add.dart';

// ─────────────────────────────────────────────
//  Design tokens
// ─────────────────────────────────────────────
class _T {
  // Brand greens
  static const g400 = Color(0xFF4ADE80);
  static const g500 = Color(0xFF22C55E);
  static const g600 = Color(0xFF16A34A);

  // Neutrals
  static const bg = Color(0xFFF0F4F8);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFE2E8F0);
  static const label = Color(0xFF475569);
  static const hint = Color(0xFFADB5BD);
  static const title = Color(0xFF0F172A);
  static const subtitle = Color(0xFF64748B);

  // Accent red
  static const red = Color(0xFFEF4444);
  static const redLight = Color(0xFFFEE2E2);

  // Gradient header
  static const headerTop = Color(0xFF0F172A);
  static const headerBot = Color(0xFF1E3A5F);

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
        color: Colors.black.withValues(alpha: 0.10),
        blurRadius: 40,
        spreadRadius: 0,
        offset: const Offset(0, 16)),
    BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 12,
        spreadRadius: 0,
        offset: const Offset(0, 4)),
  ];

  static List<BoxShadow> fieldShadow = [
    BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 8,
        offset: const Offset(0, 2)),
  ];

  static List<BoxShadow> btnShadow = [
    BoxShadow(
        color: g500.withValues(alpha: 0.35),
        blurRadius: 16,
        offset: const Offset(0, 6)),
  ];
}

// ─────────────────────────────────────────────
//  Reusable Section Card
// ─────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _T.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_T.g400, _T.g600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, size: 14, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _T.label,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Divider(color: _T.border, height: 1, indent: 20, endIndent: 20),
          Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Reusable Premium Field
// ─────────────────────────────────────────────
class _PremiumField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType keyboardType;
  final int maxLines;
  final Widget? prefix;

  const _PremiumField({
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.prefix,
  });

  @override
  State<_PremiumField> createState() => _PremiumFieldState();
}

class _PremiumFieldState extends State<_PremiumField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _focused ? _T.g500 : _T.border,
            width: _focused ? 1.8 : 1,
          ),
          boxShadow: _focused
              ? [
                  BoxShadow(
                    color: _T.g500.withValues(alpha: 0.15),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                  ..._T.fieldShadow,
                ]
              : _T.fieldShadow,
        ),
        child: TextField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          style: const TextStyle(
            fontSize: 14.5,
            color: _T.title,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            hintStyle: const TextStyle(color: _T.hint, fontSize: 13.5),
            labelStyle: TextStyle(
              color: _focused ? _T.g600 : _T.subtitle,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: widget.prefix,
            filled: false,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: widget.maxLines > 1 ? 14 : 0,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Reusable Premium Dropdown
// ─────────────────────────────────────────────
class _PremiumDropdown<T> extends StatelessWidget {
  final T value;
  final String label;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;

  const _PremiumDropdown({
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _T.border),
        boxShadow: _T.fieldShadow,
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: _T.subtitle,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
          filled: false,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        icon: const Icon(Icons.keyboard_arrow_down_rounded,
            color: _T.subtitle, size: 20),
        style: const TextStyle(
            fontSize: 14.5, color: _T.title, fontWeight: FontWeight.w500),
        dropdownColor: _T.surface,
        borderRadius: BorderRadius.circular(14),
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Main Dialog
// ─────────────────────────────────────────────
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

class _AddMenuItemDialogState extends State<AddMenuItemDialog>
    with SingleTickerProviderStateMixin {
  late final TextEditingController imageUrlController;
  late final TextEditingController nameController;
  late final TextEditingController priceController;
  late final TextEditingController descController;
  late final TextEditingController prepController;
  late final TextEditingController discountController;

  final ImagePicker _picker = ImagePicker();

  late final RxString selectedCategory;
  late final RxDouble gst;
  late final RxBool isVeg;
  final RxList<XFile> pickedImages = <XFile>[].obs;
  final RxBool isUploading = false.obs;

  static const List<double> _gstOptions = [0, 5, 12, 18];

  static final Uri _uploadEndpoint = Uri.parse(
    'https://billing-software-r2-upload.billing-software.workers.dev/upload-to-r2',
  );

  final R2UploadService _uploadService =
      R2UploadService(endpoint: _uploadEndpoint);

  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;

    imageUrlController = TextEditingController(text: e?.image ?? '');
    nameController = TextEditingController(text: e?.name ?? '');
    priceController =
        TextEditingController(text: e == null ? '' : e.price.toStringAsFixed(0));
    descController = TextEditingController(text: e?.description ?? '');
    prepController =
        TextEditingController(text: e == null ? '' : e.prepMinutes.toString());
    discountController = TextEditingController(
        text: e == null ? '' : e.discountPercent.toString());

    selectedCategory = (e?.category ??
            (widget.menuController.categories.length > 1
                ? widget.menuController.categories[1]
                : ''))
        .obs;
    gst = (e?.gstPercent ?? 5.0).obs;
    isVeg = (e?.isVeg ?? true).obs;

    // Entry animation
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _scaleAnim = CurvedAnimation(
        parent: _animCtrl,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn)
      ..drive(Tween(begin: 0.88, end: 1.0));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    imageUrlController.dispose();
    nameController.dispose();
    priceController.dispose();
    descController.dispose();
    prepController.dispose();
    discountController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = nameController.text.trim();
    final price = double.tryParse(priceController.text.trim()) ?? -1;

    if (name.isEmpty || selectedCategory.value.isEmpty || price <= 0) {
      Get.snackbar(
        'Invalid Input',
        'Please enter a valid name, category and price.',
        backgroundColor: _T.red.withValues(alpha: 0.9),
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    if (isUploading.value) return;

    var imageUrl = imageUrlController.text.trim();
    List<String> uploadedUrls = <String>[];

    try {
      if (pickedImages.isNotEmpty) {
        isUploading.value = true;
        final List<http.MultipartFile> files = [];
        for (final file in pickedImages) {
          final ext = (file.name.split('.').lastOrNull ?? '').toLowerCase();
          final mime = {'png': 'png', 'webp': 'webp', 'gif': 'gif'}[ext] ?? 'jpeg';
          if (kIsWeb) {
            final Uint8List bytes = await file.readAsBytes();
            files.add(http.MultipartFile.fromBytes('images', bytes,
                filename: file.name,
                contentType: MediaType('image', mime)));
          } else {
            files.add(await http.MultipartFile.fromPath('images', file.path,
                filename: file.name,
                contentType: MediaType('image', mime)));
          }
        }
        uploadedUrls = await _uploadService.uploadImages(
            propertyName: name, images: files);
        if (uploadedUrls.isNotEmpty) {
          imageUrl = uploadedUrls.first;
          imageUrlController.text = imageUrl;
        }
      }

      final args = (
        name: name,
        category: selectedCategory.value,
        price: price,
        gstPercent: gst.value,
        isVeg: isVeg.value,
        imageUrl: imageUrl,
        images: uploadedUrls,
        description: descController.text.trim(),
        prepMinutes: int.tryParse(prepController.text) ?? 0,
        discountPercent: double.tryParse(discountController.text) ?? 0,
      );

      if (widget.existing == null) {
        widget.menuController.addItem(
          name: args.name,
          category: args.category,
          price: args.price,
          gstPercent: args.gstPercent,
          isVeg: args.isVeg,
          imageUrl: args.imageUrl,
          images: args.images,
          description: args.description,
          prepMinutes: args.prepMinutes,
          discountPercent: args.discountPercent,
        );
      } else {
        widget.menuController.updateItem(
          id: widget.existing!.id,
          name: args.name,
          category: args.category,
          price: args.price,
          gstPercent: args.gstPercent,
          isVeg: args.isVeg,
          imageUrl: args.imageUrl,
          images: args.images.isEmpty ? widget.existing!.images : args.images,
          description: args.description,
          prepMinutes: args.prepMinutes,
          discountPercent: args.discountPercent,
        );
      }
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Upload Failed',
        e.toString(),
        backgroundColor: _T.red.withValues(alpha: 0.9),
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images =
          await _picker.pickMultiImage(imageQuality: 85);
      if (images.isEmpty) return;
      pickedImages.assignAll(images);
    } catch (_) {
      Get.snackbar('Image Error', 'Unable to pick image');
    }
  }

  // ── Build ──────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isDesktop = sw > 900;
    final isTablet = sw > 600 && sw <= 900;

    final double maxW = isDesktop ? 960 : (isTablet ? 640 : double.infinity);
    final double maxH = isDesktop ? 740 : 680;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : (isTablet ? 24 : 16),
        vertical: 32,
      ),
      child: FadeTransition(
        opacity: _fadeAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Container(
            constraints: BoxConstraints(maxWidth: maxW, maxHeight: maxH),
            decoration: BoxDecoration(
              color: _T.bg,
              borderRadius: BorderRadius.circular(24),
              boxShadow: _T.cardShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isDesktop ? 28 : 20),
                      child: isDesktop
                          ? _buildDesktopBody()
                          : _buildMobileBody(),
                    ),
                  ),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────
  Widget _buildHeader() {
    final isEdit = widget.existing != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 24, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_T.headerTop, _T.headerBot],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2), width: 1),
            ),
            child: Icon(
              isEdit ? Icons.edit_rounded : Icons.add_rounded,
              color: _T.g400,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? 'Edit Menu Item' : 'Add New Menu Item',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isEdit
                      ? 'Update the details for this item'
                      : 'Fill in the details to add a new item to your menu',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.55),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          _CloseButton(onTap: () => Get.back()),
        ],
      ),
    );
  }

  // ── Footer ────────────────────────────────
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 20),
      decoration: BoxDecoration(
        color: _T.surface,
        border: const Border(top: BorderSide(color: _T.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _CancelButton(onTap: () => Get.back()),
          const SizedBox(width: 12),
          Obx(() => _SaveButton(
                isLoading: isUploading.value,
                onTap: isUploading.value ? null : _save,
              )),
        ],
      ),
    );
  }

  // ── Layouts ───────────────────────────────
  Widget _buildDesktopBody() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 300, child: _buildImageSection()),
        const SizedBox(width: 24),
        Expanded(child: _buildFormSection()),
      ],
    );
  }

  Widget _buildMobileBody() {
    return Column(
      children: [
        _buildImageSection(),
        const SizedBox(height: 20),
        _buildFormSection(),
      ],
    );
  }

  // ── Image Upload Section ──────────────────
  Widget _buildImageSection() {
    return _SectionCard(
      title: 'ITEM PHOTO',
      icon: Icons.image_rounded,
      child: Column(
        children: [
          // Drop zone
          InkWell(
            onTap: _pickImages,
            borderRadius: BorderRadius.circular(16),
            child: Obx(() {
              final hasPick = pickedImages.isNotEmpty;
              final hasUrl = imageUrlController.text.trim().isNotEmpty;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: hasPick || hasUrl
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  color: hasPick || hasUrl ? Colors.transparent : null,
                ),
                child: hasPick
                    ? _ImagePreviewWidget(
                        file: pickedImages.first,
                        onEdit: _pickImages,
                      )
                    : hasUrl
                        ? _UrlImageWidget(
                            url: imageUrlController.text.trim(),
                            onEdit: _pickImages,
                          )
                        : _UploadPlaceholder(onTap: _pickImages),
              );
            }),
          ),

          // Thumbnail strip
          Obx(() {
            if (pickedImages.length <= 1) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: pickedImages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final x = pickedImages[i];
                    return Container(
                      width: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: i == 0 ? _T.g500 : _T.border, width: 2),
                        boxShadow: _T.fieldShadow,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: kIsWeb
                            ? Image.network(x.path, fit: BoxFit.cover)
                            : Image.file(File(x.path), fit: BoxFit.cover),
                      ),
                    );
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Form Section ─────────────────────────
  Widget _buildFormSection() {
    return Column(
      children: [
        // Basic info
        _SectionCard(
          title: 'BASIC INFO',
          icon: Icons.info_outline_rounded,
          child: Column(
            children: [
              _PremiumField(
                controller: nameController,
                label: 'Item Name',
                hint: 'e.g. Margherita Pizza',
                prefix: const Icon(Icons.restaurant_menu_rounded,
                    size: 18, color: _T.hint),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _PremiumField(
                      controller: priceController,
                      label: 'Price',
                      hint: '0',
                      keyboardType: TextInputType.number,
                      prefix: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        child: Text('₹',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _T.subtitle)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Obx(() {
                      final categoryController = Get.find<CategoryController>();
                      return CategoryDropdownWithAdd(
                        value: selectedCategory.value,
                        label: 'Category',
                        onChanged: (v) => selectedCategory.value = v,
                        categoryController: categoryController,
                        textStyle: const TextStyle(
                          fontSize: 14.5,
                          color: _T.title,
                          fontWeight: FontWeight.w500,
                        ),
                        labelStyle: const TextStyle(
                          color: _T.subtitle,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                        ),
                        borderColor: _T.border,
                        backgroundColor: _T.surface,
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Veg toggle
              Obx(() => _VegToggle(
                    isVeg: isVeg.value,
                    onChanged: (v) => isVeg.value = v,
                  )),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Description
        _SectionCard(
          title: 'DESCRIPTION',
          icon: Icons.notes_rounded,
          child: _PremiumField(
            controller: descController,
            label: 'Description',
            hint: 'Write a short mouth-watering description…',
            maxLines: 3,
          ),
        ),

        const SizedBox(height: 16),

        // Pricing & meta
        _SectionCard(
          title: 'PRICING & META',
          icon: Icons.tune_rounded,
          child: Row(
            children: [
              Expanded(
                child: _PremiumField(
                  controller: prepController,
                  label: 'Prep Time',
                  hint: 'min',
                  keyboardType: TextInputType.number,
                  prefix: const Icon(Icons.timer_outlined,
                      size: 18, color: _T.hint),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _PremiumField(
                  controller: discountController,
                  label: 'Discount %',
                  hint: '0',
                  keyboardType: TextInputType.number,
                  prefix: const Icon(Icons.local_offer_outlined,
                      size: 18, color: _T.hint),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Obx(
                  () => _PremiumDropdown<double>(
                    value: gst.value,
                    label: 'GST %',
                    items: _gstOptions
                        .map((g) => DropdownMenuItem(
                            value: g, child: Text('$g%')))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) gst.value = v;
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Sub-widgets
// ─────────────────────────────────────────────

class _VegToggle extends StatelessWidget {
  final bool isVeg;
  final void Function(bool) onChanged;

  const _VegToggle({required this.isVeg, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isVeg
            ? const Color(0xFFF0FDF4)
            : const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isVeg
              ? const Color(0xFFBBF7D0)
              : const Color(0xFFFECACA),
          width: 1.2,
        ),
        boxShadow: _T.fieldShadow,
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Container(
              key: ValueKey(isVeg),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isVeg
                    ? const Color(0xFFDCFCE7)
                    : _T.redLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isVeg ? '🌱' : '🍖',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    color: isVeg ? _T.g600 : _T.red,
                  ),
                  child: Text(isVeg ? 'Vegetarian' : 'Non-Vegetarian'),
                ),
                Text(
                  isVeg ? 'No meat or fish' : 'Contains meat or fish',
                  style: TextStyle(
                    fontSize: 12,
                    color: isVeg
                        ? const Color(0xFF4ADE80)
                        : const Color(0xFFF87171),
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: isVeg,
              activeColor: Colors.white,
              activeTrackColor: _T.g500,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFFFCA5A5),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadPlaceholder extends StatefulWidget {
  final VoidCallback onTap;
  const _UploadPlaceholder({required this.onTap});

  @override
  State<_UploadPlaceholder> createState() => _UploadPlaceholderState();
}

class _UploadPlaceholderState extends State<_UploadPlaceholder> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: DottedBorder(
          color: _hovering ? _T.g500 : const Color(0xFFA7F3D0),
          strokeWidth: 2,
          dashPattern: const [8, 5],
          borderType: BorderType.RRect,
          radius: const Radius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: _hovering
                    ? [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)]
                    : [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _hovering
                            ? [_T.g400, _T.g600]
                            : [
                                const Color(0xFFBBF7D0),
                                const Color(0xFF6EE7B7)
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _hovering
                          ? [
                              BoxShadow(
                                color: _T.g500.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              )
                            ]
                          : [],
                    ),
                    child: Icon(
                      Icons.cloud_upload_outlined,
                      size: 36,
                      color: _hovering ? Colors.white : _T.g600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Upload Photo',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _T.title,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Click to browse • PNG, JPG, WEBP',
                    style: TextStyle(
                      fontSize: 12,
                      color: _T.subtitle.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImagePreviewWidget extends StatelessWidget {
  final XFile file;
  final VoidCallback onEdit;

  const _ImagePreviewWidget({required this.file, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          kIsWeb
              ? Image.network(file.path, fit: BoxFit.cover)
              : Image.file(File(file.path), fit: BoxFit.cover),
          // Overlay gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: _EditChip(onTap: onEdit),
          ),
        ],
      ),
    );
  }
}

class _UrlImageWidget extends StatelessWidget {
  final String url;
  final VoidCallback onEdit;

  const _UrlImageWidget({required this.url, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(url, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>_UploadPlaceholder(onTap: null as dynamic)),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.4)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: _EditChip(onTap: onEdit),
          ),
        ],
      ),
    );
  }
}

class _EditChip extends StatelessWidget {
  final VoidCallback onTap;
  const _EditChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_rounded, size: 13, color: _T.title),
            SizedBox(width: 5),
            Text(
              'Change',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _T.title),
            ),
          ],
        ),
      ),
    );
  }
}

class _CloseButton extends StatefulWidget {
  final VoidCallback onTap;
  const _CloseButton({required this.onTap});

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _hover
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.15), width: 1),
          ),
          child: const Icon(Icons.close_rounded, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

class _CancelButton extends StatefulWidget {
  final VoidCallback onTap;
  const _CancelButton({required this.onTap});

  @override
  State<_CancelButton> createState() => _CancelButtonState();
}

class _CancelButtonState extends State<_CancelButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          decoration: BoxDecoration(
            color: _hover ? const Color(0xFFF1F5F9) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: _hover ? _T.border : Colors.transparent, width: 1),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: _T.subtitle,
            ),
          ),
        ),
      ),
    );
  }
}

class _SaveButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback? onTap;

  const _SaveButton({required this.isLoading, this.onTap});

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 13),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _hover
                  ? [const Color(0xFF6EE7B7), _T.g500]
                  : [_T.g400, _T.g600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(13),
            boxShadow: widget.onTap != null
                ? _hover
                    ? [
                        BoxShadow(
                          color: _T.g500.withValues(alpha: 0.45),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ]
                    : _T.btnShadow
                : [],
          ),
          child: widget.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_rounded,
                        size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text(
                      'Save Item',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}