import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app/routes/app_pages.dart';
import 'package:musicapp/app/modules/home/controllers/auth_controller.dart';
import 'package:musicapp/app/modules/home/controllers/profile_controller.dart';
import 'package:musicapp/app/modules/home/views/NotificationPage.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await _requestNotificationPermissions();

  Get.put(AuthController());
  Get.put(ProfileController());


  runApp(const MyApp());
}

Future<void> _requestNotificationPermissions() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission();

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else {
    print('User declined or has not accepted permission');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _initializeFirebaseMessaging();

    return GetMaterialApp(
      title: 'Music App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF5079FF),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5079FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }

  void _initializeFirebaseMessaging() {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message in the foreground: ${message.notification?.title}');
      if (message.notification != null) {
        _showNotificationDialog(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
      // Navigate to NotificationPage when the notification is clicked
      Get.to(() => NotificationPage(
        notifications: [
          {
            'title': message.notification?.title ?? 'Notification',
            'body': message.notification?.body ?? 'No message body',
            'time': DateTime.now().toString(), // You might want to format this
          },
        ],
      ));
    });
  }

  void _showNotificationDialog(RemoteMessage message) {
    Get.dialog(
      AlertDialog(
        title: Text(message.notification?.title ?? 'Notification'),
        content: Text(message.notification?.body ?? 'No message body'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.to(() => NotificationPage(
                notifications: [
                  {
                    'title': message.notification?.title ?? 'Notification',
                    'body': message.notification?.body ?? 'No message body',
                    'time': DateTime.now().toString(), // Format as needed
                  },
                ],
              ));
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }
}
