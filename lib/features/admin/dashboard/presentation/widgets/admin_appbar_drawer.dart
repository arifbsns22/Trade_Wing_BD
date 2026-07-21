import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trade_wign_bd/features/auth/presentation/screens/login_screen.dart';
import 'package:trade_wign_bd/features/admin/settings/presentation/screens/admin_settings_screen.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import 'package:trade_wign_bd/features/users/club/presentation/screens/business_club_screen.dart';
import 'package:trade_wign_bd/common/ui/widgets/dynamic_app_logo.dart';
import 'package:trade_wign_bd/features/admin/ecommerce/presentation/screens/product_list_screen.dart';
import 'package:trade_wign_bd/features/admin/marketing/presentation/screens/banner_screen.dart';
import 'package:trade_wign_bd/features/admin/ecommerce/presentation/screens/add_product_screen.dart';
import 'package:trade_wign_bd/features/admin/ecommerce/presentation/screens/product_config_screen.dart';
import 'package:trade_wign_bd/features/admin/ecommerce/presentation/screens/admin_orders_screen.dart';
import 'package:trade_wign_bd/features/admin/dashboard/presentation/screens/admin_home_page.dart';
import 'package:trade_wign_bd/features/admin/users/presentation/screens/all_user_screen.dart';
import 'package:trade_wign_bd/features/admin/users/presentation/screens/add_user_screen.dart';
import 'dart:convert';
import 'package:trade_wign_bd/features/common/profile/presentation/controllers/admin_profile_controller.dart';
import 'package:trade_wign_bd/features/admin/packages/presentation/screens/package_list_screen.dart';
import 'package:trade_wign_bd/features/admin/drive_pack/presentation/screens/admin_operator_setup_screens.dart';
import 'package:trade_wign_bd/features/admin/drive_pack/presentation/screens/admin_offer_creation_screens.dart';
import 'package:trade_wign_bd/features/admin/drive_pack/presentation/screens/drive_order_request_screen.dart';
import 'package:trade_wign_bd/features/admin/traning/presentation/screens/all_traning_screen.dart';

class AdminAppbarDrawer extends StatelessWidget {
  const AdminAppbarDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final profileController = Get.put(AdminProfileController());

