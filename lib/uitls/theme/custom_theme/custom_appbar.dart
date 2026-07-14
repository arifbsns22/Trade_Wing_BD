import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:trade_wign_bd/common/ui/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import 'package:trade_wign_bd/features/common/profile/presentation/controllers/admin_profile_controller.dart';
import 'package:trade_wign_bd/features/auth/presentation/screens/login_screen.dart';
import 'package:trade_wign_bd/features/common/custom_search_bar.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/controllers/cart_controller.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/screens/cart_screen.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(160);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool _isAnimation = false;
  bool _isBalanceShown = false;
  bool _isBalance = true;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 160,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: PrimaryHeaderContainer(
        height: 160 + MediaQuery.of(context).padding.top,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Profile Info & Action Icons
                Row(
                  children: [
                    // Profile Avatar
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: const AssetImage(
                        'assets/color_icons/avater.png',
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Name and Check Points
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Show User Full Name from Database
                        Obx(() {
                          final authController = Get.find<AuthController>();
                          final isLoggedIn =
                              authController.currentUserRole.value !=
                              'Guest Customer';
                          final displayName =
                              isLoggedIn &&
                                  authController
                                      .currentUserName
                                      .value
                                      .isNotEmpty
                              ? authController.currentUserName.value
                              : 'Guest User';
                          return Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }),
                        const SizedBox(height: 4),

                        InkWell(
                          onTap: animate,
                          child: Container(
                            width: 150,
                            height: 26,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AnimatedOpacity(
                                  opacity: _isBalanceShown ? 1 : 0,
                                  duration: const Duration(milliseconds: 500),
                                  //Dynamic change this reward points from database
                                  child: Obx(() {
                                    final authController =
                                        Get.find<AuthController>();
                                    final isLoggedIn =
                                        authController.currentUserRole.value !=
                                        'Guest Customer';
                                    if (!isLoggedIn) {
                                      return Text(
                                        'লগইন করুন',
                                        style: TextStyle(
                                          color: AppColors.primaryColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      );
                                    } else {
                                      final profileController = Get.put(
                                        AdminProfileController(),
                                      );
                                      return Text(
                                        '${profileController.totalRewardPoints.value}',
                                        style: TextStyle(
                                          color: AppColors.primaryColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      );
                                    }
                                  }),
                                ),

                                AnimatedOpacity(
                                  opacity: _isBalance ? 1 : 0,
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(
                                    'পয়েন্টস দেখুন',
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 1100),
                                  left: !_isAnimation ? 5 : 110,
                                  curve: Curves.fastOutSlowIn,
                                  child: Container(
                                    height: 20,
                                    width: 20,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: const Text(
                                      '★',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Action Icons (Support, Notification, Logout)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Cart Icon
                        Obx(() {
                          final cartController = Get.find<CartController>();
                          final count = cartController.totalItemsCount;
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton(
                                icon: const FaIcon(
                                  FontAwesomeIcons.cartArrowDown,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  Get.to(
                                    () => const CartScreen(),
                                    transition: Transition.rightToLeft,
                                  );
                                },
                              ),
                              if (count > 0)
                                Positioned(
                                  right: -4,
                                  top: -4,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFBEF264),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1,
                                      ),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 14,
                                      minHeight: 14,
                                    ),
                                    child: Text(
                                      count > 99 ? '99+' : '$count',
                                      style: const TextStyle(
                                        color: Color(0xFF034F4B),
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }),
                        const SizedBox(width: 14),

                        // Notification
                        Obx(() {
                          final authController = Get.find<AuthController>();
                          final userMobile = authController.currentUserMobile.value;

                          if (userMobile.isEmpty) {
                            // Guest Customer
                            return IconButton(
                              icon: const Icon(
                                Icons.notifications_active_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                Get.snackbar(
                                  'নোটিফিকেশন',
                                  'নোটিফিকেশন দেখতে অনুগ্রহ করে লগইন করুন।',
                                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                                  colorText: Colors.black87,
                                  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
                                  borderWidth: 1,
                                  snackPosition: SnackPosition.BOTTOM,
                                  margin: const EdgeInsets.all(16),
                                );
                              },
                            );
                          }

                          return StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('notifications')
                                .where('userMobile', isEqualTo: userMobile)
                                .snapshots(),
                            builder: (context, snapshot) {
                              int unreadCount = 0;
                              if (snapshot.hasData) {
                                unreadCount = snapshot.data!.docs
                                    .where((doc) => doc.get('isRead') == false)
                                    .length;
                              }

                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.notifications_active_outlined,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      _showNotificationsDialog(context, userMobile);
                                    },
                                  ),
                                  if (unreadCount > 0)
                                    Positioned(
                                      right: -4,
                                      top: -4,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1,
                                          ),
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 14,
                                          minHeight: 14,
                                        ),
                                        child: Text(
                                          unreadCount > 99 ? '99+' : '$unreadCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          );
                        }),
                        const SizedBox(width: 14),

                        // Login / Logout
                        Obx(() {
                          final authController = Get.find<AuthController>();
                          final isLoggedIn =
                              authController.currentUserRole.value !=
                              'Guest Customer';

                          return IconButton(
                            icon: Icon(
                              isLoggedIn
                                  ? Icons.logout_rounded
                                  : Icons.login_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              if (isLoggedIn) {
                                Get.defaultDialog(
                                  title: 'লগআউট',
                                  middleText:
                                      'আপনি কি নিশ্চিত যে লগআউট করতে চান?',
                                  textCancel: 'বাতিল',
                                  textConfirm: 'লগআউট',
                                  confirmTextColor: Colors.white,
                                  buttonColor: Colors.redAccent,
                                  onConfirm: () async {
                                    await authController.logout();
                                    Get.offAll(() => const LoginScreen());
                                  },
                                );
                              } else {
                                Get.to(() => const LoginScreen());
                              }
                            },
                          );
                        }),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Bottom Row: Custom Search Bar
                const CustomSearchBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void animate() async {
    _isAnimation = true;
    _isBalance = false;
    setState(() {});

    await Future.delayed(
      const Duration(milliseconds: 800),
      () => setState(() => _isBalanceShown = true),
    );

    await Future.delayed(
      const Duration(seconds: 3),
      () => setState(() => _isBalanceShown = false),
    );

    await Future.delayed(
      const Duration(milliseconds: 200),
      () => setState(() => _isAnimation = false),
    );

    await Future.delayed(
      const Duration(milliseconds: 800),
      () => setState(() => _isBalance = true),
    );
  }

  void _showNotificationsDialog(BuildContext context, String userMobile) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          titlePadding: const EdgeInsets.fromLTRB(16, 16, 12, 8),
          actionsPadding: const EdgeInsets.only(right: 16, bottom: 8),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.notifications_active, color: Color(0xFF08B3AC), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'নোটিফিকেশনসমূহ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.done_all, color: Colors.grey, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'সব পঠিত হিসেবে চিহ্নিত করুন',
                onPressed: () async {
                  try {
                    final snapshot = await FirebaseFirestore.instance
                        .collection('notifications')
                        .where('userMobile', isEqualTo: userMobile)
                        .where('isRead', isEqualTo: false)
                        .get();
                    final batch = FirebaseFirestore.instance.batch();
                    for (var doc in snapshot.docs) {
                      batch.update(doc.reference, {'isRead': true});
                    }
                    await batch.commit();
                  } catch (e) {
                    debugPrint('Error marking notifications as read: $e');
                  }
                },
              ),
            ],
          ),
          content: Container(
            width: 300,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('userMobile', isEqualTo: userMobile)
                  .orderBy('createdAt', descending: true)
                  .limit(15)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: Text(
                        'কোন নোটিফিকেশন নেই',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: docs.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final String title = data['title'] ?? '';
                    final String body = data['body'] ?? '';
                    final bool isRead = data['isRead'] ?? false;
                    final Timestamp? createdAt = data['createdAt'] as Timestamp?;
                    
                    String formattedTime = '';
                    if (createdAt != null) {
                      final date = createdAt.toDate();
                      formattedTime = DateFormat('dd MMM, hh:mm a').format(date);
                    }

                    return InkWell(
                      onTap: () {
                        if (!isRead) {
                          doc.reference.update({'isRead': true});
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isRead)
                              const Padding(
                                padding: EdgeInsets.only(top: 5.0, right: 6.0),
                                child: Icon(Icons.circle, size: 6, color: Colors.blue),
                              ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    body,
                                    style: const TextStyle(fontSize: 11, color: Colors.black54, height: 1.3),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    formattedTime,
                                    style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('বন্ধ করুন', style: TextStyle(fontSize: 13)),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}
