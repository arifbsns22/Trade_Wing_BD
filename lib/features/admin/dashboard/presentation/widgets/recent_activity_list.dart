import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import 'package:trade_wign_bd/features/admin/dashboard/presentation/controllers/admin_dashboard_controller.dart';
import 'package:trade_wign_bd/features/admin/ecommerce/presentation/screens/admin_orders_screen.dart';

class RecentActivityItem {
  final String title;
  final String orderStatus;
  final Color orderStatusColor;
  final String paymentStatus;
  final Color paymentStatusColor;
  final String amount;
  final String time;
  final IconData icon;
  final Color iconColor;
  final bool isNegative;

  RecentActivityItem({
    required this.title,
    required this.orderStatus,
    required this.orderStatusColor,
    required this.paymentStatus,
    required this.paymentStatusColor,
    required this.amount,
    required this.time,
    required this.icon,
    required this.iconColor,
    this.isNegative = false,
  });
}

class RecentActivityList extends StatelessWidget {
  const RecentActivityList({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminDashboardController controller =
        Get.find<AdminDashboardController>();

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'সাম্প্রতিক কার্যাবলী',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'সর্বশেষ ১০টি রিয়েল-টাইম অর্ডার আপডেট',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  Get.to(() => const AdminOrdersScreen());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'সব দেখুন',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Obx(() {
            final isLoading = controller.isLoading.value;

            // Generate dummy activities if loading
            List<RecentActivityItem> displayActivities = [];

            if (isLoading) {
              displayActivities = List.generate(
                10,
                (index) => RecentActivityItem(
                  title: 'লোড হচ্ছে...',
                  orderStatus: 'লোড হচ্ছে...',
                  orderStatusColor: Colors.grey,
                  paymentStatus: 'লোড হচ্ছে...',
                  paymentStatusColor: Colors.grey,
                  amount: '৳ ০০০',
                  time: '০ মিনিট আগে',
                  icon: Icons.access_time_outlined,
                  iconColor: Colors.grey,
                ),
              );
            } else if (controller.recentActivities.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Text(
                    'কোনো সাম্প্রতিক অর্ডার নেই',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            } else {
              displayActivities = controller.recentActivities.map((activity) {
                return _mapActivityToItem(activity, controller);
              }).toList();
            }

            return Skeletonizer(
              enabled: isLoading,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayActivities.length,
                separatorBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Colors.grey.shade100),
                ),
                itemBuilder: (context, index) {
                  final activity = displayActivities[index];
                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: activity.iconColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          activity.icon,
                          color: activity.iconColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(text: 'অর্ডার: '),
                                  TextSpan(
                                    text: activity.orderStatus,
                                    style: TextStyle(
                                      color: activity.orderStatusColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(text: ' • পেমেন্ট: '),
                                  TextSpan(
                                    text: activity.paymentStatus,
                                    style: TextStyle(
                                      color: activity.paymentStatusColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(text: ' • '),
                                  TextSpan(text: activity.time),
                                ],
                              ),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        activity.amount,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: activity.isNegative
                              ? Colors.redAccent
                              : AppColors.green,
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  RecentActivityItem _mapActivityToItem(
    DashboardActivityModel activity,
    AdminDashboardController controller,
  ) {
    IconData icon;
    Color color;

    switch (activity.type) {
      case DashboardActivityType.product:
        icon = Icons.shopping_bag_outlined;
        color = Colors.blue;
        break;
      case DashboardActivityType.package:
        icon = Icons.card_membership_outlined;
        color = const Color(0xffAA7BFF);
        break;
      case DashboardActivityType.drive:
        icon = Icons.bolt_outlined;
        color = Colors.orange;
        break;
      case DashboardActivityType.recharge:
        icon = Icons.phone_android_outlined;
        color = Colors.teal;
        break;
    }

    String orderStatusStr = '';
    Color orderStatusColor = Colors.grey;
    final status = activity.status.toLowerCase();

    if (status == 'pending') {
      orderStatusStr = 'পেন্ডিং';
      orderStatusColor = Colors.orange;
    } else if (status == 'processing') {
      orderStatusStr = 'প্রসেসিং';
      orderStatusColor = Colors.blue;
    } else if (status == 'shipped') {
      orderStatusStr = 'শিপড';
      orderStatusColor = const Color(0xffAA7BFF);
    } else if (status == 'delivered' || status == 'completed') {
      orderStatusStr = 'ডেলিভার্ড';
      orderStatusColor = AppColors.green;
    } else if (status == 'cancelled' || status == 'failed') {
      orderStatusStr = 'বাতিল';
      orderStatusColor = Colors.redAccent;
    } else {
      orderStatusStr = activity.status;
      orderStatusColor = Colors.grey;
    }

    String paymentStatusStr = '';
    Color paymentStatusColor = Colors.grey;
    final payStatus = activity.paymentStatus.toLowerCase();

    if (payStatus == 'pending') {
      paymentStatusStr = 'পেন্ডিং';
      paymentStatusColor = Colors.orange;
    } else if (payStatus == 'verified' || payStatus == 'completed') {
      paymentStatusStr = 'ভেরিফাইড';
      paymentStatusColor = AppColors.green;
    } else if (payStatus == 'failed') {
      paymentStatusStr = 'ফেইল্ড';
      paymentStatusColor = Colors.redAccent;
    } else {
      paymentStatusStr = activity.paymentStatus;
      paymentStatusColor = Colors.grey;
    }

    final difference = DateTime.now().difference(activity.createdAt);
    String timeAgo = '';
    if (difference.inDays > 0) {
      timeAgo =
          '${controller.toBengaliNumber(difference.inDays.toString())} দিন আগে';
    } else if (difference.inHours > 0) {
      timeAgo =
          '${controller.toBengaliNumber(difference.inHours.toString())} ঘন্টা আগে';
    } else if (difference.inMinutes > 0) {
      timeAgo =
          '${controller.toBengaliNumber(difference.inMinutes.toString())} মিনিট আগে';
    } else {
      timeAgo = 'এইমাত্র';
    }

    // Title mapping
    String titleText = activity.title;
    if (activity.type == DashboardActivityType.product || activity.type == DashboardActivityType.package) {
      titleText = '${activity.title} #${controller.toBengaliNumber(activity.id)}';
    }

    return RecentActivityItem(
      title: titleText,
      orderStatus: orderStatusStr,
      orderStatusColor: orderStatusColor,
      paymentStatus: paymentStatusStr,
      paymentStatusColor: paymentStatusColor,
      amount: controller.toBengaliNumber(
        controller.formatCurrency(activity.amount),
      ),
      time: timeAgo,
      icon: icon,
      iconColor: color,
      isNegative: status == 'cancelled' || status == 'failed',
    );
  }
}
