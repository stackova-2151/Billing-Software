import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../animations/animated_counter.dart';

class SummaryCard extends StatefulWidget {
  final String title;
  final double value;
  final IconData icon;
  final Gradient gradient;
  final String? prefix;
  final String? suffix;
  final int decimals;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    this.prefix,
    this.suffix,
    this.decimals = 0,
  });

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getCardColor() {
    if (widget.gradient == AppColors.successGradient) return const Color(0xFF34D399); // Rich emerald green
    if (widget.gradient == AppColors.primaryGradient) return const Color(0xFF60A5FA); // Rich blue
    if (widget.gradient == AppColors.warningGradient) return const Color(0xFFFBBF24); // Rich amber
    if (widget.gradient == AppColors.infoGradient) return const Color(0xFFA78BFA); // Rich purple
    return const Color(0xFF60A5FA);
  }

  Color _getIconColor() {
    return Colors.white; // White icons for better contrast
  }

  List<BoxShadow> _getShadows(bool isPressed, Color cardColor) {
    if (isPressed) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          offset: const Offset(-3, -3),
          blurRadius: 6,
        ),
        BoxShadow(
          color: cardColor.withOpacity(0.5),
          offset: const Offset(3, 3),
          blurRadius: 6,
        ),
      ];
    }
    return [
      BoxShadow(
        color: cardColor.withOpacity(0.3),
        offset: const Offset(-6, -6),
        blurRadius: 12,
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        offset: const Offset(6, 6),
        blurRadius: 12,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = _getCardColor();
    
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: _getShadows(_isPressed, cardColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      offset: const Offset(-4, -4),
                      blurRadius: 8,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(4, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  color: _getIconColor(),
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedCounter(
                value: widget.value,
                duration: const Duration(milliseconds: 1500),
                prefix: widget.prefix,
                suffix: widget.suffix,
                decimals: widget.decimals,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFF8FAFC),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
