import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import 'package:trade_wign_bd/features/admin/settings/presentation/controllers/admin_settings_controller.dart';
import 'package:trade_wign_bd/features/auth/presentation/screens/login_screen.dart';
import 'package:trade_wign_bd/features/admin/profile/presentation/screens/admin_profile_screen.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import 'package:trade_wign_bd/uitls/constants/assets_path/images_path.dart';
import 'package:trade_wign_bd/common/ui/widgets/dynamic_app_logo.dart';

class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AdminAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      centerTitle: true,

      // Left Side: Drawer Toggle Button
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: Icon(
              Icons.menu_rounded,
              color: AppColors.primaryColor,
              size: 26,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            tooltip: 'মেনু খুলুন',
          );
        },
      ),

      title: const DynamicAppLogo(
        isDark: false,
        height: 36,
      ),

      // Right Side: Bell (Notifications) and Log Out Buttons
      actions: [
        // Bell Icon (Notifications with red dot/badge)
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_none_rounded,
                color: AppColors.primaryColor,
                size: 26,
              ),
              onPressed: () {
                _showNotificationsDialog(context);
              },
              tooltip: 'নোটিফিকেশনস',
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
              ),
            ),
          ],
        ),

        // Logout Icon
        IconButton(
          icon: const Icon(
            Icons.person_rounded,
            color: Colors.deepPurple,
            size: 24,
          ),
          onPressed: () => Get.to(() => const AdminProfileScreen()),
          tooltip: 'প্রোফাইল',
        ),
        // Logout Icon
        IconButton(
          icon: const Icon(
            Icons.logout_rounded,
            color: Colors.redAccent,
            size: 24,
          ),
          onPressed: () {
            _showLogoutConfirmation(context, authController);
          },
          tooltip: 'লগআউট',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // Show notifications stub dialog
  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.notifications_active, color: Color(0xFF08B3AC)),
            SizedBox(width: 10),
            Text(
              'নোটিফিকেশনসমূহ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationItem(
              'নতুন ইউজার রেজিস্ট্রেশন সম্পন্ন হয়েছে।',
              '১০ মিনিট আগে',
            ),
            const Divider(),
            _buildNotificationItem(
              '১টি নতুন ড্রাইভ প্যাকের রিকোয়েস্ট এসেছে।',
              '২৫ মিনিট আগে',
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('বন্ধ করুন'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(String title, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // Logout Dialog Confirmation
  void _showLogoutConfirmation(
    BuildContext context,
    AuthController authController,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 10),
            Text('লগআউট', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'আপনি কি নিশ্চিত যে আপনি আপনার অ্যাকাউন্ট থেকে লগআউট করতে চান?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            child: Text('না', style: TextStyle(color: Colors.grey.shade600)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('হ্যাঁ'),
            onPressed: () async {
              Navigator.pop(context);
              await authController.logout();
              Get.offAll(() => const LoginScreen());
            },
          ),
        ],
      ),
    );
  }
}
