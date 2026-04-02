import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
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

  User? get _firebaseUser => FirebaseAuth.instance.currentUser;

  @override
  void onInit() {
    super.onInit();
    _loadFromFirebase();
  }

  void _loadFromFirebase() {
    final user = _firebaseUser;
    if (user == null) return;
    name.value = user.displayName ?? '';
    email.value = user.email ?? '';
    profileImageUrl.value = user.photoURL ?? '';
    // phone is not stored in FirebaseAuth by default, keep empty until user fills it
    phone.value = user.phoneNumber ?? '';
  }

  Future<void> pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      if (kIsWeb) {
        profileImageUrl.value = image.path;
      } else {
        profileImageFile.value = File(image.path);
      }
    } catch (e) {
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
    return nameValid && phoneValid;
  }

  Future<void> saveProfile() async {
    if (!validateInputs()) {
      Get.snackbar(
        'Validation Error',
        'Name is required and phone must be 10-15 digits',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      await _firebaseUser?.updateDisplayName(name.value.trim());
      // Reload so currentUser reflects the update
      await _firebaseUser?.reload();
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearProfileImage() {
    profileImageFile.value = null;
    profileImageUrl.value = '';
  }
}
