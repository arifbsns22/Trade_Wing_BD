import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/admin/dashboard/presentation/screens/admin_home_page.dart';
import 'package:trade_wign_bd/features/common/bottom_navbar_menu.dart';
import 'package:trade_wign_bd/uitls/constants/assets_path/images_path.dart';
import 'package:trade_wign_bd/common/ui/widgets/dynamic_app_logo.dart';
import 'package:trade_wign_bd/features/admin/dashboard/presentation/screens/admin_home_page.dart';
import '../controllers/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String name = 'splashscreen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthController _authController = Get.put(AuthController());

  @override
  void initState() {
    super.initState();
    goToNextScreen();
  }

  Future<void> goToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    // Populates login status / user role reactive variables
    await _authController.checkLoginStatus();

    // Route according to user role
    final role = _authController.currentUserRole.value;
    if (role == 'Super Admin') {
      Get.offAll(() => const AdminDashboardScreen());
    } else {
      Get.offAll(() => const BottomNavBarMenu());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(100),
          child: const DynamicAppLogo(isDark: false),
        ),
      ),
    );
  }
}
