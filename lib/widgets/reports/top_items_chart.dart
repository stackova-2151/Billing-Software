import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/report_data.dart';
import '../../theme/app_colors.dart';

class TopItemsChart extends StatefulWidget {
  final List<TopItemData> data;

  const TopItemsChart({super.key, required this.data});

  @override
  State<TopItemsChart> createState() => _TopItemsChartState();
}

class _TopItemsChartState extends State<TopItemsChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _barAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Create staggered animations for each bar
    _barAnimations = List.generate(
      widget.data.length,
      (index) {
        final start = index * 0.1;
        final end = start + 0.9;
        return Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              start.clamp(0.0, 1.0),
              end.clamp(0.0, 1.0),
              curve: Curves.easeOutCubic,
            ),
          ),
        );
      },
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Center(
        child: Text('No items data', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _getMaxValue() * 1.2,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${widget.data[groupIndex].itemName}\n₹${rod.toY.toStringAsFixed(0)}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '₹${_formatNumber(value)}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= widget.data.length) return const SizedBox();
                      final item = widget.data[value.toInt()];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _truncateText(item.itemName, 8),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: _getMaxValue() / 5,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.border,
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(show: false),
              barGroups: _getBarGroups(),
            ),
          ),
        );
      },
    );
  }

  List<BarChartGroupData> _getBarGroups() {
    return List.generate(widget.data.length, (index) {
      final colors = [
        AppColors.primary,
        AppColors.purple,
        AppColors.success,
        AppColors.warning,
        AppColors.info,
      ];
      final color = colors[index % colors.length];
      final animationValue = index < _barAnimations.length ? _barAnimations[index].value : 1.0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: widget.data[index].revenue * animationValue,
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 24,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(6),
            ),
          ),
        ],
      );
    });
  }

  double _getMaxValue() {
    if (widget.data.isEmpty) return 1000;
    return widget.data.map((e) => e.revenue).reduce((a, b) => a > b ? a : b);
  }

  String _formatNumber(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}..';
  }
}
