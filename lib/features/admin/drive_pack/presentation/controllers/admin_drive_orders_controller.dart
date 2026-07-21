import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/users/drive_pack/domain/models/recharge_model.dart';
import 'package:trade_wign_bd/features/users/drive_pack/domain/models/operator_model.dart';

class AdminDriveOrdersController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxBool isLoading = false.obs;
  final RxList<RechargeModel> allOrders = <RechargeModel>[].obs;
  
  // Filtering states
  final RxString searchQuery = ''.obs;
  final RxString selectedOperator = 'All'.obs;
  final RxString selectedOrderType = 'All'.obs; // 'All', 'regular', 'drive'
  final RxString selectedStatus = 'All'.obs; // 'All', 'pending', 'completed', 'failed'

  // List of unique operator names loaded from database
  final RxList<String> operatorFilters = <String>['All'].obs;

  // Real-time counter states
  final RxInt pendingOffersCount = 0.obs;
  final RxInt pendingRechargesCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    streamAllOrders();
    fetchOperators();
  }

  /// Listens to real-time changes in mobile recharges collection
  void streamAllOrders() {
    isLoading.value = true;
    _firestore
        .collection('mobile_recharges')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      final List<RechargeModel> orders = snapshot.docs
          .map((doc) => RechargeModel.fromFirestore(doc))
          .toList();
      
      allOrders.value = orders;
      
      // Calculate pending stats
      pendingOffersCount.value = orders
          .where((o) => o.rechargeType == 'drive' && o.status == 'pending')
          .length;
      
      pendingRechargesCount.value = orders
          .where((o) => o.rechargeType == 'regular' && o.status == 'pending')
          .length;

      isLoading.value = false;
    }, onError: (e) {
      debugPrint('Error streaming drive orders: $e');
      isLoading.value = false;
    });
  }

  /// Load operators list to build filter dropdown dynamically
  Future<void> fetchOperators() async {
    try {
      final snapshot = await _firestore.collection('operators').get();
      final names = snapshot.docs
          .map((doc) => doc.data()['name'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
      
      operatorFilters.value = ['All', ...names];
    } catch (e) {
      debugPrint('Error loading operator filters: $e');
    }
  }

  /// Filter logic for table
  List<RechargeModel> get filteredOrdersList {
    return allOrders.where((order) {
      // 1. Search Query Filter
      final query = searchQuery.value.trim().toLowerCase();
      bool matchesSearch = true;
      if (query.isNotEmpty) {
        final matchesTxn = order.transactionId.toLowerCase().contains(query);
        final matchesUser = order.userName.toLowerCase().contains(query);
        final matchesUserMobile = order.userMobile.contains(query);
        final matchesTarget = order.mobileNumber.contains(query);
        matchesSearch = matchesTxn || matchesUser || matchesUserMobile || matchesTarget;
      }

      // 2. Operator Filter
      bool matchesOperator = true;
      if (selectedOperator.value != 'All') {
        matchesOperator = order.operatorName.toLowerCase() == selectedOperator.value.toLowerCase();
      }

      // 3. Order Type Filter
      bool matchesType = true;
      if (selectedOrderType.value != 'All') {
        matchesType = order.rechargeType == selectedOrderType.value;
      }

      // 4. Status Filter
      bool matchesStatus = true;
      if (selectedStatus.value != 'All') {
        matchesStatus = order.status == selectedStatus.value;
      }

      return matchesSearch && matchesOperator && matchesType && matchesStatus;
    }).toList();
  }

  /// Update order status (Completed, Failed, Pending)
  Future<void> updateOrderStatus(String transactionId, String newStatus) async {
    try {
      await _firestore
          .collection('mobile_recharges')
          .doc(transactionId)
          .update({'status': newStatus});

      Get.snackbar(
        'সফল',
        'অর্ডার স্ট্যাটাস সফলভাবে আপডেট করা হয়েছে।',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      debugPrint('Error updating order status: $e');
      Get.snackbar(
        'ত্রুটি',
        'স্ট্যাটাস আপডেট করতে ব্যর্থ হয়েছে।',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: Colors.red.withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  /// Delete recharge/offer order record
  Future<void> deleteOrder(String transactionId) async {
    try {
      await _firestore.collection('mobile_recharges').doc(transactionId).delete();
      
      Get.snackbar(
        'সফল',
        'অর্ডার রেকর্ড সফলভাবে মুছে ফেলা হয়েছে।',
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
        'অর্ডার মুছতে ব্যর্থ হয়েছে।',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: Colors.red.withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}
