import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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

      title: const DynamicAppLogo(isDark: false, height: 36),

      // Right Side: Bell (Notifications) and Log Out Buttons
      actions: [
        // Bell Icon (Notifications with red dot/badge)
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('notifications')
              .where('isAdmin', isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            int unreadCount = 0;
            if (snapshot.hasData) {
              unreadCount = snapshot.data!.docs
                  .where((doc) => doc.get('isRead') == false)
                  .length;
            }

            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    unreadCount > 0
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_none_rounded,
                    color: unreadCount > 0
                        ? const Color(0xFF08B3AC)
                        : AppColors.primaryColor,
                    size: 26,
                  ),
                  onPressed: () {
                    _showNotificationsDialog(context);
                  },
                  tooltip: 'নোটিফিকেশনস',
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Center(
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
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

  // Show notifications dialog with real Firestore notifications
  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          titlePadding: const EdgeInsets.fromLTRB(16, 16, 12, 8),
          actionsPadding: const EdgeInsets.only(right: 16, bottom: 8),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    color: Color(0xFF08B3AC),
                    size: 20,
                  ),
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
                tooltip: 'সকল নোটিফিকেশন দেখেছি',
                onPressed: () async {
                  try {
                    final snapshot = await FirebaseFirestore.instance
                        .collection('notifications')
                        .where('isAdmin', isEqualTo: true)
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
                  .where('isAdmin', isEqualTo: true)
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

                // Sort locally to prevent Firestore composite index requirement
                final docs = List<QueryDocumentSnapshot>.from(
                  snapshot.data!.docs,
                );
                docs.sort((a, b) {
                  Timestamp? tsA;
                  Timestamp? tsB;
                  try {
                    tsA = a.get('createdAt') as Timestamp?;
                  } catch (_) {}
                  try {
                    tsB = b.get('createdAt') as Timestamp?;
                  } catch (_) {}

                  if (tsA == null && tsB == null) return 0;
                  if (tsA == null) return 1;
                  if (tsB == null) return -1;
                  return tsB.compareTo(tsA);
                });
                final limitedDocs = docs.take(15).toList();

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: limitedDocs.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, thickness: 0.5),
                  itemBuilder: (context, index) {
                    final doc = limitedDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final String title = data['title'] ?? '';
                    final String body = data['body'] ?? '';
                    final bool isRead = data['isRead'] ?? false;
                    final Timestamp? createdAt =
                        data['createdAt'] as Timestamp?;

                    String formattedTime = '';
                    if (createdAt != null) {
                      final date = createdAt.toDate();
                      formattedTime = DateFormat(
                        'dd MMM, hh:mm a',
                      ).format(date);
                    }

                    return InkWell(
                      onTap: () {
                        if (!isRead) {
                          doc.reference.update({'isRead': true});
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 4.0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isRead)
                              const Padding(
                                padding: EdgeInsets.only(top: 5.0, right: 6.0),
                                child: Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: Colors.blue,
                                ),
                              ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isRead
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    body,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.black54,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    formattedTime,
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey.shade500,
                                    ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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
