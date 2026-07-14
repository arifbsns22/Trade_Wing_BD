import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/widgets/user_home_products.dart';
import 'package:trade_wign_bd/features/admin/ecommerce/presentation/controllers/ecommerce_controller.dart';

class HomeProductSections extends StatelessWidget {
  const HomeProductSections({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserHomeProducts(
          sectionTitle: 'জনপ্রিয় পণ্য',
          categoryType: ProductTypeFilter.recent,
        ),
        const SizedBox(height: 20),
        Obx(() {
          final EcommerceController controller = Get.find<EcommerceController>();
          final publicCategories = controller.categories.where((c) => c['status'] == 'public').toList();
          
          if (publicCategories.isNotEmpty) {
            // We use a simple shuffle to pick a random category
            final randomCategory = (publicCategories.toList()..shuffle()).first;
            final categoryName = randomCategory['name'] as String;
            
            return UserHomeProducts(
              sectionTitle: categoryName,
              categoryType: ProductTypeFilter.category,
              filterId: categoryName,
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}
