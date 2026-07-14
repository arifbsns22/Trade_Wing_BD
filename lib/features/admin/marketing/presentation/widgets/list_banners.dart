import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import '../controllers/banner_controller.dart';

class ListBannersWidget extends StatelessWidget {
  const ListBannersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final BannerController controller = Get.find<BannerController>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with Search
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text(
                  'Banner List',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${controller.banners.length}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 250,
                  child: TextField(
                    onChanged: (val) => controller.searchQuery.value = val,
                    decoration: InputDecoration(
                      hintText: 'Search by title',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: Container(
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade300,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: const Icon(Icons.search, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Table Area
          Obx(() {
            if (controller.isLoading.value && controller.banners.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (controller.filteredBanners.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: Text('No banners found.')),
              );
            }
            return ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                },
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width - 32,
                  ),
                  child: DataTable(
                    columnSpacing: 48,
                    horizontalMargin: 16,
                    headingRowColor: WidgetStateProperty.all(
                      Colors.grey.shade50,
                    ),
                    headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    dataRowMinHeight: 60,
                    dataRowMaxHeight: 80,
                    dividerThickness: 0.5,
                    columns: const [
                      DataColumn(label: Text('SL')),
                      DataColumn(label: Text('Title')),
                      DataColumn(label: Text('Type')),
                      DataColumn(
                        label: Row(
                          children: [
                            Text('Featured'),
                            SizedBox(width: 4),
                            Icon(Icons.info_outline, size: 14),
                          ],
                        ),
                      ),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Action')),
                    ],
                    rows: controller.filteredBanners.asMap().entries.map((
                      entry,
                    ) {
                      final index = entry.key;
                      final banner = entry.value;
                      return DataRow(
                        cells: [
                          DataCell(Text('${index + 1}')),
                          DataCell(
                            Row(
                              children: [
                                Container(
                                  width: 100,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors.grey.shade100,
                                    image: DecorationImage(
                                      image: NetworkImage(banner.imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 160,
                                  child: Text(
                                    banner.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  banner.bannerType,
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                                if (banner.targetRoles.isNotEmpty)
                                  Text(
                                    '(${banner.targetRoles.join(", ")})',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          DataCell(
                            Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: banner.isFeatured,
                                activeColor: AppColors.primaryColor,
                                activeTrackColor: AppColors.primaryColor
                                    .withValues(alpha: 0.5),
                                onChanged: (val) => controller.toggleFeatured(
                                  banner.id,
                                  banner.isFeatured,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: banner.status,
                                activeColor: AppColors.primaryColor,
                                activeTrackColor: AppColors.primaryColor
                                    .withValues(alpha: 0.5),
                                onChanged: (val) => controller.toggleStatus(
                                  banner.id,
                                  banner.status,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.teal.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      color: Colors.teal,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      Get.snackbar(
  'তথ্য',
  'এডিট ফিচার শীঘ্রই আসছে',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.redAccent,
                                      size: 20,
                                    ),
                                    onPressed: () => _showDeleteConfirmDialog(
                                      context,
                                      banner.id,
                                      controller,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    String id,
    BannerController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('নিশ্চিত করুন'),
        content: const Text('আপনি কি এই ব্যানারটি মুছে ফেলতে চান?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('না'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(context);
              controller.deleteBanner(id);
            },
            child: const Text('হ্যাঁ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
