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

  static const Color selectedBg = Color(0xFF7ED957);
  static const Color selectedText = Colors.white;
  static const Color unselectedBg = Color(0xFFF1F1F1);
  static const Color unselectedText = Colors.black;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final c = categories[index];
          final isActive = c == selected;
          return InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => onSelected(c),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? selectedBg : unselectedBg,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Center(
                child: Text(
                  c,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isActive ? selectedText : unselectedText,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
