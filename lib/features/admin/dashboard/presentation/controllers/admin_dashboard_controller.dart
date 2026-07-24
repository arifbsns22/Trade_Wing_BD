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

  // Recent Activities (Unified list of last 10 activities of different types)
  var recentActivities = <DashboardActivityModel>[].obs;

  // Users
  var usersThisMonth = 0.obs;
  var usersComparisonPercentage = 0.0.obs;
  var isUsersPositive = true.obs;

  // Orders Count
  var pendingOrdersCount = 0.obs;
  var deliveredOrdersCount = 0.obs;

  // Compact Stats by Order & Payment Status
  var pendingRecharges = 0.obs;
  var completedRecharges = 0.obs;
  var pendingDrives = 0.obs;
  var completedDrives = 0.obs;
  var pendingPackages = 0.obs;
  var completedPackages = 0.obs;
  var pendingProducts = 0.obs;
  var completedProducts = 0.obs;
  bool _hasLoadedOnce = false;
  DateTime? _lastFetchedAt;
  static const _cacheDuration = Duration(minutes: 5);

  bool get _isCacheValid =>
      _lastFetchedAt != null &&
      DateTime.now().difference(_lastFetchedAt!) < _cacheDuration;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardMetrics();
  }

  /// Call this to force a full refresh (e.g. pull-to-refresh)
  Future<void> forceRefresh() async {
    _lastFetchedAt = null;
    await fetchDashboardMetrics();
  }

  Future<void> fetchDashboardMetrics() async {
    // If cache is still valid, serve data instantly — 0 Firestore reads
    if (_isCacheValid) {
      isLoading(false);
      return;
    }

    try {
      if (!_hasLoadedOnce) {
        isLoading(true);
      }
      
      final now = DateTime.now();
      // Start of this month
      final thisMonthStart = DateTime(now.year, now.month, 1);
      // Start of last month
      final lastMonthStart = DateTime(now.year, now.month - 1, 1);
      // End of last month (which is one millisecond before the start of this month)
      final lastMonthEnd = thisMonthStart.subtract(const Duration(milliseconds: 1));

      // Define core load futures
      Future<void> fetchOrdersFuture() async {
        try {
          final ordersSnapshot = await _firestore
              .collection('orders')
              .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(lastMonthStart))
              .get();

          double salesThisMonthTemp = 0.0;
          double salesLastMonthTemp = 0.0;
          List<double> dailySalesTemp = List.filled(31, 0.0);

          for (var doc in ordersSnapshot.docs) {
            final data = doc.data();
            final status = data['orderStatus'] as String?;
            if (status != 'cancelled') {
              final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? now;
              final amount = (data['totalAmount'] ?? 0).toDouble();

              if (createdAt.isAfter(thisMonthStart) || createdAt.isAtSameMomentAs(thisMonthStart)) {
                salesThisMonthTemp += amount;
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
          
          double maxDailySale = dailySalesTemp.reduce((curr, next) => curr > next ? curr : next);
          if (maxDailySale < 1000) maxDailySale = 1000;
          chartMaxY.value = maxDailySale * 1.2;
          
          if (salesLastMonthTemp > 0) {
            salesComparisonPercentage.value = ((salesThisMonthTemp - salesLastMonthTemp) / salesLastMonthTemp) * 100;
          } else {
            salesComparisonPercentage.value = salesThisMonthTemp > 0 ? 100.0 : 0.0;
          }
          isSalesPositive.value = salesComparisonPercentage.value >= 0;
        } catch (e) {
          print("Error fetching sales metrics: $e");
        }
      }

      Future<void> fetchUsersFuture() async {
        try {
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

          if (usersLastMonthTemp > 0) {
            usersComparisonPercentage.value = ((usersThisMonthTemp - usersLastMonthTemp) / usersLastMonthTemp) * 100;
          } else {
            usersComparisonPercentage.value = usersThisMonthTemp > 0 ? 100.0 : 0.0;
          }
          isUsersPositive.value = usersComparisonPercentage.value >= 0;
        } catch (e) {
          print("Error fetching users metrics: $e");
        }
      }

      Future<void> fetchGeneralCountsFuture() async {
        try {
          final pendingQuery = _firestore
              .collection('orders')
              .where('orderStatus', isEqualTo: 'pending')
              .count()
              .get();
          final deliveredQuery = _firestore
              .collection('orders')
              .where('orderStatus', isEqualTo: 'delivered')
              .count()
              .get();

          final results = await Future.wait([pendingQuery, deliveredQuery]);
          pendingOrdersCount.value = results[0].count ?? 0;
          deliveredOrdersCount.value = results[1].count ?? 0;
        } catch (e) {
          print("Error fetching pending/delivered counts: $e");
        }
      }

      Future<void> fetchRechargesAndDrivesFuture() async {
        try {
          final pendingRechargesQ = _firestore
              .collection('mobile_recharges')
              .where('rechargeType', isEqualTo: 'regular')
              .where('status', isEqualTo: 'pending')
              .count()
              .get();
          final completedRechargesQ = _firestore
              .collection('mobile_recharges')
              .where('rechargeType', isEqualTo: 'regular')
              .where('status', isEqualTo: 'completed')
              .count()
              .get();
          final pendingDrivesQ = _firestore
              .collection('mobile_recharges')
              .where('rechargeType', isEqualTo: 'drive')
              .where('status', isEqualTo: 'pending')
              .count()
              .get();
          final completedDrivesQ = _firestore
              .collection('mobile_recharges')
              .where('rechargeType', isEqualTo: 'drive')
              .where('status', isEqualTo: 'completed')
              .count()
              .get();

          final results = await Future.wait([
            pendingRechargesQ,
            completedRechargesQ,
            pendingDrivesQ,
            completedDrivesQ,
          ]);

          pendingRecharges.value = results[0].count ?? 0;
          completedRecharges.value = results[1].count ?? 0;
          pendingDrives.value = results[2].count ?? 0;
          completedDrives.value = results[3].count ?? 0;
        } catch (e) {
          print("Error fetching recharges and drives counts: $e");
        }
      }

      Future<void> fetchPendingPackagesAndProductsFuture() async {
        try {
          final pendingOrdersSnapshot = await _firestore
              .collection('orders')
              .where('orderStatus', isEqualTo: 'pending')
              .get();

          int pendingPkgCount = 0;
          int pendingProdCount = 0;

          for (var doc in pendingOrdersSnapshot.docs) {
            final data = doc.data();
            final items = data['items'] as List?;
            bool isPackage = false;
            if (items != null) {
              for (var item in items) {
                final name = item['productName'] as String? ?? '';
                if (name.startsWith('Package:')) {
                  isPackage = true;
                  break;
                }
              }
            }
            if (isPackage) {
              pendingPkgCount++;
            } else {
              pendingProdCount++;
            }
          }
          pendingPackages.value = pendingPkgCount;
          pendingProducts.value = pendingProdCount;
        } catch (e) {
          print("Error fetching pending packages/products count: $e");
        }
      }

      // Execute all core futures in parallel simultaneously!
      await Future.wait([
        fetchOrdersFuture(),
        fetchUsersFuture(),
        fetchGeneralCountsFuture(),
        fetchRechargesAndDrivesFuture(),
        fetchPendingPackagesAndProductsFuture(),
        _fetchRecentActivities(),
      ]);

      // Run heavier background metrics asynchronously
      _fetchCompletedPackagesAndProducts();
      _fetchRoleWiseUserCounts();
      _fetchRecentOrders();

      _hasLoadedOnce = true;
      _lastFetchedAt = DateTime.now(); // Stamp cache timestamp
    } catch (e) {
      print("Global Error fetching admin metrics: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> _fetchCompletedPackagesAndProducts() async {
    try {
      final completedOrdersSnapshot = await _firestore
          .collection('orders')
          .where('orderStatus', isEqualTo: 'delivered')
          .get();

      int completedPkgCount = 0;
      int completedProdCount = 0;

      for (var doc in completedOrdersSnapshot.docs) {
        final data = doc.data();
        final items = data['items'] as List?;
        bool isPackage = false;
        if (items != null) {
          for (var item in items) {
            final name = item['productName'] as String? ?? '';
            if (name.startsWith('Package:')) {
              isPackage = true;
              break;
            }
          }
        }
        if (isPackage) {
          completedPkgCount++;
        } else {
          completedProdCount++;
        }
      }
      completedPackages.value = completedPkgCount;
      completedProducts.value = completedProdCount;
    } catch (e) {
      print("Error fetching completed packages/products count: $e");
    }
  }

  Future<void> _fetchRoleWiseUserCounts() async {
    try {
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
    } catch (e) {
      print("Error fetching role-wise counts: $e");
    }
  }

  Future<void> _fetchRecentOrders() async {
    try {
      final recentOrdersQuery = await _firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();
      recentOrders.value = recentOrdersQuery.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error fetching recent orders: $e");
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

  Future<void> _fetchRecentActivities() async {
    final List<DashboardActivityModel> activities = [];

    // Fetch and map orders
    try {
      final ordersQuery = await _firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      for (var doc in ordersQuery.docs) {
        try {
          final data = doc.data();
          final order = OrderModel.fromMap(data, doc.id);
          
          bool isPackage = false;
          for (var item in order.items) {
            final name = item['productName'] as String? ?? '';
            if (name.startsWith('Package:')) {
              isPackage = true;
              break;
            }
          }

          activities.add(DashboardActivityModel(
            id: order.orderId,
            title: isPackage ? 'প্যাকেজ অর্ডার' : 'প্রোডাক্ট অর্ডার',
            type: isPackage ? DashboardActivityType.package : DashboardActivityType.product,
            amount: order.totalAmount,
            status: order.orderStatus.name,
            paymentStatus: order.paymentStatus.name,
            createdAt: order.createdAt,
            userName: order.userName,
            userMobile: order.userMobile,
          ));
        } catch (e) {
          print("Error parsing order doc ${doc.id}: $e");
        }
      }
    } catch (e) {
      print("Error querying recent orders: $e");
    }

    // Fetch and map recharges
    try {
      final rechargesQuery = await _firestore
          .collection('mobile_recharges')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      for (var doc in rechargesQuery.docs) {
        try {
          final data = doc.data();
          final id = doc.id;
          final operatorName = data['operatorName'] as String? ?? '';
          final mobileNumber = data['mobileNumber'] as String? ?? '';
          
          double amount = 0.0;
          if (data['amount'] != null) {
            if (data['amount'] is num) {
              amount = (data['amount'] as num).toDouble();
            } else if (data['amount'] is String) {
              amount = double.tryParse(data['amount'] as String) ?? 0.0;
            }
          }

          final userMobile = data['userMobile'] as String? ?? '';
          final userName = data['userName'] as String? ?? '';
          final status = data['status'] as String? ?? 'pending';

          DateTime createdAt = DateTime.now();
          if (data['createdAt'] != null) {
            if (data['createdAt'] is Timestamp) {
              createdAt = (data['createdAt'] as Timestamp).toDate();
            } else if (data['createdAt'] is String) {
              createdAt = DateTime.tryParse(data['createdAt'] as String) ?? DateTime.now();
            }
          }

          final rechargeType = data['rechargeType'] as String? ?? 'regular';
          final isDrive = rechargeType == 'drive';

          activities.add(DashboardActivityModel(
            id: id,
            title: isDrive 
                ? 'ড্রাইভ প্যাকেজ ($operatorName - $mobileNumber)' 
                : 'মোবাইল রিচার্জ ($operatorName - $mobileNumber)',
            type: isDrive ? DashboardActivityType.drive : DashboardActivityType.recharge,
            amount: amount,
            status: status,
            paymentStatus: status == 'completed' ? 'verified' : (status == 'failed' ? 'failed' : 'pending'),
            createdAt: createdAt,
            userName: userName,
            userMobile: userMobile,
          ));
        } catch (e) {
          print("Error parsing recharge doc ${doc.id}: $e");
        }
      }
    } catch (e) {
      print("Error querying recent mobile_recharges: $e");
    }

    try {
      // Sort combined list by createdAt descending
      activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Keep only top 10
      recentActivities.value = activities.take(10).toList();
    } catch (e) {
      print("Error sorting recent activities: $e");
    }
  }
}

enum DashboardActivityType {
  product,
  package,
  drive,
  recharge,
}

class DashboardActivityModel {
  final String id;
  final String title;
  final DashboardActivityType type;
  final double amount;
  final String status;
  final String paymentStatus;
  final DateTime createdAt;
  final String userName;
  final String userMobile;

  DashboardActivityModel({
    required this.id,
    required this.title,
    required this.type,
    required this.amount,
    required this.status,
    required this.paymentStatus,
    required this.createdAt,
    required this.userName,
    required this.userMobile,
  });
}
