import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';

class WalletController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = AuthController.instance;

  final RxBool isLoading = true.obs;
  final RxDouble walletBalance = 0.0.obs;
  final RxInt spentPoints = 0.obs;
  final RxInt totalEarnedPoints = 0.obs;
  final RxInt netPoints = 0.obs;
  final RxInt conversionRate = 100.obs;

  final RxList<Map<String, dynamic>> transactions = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> purchaseHistory = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAllData();
  }

  Future<void> loadAllData() async {
    isLoading.value = true;
    try {
      await loadConversionRate();
      await loadWalletData();
      await loadTransactions();
      await loadPurchaseHistory();
    } catch (e) {
      debugPrint('Error loading wallet data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadConversionRate() async {
    try {
      final doc = await _firestore.collection('app_settings').doc('global').get();
      if (doc.exists) {
        conversionRate.value = doc.data()?['rewardPointsRate'] ?? 100;
      }
    } catch (e) {
      debugPrint('Error loading conversion rate: $e');
    }
  }

  Future<void> loadWalletData() async {
    final mobile = _authController.currentUserMobile.value;
    if (mobile.isEmpty) return;

    try {
      final doc = await _firestore.collection('users').doc(mobile).get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        walletBalance.value = (data['walletBalance'] ?? 0.0).toDouble();
        spentPoints.value = data['spentRewardPoints'] ?? 0;
      }
    } catch (e) {
      debugPrint('Error loading wallet data: $e');
    }
  }

  Future<void> loadTransactions() async {
    final mobile = _authController.currentUserMobile.value;
    if (mobile.isEmpty) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(mobile)
          .collection('wallet_transactions')
          .orderBy('createdAt', descending: true)
          .get();

      transactions.value = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Error loading wallet transactions: $e');
    }
  }

  Future<void> loadPurchaseHistory() async {
    final mobile = _authController.currentUserMobile.value;
    if (mobile.isEmpty) return;

    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userMobile', isEqualTo: mobile)
          .get();

      int calculatedPoints = 0;
      final List<Map<String, dynamic>> history = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['orderStatus'] != 'cancelled') {
          final pts = (data['rewardPointsEarned'] ?? 0) as int;
          calculatedPoints += pts;
          
          if (pts > 0) {
            history.add({
              'orderId': data['orderId'] ?? doc.id,
              'amount': (data['totalAmount'] ?? 0.0).toDouble(),
              'points': pts,
              'createdAt': data['createdAt'],
              'status': data['orderStatus'],
            });
          }
        }
      }

      // Sort by date descending
      history.sort((a, b) {
        final Timestamp ta = a['createdAt'];
        final Timestamp tb = b['createdAt'];
        return tb.compareTo(ta);
      });

      purchaseHistory.value = history;
      totalEarnedPoints.value = calculatedPoints;
      netPoints.value = (calculatedPoints - spentPoints.value).clamp(0, 99999999);
    } catch (e) {
      debugPrint('Error loading purchase points history: $e');
    }
  }

  Future<bool> convertPoints(int pointsToConvert) async {
    if (pointsToConvert <= 0 || pointsToConvert > netPoints.value) {
      Get.snackbar(
        'ত্রুটি',
        'সঠিক পয়েন্ট সংখ্যা লিখুন',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: Colors.redAccent.withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    final mobile = _authController.currentUserMobile.value;
    if (mobile.isEmpty) return false;

    isLoading.value = true;
    try {
      final double takaAmount = pointsToConvert / conversionRate.value;
      final userRef = _firestore.collection('users').doc(mobile);

      // Perform a transaction to ensure atomic updates
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        final currentBalance = (userDoc.data()?['walletBalance'] ?? 0.0).toDouble();
        final currentSpent = userDoc.data()?['spentRewardPoints'] ?? 0;

        transaction.update(userRef, {
          'walletBalance': currentBalance + takaAmount,
          'spentRewardPoints': currentSpent + pointsToConvert,
        });

        // Add a wallet transaction document
        final newTxRef = userRef.collection('wallet_transactions').doc();
        transaction.set(newTxRef, {
          'type': 'conversion',
          'amount': takaAmount,
          'points': pointsToConvert,
          'createdAt': FieldValue.serverTimestamp(),
          'description': '$pointsToConvert পয়েন্ট টাকায় রূপান্তর করা হয়েছে।',
        });
      });

      // Reload
      await loadWalletData();
      await loadTransactions();
      await loadPurchaseHistory();

      Get.snackbar(
        'সফল হয়েছে',
        '৳$takaAmount আপনার মানিব্যাগে যুক্ত করা হয়েছে।',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return true;
    } catch (e) {
      debugPrint('Error converting points: $e');
      Get.snackbar(
        'ত্রুটি',
        'পয়েন্ট রূপান্তর ব্যর্থ হয়েছে: $e',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: Colors.redAccent.withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
