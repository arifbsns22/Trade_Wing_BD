import 'package:cloud_firestore/cloud_firestore.dart';
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
        Get.snackbar('Error', 'Failed to fetch orders: $error');
        isLoading.value = false;
      },
    );
  }
}
