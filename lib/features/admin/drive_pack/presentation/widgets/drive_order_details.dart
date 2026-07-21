import 'package:flutter/material.dart';
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
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
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

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'অর্ডার বিস্তারিত বিবরণ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),

          // Details List
          _buildDetailItem('লেনদেন আইডি (Txn ID)', order.transactionId),
          _buildDetailItem('তারিখ ও সময়', formattedDate),
          _buildDetailItem('ইউজার নাম', order.userName),
          _buildDetailItem('ইউজার মোবাইল নম্বর', order.userMobile),
          _buildDetailItem('রিচার্জ লক্ষ্য নম্বর', order.mobileNumber),
          _buildDetailItem('অপারেটর', order.operatorName),
          _buildDetailItem(
            'অর্ডার ধরণ',
            order.rechargeType == 'drive' ? 'ড্রাইভ অফার' : 'সাধারণ রিচার্জ',
          ),
          if (order.drivePackageId != null)
            _buildDetailItem('ড্রাইভ প্যাকেজ আইডি', order.drivePackageId!),
          _buildDetailItem('টাকার পরিমাণ', '৳${order.amount}'),
          
          // Dropdown Status Selector
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'অর্ডার স্ট্যাটাস',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
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
                    DropdownMenuItem(value: 'pending', child: Text('পেন্ডিং (Pending)')),
                    DropdownMenuItem(value: 'completed', child: Text('সম্পন্ন (Completed)')),
                    DropdownMenuItem(value: 'failed', child: Text('ব্যর্থ (Failed)')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Bottom CTAs
          Row(
            children: [
              // Print Receipt Button
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  onPressed: () => _printReceipt(context),
                  icon: const Icon(Icons.print, color: Color(0xFF475569), size: 18),
                  label: const Text(
                    'ইনভয়েস প্রিন্ট',
                    style: TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Approve Button
              if (order.status == 'pending') ...[
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      controller.updateOrderStatus(order.transactionId, 'completed');
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                    label: const Text(
                      'অনুমোদন করুন',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
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
