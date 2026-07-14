import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import 'package:trade_wign_bd/features/auth/presentation/screens/login_screen.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import 'package:trade_wign_bd/features/common/profile/presentation/controllers/admin_profile_controller.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/profile_stat_tile.dart';
import '../widgets/referral_code_card.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate or find the controller
    final controller = Get.put(AdminProfileController());
    final authController = AuthController.instance;

    // Reactive switch state for demo toggle
    final RxBool isSystemActive = true.obs;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Obx(() {
        if (controller.isLoading.value && controller.name.value.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF08B3AC)),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Top Section: Gradient and Profile Picture
              Stack(
                children: [
                  // Beautiful Peach Gradient Background
                  Container(
                    height: 280,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFFECE5),
                          const Color(0xFFFFF7F4),
                          Colors.grey.shade50,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // Content
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          // Header: Custom Profile AppBar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.black87,
                                  size: 20,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const Text(
                                'প্রোফাইল',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 48),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Large Profile Avatar with Edit Badge
                          Center(
                            child: Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Obx(() {
                                    final hasPic = controller.profilePicture.value.isNotEmpty;
                                    ImageProvider? imageProvider;
                                    if (hasPic) {
                                      final picVal = controller.profilePicture.value;
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

                                    return CircleAvatar(
                                      radius: 55,
                                      backgroundColor: const Color(0xFFFDE8E1),
                                      backgroundImage: imageProvider,
                                      child: imageProvider == null
                                          ? const Icon(
                                              Icons.person,
                                              size: 50,
                                              color: Colors.grey,
                                            )
                                          : null,
                                    );
                                  }),
                                ),
                                Positioned(
                                  bottom: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      controller.pickAndUploadProfilePicture();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF08B3AC),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Admin Name
                          Text(
                            controller.name.value,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Admin Role & Mobile/Email Detail Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.verified_user_rounded,
                                size: 14,
                                color: AppColors.primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                authController.currentUserRole.value == 'Super Admin'
                                    ? 'সুপার এডমিন'
                                    : 'এডমিন',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Rest of Content (Cards, Stats, Menu Items)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // Stats Row Card (AVG rating, Rank, Total Job style)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          ProfileStatTile(
                            label: 'AVG. rating',
                            value: '4.9',
                            icon: Icons.star_rounded,
                            iconColor: Colors.amber,
                          ),
                          VerticalDivider(width: 1, thickness: 1, indent: 8, endIndent: 8),
                          ProfileStatTile(
                            label: 'Current rank',
                            value: 'Top 5%',
                            icon: Icons.emoji_events_rounded,
                            iconColor: Colors.orange,
                          ),
                          VerticalDivider(width: 1, thickness: 1, indent: 8, endIndent: 8),
                          ProfileStatTile(
                            label: 'Total Active',
                            value: '128',
                            icon: Icons.people_alt_rounded,
                            iconColor: Color(0xFF08B3AC),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Referral Code Card (Copy code option)
                    ReferralCodeCard(
                      code: controller.referralCode.value,
                      onCopy: controller.copyReferralCode,
                    ),
                    const SizedBox(height: 16),

                    // Toggle Switch Card (Switch to Hire Mode style)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.sync_rounded,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'সিস্টেম স্ট্যাটাস সক্রিয়',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          Obx(() => Switch(
                            value: isSystemActive.value,
                            activeTrackColor: AppColors.primaryColor,
                            onChanged: (value) {
                              isSystemActive.value = value;
                            },
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // General Section Title
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 4.0, bottom: 12.0),
                        child: Text(
                          'সাধারণ সেটিংস',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),

                    // Profile Settings Option
                    ProfileMenuItem(
                      leadingIcon: Icons.person_outline_rounded,
                      title: 'প্রোফাইল সংশোধন',
                      onTap: () {
                        _showEditProfileBottomSheet(context, controller);
                      },
                    ),

                    // Phone & Email details (Display info)
                    ProfileMenuItem(
                      leadingIcon: Icons.phone_android_rounded,
                      title: 'মোবাইল: ${controller.mobile.value}',
                      trailing: const SizedBox.shrink(),
                      onTap: () {},
                    ),

                    ProfileMenuItem(
                      leadingIcon: Icons.mail_outline_rounded,
                      title: controller.email.value.isEmpty 
                          ? 'ইমেইল যুক্ত করুন' 
                          : 'ইমেইল: ${controller.email.value}',
                      onTap: () {
                        _showEditProfileBottomSheet(context, controller);
                      },
                    ),

                    // Additional menu items
                    ProfileMenuItem(
                      leadingIcon: Icons.lock_outline_rounded,
                      title: 'পাসওয়ার্ড পরিবর্তন',
                      onTap: () {
                        Get.snackbar(
  'তথ্য',
  'পাসওয়ার্ড পরিবর্তন ফিচারটি শীঘ্রই আসছে',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
                      },
                    ),

                    ProfileMenuItem(
                      leadingIcon: Icons.help_outline_rounded,
                      title: 'সহায়তা ও সমর্থন',
                      onTap: () {
                        Get.snackbar(
  'তথ্য',
  'সহায়তা ও সমর্থন সেন্টার শীঘ্রই চালু হবে',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
                      },
                    ),

                    // Logout Option
                    ProfileMenuItem(
                      leadingIcon: Icons.logout_rounded,
                      title: 'লগআউট',
                      iconColor: Colors.redAccent,
                      textColor: Colors.redAccent,
                      onTap: () {
                        _showLogoutConfirmation(context, authController);
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // Edit Profile Bottom Sheet
  void _showEditProfileBottomSheet(BuildContext context, AdminProfileController controller) {
    final nameController = TextEditingController(text: controller.name.value);
    final emailController = TextEditingController(text: controller.email.value);
    final formKey = GlobalKey<FormState>();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'প্রোফাইল সংশোধন করুন',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Name Field
                const Text(
                  'নাম',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline, size: 20),
                    hintText: 'আপনার নাম লিখুন',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'অনুগ্রহ করে নাম লিখুন';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email Field
                const Text(
                  'ইমেইল',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.mail_outline, size: 20),
                    hintText: 'আপনার ইমেইল লিখুন',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      if (!GetUtils.isEmail(value.trim())) {
                        return 'অনুগ্রহ করে সঠিক ইমেইল এড্রেস লিখুন';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          'বাতিল',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        onPressed: () => Get.back(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('সংরক্ষণ করুন'),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final success = await controller.updateProfile(
                              newName: nameController.text.trim(),
                              newEmail: emailController.text.trim(),
                            );
                            if (success) {
                              Get.back();
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // Logout confirmation dialog
  void _showLogoutConfirmation(BuildContext context, AuthController authController) {
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
