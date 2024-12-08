import 'package:get/get.dart';

class DrawerMenuController extends GetxController {
  // Menangani navigasi di drawer menu
  void navigateTo(String route) {
    if (route == 'home') {
      Get.offNamed('/home'); // Ganti dengan route home
    } else if (route == 'profile') {
      Get.offNamed('/profile'); // Ganti dengan route profile
    }
    // Tambahkan route lainnya jika diperlukan
  }
}
