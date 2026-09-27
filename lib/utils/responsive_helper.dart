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

  static bool isSmallMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 360;

  static bool isLargeMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 360 && width < 600;
  }

  static double getWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static int getGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1700) return 6;
    if (width >= 1400) return 5;
    if (width >= 1100) return 4;
    if (width >= 800) return 3;
    if (width >= 600) return 2;
    return 1;
  }

  static int getPosGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1700) return 6;
    if (width >= 1400) return 5;
    if (width >= 1100) return 4;
    if (width >= 800) return 3;
    // Mobile: 2 columns for better space utilization
    if (width >= 360) return 2;
    // Very small phones: 1 column
    return 1;
  }

  static int getSummaryCardCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 4;
    if (width >= 860) return 2;
    // Mobile: 2 columns for 2x2 grid layout
    if (width >= 360) return 2;
    // Very small phones: 1 column
    return 1;
  }

  static int getReportsGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 4;
    if (width >= 800) return 3;
    if (width >= 600) return 2;
    // Mobile: 2 columns for 2x2 grid layout
    if (width >= 360) return 2;
    // Very small phones: 1 column
    return 1;
  }

  static double getCartWidth(BuildContext context) {
    if (isMobile(context)) return MediaQuery.of(context).size.width;
    if (isTablet(context)) return 320;
    return 360;
  }

  static double getDialogWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (isMobile(context)) return width * 0.95;
    if (isTablet(context)) return 600;
    return 700;
  }

  static double getDialogMaxWidth(BuildContext context) {
    if (isMobile(context)) return double.infinity;
    return 700;
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isMobile(context)) return const EdgeInsets.all(12);
    if (isTablet(context)) return const EdgeInsets.all(16);
    return const EdgeInsets.all(20);
  }

  static EdgeInsets getCardPadding(BuildContext context) {
    if (isMobile(context)) return const EdgeInsets.all(12);
    if (isTablet(context)) return const EdgeInsets.all(16);
    return const EdgeInsets.all(20);
  }

  static double getFontScale(BuildContext context) {
    if (isSmallMobile(context)) return 0.85;
    if (isMobile(context)) return 0.9;
    return 1.0;
  }

  static double getButtonHeight(BuildContext context) {
    if (isMobile(context)) return 44;
    return 48;
  }

  static double getIconSize(BuildContext context) {
    if (isMobile(context)) return 20;
    return 24;
  }

  static double getBorderRadius(BuildContext context) {
    if (isMobile(context)) return 12;
    return 16;
  }

  static bool shouldUseCardLayout(BuildContext context) {
    return isMobile(context) || isTablet(context);
  }

  static bool shouldUseTableLayout(BuildContext context) {
    return isDesktop(context);
  }
}
