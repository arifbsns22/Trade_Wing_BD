import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:trade_wign_bd/features/users/drive_pack/domain/models/recharge_model.dart';
import 'package:trade_wign_bd/features/admin/drive_pack/presentation/controllers/admin_drive_orders_controller.dart';
import 'package:trade_wign_bd/features/admin/drive_pack/presentation/widgets/drive_order_details.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class AdminDriveOrdersTable extends StatelessWidget {
  const AdminDriveOrdersTable({super.key});

  void _showDeleteConfirmation(BuildContext context, AdminDriveOrdersController controller, String transactionId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('অর্ডার মুছুন', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'আপনি কি নিশ্চিতভাবে এই অর্ডার রেকর্ডটি মুছে ফেলতে চান? এটি পুনরায় ফিরিয়ে আনা সম্ভব নয়।',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              controller.deleteOrder(transactionId);
            },
            child: const Text('মুছে ফেলুন', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDriveOrdersController>();

    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
              },
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Obx(() {
                  if (!controller.isLoading.value && controller.filteredOrdersList.isEmpty) {
                    return Container(
                      width: MediaQuery.of(context).size.width - 32,
                      height: 300,
                      alignment: Alignment.center,
                      child: const Text('কোনো অর্ডার অনুরোধ পাওয়া যায়নি'),
                    );
                  }

                  // Dummy skeleton data
                  final displayList = controller.isLoading.value
                      ? List.generate(
                          5,
                          (index) => RechargeModel(
                            id: '',
                            operatorId: '',
                            operatorName: 'GP',
                            mobileNumber: '01XXXXXXXXX',
                            amount: 100.0,
                            userMobile: '01XXXXXXXXX',
                            userName: 'Loading User',
                            status: 'pending',
                            createdAt: DateTime.now(),
                            transactionId: 'TXN_DUMMY',
                            rechargeType: 'regular',
                          ),
                        )
                      : controller.filteredOrdersList;

                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width - 32,
                    ),
                    child: Skeletonizer(
                      enabled: controller.isLoading.value,
                      child: DataTable(
                        columnSpacing: 32,
                        horizontalMargin: 20,
                        headingRowColor: WidgetStateProperty.all(const Color(0xFFF8F9FA)),
                        headingTextStyle: const TextStyle(
                          color: Color(0xFF343A40),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        dataRowMinHeight: 65,
                        dataRowMaxHeight: 75,
                        dividerThickness: 0.5,
                        columns: const [
                          DataColumn(label: Text('ক্রমিক')),
                          DataColumn(label: Text('অর্ডার আইডি')),
                          DataColumn(label: Text('তারিখ')),
                          DataColumn(label: Text('ইউজার')),
                          DataColumn(label: Text('রিচার্জ নম্বর')),
                          DataColumn(label: Text('ধরণ')),
                          DataColumn(label: Text('অপারেটর')),
                          DataColumn(label: Text('পরিমাণ')),
                          DataColumn(label: Text('পেমেন্ট')),
                          DataColumn(label: Text('স্ট্যাটাস')),
                          DataColumn(label: Text('একশন')),
                        ],
                        rows: displayList.asMap().entries.map((entry) {
                          final index = entry.key;
                          final order = entry.value;

                          final formattedDate = DateFormat('dd MMM yyyy\nhh:mm a').format(order.createdAt);
                          final bool isDrive = order.rechargeType == 'drive';
                          final bool isPaid = order.status == 'completed';

                          return DataRow(
                            cells: [
                              // 1. Serial Number
                              DataCell(
                                Text(
                                  '${index + 1}',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                ),
                              ),
                              // 2. Order ID
                              DataCell(
                                Text(
                                  order.transactionId,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                              // 3. Date
                              DataCell(
                                Text(
                                  formattedDate,
                                  style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
                                ),
                              ),
                              // 4. User details
                              DataCell(
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.userName,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                    ),
                                    Text(
                                      order.userMobile,
                                      style: TextStyle(color: Colors.grey.shade500, fontSize: 10.5),
                                    ),
                                  ],
                                ),
                              ),
                              // 5. Target Mobile
                              DataCell(
                                Text(
                                  order.mobileNumber,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                              // 6. Recharge Type Chip
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDrive ? const Color(0xFFEFF6FF) : const Color(0xFFF0FDFA),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isDrive ? 'অফার' : 'রিচার্জ',
                                    style: TextStyle(
                                      color: isDrive ? const Color(0xFF2563EB) : const Color(0xFF0D9488),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              // 7. Operator Name
                              DataCell(
                                Text(
                                  order.operatorName,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                ),
                              ),
                              // 8. Amount
                              DataCell(
                                Text(
                                  '৳${order.amount.toStringAsFixed(0)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                              // 9. Payment Status
                              DataCell(
                                Text(
                                  isPaid ? 'পরিশোধিত' : 'বকেয়া',
                                  style: TextStyle(
                                    color: isPaid ? Colors.green : Colors.grey.shade600,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ),
                              // 10. Order Status Badge
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: order.status == 'completed'
                                        ? const Color(0xFFDCFCE7)
                                        : order.status == 'failed'
                                            ? const Color(0xFFFEE2E2)
                                            : const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    order.status == 'completed'
                                        ? 'সম্পন্ন'
                                        : order.status == 'failed'
                                            ? 'ব্যর্থ'
                                            : 'পেন্ডিং',
                                    style: TextStyle(
                                      color: order.status == 'completed'
                                          ? const Color(0xFF15803D)
                                          : order.status == 'failed'
                                              ? const Color(0xFFB91C1C)
                                              : const Color(0xFFB45309),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              // 11. Action Buttons
                              DataCell(
                                Row(
                                  children: [
                                    // View detail sheet
                                    IconButton(
                                      icon: const Icon(Icons.visibility, color: Colors.blue, size: 18),
                                      onPressed: () {
                                        DriveOrderDetailsSheet.show(context, order);
                                      },
                                      tooltip: 'অর্ডার বিস্তারিত',
                                    ),
                                    // Print Pos Receipt
                                    IconButton(
                                      icon: Icon(Icons.print, color: AppColors.green, size: 18),
                                      onPressed: () {
                                        // Open sheet directly, it has POS printer triggers inside
                                        DriveOrderDetailsSheet.show(context, order);
                                      },
                                      tooltip: 'ইনভয়েস প্রিন্ট',
                                    ),
                                    // Delete order record
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                      onPressed: () {
                                        _showDeleteConfirmation(context, controller, order.transactionId);
                                      },
                                      tooltip: 'মুছে ফেলুন',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
