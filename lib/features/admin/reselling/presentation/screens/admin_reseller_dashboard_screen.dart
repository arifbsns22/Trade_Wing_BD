import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../controllers/admin_reseller_dashboard_controller.dart';
import '../widgets/admin_reseller_stat_card.dart';
import '../widgets/admin_reseller_list_table.dart';
import 'package:trade_wign_bd/features/admin/dashboard/presentation/screens/admin_home_page.dart';

class AdminResellerDashboardScreen extends StatelessWidget {
  const AdminResellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminResellerDashboardController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: const Text(
          'রিসেলিং ড্যাশবোর্ড (অ্যাডমিন)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
        ),
        backgroundColor: const Color(0xFFF4F7FE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () {
            Get.offAll(() => const AdminDashboardScreen());
          },
        ),
      ),
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: () async {
            controller.setupListeners();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Grid
                Skeletonizer(
                  enabled: controller.isLoading.value,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 600;
                      return GridView.count(
                        crossAxisCount: isWide ? 4 : 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: isWide ? 2.0 : 2.3,
                        children: [
                          AdminResellerStatCard(
                            title: 'মোট রিসেলার',
                            value: '${controller.totalResellersCount.value} জন',
                            icon: Icons.group_outlined,
                            backgroundColor: const Color(0xFFFFF3E0),
                            borderColor: const Color(0xFFFFE0B2),
                            themeColor: const Color(0xFFE65100),
                          ),
                          AdminResellerStatCard(
                            title: 'সম্পন্ন অর্ডার',
                            value: '${controller.completedOrdersCount.value} টি',
                            icon: Icons.check_circle_outline_rounded,
                            backgroundColor: const Color(0xFFE8F5E9),
                            borderColor: const Color(0xFFC8E6C9),
                            themeColor: const Color(0xFF2E7D32),
                          ),
                          AdminResellerStatCard(
                            title: 'পেন্ডিং অর্ডার',
                            value: '${controller.pendingOrdersCount.value} টি',
                            icon: Icons.pending_actions_outlined,
                            backgroundColor: const Color(0xFFFFFDE7),
                            borderColor: const Color(0xFFFFF9C4),
                            themeColor: const Color(0xFFF57F17),
                          ),
                          AdminResellerStatCard(
                            title: 'মোট অর্ডার মূল্য',
                            value: '৳${controller.totalOrderedAmount.value.toStringAsFixed(2)}',
                            icon: Icons.trending_up_rounded,
                            backgroundColor: const Color(0xFFE0F7FA),
                            borderColor: const Color(0xFFB2EBF2),
                            themeColor: const Color(0xFF006064),
                          ),
                          AdminResellerStatCard(
                            title: 'রিসেলার অর্জিত লাভ',
                            value: '৳${controller.totalActualProfit.value.toStringAsFixed(2)}',
                            icon: Icons.monetization_on_outlined,
                            backgroundColor: const Color(0xFFE0F2FE),
                            borderColor: const Color(0xFFBAE6FD),
                            themeColor: const Color(0xFF0369A1),
                          ),
                          AdminResellerStatCard(
                            title: 'অ্যাডমিন কমিশন',
                            value: '৳${controller.totalAdminCommission.value.toStringAsFixed(2)}',
                            icon: Icons.percent_rounded,
                            backgroundColor: const Color(0xFFECEFF1),
                            borderColor: const Color(0xFFCFD8DC),
                            themeColor: const Color(0xFF37474F),
                          ),
                          AdminResellerStatCard(
                            title: 'মোট উত্তোলন',
                            value: '৳${controller.totalWithdrawnAmount.value.toStringAsFixed(2)}',
                            icon: Icons.account_balance_rounded,
                            backgroundColor: const Color(0xFFFCE4EC),
                            borderColor: const Color(0xFFF8BBD0),
                            themeColor: const Color(0xFFC2185B),
                          ),
                          AdminResellerStatCard(
                            title: 'রিসেলার চলতি ব্যালেন্স',
                            value: '৳${controller.totalAvailableBalance.value.toStringAsFixed(2)}',
                            icon: Icons.account_balance_wallet_outlined,
                            backgroundColor: const Color(0xFFE8EAF6),
                            borderColor: const Color(0xFFC5CAE9),
                            themeColor: const Color(0xFF1A237E),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Section Title
                const Text(
                  'রিসেলার তালিকা',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 12),

                // Table Component
                const AdminResellerListTable(),
              ],
            ),
          ),
        );
      }),
    );
  }
}
