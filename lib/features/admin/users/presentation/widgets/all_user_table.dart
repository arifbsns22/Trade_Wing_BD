import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import '../controllers/admin_users_controller.dart';
import '../screens/user_details_screen.dart';

class AllUserTable extends StatelessWidget {
  const AllUserTable({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminUsersController>();

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
                  // If not loading and empty
                  if (!controller.isLoading.value &&
                      controller.filteredUsersList.isEmpty) {
                    return Container(
                      width: MediaQuery.of(context).size.width - 32,
                      height: 300,
                      alignment: Alignment.center,
                      child: const Text('কোনো ইউজার পাওয়া যায়নি'),
                    );
                  }

                  // Use dummy data for skeletonizer if loading
                  final displayList = controller.isLoading.value
                      ? List.generate(
                          5,
                          (index) => {
                            'name': 'Loading Name',
                            'role': 'Customer',
                            'mobile': '01XXXXXXXXX',
                            'totalOrders': 0,
                            'totalOrderAmount': 0.0,
                            'createdAt': null,
                          },
                        )
                      : controller.filteredUsersList;

                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width - 32,
                    ),
                    child: Skeletonizer(
                      enabled: controller.isLoading.value,
                      child: DataTable(
                        columnSpacing: 40,
                        horizontalMargin: 24,
                        headingRowColor: WidgetStateProperty.all(
                          const Color(0xFFF8F9FA),
                        ),
                        headingTextStyle: const TextStyle(
                          color: Color(0xFF343A40),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        dataRowMinHeight: 70,
                        dataRowMaxHeight: 80,
                        dividerThickness: 0.5,
                        columns: const [
                          DataColumn(label: Text('ক্রমিক নং')),
                          DataColumn(label: Text('নাম')),
                          DataColumn(label: Text('পদবী')),
                          DataColumn(label: Text('মোবাইল নম্বর')),
                          DataColumn(label: Text('মোট অর্ডার')),
                          DataColumn(label: Text('মোট টাকার পরিমাণ')),
                          DataColumn(label: Text('যোগদানের তারিখ')),
                          DataColumn(label: Text('স্ট্যাটাস')),
                          DataColumn(label: Text('একশন')),
                        ],
                        rows: displayList.asMap().entries.map((entry) {
                          int index = entry.key;
                          Map<String, dynamic> user = entry.value;

                          // Format Date
                          String joiningDate = 'N/A';
                          if (user['createdAt'] != null &&
                              user['createdAt'] is Timestamp) {
                            joiningDate = DateFormat(
                              'dd MMM yyyy',
                            ).format((user['createdAt'] as Timestamp).toDate());
                          }

                          // Values for new fields from DB
                          int totalOrders =
                              (user['totalOrders'] as num?)?.toInt() ?? 0;
                          double totalAmount =
                              (user['totalOrderAmount'] as num?)?.toDouble() ??
                              0.0;

                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  '${index + 1}',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: AppColors.primaryColor
                                          .withValues(alpha: 0.1),
                                      child: Icon(
                                        Icons.person,
                                        size: 20,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      user['name'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    user['role'] ?? 'Customer',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${user['mobile']}',
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '$totalOrders',
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '৳${totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              ),
                              DataCell(
                                Text(
                                  joiningDate,
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              ),
                              DataCell(
                                Transform.scale(
                                  scale: 0.7,
                                  child: Switch(
                                    value: user['isActive'] ?? true, 
                                    onChanged: (val) {
                                      controller.toggleUserStatus(user['mobile'], user['isActive'] ?? true);
                                    },
                                    activeColor: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  icon: Icon(
                                    Icons.remove_red_eye,
                                    color: AppColors.primaryColor,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    Get.to(() => UserDetailsScreen(user: user));
                                  },
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
