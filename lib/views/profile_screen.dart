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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2E2E2E),
        elevation: 1,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWide ? 600 : 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Profile Image
                    _ProfileImageSection(controller: controller),
                    const SizedBox(height: 32),
                    // Name Field
                    Obx(
                      () => _ProfileField(
                        label: 'Name',
                        value: controller.name.value,
                        onChanged: (val) => controller.name(val),
                        icon: Icons.person,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Phone Field
                    Obx(
                      () => _ProfileField(
                        label: 'Phone',
                        value: controller.phone.value,
                        onChanged: (val) => controller.phone(val),
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Email Field (read-only for now)
                    Obx(
                      () => _ProfileField(
                        label: 'Email',
                        value: controller.email.value,
                        onChanged: null,
                        icon: Icons.email,
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Save Button
                    Obx(
                      () => ElevatedButton.icon(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.saveProfile,
                        icon: controller.isLoading.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          controller.isLoading.value
                              ? 'Saving...'
                              : 'Save Profile',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7ED957),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
        CircleAvatar(
          radius: 60,
          backgroundColor: const Color(0xFFE5E5E5),
          backgroundImage: _buildImageProvider(),
          child: _buildPlaceholder(),
        ),
        GestureDetector(
          onTap: controller.pickProfileImage,
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFF7ED957),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
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
    return const Icon(Icons.person, color: Colors.white, size: 40);
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
    final theme = Theme.of(context);
    return TextField(
      controller: TextEditingController(text: value)
        ..selection = TextSelection.fromPosition(
          TextPosition(offset: value.length),
        ),
      onChanged: onChanged,
      keyboardType: keyboardType,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: readOnly ? const Color(0xFFF5F5F5) : const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7ED957), width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: readOnly ? const Color(0xFF9E9E9E) : const Color(0xFF2E2E2E),
      ),
    );
  }
}
