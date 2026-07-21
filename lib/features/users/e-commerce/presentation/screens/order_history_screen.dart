import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import 'package:trade_wign_bd/features/users/e-commerce/domain/models/order_model.dart';
import 'package:trade_wign_bd/features/users/drive_pack/domain/models/recharge_model.dart';
import 'package:trade_wign_bd/features/users/drive_pack/presentation/screens/mobile_recharge_screens.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/widgets/order_details_bottom_sheet.dart';

class OrderHistoryController extends GetxController {
  final RxList<dynamic> combinedOrders = <dynamic>[].obs;
  final RxBool isLoading = true.obs;

  final RxList<OrderModel> ecommerceOrders = <OrderModel>[].obs;
  final RxList<RechargeModel> rechargeOrders = <RechargeModel>[].obs;

  void initStreams(String userMobile) {
    // 1. Listen to E-commerce Orders
    FirebaseFirestore.instance
        .collection('orders')
        .where('userMobile', isEqualTo: userMobile)
        .snapshots()
        .listen(
          (snapshot) {
            ecommerceOrders.value = snapshot.docs
                .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
                .toList();
            _combineAndSort();
          },
          onError: (e) {
            debugPrint('Error streaming ecommerce orders: $e');
          },
        );

    // 2. Listen to Mobile Recharges & Drive Orders
    FirebaseFirestore.instance
        .collection('mobile_recharges')
        .where('userMobile', isEqualTo: userMobile)
        .snapshots()
        .listen(
          (snapshot) {
            rechargeOrders.value = snapshot.docs
                .map((doc) => RechargeModel.fromFirestore(doc))
                .toList();
            _combineAndSort();
          },
          onError: (e) {
            debugPrint('Error streaming recharge orders: $e');
          },
        );
  }

