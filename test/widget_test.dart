import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import 'package:trade_wign_bd/features/users/home/presentation/screens/user_home_screen.dart';

void main() {
  testWidgets('User Dashboard smoke test', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Register AuthController
    Get.put(AuthController());

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const MaterialApp(
        home: UserDashboardScreen(),
      ),
    );

    // Verify that our dashboard shows the expected title and section.
    expect(find.text('ট্রেড উইং'), findsOneWidget);
    expect(find.text('আমাদের সেবাসমূহ'), findsOneWidget);
  });
}
