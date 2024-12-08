import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart'; // Import ProfileController

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController());
    Get.put<HomeController>(HomeController());
    Get.put<ProfileController>(ProfileController()); // Tambahkan ProfileController
  }
}
