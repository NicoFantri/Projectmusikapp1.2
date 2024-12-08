import 'package:get/get.dart';

class ProfileController extends GetxController {
  // Example user data, you can replace with real API data
  final RxString userName = 'Anisha'.obs;
  final RxString email = 'anisha@example.com'.obs;

  void updateProfile(String newName, String newEmail) {
    userName.value = newName;
    email.value = newEmail;
  }
}
