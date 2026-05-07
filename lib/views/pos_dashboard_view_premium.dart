import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../animations/animated_counter.dart';
import '../controllers/pos_dashboard_controller.dart';
import '../theme/app_colors.dart';

class PosDashboardViewPremium extends StatefulWidget {
  const PosDashboardViewPremium({super.key});

  @override
  State<PosDashboardViewPremium> createState() => _PosDashboardViewPremiumState();
}

class _PosDashboardViewPremiumState extends State<PosDashboardViewPremium>
    with SingleTickerProviderStateMixin {
  late AnimationController _pageAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _pageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _pageAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _pageAnimationController.forward();
  }

  @override
  void dispose() {
    _pageAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PosDashboardController>();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.lg),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final isWide = w >= 1100;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: AppSpacing.xl),
                    Obx(() => _buildSummaryCards(controller, w)),
                    const SizedBox(height: AppSpacing.xl),
                    if (isWide)
                      _buildWideLayout(controller)
                    else
                      _buildNarrowLayout(controller),
                    const SizedBox(height: AppSpacing.xl),
                    _buildRecentOrders(controller),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Welcome back! Here\'s what\'s happening today.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(PosDashboardController controller, double width) {
    final crossAxisCount = width >= 1200 ? 4 : width >= 860 ? 2 : 1;

    final cards = [
      _SummaryCardData(
        title: 'Today Sales',
        value: controller.todaySales.value,
        icon: Icons.trending_up_rounded,
        gradient: AppColors.infoGradient,
        prefix: '₹',
      ),
      _SummaryCardData(
        title: 'Orders Count',
        value: controller.ordersCount.value.toDouble(),
        icon: Icons.receipt_long_rounded,
        gradient: AppColors.successGradient,
        isInteger: true,
      ),
      _SummaryCardData(
        title: 'Items Sold',
        value: controller.itemsSold.value.toDouble(),
        icon: Icons.local_dining_rounded,
        gradient: AppColors.warningGradient,
        isInteger: true,
      ),
      _SummaryCardData(
        title: 'Customers',
        value: controller.customers.value.toDouble(),
        icon: Icons.groups_rounded,
        gradient: LinearGradient(
          colors: [AppColors.purple, AppColors.purpleLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        isInteger: true,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSpacing.lg,
        mainAxisSpacing: AppSpacing.lg,
        childAspectRatio: crossAxisCount == 4 ? 2.8 : 2.9,
      ),
      itemCount: cards.length,
      itemBuilder: (context, i) {
        return _AnimatedSummaryCard(
          data: cards[i],
          delay: Duration(milliseconds: 100 * i),
        );
      },
    );
  }

  Widget _buildWideLayout(PosDashboardController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: _PremiumCard(
            title: 'Sales Analytics',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionTitle('Last 7 days trend'),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 200,
                  child: Obx(() {
                    final values = controller.last7DaysSales.toList(growable: false);
                    return _AnimatedLineChart(
                      values: values,
                      gradient: AppColors.successGradient,
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              _PremiumCard(
                title: 'Payment Breakdown',
                child: Obx(() {
                  return _AnimatedPaymentBreakdown(
                    cash: controller.cashTotal.value,
                    online: controller.onlineTotal.value,
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.lg),
              _PremiumCard(
                title: 'Top Selling Items',
                child: Obx(() {
                  final items = controller.topSellingItems.toList(growable: false);
                  return _TopItemsList(items: items);
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(PosDashboardController controller) {
    return Column(
      children: [
        _PremiumCard(
          title: 'Sales Analytics',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Last 7 days trend'),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 200,
                child: Obx(() {
                  final values = controller.last7DaysSales.toList(growable: false);
                  return _AnimatedLineChart(
                    values: values,
                    gradient: AppColors.successGradient,
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _PremiumCard(
          title: 'Payment Breakdown',
          child: Obx(() {
            return _AnimatedPaymentBreakdown(
              cash: controller.cashTotal.value,
              online: controller.onlineTotal.value,
            );
          }),
        ),
        const SizedBox(height: AppSpacing.lg),
        _PremiumCard(
          title: 'Top Selling Items',
          child: Obx(() {
            final items = controller.topSellingItems.toList(growable: false);
            return _TopItemsList(items: items);
          }),
        ),
      ],
    );
  }

  Widget _buildRecentOrders(PosDashboardController controller) {
    return _PremiumCard(
      title: 'Recent Orders',
      child: Obx(() {
        final orders = controller.recentOrders.toList(growable: false);
        return _RecentOrdersTable(orders: orders);
      }),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }
}

// Premium Card Widget with hover effect
class _PremiumCard extends StatefulWidget {
  final String title;
  final Widget child;

  const _PremiumCard({required this.title, required this.child});

  @override
  State<_PremiumCard> createState() => _PremiumCardState();
}

class _PremiumCardState extends State<_PremiumCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: _isHovered ? AppColors.primary.withOpacity(0.3) : AppColors.border,
            width: 1,
          ),
          boxShadow: _isHovered ? AppShadows.large : AppShadows.medium,
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            widget.child,
          ],
        ),
      ),
    );
  }
}

// Animated Summary Card
class _SummaryCardData {
  final String title;
  final double value;
  final IconData icon;
  final LinearGradient gradient;
  final String prefix;
  final String suffix;
  final bool isInteger;

  const _SummaryCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    this.prefix = '',
    this.suffix = '',
    this.isInteger = false,
  });
}

class _AnimatedSummaryCard extends StatefulWidget {
  final _SummaryCardData data;
  final Duration delay;

  const _AnimatedSummaryCard({
    required this.data,
    this.delay = Duration.zero,
  });

  @override
  State<_AnimatedSummaryCard> createState() => _AnimatedSummaryCardState();
}

class _AnimatedSummaryCardState extends State<_AnimatedSummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            transform: Matrix4.identity()
              ..translate(0.0, _isHovered ? -4.0 : 0.0),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.border),
              boxShadow: _isHovered ? AppShadows.xl : AppShadows.medium,
            ),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: widget.data.gradient,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: [
                      BoxShadow(
                        color: widget.data.gradient.colors.first.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.data.icon,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.data.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      widget.data.isInteger
                          ? AnimatedIntCounter(
                              value: widget.data.value.toInt(),
                              prefix: widget.data.prefix,
                              suffix: widget.data.suffix,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            )
                          : AnimatedCounter(
                              value: widget.data.value,
                              prefix: widget.data.prefix,
                              suffix: widget.data.suffix,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Continue in next message due to length...

// Animated Bar Chart with gradient
class _AnimatedBarChart extends StatefulWidget {
  final List<double> values;
  final LinearGradient gradient;

  const _AnimatedBarChart({
    required this.values,
    required this.gradient,
  });

  @override
  State<_AnimatedBarChart> createState() => _AnimatedBarChartState();
}

class _AnimatedBarChartState extends State<_AnimatedBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _AnimatedBarChartPainter(
            values: widget.values,
            gradient: widget.gradient,
            progress: _animation.value,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _AnimatedBarChartPainter extends CustomPainter {
  final List<double> values;
  final LinearGradient gradient;
  final double progress;

  const _AnimatedBarChartPainter({
    required this.values,
    required this.gradient,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final maxV = values.fold<double>(0.0, (m, e) => math.max(m, e));

    // Grid lines
    final gridPaint = Paint()
      ..color = AppColors.borderLight
      ..strokeWidth = 1;

    for (int i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final n = values.length;
    final gap = 3.0;
    final barW = (size.width - gap * (n - 1)) / n;

    for (int i = 0; i < n; i++) {
      final v = values[i];
      final targetH = maxV <= 0 ? 0.0 : (v / maxV) * (size.height - 10);
      final h = targetH * progress;

      final rect = Rect.fromLTWH(
        i * (barW + gap),
        size.height - h,
        barW,
        h,
      );

      final paint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedBarChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        !listEquals(oldDelegate.values, values);
  }
}

// Animated Line Chart with gradient fill
class _AnimatedLineChart extends StatefulWidget {
  final List<double> values;
  final LinearGradient gradient;

  const _AnimatedLineChart({
    required this.values,
    required this.gradient,
  });

  @override
  State<_AnimatedLineChart> createState() => _AnimatedLineChartState();
}

class _AnimatedLineChartState extends State<_AnimatedLineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _AnimatedLineChartPainter(
            values: widget.values,
            gradient: widget.gradient,
            progress: _animation.value,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _AnimatedLineChartPainter extends CustomPainter {
  final List<double> values;
  final LinearGradient gradient;
  final double progress;

  const _AnimatedLineChartPainter({
    required this.values,
    required this.gradient,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final maxV = values.fold<double>(0.0, (m, e) => math.max(m, e));

    // Grid lines
    final gridPaint = Paint()
      ..color = AppColors.borderLight
      ..strokeWidth = 1;

    for (int i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final n = values.length;
    final dx = n <= 1 ? 0.0 : size.width / (n - 1);

    final points = <Offset>[];
    for (int i = 0; i < n; i++) {
      final v = values[i];
      final t = maxV <= 0 ? 0.0 : (v / maxV);
      final y = size.height - (t * (size.height - 10)) - 5;
      points.add(Offset(dx * i, y));
    }

    // Animate line drawing
    final visiblePoints = (points.length * progress).ceil();
    if (visiblePoints < 2) return;

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < visiblePoints && i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final controlPoint1 = Offset(prev.dx + (curr.dx - prev.dx) / 2, prev.dy);
      final controlPoint2 = Offset(prev.dx + (curr.dx - prev.dx) / 2, curr.dy);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        curr.dx,
        curr.dy,
      );
    }

    // Fill under curve
    final fillPath = Path.from(path)
      ..lineTo(points[visiblePoints - 1].dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          gradient.colors.first.withOpacity(0.3),
          gradient.colors.first.withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // Draw dots
    for (int i = 0; i < visiblePoints && i < points.length; i++) {
      final p = points[i];
      canvas.drawCircle(p, 5, Paint()..color = Colors.white);
      canvas.drawCircle(
        p,
        4,
        Paint()..color = gradient.colors.first,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedLineChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        !listEquals(oldDelegate.values, values);
  }
}

// Animated Payment Breakdown (Pie Chart)
class _AnimatedPaymentBreakdown extends StatefulWidget {
  final double cash;
  final double online;

  const _AnimatedPaymentBreakdown({
    required this.cash,
    required this.online,
  });

  @override
  State<_AnimatedPaymentBreakdown> createState() =>
      _AnimatedPaymentBreakdownState();
}

class _AnimatedPaymentBreakdownState extends State<_AnimatedPaymentBreakdown>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
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
    final total = widget.cash + widget.online;

    if (total <= 0) {
      return _EmptyState(
        icon: Icons.payments_outlined,
        message: 'No payments recorded today',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 180,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                painter: _AnimatedPieChartPainter(
                  cashFraction: widget.cash / total,
                  progress: _animation.value,
                ),
                child: const SizedBox.expand(),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _PaymentStatCard(
                label: 'Cash',
                value: widget.cash,
                color: AppColors.warning,
                delay: const Duration(milliseconds: 400),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _PaymentStatCard(
                label: 'Online',
                value: widget.online,
                color: AppColors.info,
                delay: const Duration(milliseconds: 600),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Cash ${(widget.cash / total * 100).toStringAsFixed(0)}%  •  Online ${(widget.online / total * 100).toStringAsFixed(0)}%',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _AnimatedPieChartPainter extends CustomPainter {
  final double cashFraction;
  final double progress;

  const _AnimatedPieChartPainter({
    required this.cashFraction,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2.2;

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    // Background ring
    stroke.color = AppColors.borderLight;
    canvas.drawCircle(center, radius, stroke);

    if (cashFraction <= 0 || progress <= 0) return;

    final start = -math.pi / 2;
    final cashSweep = 2 * math.pi * cashFraction * progress;
    final onlineSweep = 2 * math.pi * (1 - cashFraction) * progress;

    // Cash arc
    stroke.color = AppColors.warning;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      cashSweep,
      false,
      stroke,
    );

    // Online arc
    stroke.color = AppColors.info;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start + cashSweep,
      onlineSweep,
      false,
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _AnimatedPieChartPainter oldDelegate) {
    return oldDelegate.cashFraction != cashFraction ||
        oldDelegate.progress != progress;
  }
}

class _PaymentStatCard extends StatefulWidget {
  final String label;
  final double value;
  final Color color;
  final Duration delay;

  const _PaymentStatCard({
    required this.label,
    required this.value,
    required this.color,
    this.delay = Duration.zero,
  });

  @override
  State<_PaymentStatCard> createState() => _PaymentStatCardState();
}

class _PaymentStatCardState extends State<_PaymentStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: widget.color.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            AnimatedCounter(
              value: widget.value,
              prefix: '₹',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Top Items List with animation - Top 3 + Scrollable Rest
class _TopItemsList extends StatelessWidget {
  final List<TopSellingItem> items;

  const _TopItemsList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptyState(
        icon: Icons.local_dining_outlined,
        message: 'No sales yet today',
      );
    }

    final topThree = items.take(3).toList(); return Column(crossAxisAlignment: CrossAxisAlignment.stretch,mainAxisSize: MainAxisSize.min,children: [for (int i = 0; i < topThree.length; i++)_AnimatedTopItem(item: topThree[i],rank: i + 1,delay: Duration(milliseconds: 100 * i),),],);
  }
}

class _AnimatedTopItem extends StatefulWidget {
  final TopSellingItem item;
  final int rank;
  final Duration delay;

  const _AnimatedTopItem({
    required this.item,
    required this.rank,
    this.delay = Duration.zero,
  });

  @override
  State<_AnimatedTopItem> createState() => _AnimatedTopItemState();
}

class _AnimatedTopItemState extends State<_AnimatedTopItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: widget.rank == 6 ? Colors.transparent : AppColors.border,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: widget.rank <= 3
                      ? AppColors.primaryGradient
                      : null,
                  color: widget.rank > 3 ? AppColors.surfaceVariant : null,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Center(
                  child: Text(
                    '#${widget.rank}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: widget.rank <= 3
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  widget.item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  'x${widget.item.qty}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Recent Orders Table - First 5 + Scrollable Rest
class _RecentOrdersTable extends StatelessWidget {
  final List<RecentOrderVm> orders;

  const _RecentOrdersTable({required this.orders});

  String _two(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return _EmptyState(
        icon: Icons.receipt_long_outlined,
        message: 'No orders yet today',
      );
    }

    final firstFive = orders.take(5).toList(); return Column(crossAxisAlignment: CrossAxisAlignment.stretch,mainAxisSize: MainAxisSize.min,children: [Container(padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 2)),),child: Row(children: [Expanded(child: Text('Order ID',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w700,color: AppColors.textSecondary,letterSpacing: 0.5,),),),SizedBox(width: 140,child: Text('Amount',textAlign: TextAlign.right,style: TextStyle(fontSize: 12,fontWeight: FontWeight.w700,color: AppColors.textSecondary,letterSpacing: 0.5,),),),],),),for (int i = 0; i < firstFive.length; i++)_AnimatedOrderRow(order: firstFive[i],delay: Duration(milliseconds: 50 * i),),],);
  }
}

class _AnimatedOrderRow extends StatefulWidget {
  final RecentOrderVm order;
  final Duration delay;

  const _AnimatedOrderRow({
    required this.order,
    this.delay = Duration.zero,
  });

  @override
  State<_AnimatedOrderRow> createState() => _AnimatedOrderRowState();
}

class _AnimatedOrderRowState extends State<_AnimatedOrderRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  String _two(int v) => v.toString().padLeft(2, '0');

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        widget.order.id,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Text(
                        '${_two(widget.order.createdAt.hour)}:${_two(widget.order.createdAt.minute)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 140,
                child: Text(
                  '₹${widget.order.total.toStringAsFixed(0)}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Empty State Widget
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(
                icon,
                size: 32,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


