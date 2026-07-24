import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import 'package:trade_wign_bd/features/admin/dashboard/presentation/controllers/admin_dashboard_controller.dart';

class DashboardLineChart extends StatelessWidget {
  const DashboardLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminDashboardController controller =
        Get.find<AdminDashboardController>();

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF5F3FF), // Extremely soft lavender
            const Color(0xFFECFDF5), // Extremely soft mint/teal
            const Color(0xFFEFF6FF), // Extremely soft blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.12),
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
                      'দৈনিক বিক্রয় চিত্র',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Builder(
                      builder: (context) {
                        final monthName = _getBengaliMonthName(DateTime.now().month);
                        final year = controller.toBengaliNumber(DateTime.now().year.toString());
                        return Text(
                          '$monthName $year • চলতি মাসের আয়',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFB2DFDB)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00897B),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'লাইভ',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00796B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 1.7,
            child: Obx(() {
              final isLoading = controller.isLoading.value;

              List<FlSpot> spots = [];
              if (isLoading || controller.dailySales.isEmpty) {
                for (int i = 0; i < 7; i++) {
                  spots.add(FlSpot(i.toDouble(), (i + 1) * 10000.0));
                }
              } else {
                for (int i = 0; i < controller.dailySales.length; i++) {
                  spots.add(FlSpot(i.toDouble(), controller.dailySales[i]));
                }
                final currentDay = DateTime.now().day;
                spots = spots.sublist(0, currentDay);
              }

              double calculatedMaxX = spots.length.toDouble() - 1;
              if (calculatedMaxX < 1) calculatedMaxX = 1;

              return Skeletonizer(
                enabled: isLoading,
                child: Skeleton.replace(
                  replacement: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawHorizontalLine: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.black.withValues(alpha: 0.04),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            interval: 5,
                            getTitlesWidget: (value, meta) =>
                                _bottomTitleWidgets(value, meta, controller),
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: controller.chartMaxY.value / 4 > 0
                                ? controller.chartMaxY.value / 4
                                : 1000,
                            getTitlesWidget: (value, meta) =>
                                _leftTitleWidgets(value, meta, controller),
                            reservedSize: 48,
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: calculatedMaxX,
                      minY: 0,
                      maxY: controller.chartMaxY.value,
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (touchedSpot) => AppColors.primaryColor.withValues(alpha: 0.95),
                          tooltipBorderRadius: BorderRadius.circular(10),
                          tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                            return touchedBarSpots.map((barSpot) {
                              return LineTooltipItem(
                                controller.toBengaliNumber(controller.formatCurrency(barSpot.y)),
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          curveSmoothness: 0.35,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFAB47BC), Color(0xFF00ACC1)],
                          ),
                          barWidth: 3.5,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, bar, index) {
                              return FlDotCirclePainter(
                                radius: 3.5,
                                color: Colors.white,
                                strokeWidth: 2,
                                strokeColor: const Color(0xFF00ACC1),
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFAB47BC).withValues(alpha: 0.18),
                                const Color(0xFF00ACC1).withValues(alpha: 0.08),
                                const Color(0xFF00ACC1).withValues(alpha: 0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta, AdminDashboardController controller) {
    final style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 9,
      color: Colors.grey.shade600,
    );
    int day = value.toInt() + 1;
    return SideTitleWidget(
      meta: meta,
      space: 8,
      child: Text(controller.toBengaliNumber(day.toString()), style: style),
    );
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta, AdminDashboardController controller) {
    final style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 9,
      color: Colors.grey.shade600,
    );
    String text;
    if (value == 0) {
      text = '০';
    } else if (value >= 1000) {
      text = '${controller.toBengaliNumber((value / 1000).toStringAsFixed(0))}k';
    } else {
      text = controller.toBengaliNumber(value.toInt().toString());
    }
    return Text(text, style: style, textAlign: TextAlign.right);
  }

  String _getBengaliMonthName(int month) {
    const bnMonths = [
      'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
      'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর',
    ];
    if (month >= 1 && month <= 12) return bnMonths[month - 1];
    return '';
  }
}
