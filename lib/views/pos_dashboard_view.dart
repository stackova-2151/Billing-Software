import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/pos_dashboard_controller.dart';

class PosDashboardView extends StatelessWidget {
  const PosDashboardView({super.key});

  void _log(String message) {
    debugPrint('[PosDashboardView] $message');
  }

  @override
  Widget build(BuildContext context) {
    _log('UI: build()');

    final controller = Get.find<PosDashboardController>();

    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          _log(
            'UI: LayoutBuilder constraints maxWidth=${constraints.maxWidth}',
          );

          final w = constraints.maxWidth;
          final isWide = w >= 1100;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Dashboard',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),

                Obx(() {
                  return _SummaryGrid(
                    crossAxisCount: w >= 1200
                        ? 4
                        : w >= 860
                        ? 2
                        : 1,
                    cards: [
                      _SummaryCardVm(
                        title: 'Today Sales',
                        value:
                            '₹${controller.todaySales.value.toStringAsFixed(0)}',
                        icon: Icons.trending_up,
                        accent: const Color(0xFF2563EB),
                      ),
                      _SummaryCardVm(
                        title: 'Orders Count',
                        value: '${controller.ordersCount.value}',
                        icon: Icons.receipt_long_outlined,
                        accent: const Color(0xFF16A34A),
                      ),
                      _SummaryCardVm(
                        title: 'Items Sold',
                        value: '${controller.itemsSold.value}',
                        icon: Icons.local_dining_outlined,
                        accent: const Color(0xFFF59E0B),
                      ),
                      _SummaryCardVm(
                        title: 'Customers',
                        value: '${controller.customers.value}',
                        icon: Icons.groups_outlined,
                        accent: const Color(0xFF7C3AED),
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 16),

                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 7,
                        child: _Card(
                          title: 'Sales Analytics',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _SectionTitle('Hourly sales (today)'),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 180,
                                child: Obx(() {
                                  final values = controller.hourlySales.toList(
                                    growable: false,
                                  );
                                  return _BarChart(
                                    values: values,
                                    barColor: const Color(0xFF2563EB),
                                  );
                                }),
                              ),
                              const SizedBox(height: 16),
                              _SectionTitle('Last 7 days trend'),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 160,
                                child: Obx(() {
                                  final values = controller.last7DaysSales
                                      .toList(growable: false);
                                  return _LineChart(
                                    values: values,
                                    lineColor: const Color(0xFF16A34A),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            _Card(
                              title: 'Payment Breakdown',
                              child: Obx(() {
                                final cash = controller.cashTotal.value;
                                final online = controller.onlineTotal.value;
                                return _PaymentBreakdown(
                                  cash: cash,
                                  online: online,
                                );
                              }),
                            ),
                            const SizedBox(height: 16),
                            _Card(
                              title: 'Top Selling Items',
                              child: Obx(() {
                                final items = controller.topSellingItems.toList(
                                  growable: false,
                                );
                                return _TopItemsList(items: items);
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _Card(
                        title: 'Sales Analytics',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _SectionTitle('Hourly sales (today)'),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 180,
                              child: Obx(() {
                                final values = controller.hourlySales.toList(
                                  growable: false,
                                );
                                return _BarChart(
                                  values: values,
                                  barColor: const Color(0xFF2563EB),
                                );
                              }),
                            ),
                            const SizedBox(height: 16),
                            _SectionTitle('Last 7 days trend'),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 160,
                              child: Obx(() {
                                final values = controller.last7DaysSales.toList(
                                  growable: false,
                                );
                                return _LineChart(
                                  values: values,
                                  lineColor: const Color(0xFF16A34A),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _Card(
                        title: 'Payment Breakdown',
                        child: Obx(() {
                          return _PaymentBreakdown(
                            cash: controller.cashTotal.value,
                            online: controller.onlineTotal.value,
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      _Card(
                        title: 'Top Selling Items',
                        child: Obx(() {
                          final items = controller.topSellingItems.toList(
                            growable: false,
                          );
                          return _TopItemsList(items: items);
                        }),
                      ),
                    ],
                  ),

                const SizedBox(height: 16),

                _Card(
                  title: 'Recent Orders',
                  child: Obx(() {
                    final orders = controller.recentOrders.toList(
                      growable: false,
                    );
                    return _RecentOrdersTable(orders: orders);
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;

  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w900,
        color: const Color(0xFF334155),
      ),
    );
  }
}

class _SummaryCardVm {
  final String title;
  final String value;
  final IconData icon;
  final Color accent;

  const _SummaryCardVm({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
  });
}

class _SummaryGrid extends StatelessWidget {
  final int crossAxisCount;
  final List<_SummaryCardVm> cards;

  const _SummaryGrid({required this.crossAxisCount, required this.cards});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: crossAxisCount == 4 ? 2.8 : 2.9,
      ),
      itemCount: cards.length,
      itemBuilder: (context, i) {
        final c = cards[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: c.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(c.icon, color: c.accent, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      c.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      c.value,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TopItemsList extends StatelessWidget {
  final List<TopSellingItem> items;

  const _TopItemsList({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (items.isEmpty) {
      return Text(
        'No sales yet',
        style: theme.textTheme.titleSmall?.copyWith(
          color: const Color(0xFF64748B),
          fontWeight: FontWeight.w700,
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < items.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: i == items.length - 1
                      ? Colors.transparent
                      : const Color(0xFFE5E7EB),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '#${i + 1}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    items[i].name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                Text(
                  'x${items[i].qty}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _RecentOrdersTable extends StatelessWidget {
  final List<RecentOrderVm> orders;

  const _RecentOrdersTable({required this.orders});

  String _two(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (orders.isEmpty) {
      return Text(
        'No orders yet',
        style: theme.textTheme.titleSmall?.copyWith(
          color: const Color(0xFF64748B),
          fontWeight: FontWeight.w700,
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Order ID',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
              SizedBox(
                width: 140,
                child: Text(
                  'Amount',
                  textAlign: TextAlign.right,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
        for (final o in orders)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          o.id,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${_two(o.createdAt.hour)}:${_two(o.createdAt.minute)}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: Text(
                    '₹${o.total.toStringAsFixed(0)}',
                    textAlign: TextAlign.right,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PaymentBreakdown extends StatelessWidget {
  final double cash;
  final double online;

  const _PaymentBreakdown({required this.cash, required this.online});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = cash + online;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 180,
          child: _PieChart(cash: cash, online: online),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MiniStatCard(
                label: 'Cash',
                value: total <= 0 ? '₹0' : '₹${cash.toStringAsFixed(0)}',
                color: const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniStatCard(
                label: 'Online',
                value: total <= 0 ? '₹0' : '₹${online.toStringAsFixed(0)}',
                color: const Color(0xFF2563EB),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          total <= 0
              ? 'No payments recorded today'
              : 'Cash ${(cash / total * 100).toStringAsFixed(0)}%  •  Online ${(online / total * 100).toStringAsFixed(0)}%',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF334155),
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

class _PieChart extends StatelessWidget {
  final double cash;
  final double online;

  const _PieChart({required this.cash, required this.online});

  @override
  Widget build(BuildContext context) {
    final total = cash + online;
    final cashFrac = total <= 0 ? 0.0 : cash / total;

    return CustomPaint(
      painter: _PieChartPainter(
        cashFraction: cashFrac,
        cashColor: const Color(0xFFF59E0B),
        onlineColor: const Color(0xFF2563EB),
        bg: const Color(0xFFF1F5F9),
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final double cashFraction;
  final Color cashColor;
  final Color onlineColor;
  final Color bg;

  const _PieChartPainter({
    required this.cashFraction,
    required this.cashColor,
    required this.onlineColor,
    required this.bg,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2.2;

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    // Background ring
    stroke.color = bg;
    canvas.drawCircle(center, radius, stroke);

    if (cashFraction <= 0) return;

    final start = -math.pi / 2;
    final sweep = 2 * math.pi * cashFraction;

    stroke.color = cashColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      stroke,
    );

    // Remaining
    stroke.color = onlineColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start + sweep,
      2 * math.pi - sweep,
      false,
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.cashFraction != cashFraction ||
        oldDelegate.cashColor != cashColor ||
        oldDelegate.onlineColor != onlineColor ||
        oldDelegate.bg != bg;
  }
}

class _BarChart extends StatelessWidget {
  final List<double> values;
  final Color barColor;

  const _BarChart({required this.values, required this.barColor});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BarChartPainter(values: values, barColor: barColor),
      child: const SizedBox.expand(),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<double> values;
  final Color barColor;

  const _BarChartPainter({required this.values, required this.barColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final maxV = values.fold<double>(0.0, (m, e) => math.max(m, e));
    final paint = Paint()..color = barColor.withValues(alpha: 0.9);
    final grid = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;

    // Grid lines
    for (int i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final n = values.length;
    final gap = 2.0;
    final barW = (size.width - gap * (n - 1)) / n;

    for (int i = 0; i < n; i++) {
      final v = values[i];
      final h = maxV <= 0 ? 0.0 : (v / maxV) * (size.height - 10);
      final rect = Rect.fromLTWH(i * (barW + gap), size.height - h, barW, h);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return !listEquals(oldDelegate.values, values) ||
        oldDelegate.barColor != barColor;
  }
}

class _LineChart extends StatelessWidget {
  final List<double> values;
  final Color lineColor;

  const _LineChart({required this.values, required this.lineColor});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(values: values, lineColor: lineColor),
      child: const SizedBox.expand(),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;

  const _LineChartPainter({required this.values, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final maxV = values.fold<double>(0.0, (m, e) => math.max(m, e));

    final grid = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;
    for (int i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final line = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fill = Paint()
      ..color = lineColor.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    final n = values.length;
    final dx = n <= 1 ? 0.0 : size.width / (n - 1);

    final points = <Offset>[];
    for (int i = 0; i < n; i++) {
      final v = values[i];
      final t = maxV <= 0 ? 0.0 : (v / maxV);
      final y = size.height - (t * (size.height - 10)) - 5;
      points.add(Offset(dx * i, y));
    }

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // Fill under curve
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    canvas.drawPath(fillPath, fill);
    canvas.drawPath(path, line);

    final dot = Paint()..color = lineColor;
    for (final p in points) {
      canvas.drawCircle(p, 4, dot);
      canvas.drawCircle(p, 7, Paint()..color = Colors.white);
      canvas.drawCircle(p, 4, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return !listEquals(oldDelegate.values, values) ||
        oldDelegate.lineColor != lineColor;
  }
}
