import 'package:flutter/material.dart';

import '../controllers/app_screen_controller.dart';

class SidebarWidget extends StatelessWidget {
  final String appName;
  final AppScreenType activeSection;
  final VoidCallback onDashboardTap;
  final VoidCallback onPosTap;
  final VoidCallback onMenuItemsTap;
  final VoidCallback onBillsHistoryTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onLogoutTap;

  const SidebarWidget({
    super.key,
    required this.appName,
    required this.activeSection,
    required this.onDashboardTap,
    required this.onPosTap,
    required this.onMenuItemsTap,
    required this.onBillsHistoryTap,
    required this.onSettingsTap,
    required this.onLogoutTap,
  });

  static const Color sidebarBg = Color(0xFFF5F7F4);
  static const Color activeBg = Color(0xFFDFF5D8);
  static const Color textColor = Color(0xFF2E2E2E);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 220,
      color: sidebarBg,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFF7ED957),
                  child: Icon(Icons.restaurant, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    appName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _NavItem(
            label: 'Dashboard',
            icon: Icons.dashboard_outlined,
            active: activeSection == AppScreenType.dashboard,
            onTap: onDashboardTap,
          ),
          const SizedBox(height: 8),
          _NavItem(
            label: 'Point of Sale',
            icon: Icons.point_of_sale_outlined,
            active: activeSection == AppScreenType.pos,
            onTap: onPosTap,
          ),
          const SizedBox(height: 8),
          _NavItem(
            label: 'Menu Items',
            icon: Icons.restaurant_menu,
            active: activeSection == AppScreenType.menuItems,
            onTap: onMenuItemsTap,
          ),
          const SizedBox(height: 8),
          _NavItem(
            label: 'Bills History',
            icon: Icons.receipt_long_outlined,
            active: activeSection == AppScreenType.billsHistory,
            onTap: onBillsHistoryTap,
          ),
          const SizedBox(height: 8),
          _NavItem(
            label: 'Settings',
            icon: Icons.settings_outlined,
            active: activeSection == AppScreenType.settings,
            onTap: onSettingsTap,
          ),
          const Spacer(),
          _NavItem(
            label: 'Logout',
            icon: Icons.logout,
            active: false,
            onTap: onLogoutTap,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: active ? SidebarWidget.activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, color: SidebarWidget.textColor, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: active ? FontWeight.w900 : FontWeight.w700,
                    color: SidebarWidget.textColor,
                  ),
                ),
              ),
              if (active)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF7ED957),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
