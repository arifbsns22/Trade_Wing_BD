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
  final RxDouble totalAdminCommission = 0.0.obs;
  final RxDouble totalWithdrawnAmount = 0.0.obs;
  final RxDouble totalAvailableBalance = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    setupListeners();
  }

  void setupListeners() {
    isLoading.value = true;

    // 1. Stream Resellers
    _firestore
        .collection('users')
        .snapshots()
        .listen((userSnapshot) {
      final resellers = userSnapshot.docs.where((doc) {
        final role = (doc.data()['role'] ?? '').toString().toLowerCase().trim();
        return role == 'reseller';
      }).map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      resellersList.value = resellers;
      totalResellersCount.value = resellers.length;
      _calculateAggregates();
      isLoading.value = false;
    }, onError: (e) {
      debugPrint('Error loading admin resellers: $e');
    });

    // 2. Stream Reseller Orders
    _firestore
        .collection('orders')
        .where('isResellerOrder', isEqualTo: true)
        .snapshots()
        .listen((orderSnapshot) {
      resellerOrders.value = orderSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      _calculateAggregates();
    }, onError: (e) {
      debugPrint('Error loading admin reseller orders: $e');
    });

    // 3. Stream Reseller Withdrawals
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
      debugPrint('Error loading admin reseller withdrawals: $e');
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

    // Reseller profits & Admin Commission
    double profitSum = 0.0;
    double commSum = 0.0;
    for (var o in resellerOrders) {
      if (o['orderStatus'] == 'delivered') {
        profitSum += (o['resellerEarnings'] as num?)?.toDouble() ?? 0.0;
        commSum += (o['adminCommission'] as num?)?.toDouble() ?? 0.0;
      }
    }
    totalActualProfit.value = profitSum;
    totalAdminCommission.value = commSum;

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

  // Get specific stats per reseller mobile
  Map<String, dynamic> getResellerStats(String mobile) {
    final mob = mobile.trim();
    final orders = resellerOrders.where((o) => (o['resellerMobile'] ?? '').toString().trim() == mob).toList();
    final completed = orders.where((o) => o['orderStatus'] == 'delivered').length;
    final pending = orders.where((o) => o['orderStatus'] == 'pending').length;

    double profit = 0.0;
    double comm = 0.0;
    for (var o in orders) {
      if (o['orderStatus'] == 'delivered') {
        profit += (o['resellerEarnings'] as num?)?.toDouble() ?? 0.0;
        comm += (o['adminCommission'] as num?)?.toDouble() ?? 0.0;
      }
    }

    double withdrawn = 0.0;
    final withdrawalsList = resellerWithdrawals.where((w) => (w['resellerMobile'] ?? '').toString().trim() == mob).toList();
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
      'commission': comm,
      'withdrawn': withdrawn,
      'balance': balance,
    };
  }
}