  void _combineAndSort() {
    final List<dynamic> merged = [];
    merged.addAll(ecommerceOrders);
    merged.addAll(rechargeOrders);

    // Sort descending by date
    merged.sort((a, b) {
      final DateTime aTime = (a is OrderModel)
          ? a.createdAt
          : (a as RechargeModel).createdAt;
      final DateTime bTime = (b is OrderModel)
          ? b.createdAt
          : (b as RechargeModel).createdAt;
      return bTime.compareTo(aTime);
    });

    combinedOrders.value = merged;
    isLoading.value = false;
  }
}

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  void _showRechargeDetailsBottomSheet(
    BuildContext context,
    RechargeModel order,
  ) {
    final formattedDate = DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(order.createdAt);

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'রিচার্জ অর্ডার বিবরণ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            _buildDetailItem('অর্ডার আইডি', order.transactionId),
            _buildDetailItem('তারিখ ও সময়', formattedDate),
            _buildDetailItem('লক্ষ্য নম্বর', order.mobileNumber),
            _buildDetailItem('অপারেটর', order.operatorName),
            _buildDetailItem(
              'অর্ডারের ধরণ',
              order.rechargeType == 'drive' ? 'ড্রাইভ অফার' : 'সাধারণ রিচার্জ',
            ),
            _buildDetailItem(
              'টাকার পরিমাণ',
              '৳${order.amount.toStringAsFixed(0)}',
            ),
            _buildDetailItem(
              'স্ট্যাটাস',
              order.status == 'completed'
                  ? 'সফল (Success)'
                  : order.status == 'failed'
                  ? 'ব্যর্থ (Failed)'
                  : 'পেন্ডিং (Pending)',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: () => Get.back(),
                child: const Text(
                  'বন্ধ করুন',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final mobile = authCtrl.currentUserMobile.value;

    final controller = Get.put(OrderHistoryController());
    controller.initStreams(mobile);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'অর্ডার সমুহ',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey.shade50,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF08B3AC)),
          );
        }

        if (controller.combinedOrders.isEmpty) {
          return const Center(
            child: Text(
              'আপনার অর্ডার সমূহ দেখতে লগইন করুন',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.combinedOrders.length,
          itemBuilder: (context, index) {
            final orderItem = controller.combinedOrders[index];

            if (orderItem is OrderModel) {
              // E-commerce Order Rendering
              final order = orderItem;
              final dateStr = DateFormat(
                'EEEE, dd MMM yyyy  •  HH:mm',
              ).format(order.createdAt);
              final productNames = order.items
                  .map((i) => '${i['quantity']}x ${i['productName']}')
                  .join(', ');

              int totalItems = 0;
              for (var item in order.items) {
                totalItems += (item['quantity'] as int? ?? 1);
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildEcommerceStatusBadge(order.orderStatus),
                        GestureDetector(
                          onTap: () {
                            showOrderDetailsBottomSheet(context, order);
                          },
                          child: Row(
                            children: const [
                              Text(
                                'See Details',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(
                                Icons.chevron_right,
                                size: 16,
                                color: Colors.black87,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Trade Wign BD',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      productNames,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '$totalItems Item  •  ',
                                style: const TextStyle(color: Colors.black87),
                              ),
                              TextSpan(
                                text:
                                    '৳${order.totalAmount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            Get.snackbar(
                              'Coming Soon',
                              'Re-order feature is coming soon!',
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.9,
                              ),
                              colorText: Colors.black87,
                              borderColor: const Color(
                                0xFF08B3AC,
                              ).withValues(alpha: 0.2),
                              borderWidth: 1,
                              snackPosition: SnackPosition.BOTTOM,
                              margin: const EdgeInsets.all(16),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            side: const BorderSide(color: Color(0xFFC49A6C)),
                          ),
                          child: const Text(
                            'Re-Order',
                            style: TextStyle(
                              color: Color(0xFFC49A6C),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            } else {
              // Recharge & Drive Order Rendering
              final order = orderItem as RechargeModel;
              final dateStr = DateFormat(
                'EEEE, dd MMM yyyy  •  HH:mm',
              ).format(order.createdAt);
              final String detailStr =
                  '${order.rechargeType == 'drive' ? 'ড্রাইভ অফার' : 'সাধারণ রিচার্জ'} - ${order.operatorName} (${order.mobileNumber})';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildRechargeStatusBadge(order.status),
                        GestureDetector(
                          onTap: () {
                            _showRechargeDetailsBottomSheet(context, order);
                          },
                          child: Row(
                            children: const [
                              Text(
                                'See Details',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(
                                Icons.chevron_right,
                                size: 16,
                                color: Colors.black87,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      order.rechargeType == 'drive'
                          ? 'ড্রাইভ প্যাকেজ রিচার্জ'
                          : 'মোবাইল রিচার্জ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      detailStr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13.5,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: '1 Item  •  ',
                                style: TextStyle(color: Colors.black87),
                              ),
                              TextSpan(
                                text: '৳${order.amount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            Get.to(() => const MobileRechargeScreen());
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            side: const BorderSide(color: Color(0xFFC49A6C)),
                          ),
                          child: const Text(
                            'Recharge Again',
                            style: TextStyle(
                              color: Color(0xFFC49A6C),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
          },
        );
      }),
    );
  }

  Widget _buildEcommerceStatusBadge(OrderStatus status) {
    Color color;
    String text;

    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange.shade700;
        text = 'Pending';
        break;
      case OrderStatus.processing:
        color = Colors.blue.shade700;
        text = 'Processing';
        break;
      case OrderStatus.shipped:
        color = Colors.purple.shade700;
        text = 'Shipped';
        break;
      case OrderStatus.delivered:
        color = const Color(0xFF1E8A37);
        text = 'Success';
        break;
      case OrderStatus.cancelled:
        color = Colors.red.shade700;
        text = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildRechargeStatusBadge(String status) {
    Color color;
    String text;

    switch (status) {
      case 'completed':
        color = const Color(0xFF1E8A37);
        text = 'Success';
        break;
      case 'failed':
        color = Colors.red.shade700;
        text = 'Failed';
        break;
      case 'pending':
      default:
        color = Colors.orange.shade700;
        text = 'Pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
