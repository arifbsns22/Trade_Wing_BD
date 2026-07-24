import 'package:flutter/material.dart';
import 'package:trade_wign_bd/features/admin/dashboard/presentation/widgets/admin_appbar.dart';
import 'package:trade_wign_bd/features/admin/dashboard/presentation/widgets/admin_appbar_drawer.dart';
import 'package:trade_wign_bd/features/admin/dashboard/presentation/widgets/dashboard_summary_card.dart';
import 'package:trade_wign_bd/features/admin/dashboard/presentation/widgets/dashboard_line_chart.dart';
import 'package:trade_wign_bd/features/admin/dashboard/presentation/widgets/dashboard_bar_chart.dart';
import 'package:trade_wign_bd/features/admin/dashboard/presentation/widgets/progress_ring_card.dart';
import 'package:trade_wign_bd/features/admin/dashboard/presentation/widgets/recent_activity_list.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import 'package:trade_wign_bd/features/admin/common/widgets/create_floting_button.dart';

import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:trade_wign_bd/features/admin/dashboard/presentation/controllers/admin_dashboard_controller.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminDashboardController _controller = Get.put(
    AdminDashboardController(),
  );
  String _getFormattedBengaliDate() {
    final now = DateTime.now();

    final List<String> bnDays = [
      'সোমবার',
      'মঙ্গলবার',
      'বুধবার',
      'বৃহস্পতিবার',
      'শুক্রবার',
      'শনিবার',
      'রবিবার',
    ];
    final List<String> bnMonths = [
      'জানুয়ারি',
      'ফেব্রুয়ারি',
      'মার্চ',
      'এপ্রিল',
      'মে',
      'জুন',
      'জুলাই',
      'আগস্ট',
      'সেপ্টেম্বর',
      'অক্টোবর',
      'নভেম্বর',
      'ডিসেম্বর',
    ];

    final String dayName = bnDays[now.weekday - 1];
    final String monthName = bnMonths[now.month - 1];

    String toBengaliNumber(int number) {
      const englishToBengali = {
        '0': '০',
        '1': '১',
        '2': '২',
        '3': '৩',
        '4': '৪',
        '5': '৫',
        '6': '৬',
        '7': '৭',
        '8': '৮',
        '9': '৯',
      };
      return number
          .toString()
          .split('')
          .map((e) => englishToBengali[e] ?? e)
          .join('');
    }

    return '$dayName, ${toBengaliNumber(now.day)} $monthName ${toBengaliNumber(now.year)}';
  }

  Widget _buildCompactStatusCard({
    required String title,
    required IconData icon,
    required Color backgroundColor,
    required Color borderColor,
    required Color themeColor,
    required int pending,
    required int completed,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 168,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Title and Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: themeColor.withValues(alpha: 0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: themeColor, size: 14),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Middle: Large Count Value & Label
              Text(
                _controller.toBengaliNumber('${pending + completed} টি'),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              Text(
                'সর্বমোট অনুরোধ',
                style: TextStyle(
                  fontSize: 11,
                  color: themeColor.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),

              // Bottom: Status Indicators (Pending & Completed side-by-side)
              Row(
                children: [
                  // Pending Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.hourglass_empty_rounded,
                          color: themeColor,
                          size: 11,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'পেন্ডিং: ${_controller.toBengaliNumber('$pending')}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: themeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  // Completed Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: themeColor,
                          size: 11,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'সম্পন্ন: ${_controller.toBengaliNumber('$completed')}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: themeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const AdminAppBar(),
      drawer: const AdminAppbarDrawer(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: const CreateFloatingButton(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final bool isDesktop = width >= 900;
            final bool isTablet = width >= 650 && width < 900;

            final double horizontalPadding = isDesktop ? 28.0 : 20.0;
            final double verticalPadding = isDesktop ? 30.0 : 24.0;

            return RefreshIndicator(
                color: const Color(0xFF08B3AC),
                backgroundColor: Colors.white,
                displacement: 50,
                onRefresh: () => _controller.forceRefresh(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'স্বাগতম, সুপার এডমিন!',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getFormattedBengaliDate(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 117, 117, 117),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Summary Stats Grid (Responsive 2x2 or 4x1)
                  Obx(() {
                    final cardSales = DashboardSummaryCard(
                      title: 'মোট বিক্রয় (এই মাস)',
                      value: _controller.toBengaliNumber(
                        _controller.formatCurrency(
                          _controller.totalSalesThisMonth.value,
                        ),
                      ),
                      subtitle: 'গত মাসের তুলনায়',
                      icon: Icons.monetization_on_outlined,
                      backgroundColor: const Color(0xFFFFF3E0),
                      borderColor: const Color(0xFFFFE0B2),
                      themeColor: const Color(0xFFE65100),
                      percentage: _controller.toBengaliNumber(
                        _controller.formatPercentage(
                          _controller.salesComparisonPercentage.value,
                        ),
                      ),
                      isPositive: _controller.isSalesPositive.value,
                    );

                    final cardUsers = DashboardSummaryCard(
                      title: 'নতুন গ্রাহক (এই মাস)',
                      value: _controller.toBengaliNumber(
                        '${_controller.usersThisMonth.value} জন',
                      ),
                      subtitle: 'গত মাসের তুলনায়',
                      icon: Icons.people_outline,
                      backgroundColor: const Color(0xFFE0F7FA),
                      borderColor: const Color(0xFFB2EBF2),
                      themeColor: const Color(0xFF00796B),
                      percentage: _controller.toBengaliNumber(
                        _controller.formatPercentage(
                          _controller.usersComparisonPercentage.value,
                        ),
                      ),
                      isPositive: _controller.isUsersPositive.value,
                    );

                    final cardPending = DashboardSummaryCard(
                      title: 'পেন্ডিং রিকোয়েস্ট',
                      value: _controller.toBengaliNumber(
                        '${_controller.pendingOrdersCount.value} টি',
                      ),
                      subtitle: 'অপেক্ষমাণ অর্ডার',
                      icon: Icons.pending_actions_outlined,
                      backgroundColor: const Color(0xFFF3E5F5),
                      borderColor: const Color(0xFFE1BEE7),
                      themeColor: const Color(0xFF6A1B9A),
                      percentage: null,
                      isPositive: false,
                    );

                    final cardDelivered = DashboardSummaryCard(
                      title: 'ডেলিভারি সম্পন্ন',
                      value: _controller.toBengaliNumber(
                        '${_controller.deliveredOrdersCount.value} টি',
                      ),
                      subtitle: 'সফল অর্ডার',
                      icon: Icons.check_circle_outline,
                      backgroundColor: const Color(0xFFE8F5E9),
                      borderColor: const Color(0xFFC8E6C9),
                      themeColor: const Color(0xFF2E7D32),
                      percentage: null,
                      isPositive: true,
                    );

                    return Skeletonizer(
                      enabled: _controller.isLoading.value,
                      child: isDesktop || isTablet
                          ? Row(
                              children: [
                                Expanded(child: cardSales),
                                const SizedBox(width: 16),
                                Expanded(child: cardUsers),
                                const SizedBox(width: 16),
                                Expanded(child: cardPending),
                                const SizedBox(width: 16),
                                Expanded(child: cardDelivered),
                              ],
                            )
                          : Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: cardSales),
                                    const SizedBox(width: 16),
                                    Expanded(child: cardUsers),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(child: cardPending),
                                    const SizedBox(width: 16),
                                    Expanded(child: cardDelivered),
                                  ],
                                ),
                              ],
                            ),
                    );
                  }),
                  const SizedBox(height: 28),

                  // Compact Status section by Order/Payment Categories
                  const Text(
                    'অর্ডার ও পেমেন্ট স্ট্যাটাস',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Obx(() {
                    final int cardColumns = isDesktop ? 4 : (isTablet ? 2 : 2);
                    final double cardRatio = isDesktop
                        ? 1.6
                        : (isTablet ? 1.8 : 1.55);

                    return Skeletonizer(
                      enabled: _controller.isLoading.value,
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: cardColumns,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: cardRatio,
                        children: [
                          _buildCompactStatusCard(
                            title: 'মোবাইল রিচার্জ',
                            icon: Icons.phone_android_rounded,
                            backgroundColor: const Color(0xFFE0F7FA),
                            borderColor: const Color(0xFFB2EBF2),
                            themeColor: const Color(0xFF00796B),
                            pending: _controller.pendingRecharges.value,
                            completed: _controller.completedRecharges.value,
                          ),
                          _buildCompactStatusCard(
                            title: 'ড্রাইভ অফার',
                            icon: Icons.flash_on_rounded,
                            backgroundColor: const Color(0xFFFFF3E0),
                            borderColor: const Color(0xFFFFE0B2),
                            themeColor: const Color(0xFFE65100),
                            pending: _controller.pendingDrives.value,
                            completed: _controller.completedDrives.value,
                          ),
                          _buildCompactStatusCard(
                            title: 'প্যাকেজ সাবস্ক্রিপশন',
                            icon: Icons.card_membership_rounded,
                            backgroundColor: const Color(0xFFF3E5F5),
                            borderColor: const Color(0xFFE1BEE7),
                            themeColor: const Color(0xFF6A1B9A),
                            pending: _controller.pendingPackages.value,
                            completed: _controller.completedPackages.value,
                          ),
                          _buildCompactStatusCard(
                            title: 'ই-কমার্স প্রোডাক্ট',
                            icon: Icons.shopping_bag_rounded,
                            backgroundColor: const Color(0xFFE3F2FD),
                            borderColor: const Color(0xFFBBDEFB),
                            themeColor: const Color(0xFF0D47A1),
                            pending: _controller.pendingProducts.value,
                            completed: _controller.completedProducts.value,
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 28),

                  // Line Chart & Bar Chart Section (responsive side-by-side or stacked)
                  if (width >= 800)
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: DashboardLineChart()),
                        SizedBox(width: 18),
                        Expanded(child: DashboardBarChart()),
                      ],
                    )
                  else
                    const Column(
                      children: [
                        DashboardLineChart(),
                        SizedBox(height: 24),
                        DashboardBarChart(),
                      ],
                    ),
                  const SizedBox(height: 28),

                  // Recent Activities Section
                  const RecentActivityList(),
                  const SizedBox(height: 24),
                ],
              ),
            ), // SingleChildScrollView
            ); // RefreshIndicator
          },
        ),
      ),
    );
  }
}
