import 'package:flutter/material.dart';

/// Animated Counter Widget - Smooth number transitions
class AnimatedCounter extends StatelessWidget {
  final double value;
  final String? prefix;
  final String? suffix;
  final TextStyle? style;
  final Duration duration;
  final int decimals;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.prefix,
    this.suffix,
    this.style,
    this.duration = const Duration(milliseconds: 1500),
    this.decimals = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final formattedValue = decimals > 0
            ? value.toStringAsFixed(decimals)
            : value.toInt().toString();
        
        return Text(
          '${prefix ?? ''}$formattedValue${suffix ?? ''}',
          style: style,
        );
      },
    );
  }
}

/// Animated Integer Counter - For whole numbers
class AnimatedIntCounter extends StatelessWidget {
  final int value;
  final String? prefix;
  final String? suffix;
  final TextStyle? style;
  final Duration duration;

  const AnimatedIntCounter({
    super.key,
    required this.value,
    this.prefix,
    this.suffix,
    this.style,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(
          '${prefix ?? ''}$value${suffix ?? ''}',
          style: style,
        );
      },
    );
  }
}
