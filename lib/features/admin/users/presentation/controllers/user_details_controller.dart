import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserDetailsController extends GetxController {
  final Map<String, dynamic> user;
  
  UserDetailsController({required this.user});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxBool isLoading = true.obs;
  final RxList<Map<String, dynamic>> userOrders = <Map<String, dynamic>>[].obs;
  
  // Computed stats
  final RxInt totalOrdersCount = 0.obs;
  final RxDouble totalPaidAmount = 0.0.obs;
  final RxInt pendingOrdersCount = 0.obs;
  final RxInt totalRewardPoints = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserOrders();
  }

  Future<void> fetchUserOrders() async {
    try {
      isLoading.value = true;
      final mobile = user['mobile'] ?? '';
      if (mobile.isEmpty) {
        isLoading.value = false;
        return;
      }

      final snapshot = await _firestore
          .collection('orders')
          .where('userMobile', isEqualTo: mobile)
          .orderBy('createdAt', descending: true)
          .get();

      final orders = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      userOrders.value = orders;
      _calculateStats(orders);

    } catch (e) {
      debugPrint('Error fetching user orders: $e');
      Get.snackbar(
  'ত্রুটি',
  'ইউজারের অর্ডার সমূহ আনতে সমস্যা হচ্ছে',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateStats(List<Map<String, dynamic>> orders) {
    int ordersCount = orders.length;
    double paidAmount = 0.0;
    int pendingCount = 0;
    int points = 0;

    for (var order in orders) {
      final status = order['orderStatus'] ?? 'pending';
      final paymentStatus = order['paymentStatus'] ?? 'pending';
      final amount = (order['totalAmount'] ?? 0.0).toDouble();
      final earnedPoints = (order['rewardPointsEarned'] ?? 0) as int;

      if (status == 'pending') {
        pendingCount++;
      }
      
      // Calculate paid amount if payment is verified or order is delivered
      if (paymentStatus == 'verified' || status == 'delivered' || status == 'shipped' || status == 'processing') {
        paidAmount += amount;
      }

      if (status != 'cancelled') {
        points += earnedPoints;
      }
    }

    totalOrdersCount.value = ordersCount;
    totalPaidAmount.value = paidAmount;
    pendingOrdersCount.value = pendingCount;
    totalRewardPoints.value = points;
  }
}
