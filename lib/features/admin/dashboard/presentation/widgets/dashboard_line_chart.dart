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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'দৈনিক লেনদেন চিত্র',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Builder(
                      builder: (context) {
                        final monthName = _getBengaliMonthName(
                          DateTime.now().month,
                        );
                        final year = controller.toBengaliNumber(
                          DateTime.now().year.toString(),
                        );
                        return Text(
                          'লেনদেন ও ব্যয়ের বিবরণী • $monthName $year',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        );
                      },
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
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'লাইভ ট্র্যাকিং',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
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

              // Generate spots
              List<FlSpot> spots = [];
              if (isLoading || controller.dailySales.isEmpty) {
                // Dummy spots for Skeletonizer
                for (int i = 0; i < 7; i++) {
                  spots.add(FlSpot(i.toDouble(), (i + 1) * 10000.0));
                }
              } else {
                for (int i = 0; i < controller.dailySales.length; i++) {
                  spots.add(FlSpot(i.toDouble(), controller.dailySales[i]));
                }
                // Only show until current day of month
                final currentDay = DateTime.now().day;
                spots = spots.sublist(0, currentDay);
              }

              // FlChart needs at least 2 spots to draw a line properly,
              // or minX < maxX. If it's the 1st of the month, maxX is 0,
              // which causes division by zero and layout overflow.
              double calculatedMaxX = spots.length.toDouble() - 1;
              if (calculatedMaxX < 1)
                calculatedMaxX = 1; // Prevent minX == maxX

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
                        drawHorizontalLine: false,
                        drawVerticalLine: true,
                        getDrawingVerticalLine: (value) {
                          return FlLine(
                            color: Colors.grey.shade100,
                            strokeWidth: 1.5,
                            dashArray: [5, 5],
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
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
                            reservedSize: 42,
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
                      minX: 0,
                      maxX: calculatedMaxX,
                      minY: 0,
                      maxY: controller.chartMaxY.value,
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (touchedSpot) =>
                              AppColors.primaryColor,
                          tooltipBorderRadius: BorderRadius.circular(8),
                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                            return touchedBarSpots.map((barSpot) {
                              final val = barSpot.y;
                              return LineTooltipItem(
                                controller.formatCurrency(val),
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
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xffAA7BFF),
                              AppColors.primaryColor,
                              const Color(0xff034F4b),
                            ],
                          ),
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xffAA7BFF).withValues(alpha: 0.15),
                                AppColors.primaryColor.withValues(alpha: 0.15),
                                AppColors.primaryColor.withValues(alpha: 0.0),
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

  Widget _bottomTitleWidgets(
    double value,
    TitleMeta meta,
    AdminDashboardController controller,
  ) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 10,
      color: Colors.grey,
    );

    // value is index (0 to 30), so day is value + 1
    int day = value.toInt() + 1;
    String text =
        "${controller.toBengaliNumber(day.toString())} ${_getBengaliMonthName(DateTime.now().month)}";

    return SideTitleWidget(
      meta: meta,
      space: 10,
      child: Text(text, style: style),
    );
  }

  Widget _leftTitleWidgets(
    double value,
    TitleMeta meta,
    AdminDashboardController controller,
  ) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 9,
      color: Colors.grey,
    );

    // We format the Y axis values
    String text;
    if (value == 0) {
      text = '০';
    } else {
      text = controller.toBengaliNumber(controller.formatCurrency(value));
    }

    return Text(text, style: style, textAlign: TextAlign.right);
  }

  String _getBengaliMonthName(int month) {
    const bnMonths = [
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
    if (month >= 1 && month <= 12) {
      return bnMonths[month - 1];
    }
    return '';
  }
}
