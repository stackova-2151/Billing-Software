import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  final RxString name = ''.obs;
  final RxString phone = ''.obs;
  final RxString email = ''.obs;
  final RxString profileImageUrl = ''.obs;
  final Rx<File?> profileImageFile = Rx<File?>(null);
  final RxBool isLoading = false.obs;

  void _log(String message) {
    debugPrint('[ProfileController] $message');
  }

  void setInitialData({
    required String name,
    required String phone,
    required String email,
    required String profileImageUrl,
  }) {
    _log('setInitialData called');
    this.name.value = name;
    this.phone.value = phone;
    this.email.value = email;
    this.profileImageUrl.value = profileImageUrl;
    _log(
      'Initial data set: name=$name, phone=$phone, email=$email, profileImageUrl=$profileImageUrl',
    );
  }

  Future<void> pickProfileImage() async {
    _log('pickProfileImage called');
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) {
        _log('User cancelled image picker');
        return;
      }

      if (kIsWeb) {
        profileImageUrl.value = image.path;
        _log('Web: profileImageUrl updated to ${image.path}');
      } else {
        final file = File(image.path);
        profileImageFile.value = file;
        _log('Mobile: profileImageFile updated to ${file.path}');
      }
    } catch (e, st) {
      _log('ERROR: pickProfileImage failed: $e');
      _log('ERROR: StackTrace: $st');
      Get.snackbar(
        'Error',
        'Failed to pick image',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  bool validateInputs() {
    final nameValid = name.value.trim().isNotEmpty;
    final phoneValid = RegExp(r'^\d{10,15}$').hasMatch(phone.value.trim());
    _log('validateInputs: nameValid=$nameValid, phoneValid=$phoneValid');
    return nameValid && phoneValid;
  }

  Future<void> saveProfile() async {
    _log('saveProfile called');
    if (!validateInputs()) {
      _log('Validation failed');
      Get.snackbar(
        'Validation Error',
        'Name is required and phone must be 10-15 digits',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    _log('isLoading set to true');

    final payload = <String, dynamic>{
      'name': name.value.trim(),
      'phone': phone.value.trim(),
      'email': email.value.trim(),
      if (kIsWeb && profileImageUrl.value.isNotEmpty)
        'profileImageUrl': profileImageUrl.value,
      if (!kIsWeb && profileImageFile.value != null)
        'profileImage': profileImageFile.value!.path,
    };
    _log('API: Request payload=$payload');

    try {
      // Simulated API call; replace with real endpoint
      await Future.delayed(const Duration(seconds: 1));

      _log('API: Simulated success response');
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, st) {
      _log('ERROR: saveProfile failed: $e');
      _log('ERROR: StackTrace: $st');
      Get.snackbar(
        'Error',
        'Failed to update profile',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      _log('isLoading set to false');
    }
  }

  void clearProfileImage() {
    _log('clearProfileImage called');
    profileImageFile.value = null;
    profileImageUrl.value = '';
    _log('Profile image cleared');
  }
}
