// Example of how to use the improved SalesTrendChart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/report_controller.dart';
import '../../models/report_data.dart';
import 'sales_trend_chart.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportController>();

    return Scaffold(
      body: Obx(() {
        return SalesTrendChart(
          data: controller.salesTrend.value,
          isLoading: controller.isLoading.value,
        );
      }),
    );
  }
}

// Example controller method to safely load data
extension ReportControllerSafe on ReportController {
  Future<void> loadSalesTrendSafely() async {
    try {
      isLoading.value = true;
      
      // Fetch data using existing method
      await fetchReportData();
      
      // Validate and sanitize data
      final validData = salesTrend
          .where((item) => 
            item.amount.isFinite && 
            !item.amount.isNaN && 
            item.amount >= 0
          )
          .toList();
      
      salesTrend.value = validData;
    } catch (e) {
      // Handle error gracefully
      salesTrend.value = [];
      Get.snackbar('Error', 'Failed to load sales data');
    } finally {
      isLoading.value = false;
    }
  }
}