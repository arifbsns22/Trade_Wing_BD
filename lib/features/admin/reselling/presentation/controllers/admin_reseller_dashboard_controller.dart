import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminResellerDashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxBool isLoading = true.obs;

  final RxList<Map<String, dynamic>> resellersList = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> resellerOrders = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> resellerWithdrawals = <Map<String, dynamic>>[].obs;

  // Aggregated Stats
  final RxInt totalResellersCount = 0.obs;
  final RxInt completedOrdersCount = 0.obs;
  final RxInt pendingOrdersCount = 0.obs;
  final RxDouble totalOrderedAmount = 0.0.obs;
  final RxDouble totalActualProfit = 0.0.obs;
  final RxDouble totalWithdrawnAmount = 0.0.obs;
  final RxDouble totalAvailableBalance = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    setupListeners();
  }

  void setupListeners() {
    isLoading.value = true;

    // 1. Stream Vendors
    _firestore
        .collection('users')
        .snapshots()
        .listen((userSnapshot) {
      final vendors = userSnapshot.docs.where((doc) {
        final data = doc.data();
        final role = (data['role'] ?? '').toString().toLowerCase().trim();
        final verificationStatus = (data['resellerVerificationStatus'] ?? '').toString().toLowerCase().trim();
        return role == 'reseller' ||
            verificationStatus == 'pending' ||
            verificationStatus == 'hold' ||
            verificationStatus == 'rejected';
      }).map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      resellersList.value = vendors;
      totalResellersCount.value = vendors.length;
      _calculateAggregates();
      isLoading.value = false;
    }, onError: (e) {
      debugPrint('Error loading admin vendors: $e');
    });

    // 2. Stream Vendor Orders
    _firestore
        .collection('orders')
        .where('isVendorOrder', isEqualTo: true)
        .snapshots()
        .listen((orderSnapshot) {
      resellerOrders.value = orderSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      _calculateAggregates();
    }, onError: (e) {
      debugPrint('Error loading admin vendor orders: $e');
    });

    // 3. Stream Vendor Withdrawals
    _firestore
        .collection('withdrawals')
        .where('userRole', isEqualTo: 'reseller')
        .snapshots()
        .listen((withdrawalSnapshot) {
      resellerWithdrawals.value = withdrawalSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      _calculateAggregates();
    }, onError: (e) {
      debugPrint('Error loading admin vendor withdrawals: $e');
    });
  }

  void _calculateAggregates() {
    // Orders counts
    completedOrdersCount.value = resellerOrders.where((o) => o['orderStatus'] == 'delivered').length;
    pendingOrdersCount.value = resellerOrders.where((o) => o['orderStatus'] == 'pending').length;

    // Ordered Amount
    double orderedSum = 0.0;
    for (var o in resellerOrders) {
      orderedSum += (o['totalAmount'] as num?)?.toDouble() ?? 0.0;
    }
    totalOrderedAmount.value = orderedSum;

    // Profits
    double profitSum = 0.0;
    for (var o in resellerOrders) {
      if (o['orderStatus'] == 'delivered') {
        profitSum += (o['vendorProfit'] as num?)?.toDouble() ?? 0.0;
      }
    }
    totalActualProfit.value = profitSum;

    // Withdrawals
    double withdrawnSum = 0.0;
    for (var w in resellerWithdrawals) {
      if (w['status'] == 'approved') {
        withdrawnSum += (w['amount'] as num?)?.toDouble() ?? 0.0;
      }
    }
    totalWithdrawnAmount.value = withdrawnSum;

    // Available Balance
    totalAvailableBalance.value = (profitSum - withdrawnSum).clamp(0.0, 9999999.0);
  }

  // Get specific stats per vendor mobile
  Map<String, dynamic> getResellerStats(String mobile) {
    final mob = mobile.trim();
    final orders = resellerOrders.where((o) => (o['vendorMobile'] ?? '').toString().trim() == mob).toList();
    final completed = orders.where((o) => o['orderStatus'] == 'delivered').length;
    final pending = orders.where((o) => o['orderStatus'] == 'pending').length;

    double profit = 0.0;
    for (var o in orders) {
      if (o['orderStatus'] == 'delivered') {
        profit += (o['vendorProfit'] as num?)?.toDouble() ?? 0.0;
      }
    }

    double withdrawn = 0.0;
    final withdrawalsList = resellerWithdrawals.where((w) => (w['vendorMobile'] ?? '').toString().trim() == mob).toList();
    for (var w in withdrawalsList) {
      if (w['status'] == 'approved') {
        withdrawn += (w['amount'] as num?)?.toDouble() ?? 0.0;
      }
    }

    final balance = (profit - withdrawn).clamp(0.0, 9999999.0);

    return {
      'completedOrders': completed,
      'pendingOrders': pending,
      'profit': profit,
      'withdrawn': withdrawn,
      'balance': balance,
    };
  }

  Future<void> updateVerificationStatus(String mobile, String status) async {
    try {
      final updates = <String, dynamic>{
        'resellerVerificationStatus': status,
      };
      if (status == 'approved') {
        updates['role'] = 'Reseller';
      } else if (status == 'rejected') {
        // Demote back to customer if rejected
        updates['role'] = 'Customer';
      }
      await _firestore.collection('users').doc(mobile).update(updates);
      Get.snackbar(
        'সফল হয়েছে',
        'স্ট্যাটাস পরিবর্তন করে "$status" করা হয়েছে।',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'ত্রুটি',
        'স্ট্যাটাস পরিবর্তন করতে ব্যর্থ হয়েছে: $e',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}
