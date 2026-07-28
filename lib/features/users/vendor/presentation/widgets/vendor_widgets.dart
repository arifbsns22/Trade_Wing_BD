import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trade_wign_bd/features/admin/ecommerce/domain/models/product_model.dart';
import 'package:trade_wign_bd/features/users/e-commerce/domain/models/order_model.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

// 1. Stat Card
class VendorStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color themeColor;

  const VendorStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: 0.9 + (animValue * 0.1),
          child: Opacity(
            opacity: animValue,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: themeColor.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Top Row: Title & Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: themeColor.withValues(alpha: 0.9),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: themeColor,
                    size: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Middle: Large Value
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Bottom: Subtitle
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: themeColor.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// 2. Market Product Card
class MarketProductCard extends StatelessWidget {
  final Product product;
  final bool isAdded;
  final VoidCallback onAddTap;
  final VoidCallback onRemoveTap;

  const MarketProductCard({
    super.key,
    required this.product,
    required this.isAdded,
    required this.onAddTap,
    required this.onRemoveTap,
  });

  @override
  Widget build(BuildContext context) {
    final double vendorPrice = product.rolePrices['Vendor'] ?? 0.0;
    final double adminSellingPrice = product.rolePrices['Customer'] ?? product.regularPrice;
    final double profitMargin = adminSellingPrice - vendorPrice;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 80,
              height: 80,
              child: product.image.isNotEmpty
                  ? (product.image.startsWith('http')
                      ? Image.network(product.image, fit: BoxFit.cover)
                      : Image.asset(product.image, fit: BoxFit.cover))
                  : Container(
                      color: const Color(0xFFF1F5F9),
                      child: const Icon(Icons.image_outlined, color: Colors.grey),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  product.category,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _buildBadge('কেনা: ৳${vendorPrice.toStringAsFixed(0)}', const Color(0xFFF1F5F9), Colors.black87),
                    _buildBadge('বিক্রয়: ৳${adminSellingPrice.toStringAsFixed(0)}', const Color(0xFFEFF6FF), const Color(0xFF2563EB)),
                    _buildBadge('লাভ: ৳${profitMargin.toStringAsFixed(0)}', const Color(0xFFECFDF5), const Color(0xFF059669)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Action Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isAdded ? const Color(0xFFFEE2E2) : const Color(0xFFECFDF5),
              foregroundColor: isAdded ? Colors.redAccent : const Color(0xFF059669),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: isAdded ? onRemoveTap : onAddTap,
            child: Icon(
              isAdded ? Icons.remove_circle_outline_rounded : Icons.add_circle_outline_rounded,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: text,
        ),
      ),
    );
  }
}

// 3. Basket Item Card
class BasketItemCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onRemoveTap;
  final Function(double) onUpdatePrice;

  const BasketItemCard({
    super.key,
    required this.item,
    required this.onRemoveTap,
    required this.onUpdatePrice,
  });

  @override
  State<BasketItemCard> createState() => _BasketItemCardState();
}

class _BasketItemCardState extends State<BasketItemCard> {
  late TextEditingController _priceCtrl;
  double _localPrice = 0.0;

  @override
  void initState() {
    super.initState();
    final double adminSellingPrice = (widget.item['adminSellingPrice'] as num?)?.toDouble() ?? 0.0;
    final double mySellingPrice = (widget.item['mySellingPrice'] as num?)?.toDouble() ?? adminSellingPrice;
    _localPrice = mySellingPrice;
    _priceCtrl = TextEditingController(text: mySellingPrice.toStringAsFixed(2));
  }

  @override
  void didUpdateWidget(covariant BasketItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final double oldAdmin = (oldWidget.item['adminSellingPrice'] as num?)?.toDouble() ?? 0.0;
    final double oldMy = (oldWidget.item['mySellingPrice'] as num?)?.toDouble() ?? oldAdmin;
    final double newAdmin = (widget.item['adminSellingPrice'] as num?)?.toDouble() ?? 0.0;
    final double newMy = (widget.item['mySellingPrice'] as num?)?.toDouble() ?? newAdmin;
    
    if (oldMy != newMy) {
      _localPrice = newMy;
      _priceCtrl.text = newMy.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.item['name'] ?? '';
    final String image = widget.item['image'] ?? '';
    final double vendorPrice = (widget.item['vendorPrice'] as num?)?.toDouble() ?? 0.0;
    final double adminSellingPrice = (widget.item['adminSellingPrice'] as num?)?.toDouble() ?? 0.0;
    
    final double profit = _localPrice - vendorPrice;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: image.isNotEmpty
                      ? (image.startsWith('http')
                          ? Image.network(image, fit: BoxFit.cover)
                          : Image.asset(image, fit: BoxFit.cover))
                      : Container(
                          color: const Color(0xFFF1F5F9),
                          child: const Icon(Icons.image_outlined, color: Colors.grey),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Name and Cost details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ভেন্ডর কেনা মূল্য: ৳${vendorPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      'অ্যাডমিন বিক্রয় মূল্য: ৳${adminSellingPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                onPressed: widget.onRemoveTap,
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Custom Price editor
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'আপনার বিক্রয় মূল্য সেট করুন:',
                      style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 110,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: TextField(
                            controller: _priceCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              prefixText: '৳ ',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              isDense: true,
                            ),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            onChanged: (val) {
                              setState(() {
                                _localPrice = double.tryParse(val) ?? 0.0;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Save button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF08B3AC), // AppColors.primaryColor
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            minimumSize: const Size(0, 42),
                          ),
                          onPressed: () {
                            if (_localPrice > vendorPrice) {
                              widget.onUpdatePrice(_localPrice);
                            } else {
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
                            }
                          },
                          child: const Text('সংরক্ষণ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Realtime profit
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'অর্জিত লাভ',
                    style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '৳${profit.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: profit > 0 ? const Color(0xFF059669) : Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 4. Vendor Order Card
class VendorOrderCard extends StatelessWidget {
  final OrderModel order;
  final double vendorProfit;

  const VendorOrderCard({
    super.key,
    required this.order,
    required this.vendorProfit,
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                  const Text('আপনার অর্জিত লাভ', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text(
                    '৳${vendorProfit.toStringAsFixed(2)}',
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
    );
  }
}

// 5. Withdrawal Card
class WithdrawalCard extends StatelessWidget {
  final Map<String, dynamic> w;

  const WithdrawalCard({super.key, required this.w});

  @override
  Widget build(BuildContext context) {
    final status = w['status'] as String? ?? 'pending';
    final amount = (w['amount'] as num?)?.toDouble() ?? 0.0;
    final bankName = w['bankName'] ?? '';
    final accountNum = w['accountNumber'] ?? '';
    
    Timestamp? ts = w['createdAt'] as Timestamp?;
    final dateStr = ts != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(ts.toDate())
        : '';

    Color statusColor;
    String statusBangla;

    if (status == 'approved') {
      statusColor = const Color(0xFF10B981);
      statusBangla = 'অনুমোদিত';
    } else if (status == 'rejected') {
      statusColor = const Color(0xFFEF4444);
      statusBangla = 'বাতিল';
    } else {
      statusColor = const Color(0xFFF59E0B);
      statusBangla = 'পেন্ডিং';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '৳${amount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                '$bankName ($accountNum)',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Text(
                dateStr,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
    );
  }
}
