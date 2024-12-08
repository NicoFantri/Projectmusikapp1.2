import 'package:get/get.dart';

class LoginController extends GetxController {
  // Reactive variables to manage user input
  var email = ''.obs;
  var password = ''.obs;
  var isLoading = false.obs;
  var isLoggedIn = false.obs;

  // Boolean to check if user wants to skip login
  var skipLogin = false.obs;

  // Function to handle login logic
  void login() async {
    if (email.isNotEmpty && password.isNotEmpty) {
      isLoading.value = true;
      // Simulate a network call
      await Future.delayed(const Duration(seconds: 2));

      // Dummy authentication check
      if (email.value == 'admin' && password.value == 'admin') {
        isLoggedIn.value = true;
        Get.offNamed('/home'); // Navigate to home if successful
      } else {
        Get.snackbar('Login Failed', 'Invalid email or password',
            snackPosition: SnackPosition.BOTTOM);
      }
      isLoading.value = false;
    } else {
      Get.snackbar('Input Error', 'Please enter both email and password',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Function to skip login
  void skipLoginScreen() {
    skipLogin.value = true;
    Get.offNamed('/home'); // Directly navigate to home screen
  }
}