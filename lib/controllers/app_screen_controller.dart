import 'package:get/get.dart';

enum AppScreenType {
  dashboard,
  pos,
  menuItems,
  billsHistory,
  reports,
  stock,
  expense,
  settings,
  profile,
}

class AppScreenController extends GetxController {
  final Rx<AppScreenType> currentScreen = AppScreenType.pos.obs;

  void setScreen(AppScreenType screen) {
    currentScreen.value = screen;
  }
}
