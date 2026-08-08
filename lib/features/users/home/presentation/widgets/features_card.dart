import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/admin/traning/presentation/controllers/training_controller.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/screens/order_history_screen.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import 'package:trade_wign_bd/uitls/constants/app_texts.dart';
import 'package:trade_wign_bd/uitls/constants/assets_path/features_path.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/screens/all_products_screen.dart';
import 'package:trade_wign_bd/features/users/home/presentation/widgets/support_sheet.dart';
import 'package:trade_wign_bd/features/users/packages/presentation/screens/user_packages_screen.dart';
import 'package:trade_wign_bd/features/common/coming_soon_popuo.dart';
import 'package:trade_wign_bd/features/users/club/presentation/screens/business_club_screen.dart';
import 'package:trade_wign_bd/features/users/drive_pack/presentation/screens/user_drive_pack_screens.dart';
import 'package:trade_wign_bd/features/users/traning/presentation/screens/user_traning_screen.dart';

import 'package:trade_wign_bd/features/users/vendor/presentation/screens/vendor_dashboard_screen.dart';
import 'package:trade_wign_bd/features/users/reseller/presentation/screens/reseller_dashboard_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trade_wign_bd/features/users/home/presentation/widgets/verification_dialog.dart';

void _showActiveCustomerRequiredDialog(String targetRole) {
  Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.lock_outline_rounded, color: AppColors.green, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${targetRole == 'reseller' ? 'রিসেলার' : 'ভেন্ডর'} লক!',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Text(
        '${targetRole == 'reseller' ? 'রিসেলার' : 'ভেন্ডর'} হিসেবে আবেদন করতে হলে আপনাকে প্রথমে আমাদের মেম্বারশিপ প্যাকেজটি কিনে "সক্রিয় কাস্টমার" (Active Customer) হতে হবে।',
        style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('পরে করব', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            Get.back();
            Get.to(() => const UserPackagesScreen());
          },
          child: const Text('প্যাকেজ সমূহ'),
        ),
      ],
    ),
  );
}

class FeatureItem {
  final String title;
  final String imagePath;
  final VoidCallback? onTap;

  FeatureItem({required this.title, required this.imagePath, this.onTap});
}

