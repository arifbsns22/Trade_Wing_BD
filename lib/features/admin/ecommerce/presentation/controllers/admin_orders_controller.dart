import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/users/e-commerce/domain/models/order_model.dart';

class AdminOrdersController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var orders = <OrderModel>[].obs;
  var isLoading = true.obs;
  var searchQuery = ''.obs;

  List<OrderModel> get filteredOrders {
    if (searchQuery.value.isEmpty) {
      return orders;
    }
    
    final query = searchQuery.value.toLowerCase();
    return orders.where((order) {
      final matchesId = order.orderId.toLowerCase().contains(query);
      final matchesName = order.userName.toLowerCase().contains(query);
      final matchesPhone = order.userMobile.toLowerCase().contains(query);
      return matchesId || matchesName || matchesPhone;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _fetchOrders();
  }

  void _fetchOrders() {
    _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        orders.value = snapshot.docs.map((doc) {
          return OrderModel.fromMap(doc.data(), doc.id);
        }).toList();
        isLoading.value = false;
      },
      onError: (error) {
        Get.snackbar(
  'Error',
  'Failed to fetch orders: $error',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
        isLoading.value = false;
      },
    );
  }

  Future<void> deleteOrder(OrderModel order) async {
    try {
      isLoading.value = true;
      final batch = _firestore.batch();

      // 1. Delete order doc
      final orderRef = _firestore.collection('orders').doc(order.orderId);
      batch.delete(orderRef);

      // 2. Restore product stocks (only if the product document still exists in DB)
      for (var item in order.items) {
        final String? productId = item['productId'];
        final int qty = (item['quantity'] as num?)?.toInt() ?? 0;
        if (productId != null && productId.isNotEmpty && qty > 0) {
          final productRef = _firestore.collection('products').doc(productId);
          final productDoc = await productRef.get();
          if (productDoc.exists) {
            batch.update(productRef, {
              'stock': FieldValue.increment(qty),
            });
          }
        }
      }

      // 3. Update user financial stats
      final userRef = _firestore.collection('users').doc(order.userMobile);
      final userDoc = await userRef.get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null) {
          final int currentTotalOrders = (userData['totalOrders'] as num?)?.toInt() ?? 0;
          final double currentTotalOrderAmount = (userData['totalOrderAmount'] as num?)?.toDouble() ?? 0.0;
          final int currentRewardPoints = (userData['totalRewardPoints'] as num?)?.toInt() ?? 0;
          final double currentPurchasedAmount = (userData['totalPurchasedAmount'] as num?)?.toDouble() ?? 0.0;

          final int newTotalOrders = (currentTotalOrders - 1).clamp(0, 9999999);
          final double newTotalOrderAmount = (currentTotalOrderAmount - order.totalAmount).clamp(0.0, 9999999.0);
          final int newRewardPoints = (currentRewardPoints - order.rewardPointsEarned).clamp(0, 9999999);
          final double newPurchasedAmount = (currentPurchasedAmount - order.totalAmount).clamp(0.0, 9999999.0);

          batch.update(userRef, {
            'totalOrders': newTotalOrders,
            'totalOrderAmount': newTotalOrderAmount,
            'totalRewardPoints': newRewardPoints,
            'totalPurchasedAmount': newPurchasedAmount,
          });
        }
      }

      await batch.commit();
      Get.snackbar(
  'সফল',
  'অর্ডারটি সফলভাবে ডিলিট করা হয়েছে এবং স্টক রিস্টোর করা হয়েছে।',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
    } catch (e) {
      debugPrint('Error deleting order: $e');
      Get.snackbar(
  'ত্রুটি',
  'অর্ডার ডিলিট করতে সমস্যা হয়েছে: $e',
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
}
