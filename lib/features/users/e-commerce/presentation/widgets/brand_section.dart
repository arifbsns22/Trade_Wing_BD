import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/admin/ecommerce/presentation/controllers/ecommerce_controller.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import 'all_brands_page.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/screens/product_archive_screen.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/controllers/product_archive_controller.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/widgets/user_home_products.dart';
class BrandSection extends StatelessWidget {
  const BrandSection({super.key});

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
        size: 32,
        color: AppColors.primaryColor,
      );
    }

    if (imgStr.startsWith('data:image')) {
      try {
        final clean = imgStr.contains(',') ? imgStr.split(',')[1] : imgStr;
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(
            base64Decode(clean),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Icon(
              _getRandomIcon(name),
              size: 32,
              color: AppColors.primaryColor,
            ),
          ),
        );
      } catch (_) {
        return Icon(
          _getRandomIcon(name),
          size: 32,
          color: AppColors.primaryColor,
        );
      }
    }

    if (imgStr.startsWith('http') || imgStr.startsWith('https')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          imgStr,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            _getRandomIcon(name),
            size: 32,
            color: AppColors.primaryColor,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        imgStr,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Icon(_getRandomIcon(name), size: 32, color: AppColors.primaryColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final EcommerceController controller = Get.put(EcommerceController());

    return Obx(() {
      final brandsList = controller.brands;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'জনপ্রিয় ব্যান্ড',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Get.to(() => const AllBrandsPage());
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: const Text('সবগুলো দেখুন'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Horizontal Brands list
          if (brandsList.isEmpty)
            Container(
              height: 100,
              alignment: Alignment.center,
              child: Text(
                'কোনো ব্র্যান্ড পাওয়া যায়নি',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              ),
            )
          else
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: brandsList.length,
                itemBuilder: (context, index) {
                  final brand = brandsList[index];
                  final name = brand['name'] ?? '';
                  final image = brand['image'] ?? '';

                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        Get.to(
                          () => const ProductArchiveScreen(),
                          arguments: ProductArchiveArguments(
                            archiveTitle: name,
                            filterType: ProductTypeFilter.brand,
                            filterId: name,
                          ),
                          transition: Transition.rightToLeft,
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white,
                                width: 0.75,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.015),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: _buildBrandImage(image, name),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 80,
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.green,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      );
    });
  }
}
