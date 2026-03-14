import 'package:flutter/material.dart';

class CategoryBar extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  const CategoryBar({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final c = categories[index];
          final active = c == selected;
          return ChoiceChip(
            label: Text(
              c,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            selected: active,
            showCheckmark: false,
            selectedColor: const Color(0xFF2563EB),
            backgroundColor: const Color(0xFFF1F5F9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            onSelected: (_) => onSelected(c),
          );
        },
      ),
    );
  }
}
