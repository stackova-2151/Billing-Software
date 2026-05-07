# 🔗 Reports Module Integration Example

## How to Add Reports to Your Existing Navigation

### Step 1: Update AppScreenType Enum

**File:** `lib/controllers/app_screen_controller.dart`

```dart
enum AppScreenType {
  dashboard,
  pos,
  menuItems,
  billsHistory,
  reports,      // ← ADD THIS LINE
  settings,
  profile,
}
```

---

### Step 2: Update Sidebar Widget

**File:** `lib/widgets/sidebar_widget.dart`

#### 2a. Add callback parameter:
```dart
class SidebarWidget extends StatelessWidget {
  final String appName;
  final AppScreenType activeSection;
  final VoidCallback onDashboardTap;
  final VoidCallback onPosTap;
  final VoidCallback onMenuItemsTap;
  final VoidCallback onBillsHistoryTap;
  final VoidCallback onReportsTap;      // ← ADD THIS LINE
  final VoidCallback onSettingsTap;
  final VoidCallback onProfileTap;
  final VoidCallback onLogoutTap;

  const SidebarWidget({
    super.key,
    required this.appName,
    required this.activeSection,
    required this.onDashboardTap,
    required this.onPosTap,
    required this.onMenuItemsTap,
    required this.onBillsHistoryTap,
    required this.onReportsTap,          // ← ADD THIS LINE
    required this.onSettingsTap,
    required this.onProfileTap,
    required this.onLogoutTap,
  });
```

#### 2b. Add navigation item in build method:
```dart
// After Bills History item, add:
const SizedBox(height: 8),
_NavItem(
  label: 'Reports',
  icon: Icons.analytics_outlined,
  active: activeSection == AppScreenType.reports,
  onTap: onReportsTap,
),
```

---

### Step 3: Update Main Screen (Where Sidebar is Used)

**File:** `lib/views/pos_screen.dart` (or wherever you use SidebarWidget)

#### 3a. Import Reports Screen:
```dart
import '../views/reports_screen.dart';
```

#### 3b. Add callback in SidebarWidget:
```dart
SidebarWidget(
  appName: 'Your App',
  activeSection: controller.currentScreen.value,
  onDashboardTap: () => controller.setScreen(AppScreenType.dashboard),
  onPosTap: () => controller.setScreen(AppScreenType.pos),
  onMenuItemsTap: () => controller.setScreen(AppScreenType.menuItems),
  onBillsHistoryTap: () => controller.setScreen(AppScreenType.billsHistory),
  onReportsTap: () => controller.setScreen(AppScreenType.reports),  // ← ADD THIS
  onSettingsTap: () => controller.setScreen(AppScreenType.settings),
  onProfileTap: () => controller.setScreen(AppScreenType.profile),
  onLogoutTap: () => _handleLogout(),
)
```

#### 3c. Add Reports screen in body:
```dart
// In your screen switching logic:
Widget _buildBody() {
  switch (controller.currentScreen.value) {
    case AppScreenType.dashboard:
      return DashboardScreen();
    case AppScreenType.pos:
      return POSScreen();
    case AppScreenType.menuItems:
      return MenuManagementScreen();
    case AppScreenType.billsHistory:
      return BillHistoryScreen();
    case AppScreenType.reports:
      return const ReportsScreen();  // ← ADD THIS CASE
    case AppScreenType.settings:
      return SettingsScreen();
    case AppScreenType.profile:
      return ProfileScreen();
    default:
      return POSScreen();
  }
}
```

---

## Alternative: Direct Navigation (Simpler)

If you don't want to modify the existing navigation system, you can add a direct navigation button:

### Option 1: Add Button to Dashboard
```dart
// In your dashboard screen
ElevatedButton.icon(
  onPressed: () => Get.to(() => const ReportsScreen()),
  icon: const Icon(Icons.analytics),
  label: const Text('View Reports'),
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  ),
)
```

### Option 2: Add to App Bar Actions
```dart
// In your main screen's AppBar
AppBar(
  title: Text('POS System'),
  actions: [
    IconButton(
      icon: const Icon(Icons.analytics),
      onPressed: () => Get.to(() => const ReportsScreen()),
      tooltip: 'Reports',
    ),
  ],
)
```

### Option 3: Floating Action Button
```dart
// In your main screen
Scaffold(
  body: YourContent(),
  floatingActionButton: FloatingActionButton.extended(
    onPressed: () => Get.to(() => const ReportsScreen()),
    icon: const Icon(Icons.analytics),
    label: const Text('Reports'),
    backgroundColor: AppColors.primary,
  ),
)
```

---

## Complete Example: Modified Sidebar

Here's the complete modified sidebar with Reports:

```dart
import 'package:flutter/material.dart';
import '../controllers/app_screen_controller.dart';

class SidebarWidget extends StatelessWidget {
  final String appName;
  final AppScreenType activeSection;
  final VoidCallback onDashboardTap;
  final VoidCallback onPosTap;
  final VoidCallback onMenuItemsTap;
  final VoidCallback onBillsHistoryTap;
  final VoidCallback onReportsTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onProfileTap;
  final VoidCallback onLogoutTap;

  const SidebarWidget({
    super.key,
    required this.appName,
    required this.activeSection,
    required this.onDashboardTap,
    required this.onPosTap,
    required this.onMenuItemsTap,
    required this.onBillsHistoryTap,
    required this.onReportsTap,
    required this.onSettingsTap,
    required this.onProfileTap,
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
          // App Header
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
          
          // Navigation Items
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
          
          // ✨ NEW: Reports Item
          _NavItem(
            label: 'Reports',
            icon: Icons.analytics_outlined,
            active: activeSection == AppScreenType.reports,
            onTap: onReportsTap,
          ),
          const SizedBox(height: 8),
          
          _NavItem(
            label: 'Profile',
            icon: Icons.person_outline,
            active: activeSection == AppScreenType.profile,
            onTap: onProfileTap,
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
```

---

## Testing After Integration

1. **Run the app:**
   ```bash
   flutter run
   ```

2. **Click on "Reports" in sidebar**
   - Should navigate to Reports screen
   - Should show active state in sidebar

3. **Verify data loads**
   - Summary cards should show today's data
   - Charts should animate
   - Table should show recent orders

4. **Test navigation back**
   - Click other menu items
   - Should navigate away from Reports
   - Reports should lose active state

---

## Troubleshooting

### Issue: "onReportsTap is not defined"
**Fix:** Make sure you added the parameter in SidebarWidget constructor and passed it from parent

### Issue: "AppScreenType.reports doesn't exist"
**Fix:** Add `reports` to the enum in app_screen_controller.dart

### Issue: Reports screen shows but data doesn't load
**Fix:** Check Firebase connection and verify orders collection exists

---

## Summary of Changes

1. ✅ Add `reports` to `AppScreenType` enum
2. ✅ Add `onReportsTap` parameter to `SidebarWidget`
3. ✅ Add Reports navigation item in sidebar
4. ✅ Add Reports case in screen switching logic
5. ✅ Import `ReportsScreen` in parent widget

**That's it! Your Reports module is now fully integrated.** 🎉
