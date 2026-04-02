import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final RxBool _obscurePassword = true.obs;
  final RxBool _obscureConfirm = true.obs;

  AuthController get _auth => Get.find<AuthController>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _auth.signUp(_emailController.text, _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              children: [
                // Logo / Brand
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7ED957),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.restaurant,
                      color: Colors.white, size: 38),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Restro POS',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Create your account',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 36),
                // Card
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration(
                            label: 'Email',
                            icon: Icons.email_outlined,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!GetUtils.isEmail(v.trim())) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Password
                        Obx(() => TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword.value,
                              decoration: _inputDecoration(
                                label: 'Password',
                                icon: Icons.lock_outline,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscurePassword.value
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: const Color(0xFF64748B),
                                  ),
                                  onPressed: () => _obscurePassword.toggle(),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Password is required';
                                }
                                if (v.length < 6) {
                                  return 'Minimum 6 characters';
                                }
                                return null;
                              },
                            )),
                        const SizedBox(height: 16),
                        // Confirm Password
                        Obx(() => TextFormField(
                              controller: _confirmController,
                              obscureText: _obscureConfirm.value,
                              decoration: _inputDecoration(
                                label: 'Confirm Password',
                                icon: Icons.lock_outline,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscureConfirm.value
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: const Color(0xFF64748B),
                                  ),
                                  onPressed: () => _obscureConfirm.toggle(),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (v != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            )),
                        const SizedBox(height: 20),
                        // Error message
                        Obx(() {
                          final err = _auth.errorMessage.value;
                          if (err.isEmpty) return const SizedBox.shrink();
                          return Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: const Color(0xFFFCA5A5)),
                            ),
                            child: Text(
                              err,
                              style: const TextStyle(
                                color: Color(0xFFDC2626),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          );
                        }),
                        // Register button
                        Obx(() => SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF7ED957),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed:
                                    _auth.isLoading.value ? null : _submit,
                                child: _auth.isLoading.value
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Create Account',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Color(0xFF7ED957),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF64748B)),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
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
        borderSide: const BorderSide(color: Color(0xFF7ED957), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
