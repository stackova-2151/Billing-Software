import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../utils/responsive_helper.dart';

/// Reusable Status Badge for displaying status indicators
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? backgroundColor;
  final double? fontSize;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.backgroundColor,
    this.fontSize,
  });

  factory StatusBadge.success(String label) {
    return StatusBadge(
      label: label,
      color: AppColors.success,
      backgroundColor: AppColors.successBg,
    );
  }

  factory StatusBadge.warning(String label) {
    return StatusBadge(
      label: label,
      color: AppColors.warning,
      backgroundColor: AppColors.warningBg,
    );
  }

  factory StatusBadge.error(String label) {
    return StatusBadge(
      label: label,
      color: AppColors.error,
      backgroundColor: AppColors.errorBg,
    );
  }

  factory StatusBadge.info(String label) {
    return StatusBadge(
      label: label,
      color: AppColors.info,
      backgroundColor: AppColors.infoBg,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.isMobile(context) ? 8 : 12,
        vertical: ResponsiveHelper.isMobile(context) ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getBorderRadius(context),
        ),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: fontSize ?? (ResponsiveHelper.isMobile(context) ? 11 : 12),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// Responsive Card that adapts to screen size
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool showBorder;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.backgroundColor,
    this.onTap,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding =
        padding ?? ResponsiveHelper.getCardPadding(context);
    final effectiveMargin = margin ?? EdgeInsets.zero;
    final effectiveBackgroundColor = backgroundColor ?? AppColors.surface;
    final borderRadius = ResponsiveHelper.getBorderRadius(context);

    return Container(
      width: width,
      margin: effectiveMargin,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(color: AppColors.border, width: 1)
            : null,
        boxShadow: AppShadows.small,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(padding: effectivePadding, child: child),
        ),
      ),
    );
  }
}

/// Mobile-friendly action row for card actions
class MobileActionRow extends StatelessWidget {
  final List<Widget> actions;
  final MainAxisAlignment mainAxisAlignment;

  const MobileActionRow({
    super.key,
    required this.actions,
    this.mainAxisAlignment = MainAxisAlignment.end,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: actions.map((action) {
        return Padding(padding: const EdgeInsets.only(left: 8), child: action);
      }).toList(),
    );
  }
}

/// Responsive Section Header
class ResponsiveSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<Widget>? actions;

  const ResponsiveSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: ResponsiveHelper.getIconSize(context),
              color: AppColors.primary,
            ),
            SizedBox(width: isMobile ? 8 : 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: isMobile ? 2 : 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actions != null) ...[
            SizedBox(width: isMobile ? 8 : 12),
            ...actions!,
          ],
        ],
      ),
    );
  }
}

/// Responsive Info Row for displaying key-value pairs
class ResponsiveInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;

  const ResponsiveInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 4 : 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: isMobile ? 16 : 18, color: AppColors.textTertiary),
            SizedBox(width: isMobile ? 6 : 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: isMobile ? 2 : 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Responsive Button with consistent styling
class ResponsiveButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isSecondary;
  final bool isDestructive;

  const ResponsiveButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.isSecondary = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final effectiveBackgroundColor =
        backgroundColor ??
        (isDestructive
            ? AppColors.error
            : isSecondary
            ? Colors.transparent
            : AppColors.primary);
    final effectiveForegroundColor =
        foregroundColor ?? (isSecondary ? AppColors.primary : Colors.white);

    return SizedBox(
      height: ResponsiveHelper.getButtonHeight(context),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null
            ? Icon(icon, size: isMobile ? 18 : 20)
            : const SizedBox.shrink(),
        label: Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBackgroundColor,
          foregroundColor: effectiveForegroundColor,
          elevation: isSecondary ? 0 : 2,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.getBorderRadius(context),
            ),
            side: isSecondary
                ? BorderSide(color: AppColors.primary)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