final List<FeatureItem> featureList = [
  FeatureItem(
    title: AppTexts.ecommerce,
    imagePath: FeaturesPath.ecommerce,
    onTap: () {
      Get.to(() => const AllProductsScreen());
    },
  ),
  FeatureItem(
    title: AppTexts.drivePackage,
    imagePath: FeaturesPath.drivePackage,
    onTap: () {
      Get.to(() => const UserDrivePackScreen());
    },
  ),
  FeatureItem(
    title: AppTexts.reselling,
    imagePath: FeaturesPath.reselling,
    onTap: () async {
      final authController = Get.find<AuthController>();
      final role = authController.currentUserRole.value.toLowerCase().trim();

      // If already Reseller/Admin/Super Admin, go to dashboard
      if (role == 'reseller' || role == 'admin' || role == 'super admin') {
        Get.to(() => const ResellerDashboardScreen());
        return;
      }

      // If Guest/Guest Customer/Not Logged In, go to dashboard (which handles login flow)
      if (role == 'guest customer' || role == 'guest' || role == '') {
        Get.to(() => const ResellerDashboardScreen());
        return;
      }

      // If they are a normal Customer, they MUST purchase a membership package first
      if (role == 'customer') {
        _showActiveCustomerRequiredDialog('reseller');
        return;
      }

      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      try {
        final mobile = authController.currentUserMobile.value;
        final doc = await FirebaseFirestore.instance.collection('users').doc(mobile).get();
        Get.back(); // Dismiss loading

        if (doc.exists) {
          final data = doc.data() ?? {};
          final status = (data['resellerVerificationStatus'] ?? '').toString().toLowerCase().trim();

          if (status == 'approved') {
            authController.currentUserRole.value = 'reseller';
            Get.to(() => const ResellerDashboardScreen());
          } else if (status == 'pending' || status == 'hold' || status == 'rejected') {
            Get.dialog(VerificationStatusDialog(targetRole: 'reseller', status: status));
          } else {
            Get.dialog(const VerificationDialog(targetRole: 'reseller'));
          }
        } else {
          Get.dialog(const VerificationDialog(targetRole: 'reseller'));
        }
      } catch (e) {
        Get.back(); // Dismiss loading
        Get.snackbar(
          'ত্রুটি',
          'সার্ভার সংযোগে সমস্যা হয়েছে: $e',
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          colorText: Colors.black87,
          borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
          borderWidth: 1,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    },
  ),
  FeatureItem(
    title: AppTexts.vendorship,
    imagePath: FeaturesPath.vendorship,
    onTap: () async {
      final authController = Get.find<AuthController>();
      final role = authController.currentUserRole.value.toLowerCase().trim();

      // If already Vendor/Admin/Super Admin, go to dashboard
      if (role == 'vendor' || role == 'admin' || role == 'super admin') {
        Get.to(() => const VendorDashboardScreen());
        return;
      }

      // If Guest/Guest Customer/Not Logged In, go to dashboard (which handles login flow)
      if (role == 'guest customer' || role == 'guest' || role == '') {
        Get.to(() => const VendorDashboardScreen());
        return;
      }

      // If they are a normal Customer, they MUST purchase a membership package first
      if (role == 'customer') {
        _showActiveCustomerRequiredDialog('vendor');
        return;
      }

      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      try {
        final mobile = authController.currentUserMobile.value;
        final doc = await FirebaseFirestore.instance.collection('users').doc(mobile).get();
        Get.back(); // Dismiss loading

        if (doc.exists) {
          final data = doc.data() ?? {};
          final status = (data['vendorVerificationStatus'] ?? '').toString().toLowerCase().trim();

          if (status == 'approved') {
            authController.currentUserRole.value = 'vendor';
            Get.to(() => const VendorDashboardScreen());
          } else if (status == 'pending' || status == 'hold' || status == 'rejected') {
            Get.dialog(VerificationStatusDialog(targetRole: 'vendor', status: status));
          } else {
            Get.dialog(const VerificationDialog(targetRole: 'vendor'));
          }
        } else {
          Get.dialog(const VerificationDialog(targetRole: 'vendor'));
        }
      } catch (e) {
        Get.back(); // Dismiss loading
        Get.snackbar(
          'ত্রুটি',
          'সার্ভার সংযোগে সমস্যা হয়েছে: $e',
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          colorText: Colors.black87,
          borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
          borderWidth: 1,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    },
  ),

  FeatureItem(title: AppTexts.parcel, imagePath: FeaturesPath.parcel),
  FeatureItem(
    title: AppTexts.training,
    imagePath: FeaturesPath.training,
    onTap: () {
      Get.to(() => const UserTraningScreen());
    },
  ),
  FeatureItem(
    title: AppTexts.businessClub,
    imagePath: FeaturesPath.businessClub,
    onTap: () {
      Get.to(() => const BusinessClubScreen());
    },
  ),
  FeatureItem(title: AppTexts.others, imagePath: FeaturesPath.others),
  FeatureItem(
    title: AppTexts.support,
    imagePath: FeaturesPath.support,
    onTap: () {
      Get.bottomSheet(const SupportSheet(), isScrollControlled: true);
    },
  ),
  FeatureItem(
    title: "আমার অর্ডার",
    imagePath: "assets/color_icons/shopping-bag.png",
    onTap: () {
      Get.to(() => const OrderHistoryScreen());
    },
  ),
];

class FeatureGrid extends StatelessWidget {
  final List<FeatureItem> features;
  final void Function(FeatureItem)? onTap;

  const FeatureGrid({super.key, required this.features, this.onTap});

  void _showTrainingRequiredDialog(BuildContext context, String roleName, int pendingCount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_outline_rounded, color: Colors.orange, size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'ট্রেনিং সম্পন্ন করা বাধ্যতামূলক!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          'আপনার বর্তমান ব্যাজ ($roleName)-এর জন্য আরও $pendingCount টি ট্রেনিং বাকি আছে। অ্যাপের সকল সুবিধা ব্যবহার করতে প্রথমে ট্রেনিংগুলো সম্পন্ন করুন।',
          style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('পরে করব', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              Get.to(() => const UserTraningScreen());
            },
            child: const Text('ট্রেনিং পেজে যান'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final trainingController = Get.put(TrainingController());

    // Split features into rows of 5 items
    final List<List<FeatureItem>> rows = [];
    for (var i = 0; i < features.length; i += 5) {
      rows.add(
        features.sublist(i, i + 5 > features.length ? features.length : i + 5),
      );
    }

    return Column(
      children: [
        for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
          if (rowIndex > 0) const SizedBox(height: 12), // Spacing between rows
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final feature in rows[rowIndex])
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final title = feature.title;
                      final isAlwaysUnlocked = title == AppTexts.training ||
                          title == AppTexts.support ||
                          title == "আমার অর্ডার";

                      if (!isAlwaysUnlocked) {
                        final currentRole = authController.currentUserRole.value;
                        final currentMobile = authController.currentUserMobile.value.trim();
                        final userId = currentMobile.isNotEmpty ? currentMobile : 'guest_user';

                        final pendingCount = await trainingController.getPendingTrainingsCountAsync(
                          userRole: currentRole,
                          userId: userId,
                        );

                        if (pendingCount > 0) {
                          trainingController.checkAndSendTrainingNotification(
                            userId: userId,
                            userRole: currentRole,
                          );
                          final roleBangla = TrainingController.getRoleBangla(currentRole);
                          if (context.mounted) {
                            _showTrainingRequiredDialog(context, roleBangla, pendingCount);
                          }
                          return;
                        }
                      }

                      if (feature.onTap != null) {
                        feature.onTap!();
                      } else if (onTap != null) {
                        onTap?.call(feature);
                      } else {
                        ComingSoonPopup.show(context);
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white,
                              width: 0.75,
                            ),
                          ),
                          child: Image.asset(
                            feature.imagePath,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          feature.title,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.green,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
