import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../controllers/admin_reseller_dashboard_controller.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class AdminResellerListTable extends StatelessWidget {
  const AdminResellerListTable({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminResellerDashboardController>();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                if (!controller.isLoading.value && controller.resellersList.isEmpty) {
                  return Container(
                    width: MediaQuery.of(context).size.width - 32,
                    height: 200,
                    alignment: Alignment.center,
                    child: const Text('কোনো রিসেলার পাওয়া যায়নি'),
                  );
                }

                final List<Map<String, dynamic>> displayList = controller.isLoading.value
                    ? List<Map<String, dynamic>>.generate(
                        3,
                        (index) => {
                          'name': 'Loading Name',
                          'shopName': 'Loading Shop',
                          'mobile': '01XXXXXXXXX',
                        },
                      )
                    : controller.resellersList;

                return ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width - 32,
                  ),
                  child: Skeletonizer(
                    enabled: controller.isLoading.value,
                    child: DataTable(
                      columnSpacing: 24,
                      horizontalMargin: 16,
                      headingRowColor: WidgetStateProperty.all(
                        const Color(0xFFF8F9FA),
                      ),
                      headingTextStyle: const TextStyle(
                        color: Color(0xFF343A40),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      dataRowMinHeight: 50,
                      dataRowMaxHeight: 65,
                      dividerThickness: 0.5,
                      columns: const [
                        DataColumn(label: Text('ক্রমিক নং')),
                        DataColumn(label: Text('শপের নাম')),
                        DataColumn(label: Text('রিসেলারের নাম')),
                        DataColumn(label: Text('মোবাইল নম্বর')),
                        DataColumn(label: Text('স্ট্যাটাস')),
                        DataColumn(label: Text('অ্যাকশন')),
                        DataColumn(label: Text('সম্পন্ন অর্ডার')),
                        DataColumn(label: Text('পেন্ডিং অর্ডার')),
                        DataColumn(label: Text('অর্জিত মোট লাভ')),
                        DataColumn(label: Text('মোট উত্তোলন')),
                        DataColumn(label: Text('চলতি ব্যালেন্স')),
                      ],
                      rows: displayList.asMap().entries.map((entry) {
                        final index = entry.key;
                        final vendor = entry.value;
                        final mobile = vendor['mobile'] ?? '';
                        final status = vendor['resellerVerificationStatus'] ?? 
                            (vendor['role']?.toString().toLowerCase().trim() == 'reseller' ? 'approved' : 'none');

                        // Get real-time aggregated stats for this vendor
                        final stats = controller.getResellerStats(mobile);

                        return DataRow(
                          cells: [
                            DataCell(Text('${index + 1}', style: const TextStyle(fontSize: 12))),
                            DataCell(Text(vendor['shopName'] ?? 'No Shop Name', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                            DataCell(Text(vendor['name'] ?? 'Unnamed', style: const TextStyle(fontSize: 12))),
                            DataCell(Text(mobile, style: const TextStyle(fontSize: 12))),
                            DataCell(_buildStatusBadge(status)),
                            DataCell(Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility_outlined, size: 18),
                                  onPressed: () => _showResellerDetailDialog(context, vendor, controller, status),
                                  tooltip: 'বিস্তারিত দেখুন',
                                ),
                                if (status != 'approved') ...[
                                  IconButton(
                                    icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 18),
                                    onPressed: () => _confirmStatusChange(context, mobile, 'approved', controller),
                                    tooltip: 'অনুমোদন',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.cancel_outlined, color: Colors.red, size: 18),
                                    onPressed: () => _confirmStatusChange(context, mobile, 'rejected', controller),
                                    tooltip: 'বাতিল',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.pause_circle_outline_rounded, color: Colors.orange, size: 18),
                                    onPressed: () => _confirmStatusChange(context, mobile, 'hold', controller),
                                    tooltip: 'স্থগিত',
                                  ),
                                ],
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                                  onPressed: () => _confirmDeleteUser(context, mobile, controller),
                                  tooltip: 'ডিলিট করুন',
                                ),
                              ],
                            )),
                            DataCell(Text('${stats['completedOrders']} টি', style: const TextStyle(fontSize: 12))),
                            DataCell(Text('${stats['pendingOrders']} টি', style: const TextStyle(fontSize: 12))),
                            DataCell(Text('৳${(stats['profit'] as double).toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold))),
                            DataCell(Text('৳${(stats['withdrawn'] as double).toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Colors.redAccent))),
                            DataCell(Text('৳${(stats['balance'] as double).toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Colors.teal, fontWeight: FontWeight.bold))),
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
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status.toLowerCase().trim()) {
      case 'approved':
        bgColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF065F46);
        text = 'অনুমোদিত';
        break;
      case 'pending':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        text = 'যাচাইধীন';
        break;
      case 'hold':
        bgColor = const Color(0xFFE0F2FE);
        textColor = const Color(0xFF075985);
        text = 'স্থগিত';
        break;
      case 'rejected':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        text = 'বাতিল';
        break;
      default:
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF374151);
        text = 'সাধারণ';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _confirmStatusChange(BuildContext context, String mobile, String newStatus, AdminResellerDashboardController controller) {
    String statusBangla = newStatus == 'approved' ? 'অনুমোদন' : (newStatus == 'rejected' ? 'বাতিল' : 'স্থগিত');
    Get.defaultDialog(
      title: 'নিশ্চিত করুন',
      content: Text('আপনি কি এই আবেদনটি $statusBangla করতে চান?'),
      textCancel: 'বাতিল',
      textConfirm: 'হ্যাঁ',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primaryColor,
      onConfirm: () {
        Get.back();
        controller.updateVerificationStatus(mobile, newStatus);
      },
    );
  }

  void _showResellerDetailDialog(BuildContext context, Map<String, dynamic> reseller, AdminResellerDashboardController controller, String currentStatus) {
    final categories = reseller['resellerCategories'] ?? 'উল্লেখ করা হয়নি';
    final nidNumber = reseller['resellerNidNumber'] ?? 'উল্লেখ করা হয়নি';
    final tradeLicense = reseller['resellerTradeLicense'] ?? 'উল্লেখ করা হয়নি';
    final mobile = reseller['mobile'] ?? '';

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'রিসেলার আবেদনকারীর বিবরণ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    )
                  ],
                ),
                const Divider(),
                const SizedBox(height: 10),

                // Text Info
                _buildDetailRow('নাম', reseller['name'] ?? 'Unnamed'),
                _buildDetailRow('শপের নাম', reseller['shopName'] ?? 'No Shop Name'),
                _buildDetailRow('মোবাইল', mobile),
                _buildDetailRow('এনআইডি নম্বর', nidNumber),
                _buildDetailRow('ট্রেড লাইসেন্স', tradeLicense),
                _buildDetailRow('ক্যাটাগরি সমূহ', categories),
                const SizedBox(height: 16),

                // Images previews
                const Text(
                  'ভেরিফিকেশন ডকুমেন্টস',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildImagePreview('NID Front', reseller['resellerNidFront'])),
                    const SizedBox(width: 10),
                    Expanded(child: _buildImagePreview('NID Back', reseller['resellerNidBack'])),
                  ],
                ),
                const SizedBox(height: 10),
                _buildImagePreview('Selfie / নিজের ছবি', reseller['resellerSelfie']),

                const SizedBox(height: 24),
                // Action Buttons inside Dialog
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('বন্ধ করুন', style: TextStyle(color: Colors.grey)),
                    ),
                    if (currentStatus != 'approved') ...[
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                        onPressed: () {
                          Get.back();
                          _confirmStatusChange(context, mobile, 'hold', controller);
                        },
                        child: const Text('স্থগিত'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        onPressed: () {
                          Get.back();
                          _confirmStatusChange(context, mobile, 'rejected', controller);
                        },
                        child: const Text('বাতিল'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        onPressed: () {
                          Get.back();
                          _confirmStatusChange(context, mobile, 'approved', controller);
                        },
                        child: const Text('অনুমোদন'),
                      ),
                    ]
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 13),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(String label, String? url) {
    if (url == null || url.trim().isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black54)),
          const SizedBox(height: 6),
          Container(
            height: 100,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Text('ছবি পাওয়া যায়নি', style: TextStyle(color: Colors.black38, fontSize: 10)),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black54)),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => Get.dialog(
            Dialog(
              child: InteractiveViewer(
                child: Image.network(url),
              ),
            ),
          ),
          child: Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.broken_image_outlined, color: Colors.black26));
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDeleteUser(BuildContext context, String mobile, AdminResellerDashboardController controller) {
    Get.defaultDialog(
      title: 'ইউজার ডিলিট',
      content: const Text('আপনি কি নিশ্চিত যে এই ইউজারটি সম্পূর্ণভাবে ডিলিট করতে চান? এটি আর ফিরিয়ে আনা যাবে না।'),
      textCancel: 'বাতিল',
      textConfirm: 'ডিলিট',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        Get.back();
        controller.deleteUser(mobile);
      },
    );
  }
}
