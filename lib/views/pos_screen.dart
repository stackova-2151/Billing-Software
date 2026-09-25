import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/cart_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/app_screen_controller.dart';
import '../controllers/menu_controller.dart' as pos;
import '../utils/responsive_helper.dart';
import '../widgets/cart_widget.dart';
import '../widgets/category_chips_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/item_card_widget.dart';
import '../widgets/menu_items_management_widget.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/sidebar_widget.dart';
import 'bill_history_screen.dart';
import 'pos_dashboard_view.dart';
import 'printer_screen.dart';
import 'profile_screen.dart';
import 'reports_screen.dart';
import 'stock_management_screen.dart';
import 'expense_management_screen.dart';

class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  // ── Design tokens ──────────────────────────────────────────────────────────
  static const Color pageBg = Color(0xFFF8F7FF);
  static const Color cardBg = Colors.white;
  static const Color borderColor = Color(0xFFEAE8FF);
  static const Color textDark = Color(0xFF1E1B3A);
  static const Color textMid = Color(0xFF6B6880);
  static const Color accent = Color(0xFF6C63FF);
  static const Color accentSoft = Color(0xFFF4F3FF);

  @override
  Widget build(BuildContext context) {
    final menuController = Get.find<pos.MenuController>();
    final cartController = Get.find<CartController>();
    final screenController = Get.find<AppScreenController>();
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: pageBg,
      // ── Mobile drawer (all pages) ──────────────────────────────────────────
      drawer: isMobile ? _MobileDrawer(screenController: screenController) : null,
      body: SafeArea(
        child: Row(
          children: [
            // ── Sidebar (desktop only) ──────────────────────────────────────
            if (!isMobile)
              Obx(() {
                final screen = screenController.currentScreen.value;
                return SidebarWidget(
                  appName: 'Restro POS',
                  activeSection: screen,
                  onDashboardTap: () =>
                      screenController.setScreen(AppScreenType.dashboard),
                  onPosTap: () => screenController.setScreen(AppScreenType.pos),
                  onMenuItemsTap: () =>
                      screenController.setScreen(AppScreenType.menuItems),
                  onBillsHistoryTap: () =>
                      screenController.setScreen(AppScreenType.billsHistory),
                  onReportsTap: () =>
                      screenController.setScreen(AppScreenType.reports),
                  onStockTap: () =>
                      screenController.setScreen(AppScreenType.stock),
                  onExpenseTap: () =>
                      screenController.setScreen(AppScreenType.expense),
                  onSettingsTap: () =>
                      screenController.setScreen(AppScreenType.settings),
                  onProfileTap: () =>
                      screenController.setScreen(AppScreenType.profile),
                  onLogoutTap: () => Get.find<AuthController>().signOut(),
                );
              }),

            // ── Main content ────────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                final screen = screenController.currentScreen.value;

                if (screen == AppScreenType.menuItems) {
                  return MenuItemsManagementWidget(
                    menuController: menuController,
                  );
                }
                if (screen == AppScreenType.profile) {
                  return const ProfileScreen();
                }
                if (screen == AppScreenType.dashboard) {
                  return const PosDashboardView();
                }
                if (screen == AppScreenType.billsHistory) {
                  return const BillHistoryScreen();
                }
                if (screen == AppScreenType.reports) {
                  return const ReportsScreen();
                }
                if (screen == AppScreenType.stock) {
                  return const StockManagementScreen();
                }
                if (screen == AppScreenType.expense) {
                  return const ExpenseManagementScreen();
                }
                if (screen == AppScreenType.printer) {
                  return const PrinterScreen();
                }
                if (screen == AppScreenType.settings) {
                  return const _PlaceholderScreen(title: 'Settings');
                }

                // ── POS screen ──────────────────────────────────────────────
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      children: [
                        _PosHeader(isMobile: isMobile),
                        Expanded(
                          child: CustomScrollView(
                            physics: const BouncingScrollPhysics(),
                            slivers: [
                              // Search bar
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    isMobile ? 16 : 20,
                                    isMobile ? 12 : 16,
                                    isMobile ? 16 : 20,
                                    isMobile ? 8 : 12,
                                  ),
                                  child: _PremiumSearchBar(
                                    onChanged: menuController.setSearchQuery,
                                  ),
                                ),
                              ),

                              // Category chips
                              SliverToBoxAdapter(
                                child: Obx(
                                  () => CategoryChipsWidget(
                                    categories: menuController.categories,
                                    selected:
                                        menuController.selectedCategory.value,
                                    onSelected: menuController.setCategory,
                                  ),
                                ),
                              ),

                              SliverToBoxAdapter(
                                child: SizedBox(height: isMobile ? 12 : 16),
                              ),

                              // Items grid
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                  isMobile ? 16 : 20,
                                  0,
                                  isMobile ? 16 : 20,
                                  isMobile ? 16 : 20,
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: Container(
                                    constraints: BoxConstraints(
                                      minHeight: constraints.maxHeight * 0.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(color: borderColor),
                                      boxShadow: [
                                        BoxShadow(
                                          color: accent.withOpacity(0.05),
                                          blurRadius: 24,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                        isMobile ? 14 : 18,
                                      ),
                                      child: Obx(() {
                                        if (menuController
                                            .productController
                                            .isLoading
                                            .value) {
                                          return _buildShimmerGrid(
                                            context,
                                            isMobile,
                                          );
                                        }
                                        final items =
                                            menuController.filteredItems;
                                        if (items.isEmpty) {
                                          return const EmptyStateWidget(
                                            icon: Icons.restaurant_menu_rounded,
                                            title: 'No items found',
                                            subtitle:
                                                'Try adjusting your filters or add new menu items',
                                          );
                                        }
                                        return _buildGrid(
                                          context,
                                          items,
                                          cartController,
                                          isMobile: isMobile,
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              }),
            ),

            // ── Cart panel (desktop POS only) ───────────────────────────────
            Obx(() {
              final screen = screenController.currentScreen.value;
              if (screen != AppScreenType.pos || isMobile) {
                return const SizedBox.shrink();
              }
              return CartWidget(cartController: cartController);
            }),
          ],
        ),
      ),

      // ── Mobile bottom nav bar ──────────────────────────────────────────────
      bottomNavigationBar: isMobile
          ? Obx(() {
              final screen = screenController.currentScreen.value;
              final navIndex = _screenToNavIndex(screen);
              return _MobileNavBar(
                currentIndex: navIndex,
                onTap: (i) => screenController.setScreen(_navIndexToScreen(i)),
              );
            })
          : null,

      // ── Mobile cart FAB ─────────────────────────────────────────────────
      floatingActionButton: isMobile
          ? Obx(() {
              final screen = screenController.currentScreen.value;
              if (screen != AppScreenType.pos) return const SizedBox.shrink();
              final itemCount = cartController.totalItems;
              if (itemCount == 0) return const SizedBox.shrink();
              return _PremiumCartFab(
                itemCount: itemCount,
                onTap: () => _showMobileCart(context, cartController),
              );
            })
          : null,
    );
  }

  Widget _buildShimmerGrid(BuildContext context, bool isMobile) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.getGridCrossAxisCount(context),
        crossAxisSpacing: isMobile ? 16 : 22,
        mainAxisSpacing: isMobile ? 24 : 28,
        childAspectRatio: 0.92,
      ),
      itemCount: 8,
      itemBuilder: (_, __) => const ItemCardShimmer(),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    List items,
    CartController cartController, {
    required bool isMobile,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.getGridCrossAxisCount(context),
        crossAxisSpacing: isMobile ? 16 : 22,
        mainAxisSpacing: isMobile ? 24 : 28,
        childAspectRatio: 0.92,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ItemCardWidget(
          item: items[index],
          cartController: cartController,
          index: index,
        );
      },
    );
  }

  // Maps the 4 bottom nav tabs to screen types
  static int _screenToNavIndex(AppScreenType screen) {
    switch (screen) {
      case AppScreenType.pos:
        return 0;
      case AppScreenType.menuItems:
        return 1;
      case AppScreenType.billsHistory:
        return 2;
      case AppScreenType.profile:
        return 3;
      default:
        return 0;
    }
  }

  static AppScreenType _navIndexToScreen(int index) {
    switch (index) {
      case 0:
        return AppScreenType.pos;
      case 1:
        return AppScreenType.menuItems;
      case 2:
        return AppScreenType.billsHistory;
      case 3:
        return AppScreenType.profile;
      default:
        return AppScreenType.pos;
    }
  }

  void _showMobileCart(BuildContext context, CartController cartController) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: CartWidget(cartController: cartController),
        ),
      ),
    );
  }
}

