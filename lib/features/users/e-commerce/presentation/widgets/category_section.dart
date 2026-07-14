import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/admin/ecommerce/presentation/controllers/ecommerce_controller.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import 'all_categories_page.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/screens/product_archive_screen.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/controllers/product_archive_controller.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/widgets/user_home_products.dart';
class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

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
      final categoriesList = controller.categories;

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
                  'জনপ্রিয় ক্যাটাগরি',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Get.to(() => const AllCategoriesPage());
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

          // Horizontal Categories list
          if (categoriesList.isEmpty)
            Container(
              height: 100,
              alignment: Alignment.center,
              child: Text(
                'কোনো ক্যাটাগরি পাওয়া যায়নি',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              ),
            )
          else
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: categoriesList.length,
                itemBuilder: (context, index) {
                  final category = categoriesList[index];
                  final name = category['name'] ?? '';
                  final image = category['image'] ?? '';

                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        Get.to(
                          () => const ProductArchiveScreen(),
                          arguments: ProductArchiveArguments(
                            archiveTitle: name,
                            filterType: ProductTypeFilter.category,
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
                            child: _buildCategoryImage(image, name),
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
