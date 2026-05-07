import 'package:flutter/material.dart';

class CategoryChipsWidget extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  const CategoryChipsWidget({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  static const Color activeBg = Color(0xFF6C63FF);
  static const Color activeText = Colors.white;
  static const Color inactiveBg = Color(0xFFF4F3FF);
  static const Color inactiveText = Color(0xFF6C63FF);
  static const Color inactiveBorder = Color(0xFFE0DEFF);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final c = categories[index];
          final isActive = c == selected;

          return _ChipItem(
            label: c,
            isActive: isActive,
            onTap: () => onSelected(c),
            theme: theme,
          );
        },
      ),
    );
  }
}

class _ChipItem extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final ThemeData theme;

  const _ChipItem({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.theme,
  });

  @override
  State<_ChipItem> createState() => _ChipItemState();
}

class _ChipItemState extends State<_ChipItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onTapDown(TapDownDetails _) async {
    await _ctrl.forward();
  }

  Future<void> _onTapUp(TapUpDetails _) async {
    await _ctrl.reverse();
    widget.onTap();
  }

  Future<void> _onTapCancel() async {
    await _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: widget.isActive
                ? CategoryChipsWidget.activeBg
                : CategoryChipsWidget.inactiveBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isActive
                  ? CategoryChipsWidget.activeBg
                  : CategoryChipsWidget.inactiveBorder,
              width: 1.2,
            ),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withOpacity(0.30),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: widget.isActive
                      ? Colors.white.withOpacity(0.7)
                      : CategoryChipsWidget.activeBg.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                widget.label,
                style: widget.theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: widget.isActive
                      ? CategoryChipsWidget.activeText
                      : CategoryChipsWidget.inactiveText,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}