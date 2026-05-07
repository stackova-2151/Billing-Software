import 'package:get/get.dart';
import '../models/pos_order.dart';
import '../models/report_data.dart';
import '../services/report_service.dart';

class ReportController extends GetxController {
  final ReportService _reportService = ReportService();

  final isLoading = false.obs;
  final selectedDateRange = DateRangeType.week.obs;
  final selectedReportType = ReportType.sales.obs;
  final startDate = DateTime.now().obs;
  final endDate = DateTime.now().obs;
  
  // Pagination
  final currentPage = 1.obs;
  final itemsPerPage = 10;

  final orders = <PosOrder>[].obs;
  final summary = ReportSummary.empty().obs;
  final salesTrend = <SalesTrendData>[].obs;
  final paymentBreakdown = Rx<PaymentBreakdown>(
    const PaymentBreakdown(cashAmount: 0, onlineAmount: 0),
  );
  final topItems = <TopItemData>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeDates();
    fetchReportData();
  }

  void _initializeDates() {
    final now = DateTime.now();
    // Default to last 7 days
    startDate.value = now.subtract(const Duration(days: 6));
    endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  void setDateRange(DateRangeType type) {
    selectedDateRange.value = type;
    currentPage.value = 1; // Reset to first page
    final now = DateTime.now();

    switch (type) {
      case DateRangeType.week:
        // Last 7 days
        startDate.value = now.subtract(const Duration(days: 6));
        endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case DateRangeType.month:
        // Current month
        startDate.value = DateTime(now.year, now.month, 1);
        endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case DateRangeType.year:
        // Current year
        startDate.value = DateTime(now.year, 1, 1);
        endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
    }

    fetchReportData();
  }

  void setReportType(ReportType type) {
    selectedReportType.value = type;
  }

  Future<void> fetchReportData() async {
    try {
      isLoading.value = true;

      final fetchedOrders = await _reportService.getOrdersByDateRange(
        startDate.value,
        endDate.value,
      );

      orders.value = fetchedOrders;
      summary.value = _reportService.calculateSummary(fetchedOrders);
      salesTrend.value = _reportService.calculateSalesTrend(
        fetchedOrders,
        selectedDateRange.value,
      );
      paymentBreakdown.value = _reportService.calculatePaymentBreakdown(fetchedOrders);
      topItems.value = _reportService.calculateTopItems(fetchedOrders);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch report data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void refresh() {
    currentPage.value = 1; // Reset to first page
    fetchReportData();
  }
  
  void setPage(int page) {
    currentPage.value = page;
  }
}
