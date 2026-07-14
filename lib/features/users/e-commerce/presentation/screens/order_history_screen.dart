import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import 'package:trade_wign_bd/features/users/e-commerce/domain/models/order_model.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/widgets/order_details_bottom_sheet.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final mobile = authCtrl.currentUserMobile.value;

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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userMobile', isEqualTo: mobile)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('একটি সমস্যা হয়েছে: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'আপনার কোনো অর্ডার পাওয়া যায়নি।',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          // Sort locally by createdAt descending to avoid Firestore composite index requirement
          docs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTime =
                (aData['createdAt'] as Timestamp?)?.toDate() ??
                DateTime.fromMillisecondsSinceEpoch(0);
            final bTime =
                (bData['createdAt'] as Timestamp?)?.toDate() ??
                DateTime.fromMillisecondsSinceEpoch(0);
            return bTime.compareTo(aTime);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final order = OrderModel.fromMap(data, doc.id);

              // Date Formatting (e.g. Monday, 23 Apr 2024  •  15:44)
              final dateStr = DateFormat(
                'EEEE, dd MMM yyyy  •  HH:mm',
              ).format(order.createdAt);

              // Product List formatting
              final productNames = order.items
                  .map((i) => '${i['quantity']}x ${i['productName']}')
                  .join(', ');

              // Total items count
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
                    // Top Row: Status Badge & See Details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatusBadge(order.orderStatus),
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

                    // Order Title
                    const Text(
                      'Trade Wign BD',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Date & Time
                    Text(
                      dateStr,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Product List
                    Text(
                      productNames,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Divider
                    const Divider(height: 1),
                    const SizedBox(height: 14),

                    // Bottom Row: Total Items, Price & Re-Order
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
                            // TODO: Add items back to cart
                            Get.snackbar(
  'Coming Soon',
  'Re-order feature is coming soon!',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
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
                            side: const BorderSide(
                              color: Color(0xFFC49A6C),
                            ), // A brownish/copper color matching the image
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
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color;
    String text;

    // Customize colors to match the "Success" green badge in the image
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
        color = const Color(0xFF1E8A37); // Dark green matching the image
        text =
            'Success'; // Changing 'Delivered' to 'Success' to match the image UI
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
}
