import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/auth/domain/models/user_role.dart';
import 'package:trade_wign_bd/features/users/e-commerce/domain/models/order_model.dart';

class AdminDashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observables
  var isLoading = true.obs;
  
  // Total Sales
  var totalSalesThisMonth = 0.0.obs;
  var salesComparisonPercentage = 0.0.obs;
  var isSalesPositive = true.obs;
  
  // Daily Sales for Chart
  var dailySales = <double>[].obs;
  var chartMaxY = 1000.0.obs;

  // Role wise User Counts
  var roleUserCounts = <String, int>{}.obs;

  // Recent Orders
  var recentOrders = <OrderModel>[].obs;

  // Users
  var usersThisMonth = 0.obs;
  var usersComparisonPercentage = 0.0.obs;
  var isUsersPositive = true.obs;

  // Orders Count
  var pendingOrdersCount = 0.obs;
  var deliveredOrdersCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardMetrics();
  }

  Future<void> fetchDashboardMetrics() async {
    try {
      isLoading(true);
      
      final now = DateTime.now();
      // Start of this month
      final thisMonthStart = DateTime(now.year, now.month, 1);
      // Start of last month
      final lastMonthStart = DateTime(now.year, now.month - 1, 1);
      // End of last month (which is one millisecond before the start of this month)
      final lastMonthEnd = thisMonthStart.subtract(const Duration(milliseconds: 1));

      // 1. Fetch Orders for Sales calculation
      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(lastMonthStart))
          .get();

      double salesThisMonthTemp = 0.0;
      double salesLastMonthTemp = 0.0;
      
      // Daily sales tracking (up to 31 days)
      List<double> dailySalesTemp = List.filled(31, 0.0);

      for (var doc in ordersSnapshot.docs) {
        final data = doc.data();
        final status = data['orderStatus'] as String?;
        // We only sum sales if it's not cancelled
        if (status != 'cancelled') {
          final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? now;
          final amount = (data['totalAmount'] ?? 0).toDouble();

          if (createdAt.isAfter(thisMonthStart) || createdAt.isAtSameMomentAs(thisMonthStart)) {
            salesThisMonthTemp += amount;
            // Track daily sales
            int dayIndex = createdAt.day - 1;
            if (dayIndex >= 0 && dayIndex < 31) {
              dailySalesTemp[dayIndex] += amount;
            }
          } else if (createdAt.isAfter(lastMonthStart) && createdAt.isBefore(lastMonthEnd)) {
            salesLastMonthTemp += amount;
          }
        }
      }

      totalSalesThisMonth.value = salesThisMonthTemp;
      dailySales.value = dailySalesTemp;
      
      // Calculate maxY for chart
      double maxDailySale = dailySalesTemp.reduce((curr, next) => curr > next ? curr : next);
      // Give it some padding, round up to next 10k or just padding
      if (maxDailySale < 1000) maxDailySale = 1000;
      chartMaxY.value = maxDailySale * 1.2;
      
      // Calculate Sales Percentage Difference
      if (salesLastMonthTemp > 0) {
        salesComparisonPercentage.value = ((salesThisMonthTemp - salesLastMonthTemp) / salesLastMonthTemp) * 100;
      } else {
        salesComparisonPercentage.value = salesThisMonthTemp > 0 ? 100.0 : 0.0;
      }
      isSalesPositive.value = salesComparisonPercentage.value >= 0;

      // 2. Fetch Users for User calculation
      final usersSnapshot = await _firestore
          .collection('users')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(lastMonthStart))
          .get();

      int usersThisMonthTemp = 0;
      int usersLastMonthTemp = 0;

      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? now;

        if (createdAt.isAfter(thisMonthStart) || createdAt.isAtSameMomentAs(thisMonthStart)) {
          usersThisMonthTemp++;
        } else if (createdAt.isAfter(lastMonthStart) && createdAt.isBefore(lastMonthEnd)) {
          usersLastMonthTemp++;
        }
      }

      usersThisMonth.value = usersThisMonthTemp;

      // Calculate Users Percentage Difference
      if (usersLastMonthTemp > 0) {
        usersComparisonPercentage.value = ((usersThisMonthTemp - usersLastMonthTemp) / usersLastMonthTemp) * 100;
      } else {
        usersComparisonPercentage.value = usersThisMonthTemp > 0 ? 100.0 : 0.0;
      }
      isUsersPositive.value = usersComparisonPercentage.value >= 0;

      // 3. Fetch Total Pending Orders (All Time)
      final pendingQuery = await _firestore
          .collection('orders')
          .where('orderStatus', isEqualTo: 'pending')
          .count()
          .get();
      pendingOrdersCount.value = pendingQuery.count ?? 0;

      // 4. Fetch Total Delivered Orders (All Time)
      final deliveredQuery = await _firestore
          .collection('orders')
          .where('orderStatus', isEqualTo: 'delivered')
          .count()
          .get();
      deliveredOrdersCount.value = deliveredQuery.count ?? 0;

      // 5. Fetch Role-wise User Counts
      final countsMap = <String, int>{};
      await Future.wait(UserRole.values.map((role) async {
        final q = await _firestore
            .collection('users')
            .where('role', isEqualTo: role.value)
            .count()
            .get();
        final count = q.count ?? 0;
        if (count > 0) {
          countsMap[role.nameInBengali] = count;
        }
      }));
      roleUserCounts.value = countsMap;

      // 6. Fetch Recent 5 Orders
      final recentOrdersQuery = await _firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();
      recentOrders.value = recentOrdersQuery.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();

    } catch (e) {
      print("Error fetching admin metrics: $e");
    } finally {
      isLoading(false);
    }
  }

  // Helper method to format currency securely
  String formatCurrency(double amount) {
    return "৳ ${amount.toStringAsFixed(0)}";
  }

  // Helper for percentage formatting
  String formatPercentage(double percent) {
    return "${percent.abs().toStringAsFixed(1)}%";
  }
  
  // Helper to convert English numbers to Bengali string
  String toBengaliNumber(String input) {
    const englishToBengali = {'0': '০', '1': '১', '2': '২', '3': '৩', '4': '৪', '5': '৫', '6': '৬', '7': '৭', '8': '৮', '9': '৯'};
    return input.split('').map((e) => englishToBengali[e] ?? e).join('');
  }
}
