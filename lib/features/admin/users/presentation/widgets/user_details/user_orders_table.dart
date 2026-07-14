import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:intl/intl.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class UserOrdersTable extends StatefulWidget {
  final List<Map<String, dynamic>> orders;

  const UserOrdersTable({super.key, required this.orders});

  @override
  State<UserOrdersTable> createState() => _UserOrdersTableState();
}

class _UserOrdersTableState extends State<UserOrdersTable> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.orders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'No order history found for this user.',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                const Text(
                  'Order Activities',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.orders.length} Total',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          LayoutBuilder(
            builder: (context, constraints) {
              return ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad,
                  },
                ),
                child: Scrollbar(
                  controller: _scrollController,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: constraints.maxWidth < 700
                          ? 700
                          : constraints.maxWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header Row
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            color: Colors.grey.shade50,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: _headerText('Order ID & Date'),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: _headerText('Order Status'),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: _headerText('Payment'),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: _headerText(
                                    'Amount',
                                    alignRight: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          // Order Rows
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: widget.orders.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final order = widget.orders[index];
                              final String orderId =
                                  order['orderId'] ?? order['id'] ?? 'N/A';

                              DateTime date = DateTime.now();
                              if (order['createdAt'] != null &&
                                  order['createdAt'] is Timestamp) {
                                date = (order['createdAt'] as Timestamp)
                                    .toDate();
                              }
                              final String dateStr = DateFormat(
                                'MMM dd, yyyy HH:mm',
                              ).format(date);

                              final String orderStatus =
                                  order['orderStatus'] ?? 'pending';
                              final String paymentStatus =
                                  order['paymentStatus'] ?? 'pending';
                              final double amount =
                                  (order['totalAmount'] ?? 0.0).toDouble();

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.receipt_long_outlined,
                                                size: 16,
                                                color: Colors.grey.shade600,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  '#$orderId',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 24.0,
                                            ),
                                            child: Text(
                                              dateStr,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: _buildStatusBadge(
                                        orderStatus,
                                        isPayment: false,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: _buildStatusBadge(
                                        paymentStatus,
                                        isPayment: true,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '৳${amount.toStringAsFixed(0)}',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: AppColors.green,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _headerText(String text, {bool alignRight = false}) {
    return Text(
      text,
      textAlign: alignRight ? TextAlign.right : TextAlign.left,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget _buildStatusBadge(String status, {required bool isPayment}) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String displayStatus = status.capitalizeFirst ?? status;

    if (status == 'pending') {
      bgColor = Colors.orange.withValues(alpha: 0.15);
      textColor = Colors.orange.shade800;
      icon = Icons.pending_actions;
    } else if (status == 'delivered' ||
        status == 'verified' ||
        status == 'shipped') {
      bgColor = AppColors.green.withValues(alpha: 0.15);
      textColor = AppColors.green;
      icon = Icons.check_circle_outline;
    } else if (status == 'cancelled' || status == 'failed') {
      bgColor = Colors.red.withValues(alpha: 0.15);
      textColor = Colors.red.shade800;
      icon = Icons.cancel_outlined;
    } else {
      bgColor = Colors.blue.withValues(alpha: 0.15);
      textColor = Colors.blue.shade800;
      icon = Icons.info_outline;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
            Text(
              displayStatus,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
