import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/controllers/product_archive_controller.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/widgets/product_card.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/screens/product_detail_screen.dart';
import 'package:trade_wign_bd/features/common/custom_search_bar.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/widgets/user_home_products.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class ProductArchiveScreen extends StatefulWidget {
  final ProductArchiveArguments? args;

  const ProductArchiveScreen({super.key, this.args});

  @override
  State<ProductArchiveScreen> createState() => _ProductArchiveScreenState();
}

class _ProductArchiveScreenState extends State<ProductArchiveScreen> {
  late ProductArchiveController controller;
  final ScrollController _scrollController = ScrollController();

  late String controllerTag;

  @override
  void initState() {
    super.initState();

    // Resolve arguments from widget property or Get.arguments
    final resolvedArgs =
        widget.args ??
        (Get.arguments as ProductArchiveArguments?) ??
        ProductArchiveArguments(
          archiveTitle: 'সকল পণ্য',
          filterType: ProductTypeFilter.recent,
        );

    // Generate a unique tag based on the title/filter so multiple archive screens don't collide
    controllerTag =
        'archive_${resolvedArgs.archiveTitle}_${resolvedArgs.filterId ?? "all"}';

    controller = Get.put(
      ProductArchiveController(resolvedArgs),
      tag: controllerTag,
    );

    _scrollController.addListener(() {
      // Trigger pagination when reaching 80% of the scroll depth
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.8) {
        controller.fetchNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    Get.delete<ProductArchiveController>(tag: controllerTag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: Text(
          controller.args.archiveTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: _buildFilterSortBar(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 50),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.updateSort(
                    controller.currentSort.value,
                  ), // Refetch
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                  ),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        if (controller.productsList.isEmpty) {
          return const Center(
            child: Text(
              'কোনো পণ্য পাওয়া যায়নি',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: () async {
            controller.updateSort(
              controller.currentSort.value,
            ); // Forces refetch
          },
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.62,
            ),
            itemCount:
                controller.productsList.length +
                (controller.isFetchingMore.value ? 2 : 0),
            itemBuilder: (context, index) {
              if (index >= controller.productsList.length) {
                // Shimmer or loader for pagination
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                );
              }

              final product = controller.productsList[index];
              final uniqueHeroTag = 'archive_${product.id ?? product.name}';
              return UserProductCard(
                product: product,
                heroTag: uniqueHeroTag,
                onTap: () => Get.to(
                  () => ProductDetailScreen(product: product, heroTag: uniqueHeroTag),
                  transition: Transition.rightToLeft,
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildFilterSortBar() {
    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side: Search Bar (70% space)
          const Expanded(flex: 7, child: CustomSearchBar()),
          const SizedBox(width: 12),
          // Right side: Filter (30% space)
          Expanded(
            flex: 3,
            child: Container(
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Obx(
                () => DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.currentSort.value,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.tune,
                      size: 18,
                      color: Colors.black54,
                    ),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.updateSort(newValue);
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'default',
                        child: Text(
                          'ফিল্টার করুন',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'price_low_high',
                        child: Text(
                          'দাম: কম-বেশি',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'price_high_low',
                        child: Text(
                          'দাম: বেশি-কম',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
