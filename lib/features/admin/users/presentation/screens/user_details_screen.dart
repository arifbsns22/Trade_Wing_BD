import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import '../controllers/user_details_controller.dart';
import '../widgets/user_details/user_profile_card.dart';
import '../widgets/user_details/user_stats_cards.dart';
import '../widgets/user_details/user_orders_table.dart';

class UserDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserDetailsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final controller = Get.put(UserDetailsController(user: user), tag: user['mobile']);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Client Details'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isDesktop = constraints.maxWidth > 900;

          if (isDesktop) {
            // Desktop/Tablet Landscape Layout: Profile on left, Stats & Orders on right
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Pane
                  SizedBox(
                    width: 320,
                    child: SingleChildScrollView(
                      child: UserProfileCard(user: user),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Right Pane
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatsAndOrders(controller),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Mobile/Tablet Portrait Layout: Profile on top, Stats & Orders below
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  UserProfileCard(user: user),
                  const SizedBox(height: 24),
                  _buildStatsAndOrders(controller),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildStatsAndOrders(UserDetailsController controller) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      
      return Skeletonizer(
        enabled: isLoading,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top search bar or header could go here if needed
            
            // Stats Row
            UserStatsCards(
              totalOrders: isLoading ? 154 : controller.totalOrdersCount.value,
              totalPaidAmount: isLoading ? 980721.0 : controller.totalPaidAmount.value,
              pendingOrders: isLoading ? 19 : controller.pendingOrdersCount.value,
              rewardPoints: isLoading ? 450 : controller.totalRewardPoints.value,
            ),
            const SizedBox(height: 24),
            
            // Orders Table
            UserOrdersTable(
              orders: isLoading ? _getMockOrders() : controller.userOrders,
            ),
          ],
        ),
      );
    });
  }

  List<Map<String, dynamic>> _getMockOrders() {
    // Return mock data for skeletonizer
    return List.generate(
      5,
      (index) => {
        'orderId': 'Loading...',
        'createdAt': null,
        'orderStatus': 'pending',
        'paymentStatus': 'pending',
        'totalAmount': 0.0,
      },
    );
  }
}
