import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/report_controller.dart';
import '../models/report_data.dart';
import '../models/pos_order.dart';
import '../theme/app_colors.dart';
import '../utils/report_pdf_generator.dart';
import '../widgets/reports/summary_card.dart';
import '../widgets/reports/sales_trend_chart.dart';
import '../widgets/reports/payment_breakdown_chart.dart';
import '../widgets/reports/top_items_chart.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReportController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return CustomScrollView(
          slivers: [
            _buildAppBar(controller),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildFilterSection(controller, context),
                  const SizedBox(height: 24),
                  _buildSummaryCards(controller),
                  const SizedBox(height: 24),
                  _buildChartsSection(controller),
                  const SizedBox(height: 24),
                  _buildOrdersTable(controller),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildAppBar(ReportController controller) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      title: const Text(
        'Reports & Analytics',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.primary),
          onPressed: controller.refresh,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: ElevatedButton.icon(
            onPressed: () => _exportPdf(controller),
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Export PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection(ReportController controller, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildDateRangeChip(
                controller,
                'Last 7 Days',
                DateRangeType.week,
              ),
              _buildDateRangeChip(
                controller,
                'Month',
                DateRangeType.month,
              ),
              _buildDateRangeChip(
                controller,
                'Year',
                DateRangeType.year,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeChip(
    ReportController controller,
    String label,
    DateRangeType type,
  ) {
    return Obx(() {
      final isSelected = controller.selectedDateRange.value == type;
      return FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => controller.setDateRange(type),
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
      );
    });
  }

  Widget _buildSummaryCards(ReportController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200
            ? 4
            : constraints.maxWidth > 800
                ? 2
                : 1;

        return Obx(() {
          final summary = controller.summary.value;
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.8,
            children: [
              SummaryCard(
                title: 'Total Sales',
                value: summary.totalSales,
                icon: Icons.currency_rupee,
                gradient: AppColors.successGradient,
                prefix: '₹',
                decimals: 2,
              ),
              SummaryCard(
                title: 'Total Orders',
                value: summary.totalOrders.toDouble(),
                icon: Icons.shopping_cart,
                gradient: AppColors.primaryGradient,
              ),
              SummaryCard(
                title: 'Avg Order Value',
                value: summary.avgOrderValue,
                icon: Icons.trending_up,
                gradient: AppColors.warningGradient,
                prefix: '₹',
                decimals: 2,
              ),
              SummaryCard(
                title: 'Customers',
                value: summary.totalCustomers.toDouble(),
                icon: Icons.people,
                gradient: AppColors.infoGradient,
              ),
            ],
          );
        });
      },
    );
  }

  Widget _buildChartsSection(ReportController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;

        return Obx(() {
          if (isMobile) {
            return Column(
              children: [
                _buildChartCard(
                  'Sales Trend',
                  SalesTrendChart(data: controller.salesTrend),
                  height: 300,
                ),
                const SizedBox(height: 16),
                _buildChartCard(
                  'Payment Breakdown',
                  PaymentBreakdownChart(data: controller.paymentBreakdown.value),
                  height: 300,
                ),
                const SizedBox(height: 16),
                _buildChartCard(
                  'Top Items',
                  TopItemsChart(data: controller.topItems),
                  height: 300,
                ),
              ],
            );
          }

          return Column(
            children: [
              _buildChartCard(
                'Sales Trend',
                SalesTrendChart(data: controller.salesTrend),
                height: 350,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildChartCard(
                      'Payment Breakdown',
                      PaymentBreakdownChart(data: controller.paymentBreakdown.value),
                      height: 350,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildChartCard(
                      'Top Items',
                      TopItemsChart(data: controller.topItems),
                      height: 350,
                    ),
                  ),
                ],
              ),
            ],
          );
        });
      },
    );
  }

  Widget _buildChartCard(String title, Widget chart, {double height = 300}) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: chart),
        ],
      ),
    );
  }

  Widget _buildOrdersTable(ReportController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Obx(() {
          final allOrders = controller.orders;
          final currentPage = controller.currentPage.value;
          final itemsPerPage = controller.itemsPerPage;
          final totalPages = (allOrders.length / itemsPerPage).ceil();
          
          // Calculate pagination
          final startIndex = (currentPage - 1) * itemsPerPage;
          final endIndex = (startIndex + itemsPerPage).clamp(0, allOrders.length);
          final paginatedOrders = allOrders.sublist(
            startIndex.clamp(0, allOrders.length),
            endIndex,
          );

          if (allOrders.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.small,
              ),
              child: const Center(
                child: Text(
                  'No orders found',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            );
          }

          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.small,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Orders',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Showing ${startIndex + 1}-${endIndex} of ${allOrders.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth - 40,
                      ),
                      child: DataTable(
                        columnSpacing: 24,
                        headingRowColor: WidgetStateProperty.all(AppColors.surfaceVariant),
                        columns: const [
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Order ID',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Date & Time',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Amount',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Payment',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Customer',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Table No',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                        rows: paginatedOrders.map((order) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  _formatOrderId(order.id),
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              DataCell(Text(DateFormat('dd/MM/yy HH:mm').format(order.createdAt))),
                              DataCell(Text('₹${order.total.toStringAsFixed(2)}')),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: order.paymentMode == PosPaymentMode.cash
                                        ? AppColors.successBg
                                        : AppColors.infoBg,
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                  child: Text(
                                    order.paymentMode.name.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: order.paymentMode == PosPaymentMode.cash
                                          ? AppColors.success
                                          : AppColors.info,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(Text(order.customerName.isEmpty ? '-' : order.customerName)),
                              DataCell(Text(order.tableNo.isEmpty ? '-' : order.tableNo)),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                if (totalPages > 1) _buildPagination(controller, totalPages),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildPagination(ReportController controller, int totalPages) {
    return Obx(() {
      final currentPage = controller.currentPage.value;
      
      return Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Previous button
            IconButton(
              onPressed: currentPage > 1
                  ? () => controller.setPage(currentPage - 1)
                  : null,
              icon: const Icon(Icons.chevron_left),
              style: IconButton.styleFrom(
                backgroundColor: currentPage > 1
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                foregroundColor: currentPage > 1
                    ? AppColors.primary
                    : Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            
            // Page numbers
            ..._buildPageNumbers(currentPage, totalPages, controller),
            
            const SizedBox(width: 8),
            // Next button
            IconButton(
              onPressed: currentPage < totalPages
                  ? () => controller.setPage(currentPage + 1)
                  : null,
              icon: const Icon(Icons.chevron_right),
              style: IconButton.styleFrom(
                backgroundColor: currentPage < totalPages
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                foregroundColor: currentPage < totalPages
                    ? AppColors.primary
                    : Colors.grey,
              ),
            ),
          ],
        ),
      );
    });
  }

  List<Widget> _buildPageNumbers(int currentPage, int totalPages, ReportController controller) {
    List<Widget> pages = [];
    
    // Show max 5 page numbers
    int start = (currentPage - 2).clamp(1, totalPages);
    int end = (start + 4).clamp(1, totalPages);
    
    // Adjust start if we're near the end
    if (end == totalPages && totalPages > 5) {
      start = (totalPages - 4).clamp(1, totalPages);
    }
    
    for (int i = start; i <= end; i++) {
      pages.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: InkWell(
            onTap: () => controller.setPage(i),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: i == currentPage
                    ? AppColors.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: i == currentPage
                      ? AppColors.primary
                      : AppColors.border,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                i.toString(),
                style: TextStyle(
                  color: i == currentPage
                      ? Colors.white
                      : AppColors.textPrimary,
                  fontWeight: i == currentPage
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    return pages;
  }

  String _formatOrderId(String id) {
    // If ID is a Firebase document ID (long alphanumeric), format it nicely
    if (id.length > 12) {
      return 'ORD-${id.substring(id.length - 8).toUpperCase()}';
    }
    // If it's already a short ID, return as is
    return id;
  }

  Future<void> _exportPdf(ReportController controller) async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        barrierDismissible: false,
      );

      await ReportPdfGenerator.generateAndDownload(
        shopName: 'My Shop',
        startDate: controller.startDate.value,
        endDate: controller.endDate.value,
        summary: controller.summary.value,
        orders: controller.orders,
        paymentBreakdown: controller.paymentBreakdown.value,
        topItems: controller.topItems,
      );

      Get.back();
      Get.snackbar(
        'Success',
        'Report exported successfully',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Failed to export report: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }
}
