import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/admin/dashboard/presentation/screens/admin_home_page.dart';
import 'package:trade_wign_bd/features/auth/presentation/screens/splash_screen.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/controllers/cart_controller.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/controllers/product_review_controller.dart';
import 'package:trade_wign_bd/uitls/theme/app_theme.dart';
import 'package:trade_wign_bd/common/services/push_notification_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Push Notification Service
  await Get.putAsync(() => PushNotificationService().init());

  // Initialize AuthController globally
  Get.put(AuthController());
  Get.put(CartController());
  Get.put(ProductReviewController());

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightThemeData,
      darkTheme: AppTheme.darkThemeData,
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],
      // home: AdminDashboardScreen(),
    ),
  );
}
