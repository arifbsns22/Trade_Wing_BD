import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/common/ui/widgets/appbar/primary_appbar.dart';
import 'package:trade_wign_bd/features/admin/ecommerce/presentation/controllers/ecommerce_controller.dart';
import 'package:trade_wign_bd/features/common/bottom_navbar_menu.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class AllBrandsPage extends StatelessWidget {
  const AllBrandsPage({super.key});

  IconData _getRandomIcon(String seed) {
    final List<IconData> icons = [
      Icons.copyright_outlined,
      Icons.verified_outlined,
      Icons.stars_outlined,
      Icons.diamond_outlined,
      Icons.workspace_premium_outlined,
      Icons.bookmark_outline,
      Icons.lightbulb_outline,
      Icons.badge_outlined,
    ];
    final index = seed.hashCode.abs() % icons.length;
    return icons[index];
  }

  Widget _buildBrandImage(String imgStr, String name) {
    if (imgStr.isEmpty) {
      return Icon(
        _getRandomIcon(name),
        size: 24,
        color: AppColors.primaryColor,
      );
    }

    if (imgStr.startsWith('data:image')) {
      try {
        final clean = imgStr.contains(',') ? imgStr.split(',')[1] : imgStr;
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            base64Decode(clean),
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Icon(_getRandomIcon(name), size: 24, color: AppColors.primaryColor),
          ),
        );
      } catch (_) {
        return Icon(_getRandomIcon(name), size: 24, color: AppColors.primaryColor);
      }
    }

    if (imgStr.startsWith('http') || imgStr.startsWith('https')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imgStr,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(_getRandomIcon(name), size: 24, color: AppColors.primaryColor),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        imgStr,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(_getRandomIcon(name), size: 24, color: AppColors.primaryColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final EcommerceController controller = Get.find<EcommerceController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: PrimaryAppBar(
          iconColor: Colors.black,
          title: 'All Brands',
          titleColor: Colors.black87,
          onIconPressed: () {
            // Brings user to UserDashboardScreen (index 0 of BottomNavBarMenu)
            Get.offAll(() => const BottomNavBarMenu());
          },
        ),
      ),
      body: Obx(() {
        final brandsList = controller.brands;

        if (brandsList.isEmpty) {
          return Center(
            child: Text(
              'কোনো ব্র্যান্ড পাওয়া যায়নি',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: brandsList.length,
          itemBuilder: (context, index) {
            final brand = brandsList[index];
            final name = brand['name'] ?? '';
            final image = brand['image'] ?? '';

            return GestureDetector(
              onTap: () {
                // Handle brand filter on click
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white,
                        width: 0.75,
                      ),
                    ),
                    child: _buildBrandImage(image, name),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.green,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
