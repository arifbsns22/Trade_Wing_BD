import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminVendorDashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxBool isLoading = true.obs;

  final RxList<Map<String, dynamic>> vendorsList = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> vendorOrders = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> vendorWithdrawals = <Map<String, dynamic>>[].obs;

  // Aggregated Stats
  final RxInt totalVendorsCount = 0.obs;
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
        final role = (doc.data()['role'] ?? '').toString().toLowerCase().trim();
        return role == 'vendor';
      }).map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      vendorsList.value = vendors;
      totalVendorsCount.value = vendors.length;
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
      vendorOrders.value = orderSnapshot.docs.map((doc) {
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
        .where('userRole', isEqualTo: 'vendor')
        .snapshots()
        .listen((withdrawalSnapshot) {
      vendorWithdrawals.value = withdrawalSnapshot.docs.map((doc) {
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
    completedOrdersCount.value = vendorOrders.where((o) => o['orderStatus'] == 'delivered').length;
    pendingOrdersCount.value = vendorOrders.where((o) => o['orderStatus'] == 'pending').length;

    // Ordered Amount
    double orderedSum = 0.0;
    for (var o in vendorOrders) {
      orderedSum += (o['totalAmount'] as num?)?.toDouble() ?? 0.0;
    }
    totalOrderedAmount.value = orderedSum;

    // Profits
    double profitSum = 0.0;
    for (var o in vendorOrders) {
      if (o['orderStatus'] == 'delivered') {
        profitSum += (o['vendorProfit'] as num?)?.toDouble() ?? 0.0;
      }
    }
    totalActualProfit.value = profitSum;

    // Withdrawals
    double withdrawnSum = 0.0;
    for (var w in vendorWithdrawals) {
      if (w['status'] == 'approved') {
        withdrawnSum += (w['amount'] as num?)?.toDouble() ?? 0.0;
      }
    }
    totalWithdrawnAmount.value = withdrawnSum;

    // Available Balance
    totalAvailableBalance.value = (profitSum - withdrawnSum).clamp(0.0, 9999999.0);
  }

  // Get specific stats per vendor mobile
  Map<String, dynamic> getVendorStats(String mobile) {
    final mob = mobile.trim();
    final orders = vendorOrders.where((o) => (o['vendorMobile'] ?? '').toString().trim() == mob).toList();
    final completed = orders.where((o) => o['orderStatus'] == 'delivered').length;
    final pending = orders.where((o) => o['orderStatus'] == 'pending').length;

    double profit = 0.0;
    for (var o in orders) {
      if (o['orderStatus'] == 'delivered') {
        profit += (o['vendorProfit'] as num?)?.toDouble() ?? 0.0;
      }
    }

    double withdrawn = 0.0;
    final withdrawalsList = vendorWithdrawals.where((w) => (w['vendorMobile'] ?? '').toString().trim() == mob).toList();
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
}
