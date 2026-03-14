import 'dart:async';

import 'package:flutter/material.dart';

class HeaderBar extends StatefulWidget {
  final String shopName;
  final String cashierName;
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  const HeaderBar({
    super.key,
    required this.shopName,
    required this.cashierName,
    required this.onSettings,
    required this.onLogout,
  });

  @override
  State<HeaderBar> createState() => _HeaderBarState();
}

class _HeaderBarState extends State<HeaderBar> {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _two(int v) => v.toString().padLeft(2, '0');

  String get _dateTimeText {
    final d = _now;
    final date = '${_two(d.day)}/${_two(d.month)}/${d.year}';
    final time = '${_two(d.hour)}:${_two(d.minute)}:${_two(d.second)}';
    return '$date  $time';
  }

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
                widget.shopName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              _dateTimeText,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 18),
            Text(
              widget.cashierName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: widget.onSettings,
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Settings',
            ),
            IconButton(
              onPressed: widget.onLogout,
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
            ),
          ],
        ),
      ),
    );
  }
}
