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

  static const List<List<Color>> _cardGradients = [
    [Color(0xFFEDE9FF), Color(0xFFD6CEFF)],
    [Color(0xFFFFE8E8), Color(0xFFFFD0D0)],
    [Color(0xFFE0EFFF), Color(0xFFC8DFFF)],
    [Color(0xFFE8FFE8), Color(0xFFC8F0C8)],
    [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
    [Color(0xFFFCE4EC), Color(0xFFF8BBD0)],
  ];

  // Vibrant gradients shown when item is in cart
  static const List<List<Color>> _activeGradients = [
    [Color(0xFF6C63FF), Color(0xFF4F46E5)],
    [Color(0xFFEF4444), Color(0xFFDC2626)],
    [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    [Color(0xFF22C55E), Color(0xFF16A34A)],
    [Color(0xFFF59E0B), Color(0xFFD97706)],
    [Color(0xFFEC4899), Color(0xFFDB2777)],
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
    _tapScale = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _tapCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _tapCtrl.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) => _tapCtrl.forward();

  void _handleTapUp(TapUpDetails _) {
    _tapCtrl.reverse();
    final qty = widget.cartController.getQty(widget.item.id);
    if (qty <= 0) {
      widget.cartController.addItem(widget.item);
    } else {
      widget.cartController.increaseQty(widget.item.id);
    }
  }

  void _handleTapCancel() => _tapCtrl.reverse();

  List<Color> get _gradient =>
      _cardGradients[widget.index % _cardGradients.length];

  List<Color> get _activeGradient =>
      _activeGradients[widget.index % _activeGradients.length];

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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: qty > 0 ? _activeGradient : _gradient,
              ),
              borderRadius: BorderRadius.circular(22),
              border: qty > 0
                  ? Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 1.5,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: qty > 0
                      ? _activeGradient.last.withValues(alpha: 0.55)
                      : _gradient.last.withValues(alpha: 0.5),
                  blurRadius: qty > 0 ? 24 : 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(
              isMobile ? 10 : 14,
              isMobile ? 16 : 18,
              isMobile ? 10 : 14,
              isMobile ? 12 : 14,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Image ──────────────────────────────────────────────────
                Expanded(
                  flex: 6,
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final size = (constraints.maxHeight * 0.92)
                            .clamp(70.0, 180.0);
                        return _ItemImage(
                          item: widget.item,
                          size: size,
                          ringColor: qty > 0 ? _activeGradient.first : _gradient.first,
                          isActive: qty > 0,
                        );
                      },
                    ),
                  ),
                ),

                SizedBox(height: isMobile ? 10 : 12),

                // ── Name ───────────────────────────────────────────────────
                Expanded(
                  flex: 2,
                  child: Text(
                    widget.item.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: isMobile ? 16 : 16,
                      color: qty > 0 ? Colors.white : _textDark,
                      height: 1.2,
                    ),
                  ),
                ),

                // ── Price ──────────────────────────────────────────────────
                Text(
                  '₹${widget.item.price.toStringAsFixed(0)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 17,
                    color: qty > 0 ? Colors.white.withValues(alpha: 0.9) : _primaryAccent,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: isMobile ? 8 : 10),

                // ── Add button ─────────────────────────────────────────────
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  height: 34,
                  decoration: BoxDecoration(
                    color: qty > 0
                        ? Colors.white.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(17),
                    border: qty > 0
                        ? Border.all(
                            color: Colors.white.withValues(alpha: 0.6),
                            width: 1.5,
                          )
                        : null,
                  ),
                  child: Center(
                    child: qty > 0
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_rounded,
                                  size: 14, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                'Added ×$qty',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
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
        ),
      );
    });
  }
}

// ── Item image circle ──────────────────────────────────────────────────────────
class _ItemImage extends StatelessWidget {
  final MenuItem item;
  final double size;
  final Color ringColor;
  final bool isActive;

  const _ItemImage({
    required this.item,
    required this.size,
    required this.ringColor,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: isActive ? Colors.white : Colors.white,
          width: isActive ? 4 : 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isActive ? 0.18 : 0.10),
            blurRadius: isActive ? 20 : 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: ringColor.withValues(alpha: isActive ? 0.0 : 0.18),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(child: _buildContent()),
    );
  }

  Widget _buildContent() {
    if (item.image.trim().isEmpty) {
      return Container(
        color: const Color(0xFFF4F3FF),
        child: Icon(
          Icons.ramen_dining_rounded,
          size: size * 0.48,
          color: const Color(0xFF6C63FF),
        ),
      );
    }

    return Image.network(
      item.image,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: const Color(0xFFF4F3FF),
          child: Center(
            child: SizedBox(
              width: size * 0.28,
              height: size * 0.28,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: const Color(0xFF6C63FF),
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                    : null,
              ),
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFFF4F3FF),
        child: Icon(
          Icons.broken_image_outlined,
          size: size * 0.42,
          color: const Color(0xFF6C63FF).withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
