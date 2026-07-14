import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import 'package:trade_wign_bd/features/users/e-commerce/domain/models/order_model.dart';
import 'package:trade_wign_bd/features/admin/ecommerce/presentation/controllers/admin_orders_controller.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/widgets/order_details_bottom_sheet.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminOrdersController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE), // Soft admin background
      appBar: AppBar(
        title: const Text(
          'Orders Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: const Color(0xFFF4F7FE),
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        if (controller.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No orders found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Top Action Bar (Search, Export, Filter)
              _buildTopActionBar(controller),
              const SizedBox(height: 16),

              // Table Card
              Expanded(
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
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: MediaQuery.of(context).size.width - 32,
                            ),
                            child: DataTable(
                              columnSpacing:
                                  48, // Increased spacing to force horizontal scroll and match UI
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
                              dataRowMaxHeight: 90,
                              dividerThickness: 0.5,
                              columns: const [
                                DataColumn(label: Text('Sl')),
                                DataColumn(label: Text('Order Id')),
                                DataColumn(label: Text('Order Date')),
                                DataColumn(label: Text('Customer Information')),
                                DataColumn(label: Text('Store')),
                                DataColumn(label: Text('Item Quantity')),
                                DataColumn(label: Text('Total Amount')),
                                DataColumn(label: Text('Order Status')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: controller.filteredOrders.asMap().entries.map((
                                entry,
                              ) {
                                int index = entry.key;
                                OrderModel order = entry.value;

                                int totalQty = 0;
                                for (var item in order.items) {
                                  totalQty +=
                                      (item['quantity'] as num?)?.toInt() ?? 1;
                                }

                                return DataRow(
                                  cells: [
                                    // Sl
                                    DataCell(
                                      Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),

                                    // Order Id
                                    DataCell(
                                      Text(
                                        order.orderId,
                                        style: TextStyle(
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),

                                    // Order Date
                                    DataCell(
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            DateFormat(
                                              'dd MMM yyyy',
                                            ).format(order.createdAt),
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            DateFormat(
                                              'hh:mm a',
                                            ).format(order.createdAt),
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Customer Information
                                    DataCell(
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            order.userName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '+${order.userMobile}',
                                            style: TextStyle(
                                              color: AppColors.primaryColor,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Store
                                    const DataCell(
                                      Text(
                                        'Trade Wign BD',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),

                                    // Item Quantity
                                    DataCell(
                                      Center(
                                        child: Text(
                                          '$totalQty',
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Total Amount & Payment Status
                                    DataCell(
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            '৳${order.totalAmount.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            order.paymentStatus ==
                                                    PaymentStatus.verified
                                                ? 'Paid'
                                                : 'Unpaid',
                                            style: TextStyle(
                                              color:
                                                  order.paymentStatus ==
                                                      PaymentStatus.verified
                                                  ? AppColors.green
                                                  : Colors.red,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Order Status
                                    DataCell(
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(
                                                order.orderStatus,
                                              ).withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: _getStatusColor(
                                                  order.orderStatus,
                                                ).withValues(alpha: 0.2),
                                              ),
                                            ),
                                            child: Text(
                                              _getStatusText(order.orderStatus),
                                              style: TextStyle(
                                                color: _getStatusColor(
                                                  order.orderStatus,
                                                ),
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Home Delivery',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Actions
                                    DataCell(
                                      Row(
                                        children: [
                                          _buildActionButton(
                                            icon: Icons.remove_red_eye_outlined,
                                            color: AppColors.primaryColor,
                                            onTap: () {
                                              showOrderDetailsBottomSheet(
                                                context,
                                                order,
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                          _buildActionButton(
                                            icon: Icons.print_outlined,
                                            color: AppColors.green,
                                            onTap: () {
                                              Get.snackbar(
                                                'Print',
                                                'Coming soon.',
                                                backgroundColor: Colors.white
                                                    .withValues(alpha: 0.9),
                                                colorText: Colors.black87,
                                                borderColor: AppColors
                                                    .primaryColor
                                                    .withValues(alpha: 0.2),
                                                borderWidth: 1,
                                                snackPosition:
                                                    SnackPosition.BOTTOM,
                                                margin: const EdgeInsets.all(
                                                  16,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTopActionBar(AdminOrdersController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Search
        Expanded(
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) => controller.searchQuery.value = value,
              decoration: InputDecoration(
                hintText: 'Search by Order ID, Name, or Mobile...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Export
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(
                Icons.download_outlined,
                size: 18,
                color: Colors.grey.shade700,
              ),
              const SizedBox(width: 6),
              Text(
                'Export',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: Colors.grey.shade700,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Filter
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(Icons.filter_list, size: 18, color: Colors.grey.shade700),
              const SizedBox(width: 6),
              Text(
                'Filter',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return const Color(0xFF00BCD4); // Cyan matching reference
      case OrderStatus.processing:
        return AppColors.primaryColor;
      case OrderStatus.shipped:
        return Colors.orange;
      case OrderStatus.delivered:
        return AppColors.green;
      case OrderStatus.cancelled:
        return Colors.red;
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
}
