import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/admin/dashboard/presentation/screens/admin_home_page.dart';
import '../controllers/admin_users_controller.dart';
import '../widgets/all_user_table.dart';
import '../widgets/all_user_count_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AllUserScreen extends StatelessWidget {
  const AllUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate Controller
    final controller = Get.put(AdminUsersController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: const Text(
          'ইউজার তালিকা',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: const Color(0xFFF4F7FE),
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Take admin back to home page
            Get.offAll(() => const AdminDashboardScreen());
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Stats Cards
            _buildUserStatsCards(controller),
            const SizedBox(height: 24),

            // Top Action Bar (Search field etc. from the image)
            _buildTopActionBar(controller),
            const SizedBox(height: 16),

            // The Table
            const AllUserTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStatsCards(AdminUsersController controller) {
    final dummyRoles = [
      {'role': 'Super Admin', 'count': 0, 'growth': 0.0},
      {'role': 'Customer', 'count': 0, 'growth': 0.0},
      {'role': 'Brand Promoter', 'count': 0, 'growth': 0.0},
      {'role': 'Sales Partner', 'count': 0, 'growth': 0.0},
      {'role': 'Senior Sales Partner', 'count': 0, 'growth': 0.0},
      {'role': 'Sub Dealer', 'count': 0, 'growth': 0.0},
      {'role': 'Dealer', 'count': 0, 'growth': 0.0},
      {'role': 'Senior Dealer', 'count': 0, 'growth': 0.0},
      {'role': 'Master Dealer', 'count': 0, 'growth': 0.0},
    ];

    return Obx(() {
      final isLoading = controller.isLoading.value;
      final List<Map<String, dynamic>> statsList = isLoading
          ? dummyRoles
          : controller.roleStats.toList();
      if (statsList.isEmpty && !isLoading) {
        return const SizedBox.shrink();
      }

      return Skeletonizer(
        enabled: isLoading,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.7,
          ),
          itemCount: statsList.length,
          itemBuilder: (context, index) {
            final stat = statsList[index];
            return UserCountCard(
              title: stat['role'],
              count: stat['count'],
              growth: stat['growth'],
            );
          },
        ),
      );
    });
  }

  Widget _buildTopActionBar(AdminUsersController controller) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: TextField(
              onChanged: controller.searchUsers,
              decoration: const InputDecoration(
                hintText: 'ইউজার খুঁজুন (নাম বা ফোন)...',
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: () {
            controller.syncUserOrders();
          },
          icon: const Icon(Icons.sync, size: 18, color: Colors.black87),
          label: const Text(
            'Sync Orders',
            style: TextStyle(color: Colors.black87),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.grey.shade300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
