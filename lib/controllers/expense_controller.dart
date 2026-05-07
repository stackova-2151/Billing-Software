import 'package:get/get.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

class ExpenseController extends GetxController {
  final ExpenseService _expenseService = ExpenseService();
  
  final RxList<Expense> expenses = <Expense>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadExpenses();
  }

  void _loadExpenses() {
    _expenseService.getExpensesStream().listen(
      (data) {
        expenses.value = data;
        isLoading.value = false;
      },
      onError: (error) {
        errorMessage.value = error.toString();
        isLoading.value = false;
      },
    );
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required DateTime date,
    String note = '',
  }) async {
    try {
      if (title.trim().isEmpty) {
        throw Exception('Title is required');
      }
      
      if (amount <= 0) {
        throw Exception('Amount must be greater than 0');
      }
      
      isLoading.value = true;
      errorMessage.value = '';
      
      final expense = Expense(
        id: '',
        title: title.trim(),
        amount: amount,
        date: date,
        note: note.trim(),
        createdAt: DateTime.now(),
      );
      
      await _expenseService.addExpense(expense);
      
      Get.back();
      Get.snackbar(
        'Success',
        'Expense added successfully',
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

  Future<void> updateExpense({
    required String id,
    required String title,
    required double amount,
    required DateTime date,
    required DateTime createdAt,
    String note = '',
  }) async {
    try {
      if (title.trim().isEmpty) {
        throw Exception('Title is required');
      }
      
      if (amount <= 0) {
        throw Exception('Amount must be greater than 0');
      }
      
      isLoading.value = true;
      errorMessage.value = '';
      
      final expense = Expense(
        id: id,
        title: title.trim(),
        amount: amount,
        date: date,
        note: note.trim(),
        createdAt: createdAt,
      );
      
      await _expenseService.updateExpense(expense);
      
      Get.back();
      Get.snackbar(
        'Success',
        'Expense updated successfully',
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

  Future<void> deleteExpense(String id) async {
    try {
      isLoading.value = true;
      await _expenseService.deleteExpense(id);
      Get.back();
      Get.snackbar(
        'Success',
        'Expense deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  double get totalExpenses => 
      expenses.fold(0, (sum, expense) => sum + expense.amount);
}
