import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/report_data.dart';
import '../../theme/app_colors.dart';
import '../../controllers/report_controller.dart';

class SalesTrendChart extends StatefulWidget {
  final List<SalesTrendData>? data;
  final bool isLoading;

  const SalesTrendChart({super.key, this.data, this.isLoading = false});

  @override
  State<SalesTrendChart> createState() => _SalesTrendChartState();
}

class _SalesTrendChartState extends State<SalesTrendChart> {
  List<FlSpot> _animatedSpots = [];
  List<FlSpot> _fullSpots = [];
  Timer? _animationTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  @override
  void didUpdateWidget(SalesTrendChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _initializeAnimation();
    }
  }

  void _initializeAnimation() {
    _animationTimer?.cancel();
    _currentIndex = 0;
    _animatedSpots = [];
    
    final validData = _getValidData();
    if (validData.isEmpty) {
      _fullSpots = [];
      setState(() {});
      return;
    }

    _fullSpots = List.generate(
      validData.length,
      (index) {
        final amount = _sanitizeAmount(validData[index].amount);
        return FlSpot(index.toDouble(), amount);
      },
    );

    // Start progressive animation
    _animationTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (_currentIndex < _fullSpots.length) {
        setState(() {
          _animatedSpots.add(_fullSpots[_currentIndex]);
          _currentIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  List<SalesTrendData> _getValidData() {
    if (widget.data == null || widget.data!.isEmpty) return [];
    return widget.data!.where((item) => 
      item.amount.isFinite && !item.amount.isNaN
    ).toList();
  }

  double _sanitizeAmount(double amount) {
    if (amount.isNaN || amount.isInfinite) return 0.0;
    return amount.clamp(0.0, double.maxFinite);
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final validData = _getValidData();
    
    // Empty state
    if (validData.isEmpty) {
      return _buildEmptyState();
    }

    // Chart with minimum 2 points to prevent fl_chart crashes
    final chartSpots = _animatedSpots.isEmpty ? _getMinimumSpots() : _animatedSpots;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _calculateInterval(),
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.border,
                strokeWidth: 1,
              );
            },
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
                reservedSize: 30,
                interval: _getBottomInterval(),
                getTitlesWidget: (value, meta) {
                  return _getBottomLabel(value.toInt());
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (validData.length - 1).toDouble().clamp(0, double.maxFinite),
          minY: 0,
          maxY: _getMaxY(),
          lineBarsData: [
            LineChartBarData(
              spots: chartSpots,
              isCurved: chartSpots.length > 2,
              gradient: AppColors.primaryGradient,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: chartSpots.length <= 10,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: AppColors.primary,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: chartSpots.length > 1,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.3),
                    AppColors.primary.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: chartSpots.length > 1,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.x.toInt();
                  if (index >= validData.length || index < 0) return null;
                  
                  final data = validData[index];
                  return LineTooltipItem(
                    '${_formatTooltipDate(data.date)}\n₹${spot.y.toStringAsFixed(0)}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up_outlined,
            size: 48,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 12),
          Text(
            'No Data Available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Sales data will appear here once available',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getMinimumSpots() {
    if (_fullSpots.isEmpty) {
      return [const FlSpot(0, 0), const FlSpot(1, 0)];
    }
    if (_fullSpots.length == 1) {
      return [_fullSpots[0], FlSpot(_fullSpots[0].x + 1, _fullSpots[0].y)];
    }
    return _fullSpots;
  }

  double _getMaxY() {
    final validData = _getValidData();
    if (validData.isEmpty) return 100;
    
    final maxValue = validData
        .map((e) => _sanitizeAmount(e.amount))
        .reduce((a, b) => a > b ? a : b);
    
    return (maxValue * 1.2).clamp(1, double.maxFinite);
  }

  double _getBottomInterval() {
    final validData = _getValidData();
    if (validData.length <= 7) return 1;
    if (validData.length <= 12) return 1;
    return (validData.length / 6).ceilToDouble().clamp(1, double.maxFinite);
  }

  Widget _getBottomLabel(int index) {
    final validData = _getValidData();
    if (index >= validData.length || index < 0) return const SizedBox();
    
    final date = validData[index].date;
    final controller = Get.find<ReportController>();
    final rangeType = controller.selectedDateRange.value;
    String label;

    switch (rangeType) {
      case DateRangeType.week:
        label = DateFormat('dd MMM').format(date);
        break;
      case DateRangeType.month:
        final weekNum = index + 1;
        label = 'W$weekNum';
        break;
      case DateRangeType.year:
        label = DateFormat('MMM').format(date);
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
        ),
      ),
    );
  }

  String _formatTooltipDate(DateTime date) {
    final controller = Get.find<ReportController>();
    final rangeType = controller.selectedDateRange.value;
    final validData = _getValidData();
    
    switch (rangeType) {
      case DateRangeType.week:
        return DateFormat('dd MMM').format(date);
      case DateRangeType.month:
        final index = validData.indexWhere((d) => d.date == date);
        return 'Week ${index >= 0 ? index + 1 : 1}';
      case DateRangeType.year:
        return DateFormat('MMM yyyy').format(date);
    }
  }

  double _calculateInterval() {
    final validData = _getValidData();
    if (validData.isEmpty) return 1000;
    
    final maxValue = validData
        .map((e) => _sanitizeAmount(e.amount))
        .reduce((a, b) => a > b ? a : b);
    
    if (maxValue <= 0) return 1000;
    return (maxValue / 5).clamp(1, double.maxFinite);
  }

  String _formatNumber(double value) {
    if (!value.isFinite || value.isNaN) return '0';
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}
