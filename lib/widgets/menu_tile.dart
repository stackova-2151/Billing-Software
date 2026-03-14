import 'package:flutter/material.dart';

import '../models/menu_item.dart';

class MenuTile extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onTap;

  const MenuTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  Color _pastelColor(int seed) {
    final colors = <Color>[
      const Color(0xFFEFF6FF),
      const Color(0xFFECFDF5),
      const Color(0xFFFFFBEB),
      const Color(0xFFFFF1F2),
      const Color(0xFFF5F3FF),
      const Color(0xFFF1F5F9),
    ];
    return colors[seed % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = _pastelColor(item.id);

    return Opacity(
      opacity: item.isAvailable ? 1 : 0.55,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: item.isAvailable ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Center(
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.fastfood,
                      color: item.isVeg ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                item.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '₹${item.price.toStringAsFixed(0)}',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