    // List of 15 menu items with their titles and icons
    final List<Map<String, dynamic>> menuItems = [
      {'title': 'ড্যাশবোর্ড', 'icon': Icons.dashboard_outlined, 'badge': null},
      {
        'title': 'ইউজার',
        'icon': Icons.people_outline,
        'badge': null,
        'subItems': [
          {'title': 'সকল ইউজার', 'icon': Icons.group_outlined},
          {'title': 'ইউজার রিকোয়েস্ট', 'icon': Icons.list_alt_rounded},
          {'title': 'এড ইউজার', 'icon': Icons.person_add_alt_1_outlined},
        ],
      },
      {
        'title': 'ই-কমার্স',
        'icon': Icons.shopping_bag_outlined,
        'badge': null,
        'subItems': [
          {'title': 'পণ্য তালিকা', 'icon': Icons.list_alt_rounded},

          {
            'title': 'ক্যাটাগরি ও ব্র্যান্ড',
            'icon': Icons.settings_suggest_outlined,
          },
          {
            'title': 'অর্ডার',
            'icon': Icons.shopping_cart_outlined,
            'streamBadge': true,
          },
        ],
      },
      {
        'title': 'এপস মার্কেটিং',
        'icon': Icons.campaign,
        'badge': null,
        'subItems': [
          {'title': 'নোটিশ', 'icon': Icons.crisis_alert},
          {'title': 'কুপন কোড', 'icon': Icons.local_offer_outlined},
          {'title': 'ব্যানার', 'icon': Icons.image_outlined},
          {'title': 'নোটিফিকেশন', 'icon': Icons.notifications_active_outlined},
        ],
      },
      {
        'title': 'প্যাকেজ',
        'icon': Icons.inventory_2_outlined,
        'badge': null,
        'subItems': [
          {'title': 'এড প্যাকেজ', 'icon': Icons.add_box_outlined},
        ],
      },
      {
        'title': 'ড্রাইভ প্যাকেজ',
        'icon': Icons.phone_android_outlined,
        'badge': null,
        'subItems': [
          {'title': 'অপারেটর সেটআপ', 'icon': Icons.cell_tower_outlined},
          {'title': 'ড্রাইভ অর্ডার সমূহ', 'icon': Icons.list_alt_outlined},
          {'title': 'ড্রাইভ অফার তৈরি', 'icon': Icons.add_to_photos_outlined},
        ],
      },
      {'title': 'রিসেলিং', 'icon': Icons.storefront_outlined, 'badge': null},
      {'title': 'ভেন্ডরশিপ', 'icon': Icons.handshake_outlined, 'badge': null},
      {'title': 'বিটুবি', 'icon': Icons.business_outlined, 'badge': null},
      {
        'title': 'পার্সেল',
        'icon': Icons.local_shipping_outlined,
        'badge': null,
      },
      {'title': 'ট্রেনিং', 'icon': Icons.school_outlined, 'badge': null},
      {'title': 'বিজনেস ক্লাব', 'icon': Icons.groups_outlined, 'badge': null},
      {'title': 'পেমেন্ট', 'icon': Icons.payment_outlined, 'badge': null},
      {'title': 'রিপোর্ট', 'icon': Icons.analytics_outlined, 'badge': null},
      {'title': 'সাপোর্ট', 'icon': Icons.headset_mic_outlined, 'badge': null},
      {'title': 'সেটিংস', 'icon': Icons.settings_outlined, 'badge': null},
      {'title': 'লগ-আউট', 'icon': Icons.logout_outlined, 'badge': null},
    ];

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header Area: Logo and Quick Support Icon
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App Logo
                  const Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: DynamicAppLogo(isDark: false, height: 40),
                    ),
                  ),
                ],
              ),
            ),

            // Profile Card (bKash style pink/primary border)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 8.0,
              ),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: AppColors.primaryColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Profile Picture
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryColor.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: Obx(() {
                        final hasPic =
                            profileController.profilePicture.value.isNotEmpty;
                        ImageProvider? imageProvider;
                        if (hasPic) {
                          final picVal = profileController.profilePicture.value;
                          if (picVal.startsWith('http')) {
                            imageProvider = NetworkImage(picVal);
                          } else {
                            try {
                              imageProvider = MemoryImage(
                                base64Decode(picVal.split(',').last),
                              );
                            } catch (e) {
                              debugPrint('Error decoding base64 avatar: $e');
                            }
                          }
                        }

                        final nameStr = profileController.name.value;
                        final initials = nameStr.isNotEmpty
                            ? nameStr
                                  .trim()
                                  .split(' ')
                                  .map(
                                    (e) =>
                                        e.isNotEmpty ? e.substring(0, 1) : '',
                                  )
                                  .where((e) => e.isNotEmpty)
                                  .take(2)
                                  .join()
                                  .toUpperCase()
                            : '';

                        return CircleAvatar(
                          radius: 26,
                          backgroundColor: AppColors.primaryColor.withValues(
                            alpha: 0.1,
                          ),
                          backgroundImage: imageProvider,
                          child: imageProvider == null
                              ? Text(
                                  initials.isEmpty ? 'AD' : initials,
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        );
                      }),
                    ),
                    const SizedBox(width: 16),
                    // User Details (Reactive)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(
                            () => Text(
                              authController.currentUserName.value.isNotEmpty
                                  ? authController.currentUserName.value
                                  : 'এডমিন ইউজার',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(
                            () => Text(
                              authController.currentUserMobile.value.isNotEmpty
                                  ? authController.currentUserMobile.value
                                  : '017XXXXXXXX',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Role Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 2.0,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Obx(
                              () => Text(
                                authController.currentUserRole.value ==
                                        'Super Admin'
                                    ? 'সুপার এডমিন'
                                    : authController.currentUserRole.value,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Scrollable Menu List (15 items)
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: menuItems.length,
                separatorBuilder: (context, index) =>
                    Divider(color: Colors.grey.shade100, height: 1),
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  final isLogout = item['title'] == 'লগ-আউট';
                  final hasSubItems = item['subItems'] != null;

                  if (hasSubItems) {
                    final List<Map<String, dynamic>> subItems =
                        List<Map<String, dynamic>>.from(item['subItems']);
                    return ExpansionTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: AppColors.primaryColor,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        item['title'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      children: subItems.map((subItem) {
                        return ListTile(
                          contentPadding: const EdgeInsets.only(
                            left: 36.0,
                            right: 12.0,
                          ),
                          leading: Icon(
                            subItem['icon'] as IconData,
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.7,
                            ),
                            size: 18,
                          ),
                          title: Text(
                            subItem['title'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          trailing: subItem['streamBadge'] == true
                              ? StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('orders')
                                      .where(
                                        'orderStatus',
                                        isEqualTo: 'pending',
                                      )
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData &&
                                        snapshot.data!.docs.isNotEmpty) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6.0,
                                          vertical: 2.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Text(
                                          'নতুন অর্ডার',
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                )
                              : null,
                          onTap: () {
                            Navigator.pop(context); // Close drawer
                            if (subItem['title'] == 'পণ্য তালিকা') {
                              Get.to(() => const ProductListScreen());
                            } else if (subItem['title'] == 'নতুন পণ্য যোগ') {
                              Get.to(() => const AddProductScreen());
                            } else if (subItem['title'] ==
                                'ক্যাটাগরি ও ব্র্যান্ড') {
                              Get.to(() => const ProductConfigScreen());
                            } else if (subItem['title'] == 'অর্ডার') {
                              Get.to(() => const AdminOrdersScreen());
                            } else if (subItem['title'] == 'সকল ইউজার') {
                              Get.to(() => const AllUserScreen());
                            } else if (subItem['title'] == 'এড ইউজার') {
                              Get.to(() => const AddUserScreen());
                            } else if (subItem['title'] == 'ব্যানার') {
                              Get.to(() => const BannerScreen());
                            } else if (subItem['title'] == 'এড প্যাকেজ') {
                              Get.to(() => const PackageListScreen());
                            } else if (subItem['title'] == 'অপারেটর সেটআপ') {
                              Get.to(() => const AdminOperatorSetupScreen());
                            } else if (subItem['title'] == 'ড্রাইভ অর্ডার সমূহ') {
                              Get.to(() => const DriveOrderRequestScreen());
                            } else if (subItem['title'] == 'ড্রাইভ অফার তৈরি') {
                              Get.to(() => const AdminOfferCreationScreen());
                            } else {
                              Get.snackbar(
  subItem['title'] as String,
  'এই ফিচারটির কাজ চলমান আছে।',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
                            }
                          },
                        );
                      }).toList(),
                    );
                  }

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 2.0,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: isLogout
                            ? Colors.red.withValues(alpha: 0.05)
                            : AppColors.primaryColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: isLogout ? Colors.red : AppColors.primaryColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      item['title'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isLogout ? Colors.red : Colors.black87,
                      ),
                    ),
                    trailing: item['badge'] != null
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                              vertical: 2.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              item['badge'] as String,
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.chevron_right,
                            color: Colors.grey.shade400,
                            size: 16,
                          ),
                    onTap: () {
                      // Close drawer first
                      Navigator.pop(context);
                      if (isLogout) {
                        _showLogoutConfirmation(context, authController);
                      } else if (item['title'] == 'ড্যাশবোর্ড') {
                        Get.offAll(() => const AdminDashboardScreen());
                      } else if (item['title'] == 'সেটিংস') {
                        Get.to(() => const AdminSettingsScreen());
                      } else if (item['title'] == 'ট্রেনিং') {
                        Get.to(() => const AllTraningScreen());
                      } else if (item['title'] == 'বিজনেস ক্লাব') {
                        Get.to(() => const BusinessClubScreen());
                      } else {
                        // Show mock click feedback or route logic
                        Get.snackbar(
  item['title'] as String,
  'এই ফিচারটির কাজ চলমান আছে।',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
                      }
                    },
                  );
                },
              ),
            ),

            // Footer Section: Version
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
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
