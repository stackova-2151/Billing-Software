import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HeaderBar extends StatelessWidget {
  final String shopName;
  final String cashierName;
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  HeaderBar({
    super.key,
    required this.shopName,
    required this.cashierName,
    required this.onSettings,
    required this.onLogout,
  }) {
    Stream.periodic(const Duration(seconds: 1)).listen((_) {
      _dateTimeText.value = _formatted();
    });
  }

  static String _two(int v) => v.toString().padLeft(2, '0');

  static String _formatted() {
    final d = DateTime.now();
    final date = '${_two(d.day)}/${_two(d.month)}/${d.year}';
    final time = '${_two(d.hour)}:${_two(d.minute)}:${_two(d.second)}';
    return '$date  $time';
  }

  final RxString _dateTimeText = RxString(_formatted());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 2,
      color: Colors.white,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                shopName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Obx(() => Text(
                  _dateTimeText.value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                )),
            const SizedBox(width: 18),
            Text(
              cashierName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: onSettings,
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Settings',
            ),
            IconButton(
              onPressed: onLogout,
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
            ),
          ],
        ),
      ),
    );
  }
}
