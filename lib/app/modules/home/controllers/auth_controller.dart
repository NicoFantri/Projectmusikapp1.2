import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final firebaseUser = Rx<User?>(null);
  final isLoading = false.obs;
  static bool isHandlingRedirect = false;

  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  Future<void> _initializeAuth() async {
    await _auth.setPersistence(Persistence.LOCAL);
  }

  void _setInitialScreen(User? user) {
    if (isHandlingRedirect) return;

    try {
      isHandlingRedirect = true;
      final currentRoute = Get.currentRoute;
      print('Current Route: $currentRoute');
      print('User Status: ${user != null ? 'Logged In' : 'Logged Out'}');

      if (user == null && !['/login', '/register'].contains(currentRoute)) {
        Get.offAllNamed('/login');
      } else if (user != null && currentRoute != '/home') {
        Get.offAllNamed('/home');
      }
    } finally {
      isHandlingRedirect = false;
    }
  }

  // Add email validation
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Add password validation
  String? validatePassword(String password) {
    if (password.length < 6) {
      return 'Password harus minimal 6 karakter';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password harus mengandung minimal 1 huruf besar';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password harus mengandung minimal 1 angka';
    }
    return null;
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      // Validate inputs
      if (username.isEmpty || email.isEmpty || password.isEmpty) {
        throw 'Semua field harus diisi';
      }

      if (!isValidEmail(email)) {
        throw 'Format email tidak valid';
      }

      String? passwordError = validatePassword(password);
      if (passwordError != null) {
        throw passwordError;
      }

      // Create user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        'createdAt': Timestamp.now(),
        'lastLogin': null,
        'isActive': false,
        'role': 'user',
      });

      // Update display name
      await userCredential.user!.updateDisplayName(username);

      // Logout after registration
      await _auth.signOut();

      Get.snackbar(
        'Sukses',
        'Registrasi berhasil! Silakan login dengan email dan password yang telah didaftarkan.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Navigate to login page
      await Future.delayed(const Duration(seconds: 1));
      Get.offAllNamed('/login');

    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Password terlalu lemah';
          break;
        case 'email-already-in-use':
          message = 'Email sudah terdaftar. Silakan login atau gunakan email lain.';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid';
          break;
        default:
          message = 'Terjadi kesalahan saat registrasi: ${e.message}';
      }
      _showError(message);
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        throw 'Email dan password harus diisi';
      }

      if (!isValidEmail(email)) {
        throw 'Format email tidak valid';
      }

      // Attempt login
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user status in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).update({
        'lastLogin': Timestamp.now(),
        'isActive': true,
      });

      Get.snackbar(
        'Sukses',
        'Login berhasil! Selamat datang kembali.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Navigate to home page
      await Future.delayed(const Duration(seconds: 1));
      Get.offAllNamed('/home');

    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Email belum terdaftar. Silakan register terlebih dahulu.';
          break;
        case 'wrong-password':
          message = 'Password salah. Silakan coba lagi.';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid';
          break;
        case 'user-disabled':
          message = 'Akun ini telah dinonaktifkan. Silakan hubungi admin.';
          break;
        default:
          message = 'Terjadi kesalahan saat login: ${e.message}';
      }
      _showError(message);
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Add the missing logout method
  Future<void> logout() async {
    try {
      isLoading.value = true;

      final user = _auth.currentUser;
      if (user != null) {
        // Update user status in Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'isActive': false,
          'lastLogout': Timestamp.now(),
        });
      }

      // Sign out from Firebase
      await _auth.signOut();

      Get.snackbar(
        'Sukses',
        'Logout berhasil!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Clear any local storage if needed
      // Navigate to login page
      Get.offAllNamed('/login');

    } catch (e) {
      _showError('Gagal melakukan logout: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Add the missing getCurrentUserData method
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Get user data from Firestore
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          return doc.data() as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      _showError('Gagal mengambil data user: ${e.toString()}');
      return null;
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}