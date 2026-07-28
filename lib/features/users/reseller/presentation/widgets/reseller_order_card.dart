import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trade_wign_bd/features/users/e-commerce/domain/models/order_model.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/widgets/order_details_bottom_sheet.dart';

class ResellerOrderCard extends StatelessWidget {
  final OrderModel order;
  final double resellerEarnings;

  const ResellerOrderCard({
    super.key,
    required this.order,
    required this.resellerEarnings,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusBangla;

    switch (order.orderStatus) {
      case OrderStatus.delivered:
        statusColor = const Color(0xFF10B981);
        statusBangla = 'সম্পন্ন';
        break;
      case OrderStatus.processing:
      case OrderStatus.shipped:
        statusColor = const Color(0xFF3B82F6);
        statusBangla = 'প্রসেসিং';
        break;
      case OrderStatus.cancelled:
        statusColor = const Color(0xFFEF4444);
        statusBangla = 'বাতিল';
        break;
      case OrderStatus.pending:
      default:
        statusColor = const Color(0xFFF59E0B);
        statusBangla = 'পেন্ডিং';
        break;
    }

    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt);

    return InkWell(
      onTap: () => showOrderDetailsBottomSheet(context, order),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.01),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderId,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusBangla,
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'গ্রাহক: ${order.userName}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
            ),
            Text(
              'মোবাইল: ${order.userMobile}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              'তারিখ: $dateStr',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const Divider(height: 20),
            // Items
            ...order.items.map((item) {
              final name = item['productName'] ?? '';
              final qty = item['quantity'] ?? 1;
              final price = (item['price'] as num?)?.toDouble() ?? 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '$name x $qty',
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                    Text(
                      '৳${(price * qty).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('মোট সংগ্রহ মূল্য', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text(
                      '৳${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.black87),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('আপনার অর্জিত লাভ (কমিশন বাদে)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text(
                      '৳${resellerEarnings.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: order.orderStatus == OrderStatus.delivered
                            ? const Color(0xFF059669)
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
