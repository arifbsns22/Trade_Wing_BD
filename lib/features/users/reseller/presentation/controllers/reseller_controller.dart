import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import 'package:trade_wign_bd/features/admin/ecommerce/domain/models/product_model.dart';
import 'package:trade_wign_bd/features/users/e-commerce/domain/models/order_model.dart';

class ResellerController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  // Reactive states
  final RxList<Product> productsAvailable = <Product>[].obs;
  final RxList<Map<String, dynamic>> basketItems = <Map<String, dynamic>>[].obs;
  final RxList<OrderModel> resellerOrders = <OrderModel>[].obs;
  final RxList<Map<String, dynamic>> withdrawals = <Map<String, dynamic>>[].obs;
  
  final RxBool isLoadingProducts = false.obs;
  final RxBool isLoadingBasket = false.obs;
  final RxBool isLoadingOrders = false.obs;
  final RxBool isLoadingWithdrawals = false.obs;
  final RxBool isSubmittingAction = false.obs;

  String get resellerMobile => _authController.currentUserMobile.value.trim();

  // Dashboard Stats (Calculated reactive variables)
  RxInt get availableProductsCount => productsAvailable.length.obs;
  RxInt get basketCount => basketItems.length.obs;
  
  RxInt get pendingOrdersCount => 
      resellerOrders.where((o) => o.orderStatus == OrderStatus.pending).length.obs;
      
  RxInt get completedOrdersCount => 
      resellerOrders.where((o) => o.orderStatus == OrderStatus.delivered).length.obs;

  RxDouble get totalProfit => () {
    double profit = 0.0;
    for (var doc in resellerOrders) {
      if (doc.orderStatus == OrderStatus.delivered) {
        // We will fetch the resellerProfit directly from order metadata if it exists
        // Since OrderModel fromMap doesn't parse resellerProfit, we will query it dynamically below
      }
    }
    return profit;
  }().obs;

  // Let's store raw profit calculation separately by parsing the snapshots
  final RxDouble reactiveTotalProfit = 0.0.obs;
  final RxDouble reactiveTotalWithdrawn = 0.0.obs;
  
  RxDouble get withdrawAvailableAmount => 
      (reactiveTotalProfit.value - reactiveTotalWithdrawn.value).clamp(0.0, 9999999.0).obs;

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
    listenToAvailableProducts();
    listenToBasket();
    listenToOrders();
    listenToWithdrawals();
  }

  // 1. Stream Admin Products with Vendor pricing
  void listenToAvailableProducts() {
    isLoadingProducts.value = true;
    _firestore
        .collection('products')
        .where('status', isEqualTo: 'public')
        .snapshots()
        .listen((snapshot) {
      final List<Product> list = [];
      for (var doc in snapshot.docs) {
        final product = Product.fromFirestore(doc);
        // Only include products with a valid vendor price > 0
        final vendorPrice = product.rolePrices['Vendor'];
        if (vendorPrice != null && vendorPrice > 0) {
          list.add(product);
        }
      }
      productsAvailable.value = list;
      isLoadingProducts.value = false;
    }, onError: (e) {
      debugPrint('Error loading vendor products: $e');
      isLoadingProducts.value = false;
    });
  }

  // 2. Stream Vendor Basket items
  void listenToBasket() {
    if (resellerMobile.isEmpty) return;
    isLoadingBasket.value = true;
    _firestore
        .collection('users')
        .doc(resellerMobile)
        .collection('vendor_basket')
        .snapshots()
        .listen((snapshot) {
      basketItems.value = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      isLoadingBasket.value = false;
    }, onError: (e) {
      debugPrint('Error loading basket items: $e');
      isLoadingBasket.value = false;
    });
  }

  // 3. Stream Vendor Orders & Calculate Profit in real-time
  void listenToOrders() {
    if (resellerMobile.isEmpty) return;
    isLoadingOrders.value = true;
    _firestore
        .collection('orders')
        .where('vendorMobile', isEqualTo: resellerMobile)
        .snapshots()
        .listen((snapshot) {
      resellerOrders.value = snapshot.docs.map((doc) {
        return OrderModel.fromMap(doc.data(), doc.id);
      }).toList();

      // Calculate profit dynamically from order snapshots
      double profitSum = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final status = data['orderStatus'] as String?;
        if (status == 'delivered') {
          final profit = (data['vendorProfit'] as num?)?.toDouble() ?? 0.0;
          profitSum += profit;
        }
      }
      reactiveTotalProfit.value = profitSum;
      isLoadingOrders.value = false;
    }, onError: (e) {
      debugPrint('Error loading vendor orders: $e');
      isLoadingOrders.value = false;
    });
  }

  // 4. Stream Withdrawals
  void listenToWithdrawals() {
    if (resellerMobile.isEmpty) return;
    isLoadingWithdrawals.value = true;
    _firestore
        .collection('withdrawals')
        .where('vendorMobile', isEqualTo: resellerMobile)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      withdrawals.value = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // Calculate total approved withdrawals
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

  // Helper to publish vendor product globally
  Future<void> _publishToGlobalProducts(String productId, double customPrice) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (!doc.exists) return;
      final originalProduct = Product.fromFirestore(doc);
      
      final vendorPrice = originalProduct.rolePrices['Vendor'] ?? 0.0;
      final customProductId = 'vendor_${resellerMobile}_$productId';

      // Get vendor's shop name
      final userDoc = await _firestore.collection('users').doc(resellerMobile).get();
      String shopNameVal = '';
      if (userDoc.exists && userDoc.data() != null) {
        shopNameVal = (userDoc.data()!['shopName'] as String?) ?? '';
      }
      
      await _firestore.collection('products').doc(customProductId).set({
        'name': originalProduct.name,
        'type': originalProduct.type,
        'brand': originalProduct.brand,
        'category': originalProduct.category,
        'image': originalProduct.image,
        'description': originalProduct.description,
        'stock': originalProduct.stock,
        'regularPrice': customPrice,
        'discount': 0.0,
        'discountType': 'fixed',
        'vat': originalProduct.vat,
        'extraExpenses': originalProduct.extraExpenses,
        'unit': originalProduct.unit,
        'sizes': originalProduct.sizes,
        'variants': originalProduct.variants,
        'status': 'public',
        'rolePrices': {
          'Customer': customPrice,
        },
        'roleRewards': originalProduct.roleRewards,
        'createdAt': FieldValue.serverTimestamp(),
        'shopName': shopNameVal.isNotEmpty ? shopNameVal : 'Trade Wing BD',
        
        // Metadata fields
        'isVendorProduct': true,
        'vendorMobile': resellerMobile,
        'originalProductId': productId,
        'vendorPrice': vendorPrice,
      });
      debugPrint('Published vendor product globally: $customProductId');
    } catch (e) {
      debugPrint('Error publishing vendor product: $e');
    }
  }

  // Helper to unpublish vendor product globally
  Future<void> _unpublishFromGlobalProducts(String productId) async {
    try {
      final customProductId = 'vendor_${resellerMobile}_$productId';
      await _firestore.collection('products').doc(customProductId).delete();
      debugPrint('Unpublished vendor product globally: $customProductId');
    } catch (e) {
      debugPrint('Error unpublishing vendor product: $e');
    }
  }

  // Basket Actions
  Future<void> addToBasket(Product product) async {
    if (resellerMobile.isEmpty) return;
    try {
      isSubmittingAction.value = true;
      final vendorPrice = product.rolePrices['Vendor'] ?? 0.0;
      final adminSellingPrice = product.rolePrices['Customer'] ?? product.regularPrice;

      await _firestore
          .collection('users')
          .doc(resellerMobile)
          .collection('vendor_basket')
          .doc(product.id)
          .set({
        'productId': product.id,
        'name': product.name,
        'image': product.image,
        'vendorPrice': vendorPrice,
        'adminSellingPrice': adminSellingPrice,
        'mySellingPrice': adminSellingPrice, // Initial custom price is admin final price
        'addedAt': FieldValue.serverTimestamp(),
      });

      // Publish to global products at the default price
      await _publishToGlobalProducts(product.id!, adminSellingPrice);

      Get.snackbar(
        'সফলতা',
        'পণ্যটি আপনার বাসকেটে যোগ করা হয়েছে',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar('ত্রুটি', 'বাসকেটে যোগ করতে ব্যর্থ হয়েছে: $e');
    } finally {
      isSubmittingAction.value = false;
    }
  }

  Future<void> removeFromBasket(String productId) async {
    if (resellerMobile.isEmpty) return;
    try {
      isSubmittingAction.value = true;
      await _firestore
          .collection('users')
          .doc(resellerMobile)
          .collection('vendor_basket')
          .doc(productId)
          .delete();

      // Unpublish from global products
      await _unpublishFromGlobalProducts(productId);

      Get.snackbar(
        'সফলতা',
        'পণ্যটি বাসকেট থেকে সরানো হয়েছে',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar('ত্রুটি', 'পণ্য সরাতে ব্যর্থ হয়েছে: $e');
    } finally {
      isSubmittingAction.value = false;
    }
  }

  Future<void> updateCustomPrice(String productId, double customPrice) async {
    if (resellerMobile.isEmpty) return;
    try {
      isSubmittingAction.value = true;

      // Get the wholesale vendor price to validate
      final basketDoc = await _firestore
          .collection('users')
          .doc(resellerMobile)
          .collection('vendor_basket')
          .doc(productId)
          .get();
      
      double vendorPrice = 0.0;
      if (basketDoc.exists) {
        vendorPrice = (basketDoc.data()?['vendorPrice'] as num?)?.toDouble() ?? 0.0;
      }
      
      if (customPrice <= vendorPrice) {
        Get.snackbar(
          'ত্রুটি',
          'বিক্রয় মূল্য ভেন্ডর কেনা মূল্য (৳${vendorPrice.toStringAsFixed(2)}) এর চেয়ে বেশি হতে হবে।',
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          colorText: Colors.redAccent,
          borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
          borderWidth: 1,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return;
      }

      await _firestore
          .collection('users')
          .doc(resellerMobile)
          .collection('vendor_basket')
          .doc(productId)
          .update({
        'mySellingPrice': customPrice,
      });

      // Update in global products
      await _publishToGlobalProducts(productId, customPrice);

      Get.snackbar(
        'সফলতা',
        'বিক্রয় মূল্য আপডেট করা হয়েছে',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar('ত্রুটি', 'বিক্রয় মূল্য আপডেট করতে ব্যর্থ হয়েছে: $e');
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
    if (amount > withdrawAvailableAmount.value) {
      Get.snackbar(
        'ত্রুটি',
        'পর্যাপ্ত ব্যালেন্স নেই। সর্বোচ্চ উত্তোলনযোগ্য: ৳${withdrawAvailableAmount.value.toStringAsFixed(2)}',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.redAccent,
        borderColor: Colors.redAccent.withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    try {
      isSubmittingAction.value = true;
      await _firestore.collection('withdrawals').add({
        'vendorMobile': resellerMobile,
        'vendorName': _authController.currentUserName.value,
        'accountName': accountName,
        'accountNumber': accountNumber,
        'bankName': bankName,
        'amount': amount,
        'status': 'pending', // 'pending' | 'approved' | 'rejected'
        'userRole': _authController.currentUserRole.value.toLowerCase().trim(),
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
      Get.snackbar('ত্রুটি', 'অনুরোধ পাঠাতে ব্যর্থ হয়েছে: $e');
      return false;
    } finally {
      isSubmittingAction.value = false;
    }
  }

  // Place Vendor Order
  Future<bool> placeVendorOrder({
    required String customerName,
    required String customerPhone,
    required String customerAddress,
    required String paymentMethod,
    String? trxId,
    String? senderPhone,
    required Map<String, dynamic> basketItem,
    required int quantity,
  }) async {
    if (resellerMobile.isEmpty) return false;
    try {
      isSubmittingAction.value = true;

      final String productId = basketItem['productId'];
      final double mySellingPrice = (basketItem['mySellingPrice'] as num).toDouble();
      final double vendorPrice = (basketItem['vendorPrice'] as num).toDouble();
      final double profitPerUnit = mySellingPrice - vendorPrice;
      final double totalOrderAmount = mySellingPrice * quantity;
      final double totalVendorProfit = profitPerUnit * quantity;

      // 1. Validate Product Stock from db
      final productDoc = await _firestore.collection('products').doc(productId).get();
      if (!productDoc.exists) {
        Get.snackbar('ত্রুটি', 'পণ্যটি খুঁজে পাওয়া যায়নি');
        return false;
      }
      final productData = Product.fromFirestore(productDoc);
      if (productData.stock < quantity) {
        Get.snackbar('ত্রুটি', 'পর্যাপ্ত স্টক নেই। উপলব্ধ স্টক: ${productData.stock}');
        return false;
      }

      // 2. Prepare order doc
      final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
      
      final orderItems = [
        {
          'productId': productId,
          'productName': basketItem['name'],
          'quantity': quantity,
          'price': mySellingPrice,
          'image': basketItem['image'],
          'unit': productData.unit,
        }
      ];

      final Map<String, dynamic> orderData = {
        'orderId': orderId,
        'userMobile': customerPhone,
        'userName': customerName,
        'address': customerAddress,
        'items': orderItems,
        'totalAmount': totalOrderAmount,
        'rewardPointsEarned': 0,
        'paymentMethod': paymentMethod,
        'offlineGateway': paymentMethod == 'offline' ? 'Bkash/Nagad' : null,
        'offlineTrxId': trxId,
        'offlineSenderMobile': senderPhone,
        'orderStatus': 'pending',
        'paymentStatus': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        
        // Vendor exclusive fields
        'vendorMobile': resellerMobile,
        'vendorProfit': totalVendorProfit,
        'vendorPurchasePrice': vendorPrice * quantity,
        'isVendorOrder': true,
      };

      final batch = _firestore.batch();
      
      // Save order
      final orderRef = _firestore.collection('orders').doc(orderId);
      batch.set(orderRef, orderData);

      // Decrement stock
      final productRef = _firestore.collection('products').doc(productId);
      batch.update(productRef, {
        'stock': FieldValue.increment(-quantity),
      });

      await batch.commit();

      Get.snackbar(
        'সফলতা',
        'অর্ডারটি সফলভাবে সম্পন্ন হয়েছে। অর্ডার আইডি: $orderId',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );

      return true;
    } catch (e) {
      Get.snackbar('ত্রুটি', 'অর্ডার করতে ব্যর্থ হয়েছে: $e');
      return false;
    } finally {
      isSubmittingAction.value = false;
    }
  }
}
