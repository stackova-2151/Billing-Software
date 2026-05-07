import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/report_data.dart';
import '../../theme/app_colors.dart';

class PaymentBreakdownChart extends StatefulWidget {
  final PaymentBreakdown data;

  const PaymentBreakdownChart({super.key, required this.data});

  @override
  State<PaymentBreakdownChart> createState() => _PaymentBreakdownChartState();
}

class _PaymentBreakdownChartState extends State<PaymentBreakdownChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.total == 0) {
      return const Center(
        child: Text('No payment data', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          children: [
            Expanded(
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  sections: _getSections(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildLegend(),
          ],
        );
      },
    );
  }

  List<PieChartSectionData> _getSections() {
    return [
      PieChartSectionData(
        color: AppColors.success,
        value: widget.data.cashAmount * _animation.value,
        title: '${widget.data.cashPercentage.toStringAsFixed(1)}%',
        radius: touchedIndex == 0 ? 70 : 60,
        titleStyle: TextStyle(
          fontSize: touchedIndex == 0 ? 18 : 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: AppColors.info,
        value: widget.data.onlineAmount * _animation.value,
        title: '${widget.data.onlinePercentage.toStringAsFixed(1)}%',
        radius: touchedIndex == 1 ? 70 : 60,
        titleStyle: TextStyle(
          fontSize: touchedIndex == 1 ? 18 : 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Cash', AppColors.success, widget.data.cashAmount),
        const SizedBox(width: 24),
        _buildLegendItem('Online', AppColors.info, widget.data.onlineAmount),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, double amount) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '₹${amount.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
