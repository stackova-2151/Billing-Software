import 'package:get/get.dart';
import '../models/menu_item.dart';
import '../services/stock_service.dart';

class StockController extends GetxController {
  final StockService _stockService = StockService();
  
  final RxList<MenuItem> items = <MenuItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadStock();
  }

  void _loadStock() {
    _stockService.getStockStream().listen(
      (data) {
        items.value = data;
        isLoading.value = false;
      },
      onError: (error) {
        errorMessage.value = error.toString();
        isLoading.value = false;
      },
    );
  }

  Future<void> updateStock({
    required String itemId,
    required int addedQuantity,
    int? lowStockThreshold,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      await _stockService.updateStock(
        itemId: itemId,
        addedQuantity: addedQuantity,
        lowStockThreshold: lowStockThreshold,
      );
      
      Get.back();
      Get.snackbar(
        'Success',
        'Stock updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setStock({
    required String itemId,
    required int stockQuantity,
    required int lowStockThreshold,
  }) async {
    try {
      if (stockQuantity < 0) {
        throw Exception('Stock quantity cannot be negative');
      }
      
      if (lowStockThreshold < 0) {
        throw Exception('Low stock threshold cannot be negative');
      }
      
      isLoading.value = true;
      errorMessage.value = '';
      
      await _stockService.setStock(
        itemId: itemId,
        stockQuantity: stockQuantity,
        lowStockThreshold: lowStockThreshold,
      );
      
      Get.back();
      Get.snackbar(
        'Success',
        'Stock updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStockItem({
    required String itemId,
    required String itemCode,
    required String itemName,
    required String category,
    required int stockQuantity,
    required int lowStockThreshold,
  }) async {
    try {
      if (itemName.trim().isEmpty) {
        throw Exception('Item name cannot be empty');
      }
      
      if (stockQuantity < 0) {
        throw Exception('Stock quantity cannot be negative');
      }
      
      if (lowStockThreshold < 0) {
        throw Exception('Low stock threshold cannot be negative');
      }
      
      isLoading.value = true;
      errorMessage.value = '';
      
      await _stockService.updateStockItem(
        itemId: itemId,
        itemCode: itemCode,
        itemName: itemName,
        category: category,
        stockQuantity: stockQuantity,
        lowStockThreshold: lowStockThreshold,
      );
      
      Get.back();
      Get.snackbar(
        'Success',
        'Item updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<MenuItem> get lowStockItems => 
      items.where((item) => item.stockStatus == 'LOW_STOCK').toList();

  List<MenuItem> get outOfStockItems => 
      items.where((item) => item.stockStatus == 'OUT_OF_STOCK').toList();

  List<MenuItem> get inStockItems => 
      items.where((item) => item.stockStatus == 'IN_STOCK').toList();
}
