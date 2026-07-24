import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import 'package:trade_wign_bd/features/admin/dashboard/presentation/controllers/admin_dashboard_controller.dart';

class DashboardBarChart extends StatelessWidget {
  const DashboardBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminDashboardController controller =
        Get.find<AdminDashboardController>();

    // 10 distinct beautiful soft/pastel linear gradients for the rods
    final List<LinearGradient> rodGradients = [
      const LinearGradient(
        colors: [Color(0xFFEF9A9A), Color(0xFFE57373)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ),
      const LinearGradient(
        colors: [Color(0xFFCE93D8), Color(0xFFBA68C8)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ),
      const LinearGradient(
        colors: [Color(0xFF9FA8DA), Color(0xFF7986CB)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ),
      const LinearGradient(
        colors: [Color(0xFF90CAF9), Color(0xFF64B5F6)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ),
      const LinearGradient(
        colors: [Color(0xFF80DEEA), Color(0xFF4DD0E1)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ),
      const LinearGradient(
        colors: [Color(0xFF80CBC4), Color(0xFF4DB6AC)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ),
      const LinearGradient(
        colors: [Color(0xFFA5D6A7), Color(0xFF81C784)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ),
      const LinearGradient(
        colors: [Color(0xFFE6EE9C), Color(0xFFD4E157)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ),
      const LinearGradient(
        colors: [Color(0xFFFFE082), Color(0xFFFFD54F)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ),
      const LinearGradient(
        colors: [Color(0xFFFFCC80), Color(0xFFFFB74D)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFF3E0).withValues(alpha: 0.65), // Extremely soft orange
            const Color(0xFFF3E5F5).withValues(alpha: 0.65), // Extremely soft purple
            const Color(0xFFE3F2FD).withValues(alpha: 0.65), // Extremely soft blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xffAA7BFF).withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ইউজার রোল বিশ্লেষণ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'প্রতিটি রোলে নিবন্ধিত ইউজারের সংখ্যা',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFE1BEE7),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF9C27B0),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'রোলসমূহ',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7B1FA2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Obx(() {
            final isLoading = controller.isLoading.value;

            final roles = isLoading || controller.roleUserCounts.isEmpty
                ? ['Role 1', 'Role 2', 'Role 3', 'Role 4', 'Role 5']
                : controller.roleUserCounts.keys.toList();
            final values = isLoading || controller.roleUserCounts.isEmpty
                ? [10, 20, 15, 30, 25]
                : controller.roleUserCounts.values.toList();

            double maxCount = values.fold(
              1.0,
              (m, v) => v > m ? v.toDouble() : m,
            );
            double maxY = maxCount < 10 ? 10 : maxCount * 1.2;

            List<BarChartGroupData> barGroups = [];
            for (int i = 0; i < roles.length; i++) {
              barGroups.add(
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: values[i].toDouble(),
                      gradient: rodGradients[i % rodGradients.length],
                      width: 16,
                      borderRadius: BorderRadius.circular(4),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: maxY,
                        color: Colors.black.withValues(alpha: 0.02),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Skeletonizer(
              enabled: isLoading,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: roles.length * 60.0 >
                          MediaQuery.of(context).size.width - 80
                      ? roles.length * 60.0
                      : MediaQuery.of(context).size.width - 80,
                  height: 220,
                  child: BarChart(
                    BarChartData(
                      barGroups: barGroups,
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY,
                      minY: 0,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        drawHorizontalLine: true,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.black.withValues(alpha: 0.03),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 48,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 &&
                                  value.toInt() < roles.length) {
                                return SideTitleWidget(
                                  meta: meta,
                                  space: 8,
                                  child: Container(
                                    constraints: const BoxConstraints(maxWidth: 55),
                                    child: Text(
                                      roles[value.toInt()],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 9,
                                        color: Colors.grey.shade700,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            interval: maxY > 10 ? maxY / 4 : 2.0,
                            getTitlesWidget: (value, meta) {
                              return SideTitleWidget(
                                meta: meta,
                                space: 4,
                                child: Text(
                                  controller.toBengaliNumber(
                                    value.toInt().toString(),
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) {
                            // Match the tooltip background color with the rod color
                            final int index = group.x;
                            if (index >= 0 && index < rodGradients.length) {
                              return rodGradients[index % rodGradients.length].colors.first.withValues(alpha: 0.95);
                            }
                            return const Color(0xFF08B3AC);
                          },
                          tooltipBorderRadius: BorderRadius.circular(10),
                          tooltipPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          tooltipMargin: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              "",
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text:
                                      '${controller.toBengaliNumber(rod.toY.toInt().toString())} জন',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
