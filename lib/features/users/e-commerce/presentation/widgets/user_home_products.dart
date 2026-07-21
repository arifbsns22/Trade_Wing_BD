import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/screens/product_archive_screen.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/screens/product_detail_screen.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/screens/all_products_screen.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/widgets/product_card.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/controllers/product_archive_controller.dart';
import 'package:trade_wign_bd/features/admin/ecommerce/presentation/controllers/ecommerce_controller.dart';
import 'package:trade_wign_bd/features/admin/ecommerce/domain/models/product_model.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

/// Defines the data source filter criteria for the product section
enum ProductTypeFilter {
  recent,
  category,
  brand,
  productType, // Represents broad product type like 'medicine', 'grocery'
}

class UserHomeProducts extends StatelessWidget {
  final String sectionTitle;
  final ProductTypeFilter categoryType;
  final String? filterId;

  const UserHomeProducts({
    super.key,
    required this.sectionTitle,
    required this.categoryType,
    this.filterId,
  });

  @override
  Widget build(BuildContext context) {
    // We hook into the existing EcommerceController (or a dedicated UserProductController)
    // The controller should manage offline-first capabilities via Hive/Isar caching.
    final EcommerceController controller = Get.find<EcommerceController>();

    return Obx(() {
      // 1. Data Pipeline & State Management
      // In a robust offline-first architecture, the controller handles fetching from
      // local cache (Hive/Isar) instantly, then syncing with Firebase Firestore.

      // Here we filter the reactive products list based on the widget's parameters
      List<Product> filteredProducts = controller.products
          .where((p) => p.status.toLowerCase() == 'public')
          .toList();

      switch (categoryType) {
        case ProductTypeFilter.category:
          if (filterId != null) {
            filteredProducts = filteredProducts
                .where((p) => p.category == filterId)
                .toList();
          }
          break;
        case ProductTypeFilter.brand:
          if (filterId != null) {
            filteredProducts = filteredProducts
                .where((p) => p.brand == filterId)
                .toList();
          }
          break;
        case ProductTypeFilter.productType:
          if (filterId != null) {
            filteredProducts = filteredProducts
                .where((p) => p.type == filterId)
                .toList();
          }
          break;
        case ProductTypeFilter.recent:
          // For recent, we could sort by date added if the model supports it.
          // Fallback to default list order for now.
          break;
      }

      // Enforce maximum of 6 items for a 3x2 grid
      final List<Product> displayProducts = filteredProducts.take(6).toList();

      // If no products match the criteria, we can either hide the section or show an empty state.
      // Here we hide it to keep the home screen clean.
      if (displayProducts.isEmpty) {
        return const SizedBox.shrink();
      }

      // 2. UI Structure - Fixed Vertical Grid
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    sectionTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                      // Ensure a clean, custom Bangla font configuration is applied
                      // through the global theme or defined explicitly.
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () {
                      if (sectionTitle == 'জনপ্রিয় পণ্য') {
                        Get.to(
                          () => const AllProductsScreen(),
                          transition: Transition.rightToLeft,
                        );
                      } else {
                        // Navigate to the Product Archive screen with appropriate filters
                        Get.to(
                          () => const ProductArchiveScreen(),
                          arguments: ProductArchiveArguments(
                            archiveTitle: sectionTitle,
                            filterType: categoryType,
                            filterId: filterId,
                          ),
                          transition: Transition.rightToLeft,
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 8.0,
                      ),
                      child: Text(
                        'আরও দেখুন',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Grid Body
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: GridView.builder(
                padding: EdgeInsets.zero,
                // Avoid scrolling conflicts with the parent view
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                // 4x2 matrix layout configuration
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.62,
                ),
                itemCount: displayProducts.length,
                itemBuilder: (context, index) {
                  final product = displayProducts[index];
                  final uniqueHeroTag = '${sectionTitle}_${product.id ?? product.name}';
                  return UserProductCard(
                    product: product,
                    heroTag: uniqueHeroTag,
                    onTap: () => Get.to(
                      () => ProductDetailScreen(product: product, heroTag: uniqueHeroTag),
                      transition: Transition.fadeIn,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
