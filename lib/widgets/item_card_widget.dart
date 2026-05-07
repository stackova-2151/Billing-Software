import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/cart_controller.dart';
import '../utils/responsive_helper.dart';
import '../models/menu_item.dart';

class ItemCardWidget extends StatefulWidget {
  final MenuItem item;
  final CartController cartController;
  final int index;

  const ItemCardWidget({
    super.key,
    required this.item,
    required this.cartController,
    required this.index,
  });

  @override
  State<ItemCardWidget> createState() => _ItemCardWidgetState();
}

class _ItemCardWidgetState extends State<ItemCardWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tapCtrl;
  late final Animation<double> _tapScale;

  // Premium gradient pairs for each card slot
  static const List<List<Color>> _cardGradients = [
    [Color(0xFFEDE9FF), Color(0xFFD6CEFF)],
    [Color(0xFFFFE8E8), Color(0xFFFFD0D0)],
    [Color(0xFFE0EFFF), Color(0xFFC8DFFF)],
    [Color(0xFFE8FFE8), Color(0xFFC8F0C8)],
    [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
    [Color(0xFFFCE4EC), Color(0xFFF8BBD0)],
  ];

  static const Color _primaryAccent = Color(0xFF6C63FF);
  static const Color _textDark = Color(0xFF1E1B3A);
  static const Color _textMid = Color(0xFF6B6880);

  @override
  void initState() {
    super.initState();
    _tapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _tapScale = Tween<double>(
      begin: 1.0,
      end: 0.91,
    ).animate(CurvedAnimation(parent: _tapCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _tapCtrl.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    _tapCtrl.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    _tapCtrl.reverse();
    final qty = widget.cartController.getQty(widget.item.id);
    if (qty <= 0) {
      widget.cartController.addItem(widget.item);
    } else {
      widget.cartController.increaseQty(widget.item.id);
    }
  }

  void _handleTapCancel() {
    _tapCtrl.reverse();
  }

  List<Color> get _gradient =>
      _cardGradients[widget.index % _cardGradients.length];

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Obx(() {
      final qty = widget.cartController.getQty(widget.item.id);

      return GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: ScaleTransition(
          scale: _tapScale,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final imageSize =
                  (constraints.maxWidth * (isMobile ? 0.72 : 0.64)).clamp(
                    112.0,
                    120.0,
                  );
              final topOffset = -(imageSize * 0.38);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // ── Main card ──
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _gradient,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: _gradient.last.withOpacity(0.55),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(
                      isMobile ? 10 : 12,
                      isMobile ? 8 : 10,
                      isMobile ? 10 : 12,
                      isMobile ? 10 : 12,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: imageSize * 0.52),

                        // Item name
                        Text(
                          widget.item.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: isMobile ? 16 : 18,
                            letterSpacing: 0.1,
                            color: _textDark,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Price row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '₹${widget.item.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                color: _textMid,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // Add / added indicator
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          height: 36,
                          decoration: BoxDecoration(
                            color: qty > 0
                                ? _primaryAccent
                                : Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: qty > 0
                                  ? _primaryAccent
                                  : Colors.white.withOpacity(0.0),
                            ),
                          ),
                          child: Center(
                            child: qty > 0
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check_rounded,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Added  ×$qty',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    '+ Add',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: _primaryAccent,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Floating image circle ──
                  Positioned(
                    top: topOffset,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _FloatingImage(
                        item: widget.item,
                        imageSize: imageSize,
                        gradientColor: _gradient.first,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    });
  }
}

// ── Floating circular image with ring ──────────────────────────────────────
class _FloatingImage extends StatelessWidget {
  final MenuItem item;
  final double imageSize;
  final Color gradientColor;

  const _FloatingImage({
    required this.item,
    required this.imageSize,
    required this.gradientColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: imageSize,
      height: imageSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            spreadRadius: 2,
            color: Colors.black12,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: gradientColor.withOpacity(0.14),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        color: Colors.white,
      ),
      child: ClipOval(
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: _buildImageContent(),
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    if (item.image.trim().isEmpty) {
      return Icon(
        Icons.ramen_dining_rounded,
        size: imageSize * 0.46,
        color: const Color(0xFF6C63FF),
      );
    }

    return Image.network(
      item.image,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Center(
          child: SizedBox(
            width: imageSize * 0.3,
            height: imageSize * 0.3,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: const Color(0xFF6C63FF),
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => Icon(
        Icons.broken_image_outlined,
        size: imageSize * 0.42,
        color: const Color(0xFF6C63FF).withOpacity(0.5),
      ),
    );
  }
}
