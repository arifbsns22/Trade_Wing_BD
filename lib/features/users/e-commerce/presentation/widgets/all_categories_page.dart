import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/common/ui/widgets/appbar/primary_appbar.dart';
import 'package:trade_wign_bd/features/admin/ecommerce/presentation/controllers/ecommerce_controller.dart';
import 'package:trade_wign_bd/features/common/bottom_navbar_menu.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class AllCategoriesPage extends StatelessWidget {
  const AllCategoriesPage({super.key});

  IconData _getRandomIcon(String seed) {
    final List<IconData> icons = [
      Icons.category_outlined,
      Icons.shopping_bag_outlined,
      Icons.style_outlined,
      Icons.local_offer_outlined,
      Icons.grid_view_rounded,
      Icons.widgets_outlined,
      Icons.dashboard_customize_outlined,
      Icons.storefront_outlined,
    ];
    final index = seed.hashCode.abs() % icons.length;
    return icons[index];
  }

  Widget _buildCategoryImage(String imgStr, String name) {
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
          title: 'All Categories',
          titleColor: Colors.black87,
          onIconPressed: () {
            // Brings user to UserDashboardScreen (index 0 of BottomNavBarMenu)
            Get.offAll(() => const BottomNavBarMenu());
          },
        ),
      ),
      body: Obx(() {
        final categoriesList = controller.categories;

        if (categoriesList.isEmpty) {
          return Center(
            child: Text(
              'কোনো ক্যাটাগরি পাওয়া যায়নি',
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
          itemCount: categoriesList.length,
          itemBuilder: (context, index) {
            final category = categoriesList[index];
            final name = category['name'] ?? '';
            final image = category['image'] ?? '';

            return GestureDetector(
              onTap: () {
                // Handle category filter on click
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
                    child: _buildCategoryImage(image, name),
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
