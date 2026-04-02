import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../bindings/app_bindings.dart';
import '../services/auth_service.dart';
import '../views/login_screen.dart';
import '../views/pos_screen.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<User> user = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_authService.authStateChanges);
    ever(user, _handleAuthChange);
  }

  void _handleAuthChange(User? u) {
    if (u == null) {
      Get.offAll(() => const LoginScreen());
    } else {
      Get.offAll(() => const PosScreen(), binding: AppBindings());
    }
  }

  Future<void> signIn(String email, String password) async {
    errorMessage.value = '';
    isLoading.value = true;
    try {
      await _authService.signIn(email.trim(), password.trim());
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp(String email, String password) async {
    errorMessage.value = '';
    isLoading.value = true;
    try {
      await _authService.signUp(email.trim(), password.trim());
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> resetPassword(String email) async {
    errorMessage.value = '';
    isLoading.value = true;
    try {
      await _authService.resetPassword(email.trim());
      Get.snackbar('Email Sent', 'Password reset email sent to $email',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
