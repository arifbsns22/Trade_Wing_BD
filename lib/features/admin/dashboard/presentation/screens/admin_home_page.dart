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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const AdminAppBar(),
      drawer: const AdminAppbarDrawer(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: const CreateFloatingButton(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
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
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color.fromARGB(255, 117, 117, 117),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Summary Stats Grid (2x2)
              Obx(() {
                return Skeletonizer(
                  enabled: _controller.isLoading.value,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DashboardSummaryCard(
                              title: 'মোট বিক্রয় (এই মাস)',
                              value: _controller.toBengaliNumber(
                                _controller.formatCurrency(
                                  _controller.totalSalesThisMonth.value,
                                ),
                              ),
                              subtitle: 'গত মাসের তুলনায়',
                              icon: Icons.monetization_on_outlined,
                              gradientColors: [
                                AppColors.primaryColor,
                                const Color(0xff034F4b),
                              ],
                              percentage: _controller.toBengaliNumber(
                                _controller.formatPercentage(
                                  _controller.salesComparisonPercentage.value,
                                ),
                              ),
                              isPositive: _controller.isSalesPositive.value,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DashboardSummaryCard(
                              title: 'নতুন গ্রাহক (এই মাস)',
                              value: _controller.toBengaliNumber(
                                '${_controller.usersThisMonth.value} জন',
                              ),
                              subtitle: 'গত মাসের তুলনায়',
                              icon: Icons.people_outline,
                              gradientColors: [
                                const Color(0xffAA7BFF),
                                const Color(0xff664A99),
                              ],
                              percentage: _controller.toBengaliNumber(
                                _controller.formatPercentage(
                                  _controller.usersComparisonPercentage.value,
                                ),
                              ),
                              isPositive: _controller.isUsersPositive.value,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DashboardSummaryCard(
                              title: 'পেন্ডিং রিকোয়েস্ট',
                              value: _controller.toBengaliNumber(
                                '${_controller.pendingOrdersCount.value} টি',
                              ),
                              subtitle: 'অপেক্ষমাণ অর্ডার',
                              icon: Icons.pending_actions_outlined,
                              gradientColors: [
                                const Color(0xfff6ca44),
                                const Color(0xff8F4D05),
                              ],
                              percentage: null,
                              isPositive: false,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DashboardSummaryCard(
                              title: 'ডেলিভারি সম্পন্ন',
                              value: _controller.toBengaliNumber(
                                '${_controller.deliveredOrdersCount.value} টি',
                              ),
                              subtitle: 'সফল অর্ডার',
                              icon: Icons.check_circle_outline,
                              gradientColors: [
                                Colors.blueGrey.shade600,
                                Colors.blueGrey.shade800,
                              ],
                              percentage: null,
                              isPositive: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),

              // Line Chart Section
              const DashboardLineChart(),
              const SizedBox(height: 24),

              // Goals / Circular Ring Indicators Grid
              const SizedBox(height: 24),

              // Bar Chart Section
              const DashboardBarChart(),
              const SizedBox(height: 24),

              // Recent Activities Section
              const RecentActivityList(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
