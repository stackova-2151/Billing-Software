import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/orders_controller.dart';
import '../models/pos_order.dart';

enum _Period { all, today, week, month, custom }

class _DateGroup {
  final String label;
  final List<PosOrder> orders;
  _DateGroup(this.label, this.orders);
}

// ─────────────────────────────────────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────────────────────────────────────
class _DS {
  // Colors
  static const bg = Color(0xFFF0F4F8);
  static const surface = Colors.white;
  static const border = Color(0xFFE8EEF4);
  static const textPrimary = Color(0xFF0D1B2A);
  static const textSecondary = Color(0xFF5A6A7A);
  static const textMuted = Color(0xFF9AAABB);
  static const accent = Color(0xFF4ADE80);
  static const accentDark = Color(0xFF16A34A);

  // Gradient presets
  static const gradGreen = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradBlue = LinearGradient(
    colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradAmber = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradViolet = LinearGradient(
    colors: [Color(0xFFA78BFA), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Radius
  static const r8  = BorderRadius.all(Radius.circular(8));
  static const r10 = BorderRadius.all(Radius.circular(10));
  static const r12 = BorderRadius.all(Radius.circular(12));
  static const r16 = BorderRadius.all(Radius.circular(16));
  static const r20 = BorderRadius.all(Radius.circular(20));

  // Shadows
  static List<BoxShadow> shadow1 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];
  static List<BoxShadow> shadow2 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class BillHistoryScreen extends StatefulWidget {
  const BillHistoryScreen({super.key});

  @override
  State<BillHistoryScreen> createState() => _BillHistoryScreenState();
}

class _BillHistoryScreenState extends State<BillHistoryScreen> {
  final _searchQuery = ''.obs;
  final _expandedOrderId = Rxn<String>();
  final _searchController = TextEditingController();
  final _period = _Period.all.obs;
  final _fromDate = Rxn<DateTime>();
  final _toDate = Rxn<DateTime>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PosOrder> _filterOrders(List<PosOrder> orders) {
    var filtered = orders;
    final q = _searchQuery.value.toLowerCase();
    if (q.isNotEmpty) {
      filtered = filtered.where((o) => o.id.toLowerCase().contains(q)).toList();
    }
    final now = DateTime.now();
    switch (_period.value) {
      case _Period.today:
        final start = DateTime(now.year, now.month, now.day);
        filtered = filtered.where((o) => o.createdAt.isAfter(start)).toList();
        break;
      case _Period.week:
        final start = now.subtract(Duration(days: now.weekday - 1));
        final startDay = DateTime(start.year, start.month, start.day);
        filtered = filtered.where((o) => o.createdAt.isAfter(startDay)).toList();
        break;
      case _Period.month:
        final start = DateTime(now.year, now.month, 1);
        filtered = filtered.where((o) => o.createdAt.isAfter(start)).toList();
        break;
      case _Period.custom:
        if (_fromDate.value != null || _toDate.value != null) {
          final from = _fromDate.value;
          final to = _toDate.value;
          if (from != null && to != null) {
            final start = DateTime(from.year, from.month, from.day);
            final end = DateTime(to.year, to.month, to.day, 23, 59, 59);
            filtered = filtered
                .where((o) => !o.createdAt.isBefore(start) && !o.createdAt.isAfter(end))
                .toList();
          } else if (from != null) {
            final start = DateTime(from.year, from.month, from.day);
            filtered = filtered.where((o) => !o.createdAt.isBefore(start)).toList();
          } else if (to != null) {
            final end = DateTime(to.year, to.month, to.day, 23, 59, 59);
            filtered = filtered.where((o) => !o.createdAt.isAfter(end)).toList();
          }
        }
        break;
      case _Period.all:
        break;
    }
    return filtered;
  }

  List<_DateGroup> _groupByDate(List<PosOrder> orders) {
    if (orders.isEmpty) return [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final Map<String, List<PosOrder>> grouped = {};
    for (final order in orders) {
      final orderDate = DateTime(
        order.createdAt.year,
        order.createdAt.month,
        order.createdAt.day,
      );
      String key;
      if (orderDate == today) {
        key = 'Today';
      } else if (orderDate == yesterday) {
        key = 'Yesterday';
      } else {
        key = DateFormat('MMM dd, yyyy').format(orderDate);
      }
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(order);
    }
    final result = grouped.entries.map((e) => _DateGroup(e.key, e.value)).toList();
    result.sort((a, b) {
      if (a.label == 'Today') return -1;
      if (b.label == 'Today') return 1;
      if (a.label == 'Yesterday') return -1;
      if (b.label == 'Yesterday') return 1;
      return b.orders.first.createdAt.compareTo(a.orders.first.createdAt);
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrdersController>();

    return Scaffold(
      backgroundColor: _DS.bg,
      body: Column(
        children: [
          _DashboardHeader(
            onExport: () {/* TODO: export */},
          ),
          _SearchAndFilters(
            searchController: _searchController,
            searchQuery: _searchQuery,
            period: _period,
            fromDate: _fromDate,
            toDate: _toDate,
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const _LoadingState();
              }
              final filtered = _filterOrders(controller.orders);
              if (filtered.isEmpty) {
                return _EmptyState(
                  hasFilters: _searchQuery.value.isNotEmpty ||
                      _period.value != _Period.all ||
                      _fromDate.value != null ||
                      _toDate.value != null,
                );
              }
              final dateGroups = _groupByDate(filtered);
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _MetricsRow(orders: filtered),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final group = dateGroups[index];
                          return _DateGroupSection(
                            group: group,
                            expandedOrderId: _expandedOrderId,
                            onOrderTap: (orderId) {
                              _expandedOrderId.value =
                                  _expandedOrderId.value == orderId ? null : orderId;
                            },
                          );
                        },
                        childCount: dateGroups.length,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD HEADER
// ─────────────────────────────────────────────────────────────────────────────
class _DashboardHeader extends StatelessWidget {
  final VoidCallback onExport;

  const _DashboardHeader({required this.onExport});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _DS.surface,
        border: Border(bottom: BorderSide(color: _DS.border)),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 14,
      ),
      child: Row(
        children: [          
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bill History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _DS.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  DateFormat('EEEE, MMM dd yyyy').format(DateTime.now()),
                  style: const TextStyle(
                    fontSize: 12,
                    color: _DS.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),         
          // const SizedBox(width: 8),
          // _PrimaryBtn(
          //   icon: Icons.file_download_outlined,
          //   label: 'Export',
          //   onTap: onExport,
          // ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  const _IconBtn({required this.icon, required this.onTap, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final btn = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: _DS.r10,
        ),
        child: Icon(icon, size: 18, color: _DS.textSecondary),
      ),
    );
    if (tooltip != null) return Tooltip(message: tooltip!, child: btn);
    return btn;
  }
}

class _PrimaryBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PrimaryBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: _DS.gradGreen,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF22C55E).withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEARCH & FILTERS
// ─────────────────────────────────────────────────────────────────────────────
class _SearchAndFilters extends StatelessWidget {
  final TextEditingController searchController;
  final RxString searchQuery;
  final Rx<_Period> period;
  final Rxn<DateTime> fromDate;
  final Rxn<DateTime> toDate;

  const _SearchAndFilters({
    required this.searchController,
    required this.searchQuery,
    required this.period,
    required this.fromDate,
    required this.toDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _DS.surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        children: [
          // Search bar
          Obx(() => Container(
                decoration: BoxDecoration(
                  color: _DS.bg,
                  borderRadius: _DS.r12,
                  border: Border.all(
                    color: searchQuery.value.isNotEmpty
                        ? const Color(0xFF22C55E).withValues(alpha: 0.5)
                        : Colors.transparent,
                  ),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: (v) => searchQuery.value = v,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _DS.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by order ID…',
                    hintStyle: const TextStyle(color: _DS.textMuted, fontSize: 14),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: searchQuery.value.isNotEmpty
                          ? const Color(0xFF22C55E)
                          : _DS.textMuted,
                      size: 20,
                    ),
                    suffixIcon: searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.cancel_rounded,
                                size: 18, color: _DS.textMuted),
                            onPressed: () {
                              searchController.clear();
                              searchQuery.value = '';
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              )),
          const SizedBox(height: 12),
          // Period chips
          Obx(() => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    (_Period.all, 'All Time', Icons.all_inclusive_rounded),
                    (_Period.today, 'Today', Icons.today_rounded),
                    (_Period.week, 'This Week', Icons.date_range_rounded),
                    (_Period.month, 'This Month', Icons.calendar_month_rounded),
                  ].map((e) {
                    final isActive = period.value == e.$1;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _FilterChip(
                        label: e.$2,
                        icon: e.$3,
                        isActive: isActive,
                        onTap: () {
                          period.value = e.$1;
                          fromDate.value = null;
                          toDate.value = null;
                        },
                      ),
                    );
                  }).toList(),
                ),
              )),
          const SizedBox(height: 10),
          // Date range
          Obx(() => Row(
                children: [
                  Expanded(
                    child: _DateRangeField(
                      label: 'From Date',
                      date: fromDate.value,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: fromDate.value ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (context, child) =>
                              _datePickerTheme(context, child),
                        );
                        if (picked != null) {
                          fromDate.value = picked;
                          period.value = _Period.custom;
                        }
                      },
                      onClear: () {
                        fromDate.value = null;
                        if (toDate.value == null) period.value = _Period.all;
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    height: 1,
                    width: 10,
                    color: _DS.textMuted,
                  ),
                  Expanded(
                    child: _DateRangeField(
                      label: 'To Date',
                      date: toDate.value,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: toDate.value ?? DateTime.now(),
                          firstDate: fromDate.value ?? DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (context, child) =>
                              _datePickerTheme(context, child),
                        );
                        if (picked != null) {
                          toDate.value = picked;
                          period.value = _Period.custom;
                        }
                      },
                      onClear: () {
                        toDate.value = null;
                        if (fromDate.value == null) period.value = _Period.all;
                      },
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _datePickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF22C55E),
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: _DS.textPrimary,
        ),
      ),
      child: child!,
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive ? _DS.gradGreen : null,
          color: isActive ? null : _DS.bg,
          borderRadius: _DS.r10,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? Colors.white : _DS.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : _DS.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateRangeField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DateRangeField({
    required this.label,
    required this.date,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasDate = date != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _DS.bg,
          borderRadius: _DS.r12,
          border: Border.all(
            color: hasDate
                ? const Color(0xFF22C55E).withValues(alpha: 0.6)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: hasDate
                    ? const Color(0xFF22C55E).withValues(alpha: 0.1)
                    : Colors.white,
                borderRadius: _DS.r8,
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: hasDate ? const Color(0xFF22C55E) : _DS.textMuted,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _DS.textMuted,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasDate
                        ? DateFormat('dd MMM yyyy').format(date!)
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: hasDate ? _DS.textPrimary : _DS.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (hasDate)
              GestureDetector(
                onTap: onClear,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _DS.textMuted.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 12, color: _DS.textSecondary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// METRICS ROW (gradient cards)
// ─────────────────────────────────────────────────────────────────────────────
class _MetricsRow extends StatelessWidget {
  final List<PosOrder> orders;

  const _MetricsRow({required this.orders});

  @override
  Widget build(BuildContext context) {
    final total = orders.fold<double>(0, (s, o) => s + o.total);
    final cashCount = orders.where((o) => o.paymentMode == PosPaymentMode.cash).length;
    final onlineCount = orders.length - cashCount;
    final cashTotal = orders
        .where((o) => o.paymentMode == PosPaymentMode.cash)
        .fold<double>(0, (s, o) => s + o.total);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _MetricCard(
              label: 'Total Revenue',
              value: '₹${_formatAmount(total)}',
              subLabel: '${orders.length} orders',
              gradient: _DS.gradGreen,
              icon: Icons.trending_up_rounded,
              iconBg: Colors.white.withValues(alpha: 0.2),
              compact: true,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MetricCard(
              label: 'Total Orders',
              value: '${orders.length}',
              subLabel: 'Processed',
              gradient: _DS.gradViolet,
              icon: Icons.receipt_long_rounded,
              iconBg: Colors.white.withValues(alpha: 0.2),
              compact: true,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MetricCard(
              label: 'Cash Sales',
              value: '$cashCount',
              subLabel: '₹${_formatAmount(cashTotal)}',
              gradient: _DS.gradAmber,
              icon: Icons.payments_rounded,
              iconBg: Colors.white.withValues(alpha: 0.2),
              compact: true,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MetricCard(
              label: 'Online Sales',
              value: '$onlineCount',
              subLabel: '₹${_formatAmount(total - cashTotal)}',
              gradient: _DS.gradBlue,
              icon: Icons.phone_iphone_rounded,
              iconBg: Colors.white.withValues(alpha: 0.2),
              compact: true,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String subLabel;
  final Gradient gradient;
  final IconData icon;
  final Color iconBg;
  final bool compact;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.subLabel,
    required this.gradient,
    required this.icon,
    required this.iconBg,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 14 : 18),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: _DS.r16,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: compact ? 11 : 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                SizedBox(height: compact ? 4 : 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: compact ? 22 : 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    height: 1,
                  ),
                ),
                SizedBox(height: compact ? 3 : 4),
                Text(
                  subLabel,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: compact ? 36 : 44,
            height: compact ? 36 : 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: _DS.r12,
            ),
            child: Icon(icon, color: Colors.white, size: compact ? 18 : 22),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DATE GROUP SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _DateGroupSection extends StatelessWidget {
  final _DateGroup group;
  final Rxn<String> expandedOrderId;
  final Function(String) onOrderTap;

  const _DateGroupSection({
    required this.group,
    required this.expandedOrderId,
    required this.onOrderTap,
  });

  @override
  Widget build(BuildContext context) {
    final dayRevenue = group.orders.fold<double>(0, (s, o) => s + o.total);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 20, 2, 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _DS.textPrimary,
                  borderRadius: _DS.r8,
                ),
                child: Text(
                  group.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: _DS.r8,
                ),
                child: Text(
                  '${group.orders.length} bills',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _DS.textSecondary,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '₹${dayRevenue.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _DS.accentDark,
                ),
              ),
            ],
          ),
        ),
        ...group.orders.map((order) => Obx(() => _OrderCard(
              order: order,
              isExpanded: expandedOrderId.value == order.id,
              onTap: () => onOrderTap(order.id),
            ))),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ORDER CARD
// ─────────────────────────────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final PosOrder order;
  final bool isExpanded;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _DS.surface,
        borderRadius: _DS.r16,
        border: Border.all(
          color: isExpanded
              ? const Color(0xFF22C55E).withValues(alpha: 0.5)
              : _DS.border,
          width: isExpanded ? 1.5 : 1,
        ),
        boxShadow: isExpanded ? _DS.shadow2 : _DS.shadow1,
      ),
      child: ClipRRect(
        borderRadius: _DS.r16,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: const Color(0xFF22C55E).withValues(alpha: 0.06),
            highlightColor: const Color(0xFF22C55E).withValues(alpha: 0.03),
            child: Column(
              children: [
                // Expanded indicator bar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: isExpanded ? 3 : 0,
                  decoration: const BoxDecoration(
                    gradient: _DS.gradGreen,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _OrderCardHeader(order: order, isExpanded: isExpanded),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        child: isExpanded
                            ? _OrderCardDetails(order: order)
                            : const SizedBox.shrink(),
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

class _OrderCardHeader extends StatelessWidget {
  final PosOrder order;
  final bool isExpanded;

  const _OrderCardHeader({required this.order, required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left icon
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: isExpanded ? _DS.gradGreen : null,
            color: isExpanded ? null : const Color(0xFFF1F5F9),
            borderRadius: _DS.r12,
          ),
          child: Icon(
            Icons.receipt_outlined,
            color: isExpanded ? Colors.white : _DS.textMuted,
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        // Center info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    order.id,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _DS.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _PaymentBadge(mode: order.paymentMode),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded,
                      size: 12, color: _DS.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('hh:mm a').format(order.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: _DS.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (order.customerName.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    const Icon(Icons.person_outline_rounded,
                        size: 12, color: _DS.textMuted),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        order.customerName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _DS.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        // Right amount + chevron
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${order.total.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: _DS.accentDark,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isExpanded
                      ? const Color(0xFF22C55E).withValues(alpha: 0.1)
                      : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: isExpanded ? const Color(0xFF22C55E) : _DS.textMuted,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OrderCardDetails extends StatelessWidget {
  final PosOrder order;

  const _OrderCardDetails({required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(height: 1, color: _DS.border),
        const SizedBox(height: 14),
        // Items header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: _DS.bg,
            borderRadius: _DS.r8,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text('Item',
                    style: _itemHeaderStyle),
              ),
              Text('Qty', style: _itemHeaderStyle),
              const SizedBox(width: 20),
              SizedBox(
                width: 80,
                child: Text('Amount',
                    textAlign: TextAlign.right,
                    style: _itemHeaderStyle),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Line items
        ...order.lines.map((line) => Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 4, right: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            line.itemName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _DS.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _DS.bg,
                      borderRadius: _DS.r8,
                    ),
                    child: Text(
                      '×${line.qty}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _DS.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 80,
                    child: Text(
                      '₹${line.lineTotal.toStringAsFixed(0)}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _DS.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            )),
        Container(height: 1, color: _DS.border),
        const SizedBox(height: 12),
        // Subtotal & GST
        _TotalsRow(label: 'Subtotal', value: '₹${order.subtotal.toStringAsFixed(0)}'),
        const SizedBox(height: 8),
        _TotalsRow(
          label: 'GST (5%)',
          value: '₹${order.gstAmount.toStringAsFixed(0)}',
          valueColor: const Color(0xFF64748B),
        ),
        const SizedBox(height: 12),
        // Grand total
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: _DS.gradGreen,
            borderRadius: _DS.r12,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF22C55E).withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                '₹${order.total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  static const _itemHeaderStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: _DS.textMuted,
    letterSpacing: 0.5,
  );
}

class _TotalsRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _TotalsRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _DS.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor ?? _DS.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool outlined;
  final bool filled;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.outlined = false,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: filled ? _DS.gradGreen : null,
          color: outlined ? _DS.bg : (filled ? null : _DS.bg),
          border: outlined ? Border.all(color: _DS.border, width: 1.5) : null,
          borderRadius: _DS.r10,
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: filled ? Colors.white : _DS.textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: filled ? Colors.white : _DS.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAYMENT BADGE
// ─────────────────────────────────────────────────────────────────────────────
class _PaymentBadge extends StatelessWidget {
  final PosPaymentMode mode;

  const _PaymentBadge({required this.mode});

  @override
  Widget build(BuildContext context) {
    final isCash = mode == PosPaymentMode.cash;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isCash
            ? const Color(0xFFFEF3C7)
            : const Color(0xFFEFF6FF),
        borderRadius: _DS.r8,
        border: Border.all(
          color: isCash
              ? const Color(0xFFFBBF24).withValues(alpha: 0.5)
              : const Color(0xFF93C5FD).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCash ? Icons.payments_rounded : Icons.phone_iphone_rounded,
            size: 10,
            color: isCash ? const Color(0xFFB45309) : const Color(0xFF1D4ED8),
          ),
          const SizedBox(width: 3),
          Text(
            isCash ? 'CASH' : 'ONLINE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              color: isCash ? const Color(0xFFB45309) : const Color(0xFF1D4ED8),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool hasFilters;

  const _EmptyState({required this.hasFilters});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: _DS.bg,
              shape: BoxShape.circle,
              border: Border.all(color: _DS.border, width: 2),
            ),
            child: Icon(
              hasFilters ? Icons.search_off_rounded : Icons.receipt_long_outlined,
              size: 38,
              color: _DS.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            hasFilters ? 'No bills found' : 'No bills yet',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _DS.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Try adjusting your search or filters'
                : 'Bills will appear here once orders are created',
            style: const TextStyle(
              fontSize: 13,
              color: _DS.textMuted,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOADING STATE
// ─────────────────────────────────────────────────────────────────────────────
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: _DS.gradGreen,
              borderRadius: _DS.r16,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading bills…',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _DS.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}