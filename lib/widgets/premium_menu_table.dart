import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/menu_controller.dart' as app;
import '../models/menu_item.dart';
import 'add_menu_item_dialog.dart';

class PremiumMenuTable extends StatefulWidget {
  final app.MenuController menuController;

  const PremiumMenuTable({super.key, required this.menuController});

  @override
  State<PremiumMenuTable> createState() => _PremiumMenuTableState();
}

class _PremiumMenuTableState extends State<PremiumMenuTable> {
  int _currentPage = 0;
  final int _itemsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = widget.menuController.managementItems;
      final totalPages = (items.length / _itemsPerPage).ceil();
      final startIndex = _currentPage * _itemsPerPage;
      final endIndex = (startIndex + _itemsPerPage).clamp(0, items.length);
      final paginatedItems = items.sublist(startIndex, endIndex);

      return LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final isTablet = constraints.maxWidth < 1024;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: isMobile
                        ? constraints.maxWidth
                        : constraints.maxWidth,
                    child: ListView(
                      children: [
                        _TableHeader(isMobile: isMobile, isTablet: isTablet),
                        const SizedBox(height: 12),
                        ...paginatedItems.map(
                          (item) => _TableRowCard(
                            item: item,
                            menuController: widget.menuController,
                            isMobile: isMobile,
                            isTablet: isTablet,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (totalPages > 1) _buildPagination(totalPages),
            ],
          );
        },
      );
    });
  }

  Widget _buildPagination(int totalPages) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate how many page buttons can fit
          final availableWidth =
              constraints.maxWidth - 120; // Reserve space for nav buttons
          final maxVisiblePages = (availableWidth / 44).floor().clamp(
            1,
            totalPages,
          );

          // Calculate page range to show
          int startPage = (_currentPage - maxVisiblePages ~/ 2).clamp(
            0,
            totalPages - maxVisiblePages,
          );
          int endPage = (startPage + maxVisiblePages).clamp(
            maxVisiblePages,
            totalPages,
          );
          startPage = endPage - maxVisiblePages;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _currentPage > 0
                      ? () => setState(() => _currentPage--)
                      : null,
                  icon: const Icon(Icons.chevron_left),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFF5F6FA),
                    disabledBackgroundColor: const Color(0xFFE5E5E5),
                  ),
                ),
                const SizedBox(width: 8),
                if (startPage > 0) ...[
                  _buildPageButton(0),
                  if (startPage > 1)
                    const Text(
                      '...',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                ],
                ...List.generate(endPage - startPage, (index) {
                  final pageIndex = startPage + index;
                  return _buildPageButton(pageIndex);
                }),
                if (endPage < totalPages) ...[
                  if (endPage < totalPages - 1)
                    const Text(
                      '...',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  _buildPageButton(totalPages - 1),
                ],
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _currentPage < totalPages - 1
                      ? () => setState(() => _currentPage++)
                      : null,
                  icon: const Icon(Icons.chevron_right),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFF5F6FA),
                    disabledBackgroundColor: const Color(0xFFE5E5E5),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageButton(int pageIndex) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: () => setState(() => _currentPage = pageIndex),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _currentPage == pageIndex
                ? const Color(0xFF7ED957)
                : const Color(0xFFF5F6FA),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${pageIndex + 1}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _currentPage == pageIndex
                    ? Colors.white
                    : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;

  const _TableHeader({required this.isMobile, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 18,
        vertical: isMobile ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(isMobile ? 10 : 14),
      ),
      child: Row(
        children: [
          SizedBox(
            width: isMobile ? 40 : 64,
            child: Text(
              'Image',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 12 : 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: isMobile ? 30 : 20),
          Expanded(
            child: Text(
              'Item Info',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 12 : 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!isMobile) ...[
            const SizedBox(width: 20),
            SizedBox(
              width: 120,
              child: Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          SizedBox(width: isMobile ? 8 : 20),
          SizedBox(
            width: isMobile ? 70 : 80,
            child: Text(
              'Price',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 12 : 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!isMobile) ...[
            const SizedBox(width: 24),
            SizedBox(
              width: 100,
              child: Text(
                'Status',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          if (!isMobile) const Spacer(),
          SizedBox(
            width: isMobile ? 70 : 140,
            child: Text(
              'Actions',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 12 : 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _TableRowCard extends StatefulWidget {
  final MenuItem item;
  final app.MenuController menuController;
  final bool isMobile;
  final bool isTablet;

  const _TableRowCard({
    required this.item,
    required this.menuController,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  State<_TableRowCard> createState() => _TableRowCardState();
}

class _TableRowCardState extends State<_TableRowCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: widget.isMobile ? 6 : 10),
        padding: EdgeInsets.symmetric(
          horizontal: widget.isMobile ? 12 : 18,
          vertical: widget.isMobile ? 10 : 16,
        ),
        decoration: BoxDecoration(
          color: _isHovered ? const Color(0xFFFAFBFC) : const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(widget.isMobile ? 10 : 14),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            _ItemImage(url: widget.item.image, isMobile: widget.isMobile),
            SizedBox(width: widget.isMobile ? 8 : 20),
            Expanded(
              child: _ItemInfo(
                name: widget.item.name,
                isVeg: widget.item.isVeg,
                category: widget.item.category,
                isMobile: widget.isMobile,
              ),
            ),
            if (!widget.isMobile) ...[
              const SizedBox(width: 20),
              SizedBox(
                width: 120,
                child: _CategoryPill(category: widget.item.category),
              ),
            ],
            SizedBox(width: widget.isMobile ? 8 : 20),
            SizedBox(
              width: widget.isMobile ? 60 : 80,
              child: _PriceText(
                price: widget.item.price,
                isMobile: widget.isMobile,
              ),
            ),
            if (!widget.isMobile) ...[
              const SizedBox(width: 24),
              SizedBox(
                width: 100,
                child: _StatusChip(isAvailable: widget.item.isAvailable),
              ),
            ],
            if (!widget.isMobile) const Spacer(),
            SizedBox(
              width: widget.isMobile ? 96 : 140,
              child: _ActionButtons(
                item: widget.item,
                menuController: widget.menuController,
                isMobile: widget.isMobile,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemImage extends StatelessWidget {
  final String url;
  final bool isMobile;

  const _ItemImage({required this.url, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isMobile ? 40 : 48,
      height: isMobile ? 40 : 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: url.trim().isEmpty
            ? Container(
                color: const Color(0xFFE5E7EB),
                child: Icon(
                  Icons.restaurant,
                  size: isMobile ? 20 : 24,
                  color: const Color(0xFF9CA3AF),
                ),
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFE5E7EB),
                  child: Icon(
                    Icons.broken_image,
                    size: isMobile ? 20 : 24,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
      ),
    );
  }
}

class _ItemInfo extends StatelessWidget {
  final String name;
  final bool isVeg;
  final String category;
  final bool isMobile;

  const _ItemInfo({
    required this.name,
    required this.isVeg,
    required this.category,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 14 : 15,
            color: Color(0xFF1F2937),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isVeg
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFEF4444),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isVeg
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isVeg ? 'Veg' : 'Non-Veg',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String category;

  const _CategoryPill({required this.category});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          category,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _PriceText extends StatelessWidget {
  final double price;
  final bool isMobile;

  const _PriceText({required this.price, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Text(
      '₹${price.toStringAsFixed(2)}',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: isMobile ? 13 : 14,
        color: Color(0xFF059669),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isAvailable;

  const _StatusChip({required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isAvailable
              ? const Color(0xFFD1FAE5)
              : const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          isAvailable ? 'In Stock' : 'Out of Stock',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isAvailable
                ? const Color(0xFF065F46)
                : const Color(0xFF991B1B),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final MenuItem item;
  final app.MenuController menuController;
  final bool isMobile;

  const _ActionButtons({
    required this.item,
    required this.menuController,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: 'View Details',
            child: IconButton(
              onPressed: () => _showViewDialog(context),
              icon: Icon(Icons.visibility_outlined, size: isMobile ? 16 : 20),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: isMobile
                  ? const BoxConstraints(minWidth: 28, minHeight: 28)
                  : const BoxConstraints(minWidth: 36, minHeight: 36),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFDCEEFB),
                foregroundColor: const Color(0xFF2563EB),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          SizedBox(width: isMobile ? 4 : 8),
          Tooltip(
            message: 'Edit Item',
            child: IconButton(
              onPressed: () => _editItem(context),
              icon: Icon(Icons.edit_outlined, size: isMobile ? 16 : 20),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: isMobile
                  ? const BoxConstraints(minWidth: 28, minHeight: 28)
                  : const BoxConstraints(minWidth: 36, minHeight: 36),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFD1FAE5),
                foregroundColor: const Color(0xFF059669),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          SizedBox(width: isMobile ? 4 : 8),
          Tooltip(
            message: 'Delete Item',
            child: IconButton(
              onPressed: () => _deleteItem(context),
              icon: Icon(Icons.delete_outline, size: isMobile ? 16 : 20),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: isMobile
                  ? const BoxConstraints(minWidth: 28, minHeight: 28)
                  : const BoxConstraints(minWidth: 36, minHeight: 36),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFFEE2E2),
                foregroundColor: const Color(0xFFDC2626),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showViewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
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
                  const Text(
                    'Item Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(height: 24),
              if (item.image.isNotEmpty)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item.image,
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 150,
                        width: 150,
                        color: const Color.fromARGB(255, 12, 38, 91),
                        child: const Icon(Icons.broken_image, size: 48),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              _DetailRow('Name', item.name),
              _DetailRow('Category', item.category),
              _DetailRow('Price', '₹${item.price.toStringAsFixed(2)}'),
              _DetailRow('Type', item.isVeg ? 'Vegetarian' : 'Non-Vegetarian'),
              _DetailRow(
                'Status',
                item.isAvailable ? 'In Stock' : 'Out of Stock',
              ),
              _DetailRow('GST', '${item.gstPercent}%'),
              if (item.description.isNotEmpty)
                _DetailRow('Description', item.description),
            ],
          ),
        ),
      ),
    );
  }

  Widget _DetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editItem(BuildContext context) {
    Get.dialog(
      AddMenuItemDialog(menuController: menuController, existing: item),
    );
  }

  void _deleteItem(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              menuController.deleteItem(item.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
