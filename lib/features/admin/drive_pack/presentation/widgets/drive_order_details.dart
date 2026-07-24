import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:trade_wign_bd/features/users/drive_pack/domain/models/recharge_model.dart';
import 'package:trade_wign_bd/features/admin/drive_pack/presentation/controllers/admin_drive_orders_controller.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class DriveOrderDetailsSheet extends StatelessWidget {
  final RechargeModel order;
  const DriveOrderDetailsSheet({super.key, required this.order});

  static void show(BuildContext context, RechargeModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DriveOrderDetailsSheet(order: order),
    );
  }

  void _printReceipt(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const Text(
                'TRADE WING BD',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 1.2,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Text(
                'অফিসিয়াল রিচার্জ ইনভয়েস',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 1, color: Colors.grey),
              const SizedBox(height: 12),
              _buildReceiptRow('অর্ডার আইডি:', order.transactionId),
              _buildReceiptRow(
                'তারিখ:',
                DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt),
              ),
              _buildReceiptRow('গ্রাহকের নাম:', order.userName),
              _buildReceiptRow('গ্রাহকের ফোন:', order.userMobile),
              _buildReceiptRow('রিচার্জ নম্বর:', order.mobileNumber),
              _buildReceiptRow('অপারেটর:', order.operatorName),
              _buildReceiptRow(
                'অর্ডার টাইপ:',
                order.rechargeType == 'drive' ? 'ড্রাইভ অফার' : 'সাধারণ রিচার্জ',
              ),
              _buildReceiptRow(
                'পেমেন্ট পদ্ধতি:',
                order.paymentMethod == 'offline' ? 'অফলাইন' : 'ওয়ালেট',
              ),
              if (order.paymentMethod == 'offline') ...[
                _buildReceiptRow('গেটওয়ে:', order.offlineGateway?.toUpperCase() ?? 'N/A'),
                _buildReceiptRow('প্রেরক ফোন:', order.offlineSenderMobile ?? 'N/A'),
                _buildReceiptRow('পেমেন্ট TrxID:', order.offlineTrxId ?? 'N/A'),
              ],
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 1, color: Colors.grey),
              const SizedBox(height: 12),
              _buildReceiptRow('মোট পরিমাণ:', '৳${order.amount}', isBold: true),
              _buildReceiptRow(
                'পেমেন্ট স্ট্যাটাস:',
                order.status == 'completed' ? 'পরিশোধিত (Paid)' : 'পেন্ডিং (Pending)',
                isBold: true,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('বন্ধ করুন', style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Get.snackbar(
                        'সফল',
                        'ইনভয়েস প্রিন্ট করার অনুরোধ ব্রাউজারে পাঠানো হয়েছে।',
                        backgroundColor: Colors.white.withValues(alpha: 0.9),
                        colorText: Colors.black87,
                        borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
                        borderWidth: 1,
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(16),
                      );
                    },
                    icon: const Icon(Icons.print, color: Colors.white, size: 16),
                    label: const Text(
                      'প্রিন্ট করুন',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDriveOrdersController>();
    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt);
    
    // Status coloring configurations
    Color statusBgColor = Colors.amber.shade50;
    Color statusTextColor = Colors.amber.shade800;
    String statusTextBangla = 'পেন্ডিং';
    if (order.status == 'completed') {
      statusBgColor = Colors.green.shade50;
      statusTextColor = Colors.green.shade700;
      statusTextBangla = 'সম্পন্ন';
    } else if (order.status == 'failed') {
      statusBgColor = Colors.red.shade50;
      statusTextColor = Colors.red.shade700;
      statusTextBangla = 'ব্যর্থ';
    }

    // Dynamic payment colors & branding based on gateway
    Color paymentBrandColor = AppColors.primaryColor;
    String paymentLogoText = 'ওয়ালেট পেমেন্ট';
    IconData paymentIcon = Icons.account_balance_wallet_outlined;
    bool isOffline = order.paymentMethod == 'offline';
    
    if (isOffline) {
      final gateway = order.offlineGateway?.toLowerCase() ?? '';
      if (gateway.contains('bkash')) {
        paymentBrandColor = const Color(0xFFE2125B); // bKash Pink
        paymentLogoText = 'bKash (অফলাইন পেমেন্ট)';
        paymentIcon = Icons.mobile_friendly_outlined;
      } else if (gateway.contains('nagad')) {
        paymentBrandColor = const Color(0xFFF37021); // Nagad Orange
        paymentLogoText = 'Nagad (অফলাইন পেমেন্ট)';
        paymentIcon = Icons.mobile_friendly_outlined;
      } else {
        paymentBrandColor = const Color(0xFF08B3AC);
        paymentLogoText = 'অফলাইন পেমেন্ট';
        paymentIcon = Icons.payment_outlined;
      }
    }

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Top Header & Status Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        order.rechargeType == 'drive'
                            ? Icons.local_shipping_outlined
                            : Icons.phone_android_outlined,
                        color: AppColors.primaryColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'অর্ডার বিস্তারিত বিবরণ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusTextColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    statusTextBangla,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // 1. HIGHLIGHTED HERO PAYMENT CARD (The main visual focus)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    paymentBrandColor.withValues(alpha: 0.08),
                    paymentBrandColor.withValues(alpha: 0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: paymentBrandColor.withValues(alpha: 0.15), width: 1.5),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(paymentIcon, color: paymentBrandColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            paymentLogoText,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: paymentBrandColor,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'মোট বিল',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '৳${order.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: paymentBrandColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (order.status == 'completed')
                        Row(
                          children: [
                            Icon(Icons.verified, color: Colors.green.shade600, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'পরিশোধিত',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade600,
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Icon(Icons.hourglass_empty, color: Colors.amber.shade700, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'পেমেন্ট যাচাই প্রয়োজন',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade700,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  
                  // Offline Txn particulars
                  if (isOffline) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: paymentBrandColor.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'প্রেরক নম্বর (Sender Mobile):',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                order.offlineSenderMobile ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Divider(height: 1, thickness: 0.5),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'ট্রানজ্যাকশন আইডি (TrxID):',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    order.offlineTrxId ?? 'N/A',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: paymentBrandColor,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  if (order.offlineTrxId != null &&
                                      order.offlineTrxId!.isNotEmpty)
                                    GestureDetector(
                                      onTap: () {
                                        Clipboard.setData(
                                          ClipboardData(text: order.offlineTrxId!),
                                        );
                                        Get.snackbar(
                                          'সফল',
                                          'ট্রানজ্যাকশন আইডি কপি করা হয়েছে।',
                                          backgroundColor:
                                              Colors.white.withValues(alpha: 0.9),
                                          colorText: Colors.black87,
                                          borderColor: const Color(0xFF08B3AC)
                                              .withValues(alpha: 0.2),
                                          borderWidth: 1,
                                          snackPosition: SnackPosition.BOTTOM,
                                          margin: const EdgeInsets.all(16),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: paymentBrandColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Icon(
                                          Icons.copy,
                                          size: 14,
                                          color: paymentBrandColor,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. ORDER DETAILS & TARGET CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey.shade600, size: 16),
                      const SizedBox(width: 6),
                      const Text(
                        'অর্ডার তথ্য',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDetailItem('লেনদেন আইডি (Txn ID)', order.transactionId),
                  _buildDetailItem('তারিখ ও সময়', formattedDate),
                  _buildDetailItem('অপারেটর', order.operatorName),
                  _buildDetailItem(
                    'অর্ডার ধরণ',
                    order.rechargeType == 'drive' ? 'ড্রাইভ অফার' : 'সাধারণ রিচার্জ',
                  ),
                  if (order.drivePackageId != null)
                    _buildDetailItem('ড্রাইভ প্যাকেজ আইডি', order.drivePackageId!),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. TARGET RECHARGE MOBILE & USER TILE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Target Phone Number Display Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.phone_iphone, color: Color(0xFF08B3AC), size: 18),
                            SizedBox(width: 8),
                            Text(
                              'রিচার্জ লক্ষ্য নম্বর:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          order.mobileNumber,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // User Details particulars
                  _buildDetailItem('ইউজার নাম', order.userName),
                  _buildDetailItem('ইউজার মোবাইল নম্বর', order.userMobile),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. Dropdown Status Selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.edit_road_outlined, color: Color(0xFF475569), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'স্ট্যাটাস পরিবর্তন করুন',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.grey.shade50,
                    ),
                    child: DropdownButton<String>(
                      value: order.status,
                      underline: const SizedBox(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                      onChanged: (newStatus) {
                        if (newStatus != null) {
                          controller.updateOrderStatus(order.transactionId, newStatus);
                          Navigator.pop(context); // Close sheet
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text('পেন্ডিং (Pending)'),
                        ),
                        DropdownMenuItem(
                          value: 'completed',
                          child: Text('সম্পন্ন (Completed)'),
                        ),
                        DropdownMenuItem(
                          value: 'failed',
                          child: Text('ব্যর্থ (Failed)'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bottom Actions (Print Receipt / Approve)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    onPressed: () => _printReceipt(context),
                    icon: const Icon(Icons.print, color: Color(0xFF475569), size: 18),
                    label: const Text(
                      'ইনভয়েস প্রিন্ট',
                      style: TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (order.status == 'pending') ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        controller.updateOrderStatus(order.transactionId, 'completed');
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: const Text(
                        'অনুমোদন করুন',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
