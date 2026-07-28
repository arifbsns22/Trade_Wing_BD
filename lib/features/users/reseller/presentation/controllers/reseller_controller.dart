import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import 'package:trade_wign_bd/features/admin/ecommerce/domain/models/product_model.dart';
import 'package:trade_wign_bd/features/users/e-commerce/domain/models/order_model.dart';
import 'package:trade_wign_bd/common/services/notification_helper.dart';

class ResellerController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  String get resellerMobile => _authController.currentUserMobile.value.trim();

  // Loading states
  final RxBool isLoadingProducts = false.obs;
  final RxBool isLoadingOrders = false.obs;
  final RxBool isLoadingWithdrawals = false.obs;
  final RxBool isSubmittingAction = false.obs;

  // Reseller data lists
  final RxList<Product> resellerProducts = <Product>[].obs;
  final RxList<OrderModel> resellerOrders = <OrderModel>[].obs;
  final RxList<Map<String, dynamic>> withdrawals = <Map<String, dynamic>>[].obs;

  // Dropdown configuration data lists
  final RxList<Map<String, dynamic>> productTypes = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> units = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> brands = <Map<String, dynamic>>[].obs;

  // Earning / Finance states
  final RxDouble reactiveTotalEarnings = 0.0.obs;
  final RxDouble reactiveTotalSales = 0.0.obs;
  final RxDouble reactiveTotalWithdrawn = 0.0.obs;

  double get withdrawAvailableAmount =>
      (reactiveTotalEarnings.value - reactiveTotalWithdrawn.value).clamp(0.0, 9999999.0);

  // Stats counts
  int get pendingOrdersCount =>
      resellerOrders.where((o) => o.orderStatus == OrderStatus.pending).length;
  int get completedOrdersCount =>
      resellerOrders.where((o) => o.orderStatus == OrderStatus.delivered).length;

  @override
  void onInit() {
    super.onInit();
    if (resellerMobile.isNotEmpty) {
      setupListeners();
    } else {
      ever(_authController.currentUserMobile, (String mobile) {
        if (mobile.isNotEmpty) {
          setupListeners();
        }
      });
    }
  }

  void setupListeners() {
    listenToProducts();
    listenToOrders();
    listenToWithdrawals();
    fetchConfigData();
  }

  // 1. Stream reseller's own products
  void listenToProducts() {
    if (resellerMobile.isEmpty) return;
    isLoadingProducts.value = true;
    _firestore
        .collection('products')
        .where('isResellerProduct', isEqualTo: true)
        .where('resellerMobile', isEqualTo: resellerMobile)
        .snapshots()
        .listen((snapshot) {
      resellerProducts.value = snapshot.docs.map((doc) {
        return Product.fromFirestore(doc);
      }).toList();
      isLoadingProducts.value = false;
    }, onError: (e) {
      debugPrint('Error loading reseller products: $e');
      isLoadingProducts.value = false;
    });
  }

  // 2. Stream reseller orders & calculate earnings in real-time
  void listenToOrders() {
    if (resellerMobile.isEmpty) return;
    isLoadingOrders.value = true;
    _firestore
        .collection('orders')
        .where('isResellerOrder', isEqualTo: true)
        .where('resellerMobile', isEqualTo: resellerMobile)
        .snapshots()
        .listen((snapshot) {
      resellerOrders.value = snapshot.docs.map((doc) {
        return OrderModel.fromMap(doc.data(), doc.id);
      }).toList();

      double salesSum = 0.0;
      double earningsSum = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final status = data['orderStatus'] as String?;
        if (status == 'delivered') {
          final double totalAmount = (data['totalAmount'] ?? 0.0).toDouble();
          final double earnings = (data['resellerEarnings'] ?? 0.0).toDouble();
          salesSum += totalAmount;
          earningsSum += earnings;
        }
      }
      reactiveTotalSales.value = salesSum;
      reactiveTotalEarnings.value = earningsSum;
      isLoadingOrders.value = false;
    }, onError: (e) {
      debugPrint('Error loading reseller orders: $e');
      isLoadingOrders.value = false;
    });
  }

  // 3. Stream withdrawals
  void listenToWithdrawals() {
    if (resellerMobile.isEmpty) return;
    isLoadingWithdrawals.value = true;
    _firestore
        .collection('withdrawals')
        .where('resellerMobile', isEqualTo: resellerMobile)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      withdrawals.value = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      double withdrawnSum = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String?;
        if (status == 'approved') {
          final amt = (data['amount'] as num?)?.toDouble() ?? 0.0;
          withdrawnSum += amt;
        }
      }
      reactiveTotalWithdrawn.value = withdrawnSum;
      isLoadingWithdrawals.value = false;
    }, onError: (e) {
      debugPrint('Error loading withdrawals: $e');
      isLoadingWithdrawals.value = false;
    });
  }

  // 4. Load dynamic categories/brands/units/types from Firestore config
  void fetchConfigData() {
    // Categories
    _firestore.collection('categories').orderBy('name').snapshots().listen((snapshot) {
      categories.value = snapshot.docs.map((doc) => {
        'id': doc.id,
        'name': doc.data()['name'] ?? '',
      }).toList();
    });

    // Brands
    _firestore.collection('brands').orderBy('name').snapshots().listen((snapshot) {
      brands.value = snapshot.docs.map((doc) => {
        'id': doc.id,
        'name': doc.data()['name'] ?? '',
      }).toList();
    });

    // Product Types
    _firestore.collection('product_types').orderBy('name').snapshots().listen((snapshot) {
      productTypes.value = snapshot.docs.map((doc) => {
        'id': doc.id,
        'name': doc.data()['name'] ?? '',
      }).toList();
    });

    // Units
    _firestore.collection('units').orderBy('name').snapshots().listen((snapshot) {
      units.value = snapshot.docs.map((doc) => {
        'id': doc.id,
        'name': doc.data()['name'] ?? '',
      }).toList();
    });
  }

  // Reseller Product Operations
  Future<bool> addResellerProduct(Product product) async {
    try {
      isSubmittingAction.value = true;

      // Get shop name
      final userDoc = await _firestore.collection('users').doc(resellerMobile).get();
      String shopNameVal = '';
      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null) {
          shopNameVal = userData['shopName'] ?? '';
        }
      }

      final Map<String, dynamic> data = product.toFirestore();
      data['shopName'] = shopNameVal.isNotEmpty ? shopNameVal : 'Reseller Shop';
      data['isResellerProduct'] = true;
      data['resellerMobile'] = resellerMobile;
      data['status'] = 'public';

      final customProductId = 'reseller_${resellerMobile}_${DateTime.now().millisecondsSinceEpoch}';
      await _firestore.collection('products').doc(customProductId).set(data);

      Get.snackbar(
        'সফলতা',
        'পণ্যটি সফলভাবে যুক্ত করা হয়েছে',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return true;
    } catch (e) {
      debugPrint('Error adding reseller product: $e');
      Get.snackbar('ত্রুটি', 'পণ্য যুক্ত করা যায়নি: $e');
      return false;
    } finally {
      isSubmittingAction.value = false;
    }
  }

  Future<bool> updateResellerProduct(String productId, Product product) async {
    try {
      isSubmittingAction.value = true;

      final Map<String, dynamic> data = product.toFirestore();
      data['isResellerProduct'] = true;
      data['resellerMobile'] = resellerMobile;

      await _firestore.collection('products').doc(productId).update(data);

      Get.snackbar(
        'সফলতা',
        'পণ্যের তথ্য সফলভাবে আপডেট করা হয়েছে',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return true;
    } catch (e) {
      debugPrint('Error updating reseller product: $e');
      Get.snackbar('ত্রুটি', 'পণ্য আপডেট করা যায়নি: $e');
      return false;
    } finally {
      isSubmittingAction.value = false;
    }
  }

  Future<bool> deleteResellerProduct(String productId) async {
    try {
      isSubmittingAction.value = true;
      await _firestore.collection('products').doc(productId).delete();
      Get.snackbar(
        'সফলতা',
        'পণ্যটি সফলভাবে মুছে ফেলা হয়েছে',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return true;
    } catch (e) {
      debugPrint('Error deleting reseller product: $e');
      Get.snackbar('ত্রুটি', 'পণ্য মুছে ফেলা যায়নি: $e');
      return false;
    } finally {
      isSubmittingAction.value = false;
    }
  }

  Future<bool> toggleResellerProductStatus(String productId, String currentStatus) async {
    try {
      isSubmittingAction.value = true;
      final newStatus = currentStatus == 'public' ? 'draft' : 'public';
      await _firestore.collection('products').doc(productId).update({'status': newStatus});
      Get.snackbar(
        'সফলতা',
        'পণ্যের অবস্হা পরিবর্তন করা হয়েছে',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return true;
    } catch (e) {
      debugPrint('Error toggling reseller product status: $e');
      return false;
    } finally {
      isSubmittingAction.value = false;
    }
  }

  // Submit Withdrawal Request
  Future<bool> requestWithdrawal({
    required String accountName,
    required String accountNumber,
    required String bankName,
    required double amount,
  }) async {
    if (resellerMobile.isEmpty) return false;
    try {
      isSubmittingAction.value = true;

      if (amount > withdrawAvailableAmount) {
        Get.snackbar('ত্রুটি', 'আপনার একাউন্টে পর্যাপ্ত ব্যালেন্স নেই।');
        return false;
      }

      await _firestore.collection('withdrawals').add({
        'resellerMobile': resellerMobile,
        'accountName': accountName,
        'accountNumber': accountNumber,
        'bankName': bankName,
        'amount': amount,
        'status': 'pending', // pending | approved | rejected
        'userRole': 'reseller',
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'সফলতা',
        'উত্তোলন অনুরোধ সফলভাবে পাঠানো হয়েছে',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return true;
    } catch (e) {
      Get.snackbar('ত্রুটি', 'অনুরোধ সম্পন্ন করতে ব্যর্থ হয়েছে: $e');
      return false;
    } finally {
      isSubmittingAction.value = false;
    }
  }

  // Update order statuses
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({'orderStatus': newStatus.name});

      // Send notification to customer
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();
      final customerMobile = orderDoc.data()?['userMobile'] as String?;
      if (customerMobile != null) {
        await NotificationHelper.sendNotification(
          title: 'অর্ডার স্ট্যাটাস আপডেট! 📦',
          body: 'আপনার রিসেলার অর্ডার #${orderId} এর বর্তমান অবস্থা: ${newStatus.name}',
          type: 'status_updated',
          userMobile: customerMobile,
          isAdmin: false,
        );
      }
    } catch (e) {
      debugPrint('Error updating reseller order status: $e');
    }
  }

  Future<void> updatePaymentStatus(String orderId, PaymentStatus newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({'paymentStatus': newStatus.name});
    } catch (e) {
      debugPrint('Error updating reseller payment status: $e');
    }
  }
}
