import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/admin/dashboard/presentation/screens/admin_home_page.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import '../controllers/admin_drive_orders_controller.dart';
import '../widgets/order_stats_card.dart';
import '../widgets/admin_drive_orders_table.dart';

class DriveOrderRequestScreen extends StatelessWidget {
  const DriveOrderRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate Admin Drive Orders Controller
    final controller = Get.put(AdminDriveOrdersController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: const Text(
          'ড্রাইভ ও রিচার্জ অর্ডার সমূহ',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFFF4F7FE),
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.offAll(() => const AdminDashboardScreen());
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Stats Counter Cards
            Obx(() {
              return Row(
                children: [
                  Expanded(
                    child: OrderStatsCard(
                      title: 'পেন্ডিং ড্রাইভ অর্ডার',
                      count: controller.pendingOffersCount.value,
                      icon: Icons.offline_bolt_outlined,
                      accentColor: const Color(0xFFEA580C),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OrderStatsCard(
                      title: 'পেন্ডিং সাধারণ রিচার্জ',
                      count: controller.pendingRechargesCount.value,
                      icon: Icons.phonelink_ring_outlined,
                      accentColor: const Color(0xFF0D9488),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 20),

            // 2. Search and Filter Bar
            Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Search Row
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: TextField(
                              onChanged: (val) => controller.searchQuery.value = val,
                              decoration: InputDecoration(
                                hintText: 'অর্ডার আইডি, গ্রাহক নাম বা নম্বর দিয়ে খুঁজুন...',
                                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                                prefixIcon: const Icon(Icons.search, size: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Filters Row
                    Obx(() {
                      return Row(
                        children: [
                          // Operator Dropdown
                          Expanded(
                            child: _buildFilterDropdown<String>(
                              label: 'অপারেটর',
                              value: controller.selectedOperator.value,
                              items: controller.operatorFilters.toList(),
                              onChanged: (val) {
                                if (val != null) controller.selectedOperator.value = val;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Order Type Dropdown
                          Expanded(
                            child: _buildFilterDropdown<String>(
                              label: 'ধরণ',
                              value: controller.selectedOrderType.value,
                              items: const ['All', 'regular', 'drive'],
                              displayNames: {
                                'All': 'সব ধরণের',
                                'regular': 'সাধারণ রিচার্জ',
                                'drive': 'ড্রাইভ অফার',
                              },
                              onChanged: (val) {
                                if (val != null) controller.selectedOrderType.value = val;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Status Dropdown
                          Expanded(
                            child: _buildFilterDropdown<String>(
                              label: 'স্ট্যাটাস',
                              value: controller.selectedStatus.value,
                              items: const ['All', 'pending', 'completed', 'failed'],
                              displayNames: {
                                'All': 'সব স্ট্যাটাস',
                                'pending': 'পেন্ডিং',
                                'completed': 'সম্পন্ন',
                                'failed': 'ব্যর্থ',
                              },
                              onChanged: (val) {
                                if (val != null) controller.selectedStatus.value = val;
                              },
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Horizontal Scrollable Orders Table
            const AdminDriveOrdersTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    Map<T, String>? displayNames,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          style: const TextStyle(fontSize: 12.5, color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
          onChanged: onChanged,
          items: items.map((item) {
            final String text = displayNames != null && displayNames.containsKey(item)
                ? displayNames[item]!
                : item.toString();
            return DropdownMenuItem<T>(
              value: item,
              child: Text(text),
            );
          }).toList(),
        ),
      ),
    );
  }
}
