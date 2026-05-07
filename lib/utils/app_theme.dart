import 'package:flutter/material.dart';

/// Premium Design System for Restaurant POS
class AppColors {
  // Primary Brand Colors
  static const primary = Color(0xFF6366F1); // Indigo
  static const primaryDark = Color(0xFF4F46E5);
  static const primaryLight = Color(0xFFEEF2FF);
  
  // Secondary Colors
  static const secondary = Color(0xFF0F172A); // Dark slate
  static const secondaryLight = Color(0xFF334155);
  static const secondaryMuted = Color(0xFF64748B);
  
  // Background & Surface
  static const background = Color(0xFFF8FAFC);
  static const surface = Colors.white;
  static const surfaceHover = Color(0xFFFAFAFA);
  
  // Accent Colors (for metrics)
  static const accentBlue = Color(0xFF2563EB);
  static const accentGreen = Color(0xFF16A34A);
  static const accentOrange = Color(0xFFF59E0B);
  static const accentPurple = Color(0xFF7C3AED);
  static const accentRed = Color(0xFFDC2626);
  
  // Neutral Grays
  static const gray50 = Color(0xFFF8FAFC);
  static const gray100 = Color(0xFFF1F5F9);
  static const gray200 = Color(0xFFE5E7EB);
  static const gray300 = Color(0xFFD1D5DB);
  
  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const successGradient = LinearGradient(
    colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppShadows {
  static const card = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 16,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x05000000),
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
  
  static const cardHover = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
}

class AppDurations {
  static const fast = Duration(milliseconds: 200);
  static const normal = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 500);
  static const countAnimation = Duration(milliseconds: 1200);
  static const chartAnimation = Duration(milliseconds: 1000);
  static const pageLoad = Duration(milliseconds: 600);
}

class AppCurves {
  static const smooth = Curves.easeInOutCubic;
  static const bounce = Curves.easeOutBack;
  static const spring = Curves.elasticOut;
}
