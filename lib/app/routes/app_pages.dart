import 'package:get/get.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/home/views/login_view.dart';
import '../modules/home/views/registerview.dart';
import '../modules/home/views/start_screen.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.ONBOARDING;

  static final routes = [
    GetPage(
      name: Routes.ONBOARDING,
      page: () => OnboardingView(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginView(),
      binding: HomeBinding(), // Ini bisa dihapus jika Anda sudah menginisialisasi AuthController di bagian lain
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => RegisterView(),
      binding: HomeBinding(), // Sama seperti di atas, bisa dihapus
    ),
    GetPage(
      name: Routes.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
  ];
}