// ── Placeholder screen ───────────────────────────────────────────────────────
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PosScreen.borderColor),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: PosScreen.textDark,
          ),
        ),
      ),
    );
  }
}

// ── Premium header ────────────────────────────────────────────────────────────
class _PosHeader extends StatelessWidget {
  final bool isMobile;

  const _PosHeader({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: isMobile ? 58 : 66,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          bottom: BorderSide(color: PosScreen.borderColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: PosScreen.accent.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Hamburger menu (mobile only)
          if (isMobile) ...[
            Builder(
              builder: (ctx) => GestureDetector(
                onTap: () => Scaffold.of(ctx).openDrawer(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: PosScreen.accentSoft,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: PosScreen.borderColor),
                  ),
                  child: const Icon(Icons.menu_rounded,
                      size: 20, color: PosScreen.accent),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          // Logo
          RichText(
            text: TextSpan(
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: isMobile ? 18 : 22,
                color: PosScreen.textDark,
              ),
              children: const [
                TextSpan(text: 'Restro '),
                TextSpan(
                  text: 'POS',
                  style: TextStyle(color: PosScreen.accent),
                ),
              ],
            ),
          ),
          const Spacer(),

          // Live datetime
          const _LiveDateTime(),
          SizedBox(width: isMobile ? 8 : 12),

          // Cashier avatar
          if (!isMobile) ...[
            const SizedBox(width: 4),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFFA78BFA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: PosScreen.accent.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'C',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Live date & time ──────────────────────────────────────────────────────────
class _LiveDateTime extends StatelessWidget {
  const _LiveDateTime();

  static String _p(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final now = DateTime.now().obs;
    Stream.periodic(const Duration(seconds: 1)).listen((_) {
      now.value = DateTime.now();
    });

    return Obx(() {
      final d = now.value;
      final date = '${_p(d.day)}/${_p(d.month)}/${d.year}';
      final time = '${_p(d.hour)}:${_p(d.minute)}';

      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10 : 14,
          vertical: isMobile ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: PosScreen.accentSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PosScreen.borderColor),
        ),
        child: Text(
          isMobile ? time : '$date   $time',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: isMobile ? 12 : 13,
            color: PosScreen.accent,
            letterSpacing: 0.4,
          ),
        ),
      );
    });
  }
}

// ── Premium search bar ────────────────────────────────────────────────────────
class _PremiumSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const _PremiumSearchBar({required this.onChanged});

  @override
  State<_PremiumSearchBar> createState() => _PremiumSearchBarState();
}

class _PremiumSearchBarState extends State<_PremiumSearchBar> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _focused ? Colors.white : PosScreen.accentSoft,
        borderRadius: BorderRadius.circular(isMobile ? 16 : 18),
        border: Border.all(
          color: _focused ? PosScreen.accent : PosScreen.borderColor,
          width: _focused ? 1.5 : 1.0,
        ),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: PosScreen.accent.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Focus(
        onFocusChange: (v) => setState(() => _focused = v),
        child: TextField(
          onChanged: widget.onChanged,
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            color: PosScreen.textDark,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Search dishes, starters...',
            hintStyle: TextStyle(
              color: PosScreen.textMid.withOpacity(0.6),
              fontSize: isMobile ? 13 : 14,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Icon(
                Icons.search_rounded,
                size: isMobile ? 19 : 21,
                color: _focused ? PosScreen.accent : PosScreen.textMid,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 46),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              vertical: isMobile ? 13 : 15,
              horizontal: 4,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Premium FAB for mobile cart ────────────────────────────────────────────────
class _PremiumCartFab extends StatelessWidget {
  final int itemCount;
  final VoidCallback onTap;

  const _PremiumCartFab({required this.itemCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFFA78BFA)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.40),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_bag_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              'View Cart',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$itemCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mobile bottom navigation bar ─────────────────────────────────────────────
class _MobileNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _MobileNavBar({required this.currentIndex, required this.onTap});

  static const _accent = Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEAE8FF))),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              _NavBarItem(
                icon: Icons.point_of_sale_rounded,
                label: 'POS',
                active: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavBarItem(
                icon: Icons.restaurant_menu_rounded,
                label: 'Menu',
                active: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavBarItem(
                icon: Icons.receipt_long_rounded,
                label: 'Bills',
                active: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavBarItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                active: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  static const _accent = Color(0xFF6C63FF);
  static const _inactive = Color(0xFF9CA3AF);

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: active ? _accent.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 22,
                color: active ? _accent : _inactive,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? _accent : _inactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mobile side drawer ────────────────────────────────────────────────────────
class _MobileDrawer extends StatelessWidget {
  final AppScreenController screenController;

  const _MobileDrawer({required this.screenController});

  static const _accent = Color(0xFF6C63FF);
  static const _bg = Color(0xFFF8F7FF);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: _bg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFEAE8FF))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFFA78BFA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.restaurant, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Restro POS',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E1B3A),
                        ),
                      ),
                      Text(
                        'Restaurant Management',
                        style: TextStyle(fontSize: 11, color: Color(0xFF6B6880)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Nav items
            Expanded(
              child: Obx(() {
                final current = screenController.currentScreen.value;
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  children: [
                    _DrawerItem(
                      icon: Icons.dashboard_outlined,
                      label: 'Dashboard',
                      active: current == AppScreenType.dashboard,
                      onTap: () => _go(context, AppScreenType.dashboard),
                    ),
                    _DrawerItem(
                      icon: Icons.point_of_sale_rounded,
                      label: 'Point of Sale',
                      active: current == AppScreenType.pos,
                      onTap: () => _go(context, AppScreenType.pos),
                    ),
                    _DrawerItem(
                      icon: Icons.restaurant_menu_rounded,
                      label: 'Menu Items',
                      active: current == AppScreenType.menuItems,
                      onTap: () => _go(context, AppScreenType.menuItems),
                    ),
                    _DrawerItem(
                      icon: Icons.receipt_long_rounded,
                      label: 'Bills History',
                      active: current == AppScreenType.billsHistory,
                      onTap: () => _go(context, AppScreenType.billsHistory),
                    ),
                    _DrawerItem(
                      icon: Icons.bar_chart_rounded,
                      label: 'Reports',
                      active: current == AppScreenType.reports,
                      onTap: () => _go(context, AppScreenType.reports),
                    ),
                    _DrawerItem(
                      icon: Icons.inventory_2_outlined,
                      label: 'Stock',
                      active: current == AppScreenType.stock,
                      onTap: () => _go(context, AppScreenType.stock),
                    ),
                    _DrawerItem(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Expenses',
                      active: current == AppScreenType.expense,
                      onTap: () => _go(context, AppScreenType.expense),
                    ),
                    _DrawerItem(
                      icon: Icons.print_rounded,
                      label: 'Printer Setup',
                      active: current == AppScreenType.printer,
                      onTap: () => _go(context, AppScreenType.printer),
                    ),
                    _DrawerItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Profile',
                      active: current == AppScreenType.profile,
                      onTap: () => _go(context, AppScreenType.profile),
                    ),
                  ],
                );
              }),
            ),
            // Logout
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: _DrawerItem(
                icon: Icons.logout_rounded,
                label: 'Logout',
                active: false,
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  Get.find<AuthController>().signOut();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _go(BuildContext context, AppScreenType screen) {
    Navigator.pop(context);
    screenController.setScreen(screen);
  }
}

class _DrawerItem extends StatelessWidget {
  static const _accent = Color(0xFF6C63FF);

  final IconData icon;
  final String label;
  final bool active;
  final bool isDestructive;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? const Color(0xFFDC2626)
        : active
            ? _accent
            : const Color(0xFF4B5563);

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: active ? _accent.withOpacity(0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
                if (active)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: _accent,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
