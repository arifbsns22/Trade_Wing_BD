import 'package:flutter/material.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import 'package:trade_wign_bd/uitls/constants/app_texts.dart';
import 'package:trade_wign_bd/uitls/constants/assets_path/features_path.dart';

class AdminFeatureItem {
  final String title;
  final String imagePath;
  final VoidCallback? onTap;

  AdminFeatureItem({required this.title, required this.imagePath, this.onTap});
}

final List<AdminFeatureItem> adminfeatureList = [
  AdminFeatureItem(title: "ইউজার", imagePath: FeaturesPath.ecommerce),
  AdminFeatureItem(
    title: AppTexts.ecommerce,
    imagePath: FeaturesPath.ecommerce,
  ),
  AdminFeatureItem(
    title: AppTexts.drivePackage,
    imagePath: FeaturesPath.drivePackage,
  ),
  AdminFeatureItem(
    title: AppTexts.reselling,
    imagePath: FeaturesPath.reselling,
  ),
  AdminFeatureItem(
    title: AppTexts.vendorship,
    imagePath: FeaturesPath.vendorship,
  ),
  AdminFeatureItem(title: AppTexts.b2b, imagePath: FeaturesPath.b2b),
  AdminFeatureItem(title: AppTexts.parcel, imagePath: FeaturesPath.parcel),
  AdminFeatureItem(title: AppTexts.training, imagePath: FeaturesPath.training),
  AdminFeatureItem(
    title: AppTexts.businessClub,
    imagePath: FeaturesPath.businessClub,
  ),
  AdminFeatureItem(title: "সেটিংস", imagePath: FeaturesPath.others),
  AdminFeatureItem(title: AppTexts.support, imagePath: FeaturesPath.support),
];

class AdminFeatureGrid extends StatelessWidget {
  final List<AdminFeatureItem> features;
  final void Function(AdminFeatureItem)? onTap;

  const AdminFeatureGrid({super.key, required this.features, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: features.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 0.75,
        crossAxisSpacing: 1,
        mainAxisSpacing: 5,
      ),
      itemBuilder: (context, index) {
        final feature = features[index];
        return GestureDetector(
          onTap: () => onTap?.call(feature),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 0.75),
                ),
                child: Image.asset(
                  feature.imagePath,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 6),
              Text(
                feature.title,
                style: TextStyle(fontSize: 12, color: AppColors.green),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
