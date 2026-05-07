import 'package:flutter/material.dart';

/// Premium Color System - SaaS Quality Design
class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF6366F1); // Indigo - Modern & Professional
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF0F172A); // Slate 900 - Dark Text
  static const Color secondaryLight = Color(0xFF1E293B); // Slate 800
  
  // Success (Green)
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color successLight = Color(0xFF34D399);
  static const Color successBg = Color(0xFFD1FAE5);
  
  // Warning (Amber)
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningBg = Color(0xFFFEF3C7);
  
  // Error (Red)
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorBg = Color(0xFFFEE2E2);
  
  // Info (Blue)
  static const Color info = Color(0xFF3B82F6); // Blue 500
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoBg = Color(0xFFDBEAFE);
  
  // Purple Accent
  static const Color purple = Color(0xFF8B5CF6); // Violet 500
  static const Color purpleLight = Color(0xFFA78BFA);
  static const Color purpleBg = Color(0xFFEDE9FE);
  
  // Background Colors
  static const Color background = Color(0xFFFAFAFA); // Neutral 50
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color surfaceVariant = Color(0xFFF8FAFC); // Slate 50
  
  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textTertiary = Color(0xFF94A3B8); // Slate 400
  static const Color textDisabled = Color(0xFFCBD5E1); // Slate 300
  
  // Border Colors
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color borderLight = Color(0xFFF1F5F9); // Slate 100
  static const Color borderDark = Color(0xFFCBD5E1); // Slate 300
  
  // Shadow Colors
  static const Color shadow = Color(0x0F000000); // 6% black
  static const Color shadowMedium = Color(0x1A000000); // 10% black
  static const Color shadowStrong = Color(0x29000000); // 16% black
  
  // Gradient Colors
  static LinearGradient primaryGradient = const LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient successGradient = const LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient warningGradient = const LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient infoGradient = const LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Premium Shadow System
class AppShadows {
  static const List<BoxShadow> small = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];
  
  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x05000000),
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
  ];
  
  static const List<BoxShadow> large = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];
  
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];
}

/// Premium Border Radius System
class AppRadius {
  static const double xs = 6.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 9999.0;
}

/// Premium Spacing System
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
}
