import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../controllers/admin_vendor_dashboard_controller.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class AdminVendorListTable extends StatelessWidget {
  const AdminVendorListTable({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminVendorDashboardController>();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
            },
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Obx(() {
                if (!controller.isLoading.value && controller.vendorsList.isEmpty) {
                  return Container(
                    width: MediaQuery.of(context).size.width - 32,
                    height: 200,
                    alignment: Alignment.center,
                    child: const Text('কোনো ভেন্ডর পাওয়া যায়নি'),
                  );
                }

                final List<Map<String, dynamic>> displayList = controller.isLoading.value
                    ? List<Map<String, dynamic>>.generate(
                        3,
                        (index) => {
                          'name': 'Loading Name',
                          'shopName': 'Loading Shop',
                          'mobile': '01XXXXXXXXX',
                        },
                      )
                    : controller.vendorsList;

                return ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width - 32,
                  ),
                  child: Skeletonizer(
                    enabled: controller.isLoading.value,
                    child: DataTable(
                      columnSpacing: 24,
                      horizontalMargin: 16,
                      headingRowColor: WidgetStateProperty.all(
                        const Color(0xFFF8F9FA),
                      ),
                      headingTextStyle: const TextStyle(
                        color: Color(0xFF343A40),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      dataRowMinHeight: 50,
                      dataRowMaxHeight: 65,
                      dividerThickness: 0.5,
                      columns: const [
                        DataColumn(label: Text('ক্রমিক নং')),
                        DataColumn(label: Text('শপের নাম')),
                        DataColumn(label: Text('ভেন্ডরের নাম')),
                        DataColumn(label: Text('মোবাইল নম্বর')),
                        DataColumn(label: Text('সম্পন্ন অর্ডার')),
                        DataColumn(label: Text('পেন্ডিং অর্ডার')),
                        DataColumn(label: Text('অর্জিত মোট লাভ')),
                        DataColumn(label: Text('মোট উত্তোলন')),
                        DataColumn(label: Text('চলতি ব্যালেন্স')),
                      ],
                      rows: displayList.asMap().entries.map((entry) {
                        final index = entry.key;
                        final vendor = entry.value;
                        final mobile = vendor['mobile'] ?? '';

                        // Get real-time aggregated stats for this vendor
                        final stats = controller.getVendorStats(mobile);

                        return DataRow(
                          cells: [
                            DataCell(Text('${index + 1}', style: const TextStyle(fontSize: 12))),
                            DataCell(Text(vendor['shopName'] ?? 'No Shop Name', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                            DataCell(Text(vendor['name'] ?? 'Unnamed', style: const TextStyle(fontSize: 12))),
                            DataCell(Text(mobile, style: const TextStyle(fontSize: 12))),
                            DataCell(Text('${stats['completedOrders']} টি', style: const TextStyle(fontSize: 12))),
                            DataCell(Text('${stats['pendingOrders']} টি', style: const TextStyle(fontSize: 12))),
                            DataCell(Text('৳${(stats['profit'] as double).toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold))),
                            DataCell(Text('৳${(stats['withdrawn'] as double).toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Colors.redAccent))),
                            DataCell(Text('৳${(stats['balance'] as double).toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Colors.teal, fontWeight: FontWeight.bold))),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
