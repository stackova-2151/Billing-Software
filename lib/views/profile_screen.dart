import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header with Gradient
            Container(
              width: double.infinity,
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Profile Image
                    _ProfileImageSection(controller: controller),
                    const SizedBox(height: 20),
                    // Name
                    Obx(
                      () => Text(
                        controller.name.value.isEmpty
                            ? 'User Name'
                            : controller.name.value,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Role
                    const Text(
                      'Restaurant Owner',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color.fromARGB(255, 4, 10, 0),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Form Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isWide ? 600 : 500),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Name Field
                        Obx(
                          () => _ProfileField(
                            label: 'Name',
                            value: controller.name.value,
                            onChanged: (val) => controller.name(val),
                            icon: Icons.person_outline,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Phone Field
                        Obx(
                          () => _ProfileField(
                            label: 'Phone',
                            value: controller.phone.value,
                            onChanged: (val) => controller.phone(val),
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Email Field (read-only)
                        Obx(
                          () => _ProfileField(
                            label: 'Email',
                            value: controller.email.value,
                            onChanged: null,
                            icon: Icons.lock_outline,
                            readOnly: true,
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Save Button
                        Obx(
                          () => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7ED957), Color(0xFF5FB83A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF7ED957).withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : controller.saveProfile,
                              icon: controller.isLoading.value
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.save_outlined, size: 20),
                              label: Text(
                                controller.isLoading.value
                                    ? 'Saving...'
                                    : 'Save Profile',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileImageSection extends StatelessWidget {
  final ProfileController controller;

  const _ProfileImageSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundColor: const Color(0xFFE8F5E0),
            backgroundImage: _buildImageProvider(),
            child: _buildPlaceholder(),
          ),
        ),
        GestureDetector(
          onTap: controller.pickProfileImage,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.camera_alt, color: Color(0xFF7ED957), size: 20),
          ),
        ),
      ],
    );
  }

  ImageProvider? _buildImageProvider() {
    if (kIsWeb && controller.profileImageUrl.value.isNotEmpty) {
      return NetworkImage(controller.profileImageUrl.value);
    }
    if (!kIsWeb && controller.profileImageFile.value != null) {
      return FileImage(controller.profileImageFile.value!);
    }
    return null;
  }

  Widget? _buildPlaceholder() {
    if (kIsWeb && controller.profileImageUrl.value.isNotEmpty) return null;
    if (!kIsWeb && controller.profileImageFile.value != null) return null;
    return const Icon(Icons.person, color: Color(0xFF7ED957), size: 48);
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String>? onChanged;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool readOnly;

  const _ProfileField({
    required this.label,
    required this.value,
    required this.icon,
    this.onChanged,
    this.keyboardType,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: TextEditingController(text: value)
          ..selection = TextSelection.fromPosition(
            TextPosition(offset: value.length),
          ),
        onChanged: onChanged,
        keyboardType: keyboardType,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: readOnly ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(right: 12),
            child: Icon(
              icon,
              color: readOnly ? const Color(0xFF9CA3AF) : const Color(0xFF7ED957),
              size: 20,
            ),
          ),
          filled: true,
          fillColor: readOnly ? const Color(0xFFF9FAFB) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF7ED957), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: readOnly ? const Color(0xFF9CA3AF) : const Color(0xFF111827),
        ),
      ),
    );
  }
}
