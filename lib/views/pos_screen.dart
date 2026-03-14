import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/app_screen_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/menu_controller.dart' as pos;
import '../widgets/cart_widget.dart';
import '../widgets/category_chips_widget.dart';
import '../widgets/item_card_widget.dart';
import '../widgets/menu_items_management_widget.dart';
import '../widgets/sidebar_widget.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  late final pos.MenuController menuController;
  late final CartController cartController;

  late final AppScreenController screenController;

  static const Color pageBg = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFE5E5E5);
  static const Color textColor = Color(0xFF2E2E2E);

  @override
  void initState() {
    super.initState();
    menuController = Get.isRegistered<pos.MenuController>()
        ? Get.find<pos.MenuController>()
        : Get.put(pos.MenuController());
    cartController = Get.isRegistered<CartController>()
        ? Get.find<CartController>()
        : Get.put(CartController());

    screenController = Get.isRegistered<AppScreenController>()
        ? Get.find<AppScreenController>()
        : Get.put(AppScreenController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Row(
          children: [
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
                onSettingsTap: () =>
                    screenController.setScreen(AppScreenType.settings),
                onLogoutTap: () {},
              );
            }),
            Expanded(
              child: Obx(() {
                final screen = screenController.currentScreen.value;

                if (screen == AppScreenType.menuItems) {
                  return MenuItemsManagementWidget(
                    menuController: menuController,
                  );
                }

                if (screen == AppScreenType.dashboard) {
                  return const _PlaceholderScreen(title: 'Dashboard');
                }

                if (screen == AppScreenType.billsHistory) {
                  return const _PlaceholderScreen(title: 'Bills History');
                }

                if (screen == AppScreenType.settings) {
                  return const _PlaceholderScreen(title: 'Settings');
                }

                return Column(
                  children: [
                    _CenterHeader(
                      appName: 'Restro POS',
                      cashierName: 'Cashier',
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                      child: _SearchBar(
                        onChanged: menuController.setSearchQuery,
                      ),
                    ),
                    Obx(() {
                      return CategoryChipsWidget(
                        categories: menuController.categories,
                        selected: menuController.selectedCategory.value,
                        onSelected: menuController.setCategory,
                      );
                    }),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        decoration: BoxDecoration(
                          color: pageBg,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: borderColor),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Obx(() {
                            final items = menuController.filteredItems;

                            return GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 30,
                                    mainAxisSpacing: 30,
                                    childAspectRatio: 1.0,
                                  ),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return ItemCardWidget(
                                  item: item,
                                  cartController: cartController,
                                  index: index,
                                );
                              },
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
            Obx(() {
              final screen = screenController.currentScreen.value;
              if (screen != AppScreenType.pos) return const SizedBox.shrink();
              return CartWidget(cartController: cartController);
            }),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _PosScreenState.borderColor),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: _PosScreenState.textColor,
          ),
        ),
      ),
    );
  }
}

class _CenterHeader extends StatelessWidget {
  final String appName;
  final String cashierName;

  const _CenterHeader({required this.appName, required this.cashierName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              appName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: _PosScreenState.textColor,
              ),
            ),
          ),
          const _LiveDateTime(),
          const SizedBox(width: 16),
          Text(
            cashierName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: _PosScreenState.textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveDateTime extends StatefulWidget {
  const _LiveDateTime();

  @override
  State<_LiveDateTime> createState() => _LiveDateTimeState();
}

class _LiveDateTimeState extends State<_LiveDateTime> {
  late DateTime now;

  @override
  void initState() {
    super.initState();
    now = DateTime.now();
    Future.doWhile(() async {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        now = DateTime.now();
      });
      return true;
    });
  }

  String _two(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final d = now;
    final date = '${_two(d.day)}/${_two(d.month)}/${d.year}';
    final time = '${_two(d.hour)}:${_two(d.minute)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _PosScreenState.borderColor),
      ),
      child: Text(
        '$date  $time',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: const Color(0xFF2E2E2E),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search dishes, starters...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: const Color(0xFFF5F7F4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _PosScreenState.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _PosScreenState.borderColor),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
