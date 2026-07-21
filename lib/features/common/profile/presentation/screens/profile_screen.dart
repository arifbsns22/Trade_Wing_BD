import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:trade_wign_bd/features/users/home/presentation/widgets/support_sheet.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import 'package:trade_wign_bd/features/auth/presentation/screens/login_screen.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import '../controllers/admin_profile_controller.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/profile_stat_tile.dart';
import '../widgets/referral_code_card.dart';
import '../widgets/help_text_referall_code_sheet.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/screens/order_history_screen.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

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
                          const SizedBox(
                            height: 48,
                            child: Center(
                              child: Text(
                                'প্রোফাইল',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
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
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Obx(
                                    () =>
                                        controller.profilePicture.value.isEmpty
                                        ? const CircleAvatar(
                                            radius: 55,
                                            backgroundColor: Color(0xFFFDE8E1),
                                            child: Icon(
                                              Icons.person,
                                              size: 50,
                                              color: Colors.grey,
                                            ),
                                          )
                                        : CircleAvatar(
                                            radius: 55,
                                            backgroundColor: const Color(
                                              0xFFFDE8E1,
                                            ),
                                            backgroundImage:
                                                controller.profilePicture.value
                                                    .startsWith('http')
                                                ? NetworkImage(
                                                        controller
                                                            .profilePicture
                                                            .value,
                                                      )
                                                      as ImageProvider
                                                : MemoryImage(
                                                    base64Decode(
                                                      controller
                                                          .profilePicture
                                                          .value
                                                          .split(',')
                                                          .last,
                                                    ),
                                                  ),
                                          ),
                                  ),
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
                          const SizedBox(height: 6),

                          // User Name
                          Text(
                            controller.name.value,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Mobile
                          Text(
                            controller.mobile.value,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 2),

                          // Email
                          if (controller.email.value.isNotEmpty)
                            Text(
                              controller.email.value,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          const SizedBox(height: 8),

                          // User Role
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_user_rounded,
                                  size: 14,
                                  color: AppColors.primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  authController.currentUserRole.value ==
                                          'Super Admin'
                                      ? 'সুপার এডমিন'
                                      : (authController
                                                .currentUserRole
                                                .value
                                                .isEmpty
                                            ? 'ইউজার'
                                            : authController
                                                  .currentUserRole
                                                  .value),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
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
                      child: Row(
                        children: [
                          Expanded(
                            child: ProfileStatTile(
                              label: 'রিওয়ার্ড পয়েন্ট',
                              value: '${controller.totalRewardPoints.value}',
                              icon: Icons.stars_rounded,
                              iconColor: Colors.amber,
                            ),
                          ),
                          const VerticalDivider(
                            width: 1,
                            thickness: 1,
                            indent: 8,
                            endIndent: 8,
                          ),
                          Expanded(
                            child: ProfileStatTile(
                              label: 'মোট কেনাকাটা',
                              value:
                                  '৳${controller.totalPurchasedAmount.value.toStringAsFixed(0)}',
                              icon: Icons.shopping_bag_rounded,
                              iconColor: const Color(0xFF08B3AC),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Referral Code Card (Copy code option)
                    ReferralCodeCard(
                      code: controller.referralCode.value,
                      onCopy: controller.copyReferralCode,
                      role: authController.currentUserRole.value,
                      onCustomerTap: () {
                        Get.bottomSheet(
                          const HelpTextReferralCodeSheet(),
                          isScrollControlled: true,
                        );
                      },
                    ),
                    const SizedBox(height: 16),

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
                      leadingIcon: Icons.shopping_cart_checkout_rounded,
                      title: 'অর্ডার সমুহ',
                      onTap: () {
                        Get.to(() => const OrderHistoryScreen());
                      },
                    ),

                    ProfileMenuItem(
                      leadingIcon: Icons.person_outline_rounded,
                      title: 'প্রোফাইল সংশোধন',
                      onTap: () {
                        _showEditProfileBottomSheet(context, controller);
                      },
                    ),

                    ProfileMenuItem(
                      leadingIcon: Icons.location_on_outlined,
                      title: 'আমার ঠিকানা',
                      onTap: () {
                        _showUpdateAddressBottomSheet(context, controller);
                      },
                    ),

                    ProfileMenuItem(
                      leadingIcon: Icons.account_balance_wallet_outlined,
                      title: 'ডিজিটাল মানিব্যাগ',
                      onTap: () {
                        Get.snackbar(
  'তথ্য',
  'ডিজিটাল মানিব্যাগ শীঘ্রই আসছে',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
                      },
                    ),

                    // Additional menu items
                    ProfileMenuItem(
                      leadingIcon: Icons.lock_outline_rounded,
                      title: 'পাসওয়ার্ড পরিবর্তন',
                      onTap: () {
                        _showChangePasswordBottomSheet(context, controller);
                      },
                    ),

                    ProfileMenuItem(
                      leadingIcon: Icons.support_agent_rounded,
                      title: 'সাপোর্ট',
                      onTap: () {
                        Get.bottomSheet(
                          const SupportSheet(),
                          isScrollControlled: true,
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
                    const SizedBox(height: 100),
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
  void _showEditProfileBottomSheet(
    BuildContext context,
    AdminProfileController controller,
  ) {
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
                      borderSide: BorderSide(
                        color: AppColors.primaryColor,
                        width: 1.5,
                      ),
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
                      borderSide: BorderSide(
                        color: AppColors.primaryColor,
                        width: 1.5,
                      ),
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

  // Update Address Bottom Sheet
  void _showUpdateAddressBottomSheet(
    BuildContext context,
    AdminProfileController controller,
  ) {
    final houseController = TextEditingController();
    final streetController = TextEditingController();
    final cityController = TextEditingController();
    final divisionController = TextEditingController();
    final postcodeController = TextEditingController();

    // Optional: Try to prefill
    if (controller.address.value.isNotEmpty) {
      streetController.text = controller.address.value;
    }
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
                const SizedBox(height: 24),
                const Text(
                  'ঠিকানা আপডেট করুন',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'আপনার পণ্য এবং প্যাকেজ ডেলিভারির জন্য সঠিক ঠিকানা দিন',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 24),

                // Address Inputs
                _buildAddressInput(houseController, 'বাড়ি / বাসা নম্বর'),
                _buildAddressInput(streetController, 'রাস্তার নাম / এলাকা'),
                _buildAddressInput(cityController, 'শহর / উপজেলা'),
                _buildAddressInput(divisionController, 'বিভাগ / জেলা'),
                _buildAddressInput(postcodeController, 'পোস্টকোড / জিপকোড'),
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
                      child: Obx(
                        () => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: controller.isLoading.value
                              ? null
                              : () async {
                                  if (formKey.currentState!.validate()) {
                                    final fullAddress =
                                        'বাসা: ${houseController.text.trim()}, রাস্তা: ${streetController.text.trim()}, শহর: ${cityController.text.trim()}, বিভাগ: ${divisionController.text.trim()}, পোস্টকোড: ${postcodeController.text.trim()}';
                                    final success = await controller
                                        .updateAddress(fullAddress);
                                    if (success) {
                                      Get.back();
                                    }
                                  }
                                },
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('সংরক্ষণ করুন'),
                        ),
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

  Widget _buildAddressInput(TextEditingController ctrl, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'অনুগ্রহ করে পূরণ করুন';
          }
          return null;
        },
      ),
    );
  }

  // Change Password Bottom Sheet
  void _showChangePasswordBottomSheet(
    BuildContext context,
    AdminProfileController controller,
  ) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final RxBool isOldPasswordVisible = false.obs;
    final RxBool isNewPasswordVisible = false.obs;
    final RxBool isConfirmPasswordVisible = false.obs;

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
                  'পাসওয়ার্ড পরিবর্তন করুন',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // Old Password
                const Text(
                  'পুরাতন পাসওয়ার্ড',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => TextFormField(
                    controller: oldPasswordController,
                    obscureText: !isOldPasswordVisible.value,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isOldPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 20,
                        ),
                        onPressed: () => isOldPasswordVisible.value =
                            !isOldPasswordVisible.value,
                      ),
                      hintText: 'পুরাতন পাসওয়ার্ড লিখুন',
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
                        borderSide: BorderSide(
                          color: AppColors.primaryColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'অনুগ্রহ করে পুরাতন পাসওয়ার্ড লিখুন'
                        : null,
                  ),
                ),
                const SizedBox(height: 16),

                // New Password
                const Text(
                  'নতুন পাসওয়ার্ড',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => TextFormField(
                    controller: newPasswordController,
                    obscureText: !isNewPasswordVisible.value,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isNewPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 20,
                        ),
                        onPressed: () => isNewPasswordVisible.value =
                            !isNewPasswordVisible.value,
                      ),
                      hintText: 'নতুন পাসওয়ার্ড লিখুন',
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
                        borderSide: BorderSide(
                          color: AppColors.primaryColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'অনুগ্রহ করে নতুন পাসওয়ার্ড লিখুন';
                      if (value.length < 6)
                        return 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm Password
                const Text(
                  'নতুন পাসওয়ার্ড নিশ্চিত করুন',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => TextFormField(
                    controller: confirmPasswordController,
                    obscureText: !isConfirmPasswordVisible.value,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isConfirmPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 20,
                        ),
                        onPressed: () => isConfirmPasswordVisible.value =
                            !isConfirmPasswordVisible.value,
                      ),
                      hintText: 'নতুন পাসওয়ার্ড আবার লিখুন',
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
                        borderSide: BorderSide(
                          color: AppColors.primaryColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'অনুগ্রহ করে পাসওয়ার্ড নিশ্চিত করুন';
                      if (value != newPasswordController.text)
                        return 'পাসওয়ার্ড মিলেনি';
                      return null;
                    },
                  ),
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
                            final success = await controller.changePassword(
                              oldPassword: oldPasswordController.text,
                              newPassword: newPasswordController.text,
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
