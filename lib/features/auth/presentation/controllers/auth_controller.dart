import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:trade_wign_bd/common/services/push_notification_service.dart';
import '../../data/service/auth_service.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find<AuthController>();

  final AuthService _authService = AuthService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Reactive states
  final RxBool isLoading = false.obs;
  final RxString currentUserName = ''.obs;
  final RxString currentUserMobile = ''.obs;
  final RxString currentUserRole = 'Guest Customer'.obs; // Default is Guest Customer until logged in

  static const String _firstTimeKey = 'isFirstTime';
  static const String _loggedInUserKey = 'isLoggedIn';
  static const String _userRoleKey = 'userRole';
  static const String _userNameKey = 'userName';
  static const String _userMobileKey = 'userMobile';

  // Check if onboarding needs to be shown (only once in a lifetime)
  Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstTimeKey) ?? true;
  }

  // Set onboarding shown flag
  Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstTimeKey, false);
  }

  // Check if user is already logged in
  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_loggedInUserKey) ?? false;
    if (isLoggedIn) {
      currentUserName.value = prefs.getString(_userNameKey) ?? '';
      currentUserMobile.value = prefs.getString(_userMobileKey) ?? '';
      currentUserRole.value = prefs.getString(_userRoleKey) ?? 'Customer';
      return true;
    }
    return false;
  }

  // Register a new user
  Future<String> register({
    required String name,
    required String mobile,
    required String email,
    required String password,
    String? businessCode,
  }) async {
    isLoading.value = true;
    final result = await _authService.signUpUser(
      name: name,
      mobile: mobile,
      email: email,
      password: password,
      businessCode: businessCode,
    );
    isLoading.value = false;
    return result;
  }

  // Login an existing user
  Future<String> login({
    required String mobile,
    required String password,
  }) async {
    isLoading.value = true;
    final result = await _authService.signInUser(
      mobile: mobile,
      password: password,
    );
    isLoading.value = false;

    if (result == null) {
      return 'লগইন করতে ব্যর্থ হয়েছে';
    }

    if (result['status'] == 'success') {
      currentUserName.value = result['name'] ?? '';
      currentUserMobile.value = result['mobile'] ?? '';
      currentUserRole.value = result['role'] ?? 'Customer';

      // Persist login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_loggedInUserKey, true);
      await prefs.setString(_userNameKey, currentUserName.value);
      await prefs.setString(_userMobileKey, currentUserMobile.value);
      await prefs.setString(_userRoleKey, currentUserRole.value);

      // Save credentials for biometric login
      await _secureStorage.write(key: 'biometric_mobile', value: mobile);
      await _secureStorage.write(key: 'biometric_password', value: password);

      // Initialize Push Notification token & listener
      try {
        if (Get.isRegistered<PushNotificationService>()) {
          final pushService = Get.find<PushNotificationService>();
          await pushService.saveTokenToUserDocument();
          pushService.startNotificationListener();
        }
      } catch (e) {
        debugPrint("Error initializing push service on login: $e");
      }

      return 'success';
    } else {
      return result['message'] ?? 'লগইন করতে ব্যর্থ হয়েছে';
    }
  }

  // Login as a Guest Customer
  Future<void> loginAsGuest() async {
    currentUserName.value = 'অতিথি গ্রাহক';
    currentUserMobile.value = '';
    currentUserRole.value = 'Guest Customer';

    // Clear saved login credentials, but keep first-time false
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInUserKey, false);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userMobileKey);
    await prefs.remove(_userRoleKey);
  }

  // Logout
  Future<void> logout() async {
    currentUserName.value = '';
    currentUserMobile.value = '';
    currentUserRole.value = 'Guest Customer';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInUserKey, false);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userMobileKey);
    await prefs.remove(_userRoleKey);
  }

  // Biometric Login (Silently fetches credentials and logs in)
  Future<String> biometricLogin() async {
    final mobile = await _secureStorage.read(key: 'biometric_mobile');
    final password = await _secureStorage.read(key: 'biometric_password');

    if (mobile == null || password == null) {
      return 'no_credentials';
    }

    // Call the regular login method which will also update the UI state
    return await login(mobile: mobile, password: password);
  }
}
