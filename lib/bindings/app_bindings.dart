import 'package:get/get.dart';

import '../controllers/app_screen_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/menu_controller.dart';
import '../controllers/orders_controller.dart';
import '../controllers/pos_dashboard_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/profile_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.lazyPut<AppScreenController>(() => AppScreenController(), fenix: true);
    Get.lazyPut<CartController>(() => CartController(), fenix: true);
    Get.lazyPut<CategoryController>(() => CategoryController(), fenix: true);
    Get.lazyPut<ProductController>(() => ProductController(), fenix: true);
    Get.lazyPut<OrdersController>(() => OrdersController(), fenix: true);
    Get.lazyPut<MenuController>(() => MenuController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    Get.lazyPut<PosDashboardController>(
      () => PosDashboardController(ordersController: Get.find()),
      fenix: true,
    );
  }
}
