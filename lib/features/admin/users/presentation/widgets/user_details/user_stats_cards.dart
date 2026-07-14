import 'package:flutter/material.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class UserStatsCards extends StatelessWidget {
  final int totalOrders;
  final double totalPaidAmount;
  final int pendingOrders;
  final int rewardPoints;

  const UserStatsCards({
    super.key,
    required this.totalOrders,
    required this.totalPaidAmount,
    required this.pendingOrders,
    required this.rewardPoints,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        // On small screens, 2 columns. On wider screens, 4 columns.
        final int crossAxisCount = width > 800 ? 4 : (width > 400 ? 2 : 1);
        final double childAspectRatio = width > 800 ? 2.2 : 2.5;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
          children: [
            _buildStatCard(
              title: 'Total Orders',
              value: '$totalOrders',
              subtitle: 'All time orders',
              icon: Icons.shopping_cart_outlined,
              bgColor: Colors.blue.withValues(alpha: 0.1),
              iconColor: Colors.blue,
            ),
            _buildStatCard(
              title: 'Total Paid',
              value: '৳${totalPaidAmount.toStringAsFixed(0)}',
              subtitle: 'Verified payments',
              icon: Icons.monetization_on_outlined,
              bgColor: AppColors.green.withValues(alpha: 0.15),
              iconColor: AppColors.green,
            ),
            _buildStatCard(
              title: 'Pending Orders',
              value: '$pendingOrders',
              subtitle: 'Awaiting delivery',
              icon: Icons.pending_actions_outlined,
              bgColor: Colors.orange.withValues(alpha: 0.15),
              iconColor: Colors.orange,
            ),
            _buildStatCard(
              title: 'Reward Points',
              value: '$rewardPoints',
              subtitle: 'Earned points',
              icon: Icons.stars_rounded,
              bgColor: Colors.purple.withValues(alpha: 0.1),
              iconColor: Colors.purple,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: iconColor.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
