import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static int getGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1700) return 6;
    if (width >= 1400) return 5;
    if (width >= 1100) return 4;
    if (width >= 800) return 3;
    if (width >= 600) return 2;
    return 1;
  }

  static double getCartWidth(BuildContext context) {
    if (isMobile(context)) return MediaQuery.of(context).size.width;
    if (isTablet(context)) return 320;
    return 360;
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isMobile(context)) return const EdgeInsets.all(12);
    if (isTablet(context)) return const EdgeInsets.all(16);
    return const EdgeInsets.all(20);
  }

  static double getFontScale(BuildContext context) {
    if (isMobile(context)) return 0.9;
    return 1.0;
  }
}
