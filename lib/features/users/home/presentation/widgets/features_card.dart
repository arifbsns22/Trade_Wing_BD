import 'package:flutter/material.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import 'package:trade_wign_bd/uitls/constants/app_texts.dart';
import 'package:trade_wign_bd/uitls/constants/assets_path/features_path.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/screens/all_products_screen.dart';
import 'package:trade_wign_bd/features/users/home/presentation/widgets/support_sheet.dart';
import 'package:trade_wign_bd/features/common/coming_soon_popuo.dart';
import 'package:trade_wign_bd/features/users/club/presentation/screens/business_club_screen.dart';

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
  ),
  FeatureItem(title: AppTexts.reselling, imagePath: FeaturesPath.reselling),
  FeatureItem(title: AppTexts.vendorship, imagePath: FeaturesPath.vendorship),

  FeatureItem(title: AppTexts.parcel, imagePath: FeaturesPath.parcel),
  FeatureItem(title: AppTexts.training, imagePath: FeaturesPath.training),
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
      Get.bottomSheet(
        const SupportSheet(),
        isScrollControlled: true,
      );
    },
  ),
];

class FeatureGrid extends StatelessWidget {
  final List<FeatureItem> features;
  final void Function(FeatureItem)? onTap;

  const FeatureGrid({super.key, required this.features, this.onTap});

  @override
  Widget build(BuildContext context) {
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
                    onTap: () {
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
