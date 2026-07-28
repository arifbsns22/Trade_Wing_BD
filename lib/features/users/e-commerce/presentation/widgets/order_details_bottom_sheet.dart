import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import 'package:trade_wign_bd/features/users/e-commerce/domain/models/order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import 'package:trade_wign_bd/common/services/notification_helper.dart';

void showOrderDetailsBottomSheet(BuildContext context, OrderModel order) {
  Get.bottomSheet(
    OrderDetailsSheet(order: order),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class OrderDetailsSheet extends StatefulWidget {
  final OrderModel order;
  const OrderDetailsSheet({super.key, required this.order});

  @override
  State<OrderDetailsSheet> createState() => _OrderDetailsSheetState();
}

class _OrderDetailsSheetState extends State<OrderDetailsSheet> {
  late OrderStatus currentOrderStatus;
  late PaymentStatus currentPaymentStatus;
  bool isUpdating = false;
  late bool isAdmin;

  @override
  void initState() {
    super.initState();
    currentOrderStatus = widget.order.orderStatus;
    currentPaymentStatus = widget.order.paymentStatus;
    final auth = Get.find<AuthController>();
    final role = auth.currentUserRole.value.toLowerCase().trim();
    final mobile = auth.currentUserMobile.value.trim();
    final isReseller = role == 'reseller';
    final isOrderOwner = widget.order.isResellerOrder == true && widget.order.resellerMobile == mobile;
    isAdmin = role == 'super admin' || role == 'admin' || (isReseller && isOrderOwner);
  }

  Future<void> _updateOrderStatus(OrderStatus newStatus) async {
    setState(() => isUpdating = true);
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.order.orderId)
          .update({'orderStatus': newStatus.name});

      // Send real-time notification to User
      await NotificationHelper.sendNotification(
        title: 'অর্ডার স্ট্যাটাস আপডেট! 📦',
        body: 'আপনার অর্ডার #${widget.order.orderId} এর বর্তমান অবস্থা: ${newStatus.name}',
        type: 'status_updated',
        userMobile: widget.order.userMobile,
        isAdmin: false,
      );

      setState(() {
        currentOrderStatus = newStatus;
      });
      Get.snackbar(
  'Success',
  'Order status updated to ${newStatus.name}',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
    } catch (e) {
      Get.snackbar(
  'Error',
  'Failed to update order status',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
    } finally {
      setState(() => isUpdating = false);
    }
  }

  Future<void> _updatePaymentStatus(PaymentStatus newStatus) async {
    setState(() => isUpdating = true);
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.order.orderId)
          .update({'paymentStatus': newStatus.name});
      setState(() {
        currentPaymentStatus = newStatus;
      });
      Get.snackbar(
  'Success',
  'Payment status updated to ${newStatus.name}',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
    } catch (e) {
      Get.snackbar(
  'Error',
  'Failed to update payment status',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
    } finally {
      setState(() => isUpdating = false);
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return Stack(
      children: [
        Container(
      constraints: BoxConstraints(
        maxHeight: Get.height * 0.9,
      ), // flexible height
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // allow it to be compact
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Order Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black87,
                      size: 16,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildHeaderCard(),
                  const SizedBox(height: 16),

                  if (isAdmin) ...[
                    _sectionTitle('Admin Actions', Icons.admin_panel_settings_outlined),
                    const SizedBox(height: 10),
                    _buildAdminActionsCard(),
                    const SizedBox(height: 16),
                  ],

                  _sectionTitle('Items Ordered', Icons.shopping_bag_outlined),
                  const SizedBox(height: 10),
                  _buildProductsList(),
                  const SizedBox(height: 16),

                  _sectionTitle('Order Status', Icons.local_shipping_outlined),
                  const SizedBox(height: 10),
                  _buildTimelineCard(),
                  const SizedBox(height: 16),

                  _sectionTitle(
                    'Payment & Summary',
                    Icons.receipt_long_outlined,
                  ),
                  const SizedBox(height: 10),
                  _buildFinanceSummary(),
                  const SizedBox(height: 16),

                  _sectionTitle('Delivery Details', Icons.location_on_outlined),
                  const SizedBox(height: 10),
                  _buildShippingDetails(),
                  const SizedBox(height: 32), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    ),
        if (isUpdating)
          Positioned.fill(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
          ),
      ],
    );
  }

  Widget _sectionTitle(String title, IconData icon, {Widget? trailing}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryColor),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ORDER ID',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.order.orderId,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
          Container(width: 1, height: 32, color: Colors.grey.shade200),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'PLACED ON',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('dd MMM yyyy').format(widget.order.createdAt),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    return Column(
      children: widget.order.items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // 1:1 ratio image with soft background
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      item['image'] != null &&
                          item['image'].toString().isNotEmpty
                      ? Image.network(
                          item['image'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderImage(),
                        )
                      : _buildPlaceholderImage(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['productName'] ?? 'Unknown Product',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Qty: ${item['quantity']}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '৳${((item['price'] as num?) ?? 0) * ((item['quantity'] as num?) ?? 1)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 50,
      height: 50,
      color: Colors.grey.shade100,
      child: const Icon(Icons.image_outlined, color: Colors.grey, size: 20),
    );
  }

  Widget _buildAdminActionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Status',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              DropdownButton<OrderStatus>(
                value: currentOrderStatus,
                isDense: true,
                underline: const SizedBox(),
                icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (newStatus) {
                  if (newStatus != null) {
                    _updateOrderStatus(newStatus);
                  }
                },
                items: OrderStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(_getStatusText(status)),
                  );
                }).toList(),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Status',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              DropdownButton<PaymentStatus>(
                value: currentPaymentStatus,
                isDense: true,
                underline: const SizedBox(),
                icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                style: TextStyle(
                  fontSize: 13,
                  color: currentPaymentStatus == PaymentStatus.verified
                      ? AppColors.green
                      : (currentPaymentStatus == PaymentStatus.failed
                          ? Colors.red
                          : Colors.orange),
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (newStatus) {
                  if (newStatus != null) {
                    _updatePaymentStatus(newStatus);
                  }
                },
                items: PaymentStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.name.toUpperCase()),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildTimelineCard() {
    final List<String> steps = [
      'Pending',
      'Processing',
      'Shipped',
      'Delivered',
    ];

    int currentIndex = 0;
    bool isCancelled = currentOrderStatus == OrderStatus.cancelled;

    if (isCancelled) {
      steps.clear();
      steps.addAll(['Pending', 'Cancelled']);
      currentIndex = 1;
    } else {
      switch (currentOrderStatus) {
        case OrderStatus.pending:
          currentIndex = 0;
          break;
        case OrderStatus.processing:
          currentIndex = 1;
          break;
        case OrderStatus.shipped:
          currentIndex = 2;
          break;
        case OrderStatus.delivered:
          currentIndex = 3;
          break;
        case OrderStatus.cancelled:
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FixedTimeline.tileBuilder(
        theme: TimelineThemeData(
          nodePosition: 0,
          color: Colors.grey.shade200,
          indicatorTheme: const IndicatorThemeData(position: 0, size: 20.0),
          connectorTheme: const ConnectorThemeData(thickness: 2.5),
        ),
        builder: TimelineTileBuilder.connected(
          connectionDirection: ConnectionDirection.before,
          itemCount: steps.length,
          contentsBuilder: (context, index) {
            final isCompleted = index <= currentIndex;
            final isCurrent = index == currentIndex;

            Color textColor = Colors.grey.shade400;
            if (isCompleted) {
              if (isCancelled && index == 1)
                textColor = Colors.red;
              else
                textColor = AppColors.primaryColor;
            }
            if (isCurrent && !isCompleted && !isCancelled)
              textColor = Colors.amber.shade700;

            return Padding(
              padding: const EdgeInsets.only(
                left: 12.0,
                bottom: 24.0,
                top: 0.0,
              ),
              child: Text(
                steps[index],
                style: TextStyle(
                  fontWeight: isCompleted || isCurrent
                      ? FontWeight.bold
                      : FontWeight.w600,
                  color: textColor,
                  fontSize: 13,
                ),
              ),
            );
          },
          indicatorBuilder: (context, index) {
            final isCompleted = index <= currentIndex;
            if (isCompleted) {
              if (isCancelled && index == 1) {
                return const DotIndicator(
                  color: Colors.red,
                  child: Icon(Icons.close, color: Colors.white, size: 12),
                );
              }
              return DotIndicator(
                color: AppColors.primaryColor,
                child: const Icon(Icons.check, color: Colors.white, size: 12),
              );
            }
            return DotIndicator(
              color: Colors.grey.shade100,
              border: Border.all(color: Colors.grey.shade300, width: 2),
            );
          },
          connectorBuilder: (context, index, type) {
            if (index > 0) {
              if (index <= currentIndex) {
                return SolidLineConnector(color: AppColors.primaryColor);
              } else {
                return SolidLineConnector(color: Colors.grey.shade200);
              }
            } else {
              return null;
            }
          },
        ),
      ),
    );
  }

  Widget _buildFinanceSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _summaryRow('Payment Method', widget.order.paymentMethod.toUpperCase()),
          const SizedBox(height: 12),
                    Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Status',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (currentPaymentStatus == PaymentStatus.verified
                          ? AppColors.green
                          : (currentPaymentStatus == PaymentStatus.failed
                              ? Colors.red
                              : Colors.orange))
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  currentPaymentStatus.name.toUpperCase(),
                  style: TextStyle(
                    color: currentPaymentStatus == PaymentStatus.verified
                        ? AppColors.green
                        : (currentPaymentStatus == PaymentStatus.failed
                            ? Colors.red
                            : Colors.orange),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          _summaryRow(
            'Reward Points',
            '+${widget.order.rewardPointsEarned}',
            valueColor: Colors.amber.shade700,
            isBadge: true,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: Color(0xFFEEEEEE), thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              Text(
                '৳${widget.order.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: AppColors.secondaryColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String title,
    String value, {
    Color? valueColor,
    bool isBadge = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        if (isBadge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (valueColor ?? Colors.black87).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          )
        else
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
      ],
    );
  }

  Widget _buildShippingDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shippingInfoRow(Icons.person_rounded, widget.order.userName),
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Divider(height: 20, color: Color(0xFFF0F0F0)),
          ),
          _shippingInfoRow(Icons.phone_rounded, widget.order.userMobile),
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Divider(height: 20, color: Color(0xFFF0F0F0)),
          ),
          _shippingInfoRow(
            Icons.location_on_rounded,
            widget.order.address,
            isAddress: true,
          ),
        ],
      ),
    );
  }

  Widget _shippingInfoRow(
    IconData icon,
    String text, {
    bool isAddress = false,
  }) {
    return Row(
      crossAxisAlignment: isAddress
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: AppColors.primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: isAddress ? 6 : 0),
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.black87,
                height: isAddress ? 1.4 : 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
