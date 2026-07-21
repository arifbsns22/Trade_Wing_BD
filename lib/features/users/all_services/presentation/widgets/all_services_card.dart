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
import 'package:trade_wign_bd/features/common/coming_soon_popuo.dart';
import 'package:trade_wign_bd/features/users/club/presentation/screens/business_club_screen.dart';
import 'package:trade_wign_bd/features/users/drive_pack/presentation/screens/user_drive_pack_screens.dart';
import 'package:trade_wign_bd/features/users/traning/presentation/screens/user_traning_screen.dart';

class AllServicesItem {
  final String title;
  final String imagePath;
  final VoidCallback? onTap;

  AllServicesItem({required this.title, required this.imagePath, this.onTap});
}

final List<AllServicesItem> featureList = [
  AllServicesItem(
    title: AppTexts.ecommerce,
    imagePath: FeaturesPath.ecommerce,
    onTap: () {
      Get.to(() => const AllProductsScreen());
    },
  ),
  AllServicesItem(
    title: AppTexts.drivePackage,
    imagePath: FeaturesPath.drivePackage,
    onTap: () {
      Get.to(() => const UserDrivePackScreen());
    },
  ),
  AllServicesItem(title: AppTexts.reselling, imagePath: FeaturesPath.reselling),
  AllServicesItem(
    title: AppTexts.vendorship,
    imagePath: FeaturesPath.vendorship,
  ),

  AllServicesItem(title: AppTexts.parcel, imagePath: FeaturesPath.parcel),
  AllServicesItem(
    title: AppTexts.training,
    imagePath: FeaturesPath.training,
    onTap: () {
      Get.to(() => const UserTraningScreen());
    },
  ),
  AllServicesItem(
    title: AppTexts.businessClub,
    imagePath: FeaturesPath.businessClub,
    onTap: () {
      Get.to(() => const BusinessClubScreen());
    },
  ),
  AllServicesItem(title: AppTexts.others, imagePath: FeaturesPath.others),
  AllServicesItem(
    title: AppTexts.support,
    imagePath: FeaturesPath.support,
    onTap: () {
      Get.bottomSheet(const SupportSheet(), isScrollControlled: true);
    },
  ),
  AllServicesItem(
    title: "আমার অর্ডার",
    imagePath: "assets/color_icons/shopping-bag.png",
    onTap: () {
      Get.to(() => const OrderHistoryScreen());
    },
  ),
];

class AllServicesGrid extends StatelessWidget {
  final List<AllServicesItem> features;
  final void Function(AllServicesItem)? onTap;

  const AllServicesGrid({super.key, required this.features, this.onTap});

  void _showTrainingRequiredDialog(
    BuildContext context,
    String roleName,
    int pendingCount,
  ) {
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
          'আপনার বর্তমান রোল ($roleName)-এর জন্য আরও $pendingCount টি ট্রেনিং বাকি আছে। অ্যাপের সকল সুবিধা ব্যবহার করতে প্রথমে ট্রেনিংগুলো সম্পন্ন করুন।',
          style: const TextStyle(
            fontSize: 13,
            height: 1.4,
            color: Colors.black87,
          ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
    final List<List<AllServicesItem>> rows = [];
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
                      final isAlwaysUnlocked =
                          title == AppTexts.training ||
                          title == AppTexts.support ||
                          title == "আমার অর্ডার";

                      if (!isAlwaysUnlocked) {
                        final currentRole =
                            authController.currentUserRole.value;
                        final currentMobile = authController
                            .currentUserMobile
                            .value
                            .trim();
                        final userId = currentMobile.isNotEmpty
                            ? currentMobile
                            : 'guest_user';

                        final pendingCount = await trainingController
                            .getPendingTrainingsCountAsync(
                              userRole: currentRole,
                              userId: userId,
                            );

                        if (pendingCount > 0) {
                          trainingController.checkAndSendTrainingNotification(
                            userId: userId,
                            userRole: currentRole,
                          );
                          final roleBangla = TrainingController.getRoleBangla(
                            currentRole,
                          );
                          if (context.mounted) {
                            _showTrainingRequiredDialog(
                              context,
                              roleBangla,
                              pendingCount,
                            );
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
