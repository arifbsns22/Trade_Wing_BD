import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:trade_wign_bd/features/users/vendor/presentation/controllers/vendor_controller.dart';
import 'package:trade_wign_bd/features/users/vendor/presentation/widgets/vendor_stat_card.dart';
import 'package:trade_wign_bd/features/users/vendor/presentation/widgets/vendor_order_card.dart';
import 'package:trade_wign_bd/features/users/vendor/presentation/widgets/vendor_product_card.dart';
import 'package:trade_wign_bd/features/users/vendor/presentation/screens/vendor_add_product_screen.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({super.key});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  final VendorController controller = Get.put(VendorController());
  int _activeTabIndex = 0; // 0: Overview, 1: Products, 2: Orders

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'ভেন্ডর ড্যাশবোর্ড',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.vendorMobile.isEmpty) {
          return const Center(child: Text('অনুগ্রহ করে লগইন করুন।'));
        }
        return RefreshIndicator(
          onRefresh: () async {
            controller.setupListeners();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Stats Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 600;
                    return GridView.count(
                      crossAxisCount: isWide ? 4 : 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: isWide ? 2.0 : 2.3,
                      children: [
                        VendorStatCard(
                          title: 'আমার পণ্য',
                          value: '${controller.vendorProducts.length} টি',
                          icon: Icons.inventory_2_outlined,
                          backgroundColor: const Color(0xFFE0F2FE),
                          borderColor: const Color(0xFFBAE6FD),
                          themeColor: const Color(0xFF0369A1),
                        ),
                        VendorStatCard(
                          title: 'পেন্ডিং অর্ডার',
                          value: '${controller.pendingOrdersCount} টি',
                          icon: Icons.pending_outlined,
                          backgroundColor: const Color(0xFFFEF3C7),
                          borderColor: const Color(0xFFFDE68A),
                          themeColor: const Color(0xFFB45309),
                        ),
                        VendorStatCard(
                          title: 'সম্পন্ন অর্ডার',
                          value: '${controller.completedOrdersCount} টি',
                          icon: Icons.check_circle_outline_rounded,
                          backgroundColor: const Color(0xFFDCFCE7),
                          borderColor: const Color(0xFFBBF7D0),
                          themeColor: const Color(0xFF15803D),
                        ),
                        VendorStatCard(
                          title: 'মোট বিক্রয়',
                          value: '৳${controller.reactiveTotalSales.value.toStringAsFixed(2)}',
                          icon: Icons.trending_up_rounded,
                          backgroundColor: const Color(0xFFF3E8FF),
                          borderColor: const Color(0xFFE9D5FF),
                          themeColor: const Color(0xFF6B21A8),
                        ),
                        VendorStatCard(
                          title: 'অর্জিত লাভ',
                          value: '৳${controller.reactiveTotalEarnings.value.toStringAsFixed(2)}',
                          icon: Icons.monetization_on_outlined,
                          backgroundColor: const Color(0xFFFEE2E2),
                          borderColor: const Color(0xFFFECACA),
                          themeColor: const Color(0xFFB91C1C),
                        ),
                        VendorStatCard(
                          title: 'উত্তোলনযোগ্য ব্যালেন্স',
                          value: '৳${controller.withdrawAvailableAmount.toStringAsFixed(2)}',
                          icon: Icons.account_balance_wallet_outlined,
                          backgroundColor: const Color(0xFFECFDF5),
                          borderColor: const Color(0xFFA7F3D0),
                          themeColor: const Color(0xFF047857),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // 2. Tab Bar
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _buildTabButton(0, 'সারসংক্ষেপ / উত্তোলন', Icons.analytics_outlined)),
                      Expanded(child: _buildTabButton(1, 'আমার পণ্যসমূহ', Icons.inventory_2_outlined)),
                      Expanded(child: _buildTabButton(2, 'অর্ডারসমূহ', Icons.receipt_long_outlined)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Tab Body
                _buildTabContent(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _activeTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTabIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF08B3AC) : Colors.black54, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black87 : Colors.black54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_activeTabIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildProductsTab();
      case 2:
        return _buildOrdersTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOverviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Withdrawal request form / button card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ব্যালেন্স উত্তোলন করুন',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                'আপনার বর্তমান উত্তোলনযোগ্য ব্যালেন্স: ৳${controller.withdrawAvailableAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF08B3AC),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.account_balance_rounded, size: 18),
                label: const Text('উত্তোলন অনুরোধ পাঠান', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => _showWithdrawalSheet(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Recent withdrawals list
        const Text(
          'উত্তোলন হিস্ট্রি',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        if (controller.isLoadingWithdrawals.value)
          const Center(child: CircularProgressIndicator())
        else if (controller.withdrawals.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('কোনো উত্তোলনের রেকর্ড পাওয়া যায়নি।'),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.withdrawals.length,
            itemBuilder: (context, index) {
              final w = controller.withdrawals[index];
              final amt = (w['amount'] as num?)?.toDouble() ?? 0.0;
              final status = w['status'] ?? 'pending';
              final DateTime date = (w['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

              Color statusColor;
              String statusBangla;
              switch (status) {
                case 'approved':
                  statusColor = Colors.green;
                  statusBangla = 'অনুমোদিত';
                  break;
                case 'rejected':
                  statusColor = Colors.red;
                  statusBangla = 'প্রত্যাখ্যাত';
                  break;
                case 'pending':
                default:
                  statusColor = Colors.orange;
                  statusBangla = 'অপেক্ষমাণ';
                  break;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('৳${amt.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(
                          '${w['bankName']} (${w['accountNumber']})',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        Text(
                          DateFormat('dd MMM yyyy, hh:mm a').format(date),
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
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
              );
            },
          ),
      ],
    );
  }

  Widget _buildProductsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'আমার পণ্য তালিকা',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF08B3AC),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('নতুন পণ্য', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              onPressed: () {
                Get.to(() => const VendorAddProductScreen());
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (controller.isLoadingProducts.value)
          const Center(child: CircularProgressIndicator())
        else if (controller.vendorProducts.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 48.0),
              child: Text('আপনার কোনো পণ্য নেই। নতুন পণ্য যুক্ত করুন।'),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.vendorProducts.length,
            itemBuilder: (context, index) {
              final product = controller.vendorProducts[index];
              return VendorProductCard(
                product: product,
                onEdit: () {
                  Get.to(() => VendorAddProductScreen(product: product));
                },
                onDelete: () {
                  _showDeleteConfirmDialog(context, product.id!);
                },
                onToggleStatus: () {
                  controller.toggleVendorProductStatus(product.id!, product.status);
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildOrdersTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'অর্ডার তালিকা',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        if (controller.isLoadingOrders.value)
          const Center(child: CircularProgressIndicator())
        else if (controller.vendorOrders.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 48.0),
              child: Text('কোনো ভেন্ডর অর্ডার নেই।'),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.vendorOrders.length,
            itemBuilder: (context, index) {
              final order = controller.vendorOrders[index];
              return VendorOrderCard(
                order: order,
                vendorEarnings: order.resellerEarnings,
              );
            },
          ),
      ],
    );
  }

  void _showWithdrawalSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final numCtrl = TextEditingController();
    final bankCtrl = TextEditingController();
    final amtCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('ব্যালেন্স উত্তোলন ফর্ম'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'অ্যাকাউন্টের নাম'),
                ),
                TextField(
                  controller: numCtrl,
                  decoration: const InputDecoration(labelText: 'নম্বর / অ্যাকাউন্ট নম্বর'),
                ),
                TextField(
                  controller: bankCtrl,
                  decoration: const InputDecoration(labelText: 'ব্যাংক / গেটওয়ে নাম (যেমন: বিকাশ)'),
                ),
                TextField(
                  controller: amtCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'পরিমাণ (টাকা)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('বাতিল'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF08B3AC)),
              onPressed: () async {
                final double? amt = double.tryParse(amtCtrl.text.trim());
                if (nameCtrl.text.isEmpty ||
                    numCtrl.text.isEmpty ||
                    bankCtrl.text.isEmpty ||
                    amt == null ||
                    amt <= 0) {
                  Get.snackbar('ত্রুটি', 'সবগুলো তথ্য সঠিকভাবে দিন।');
                  return;
                }

                final success = await controller.requestWithdrawal(
                  accountName: nameCtrl.text.trim(),
                  accountNumber: numCtrl.text.trim(),
                  bankName: bankCtrl.text.trim(),
                  amount: amt,
                );
                if (success) {
                  Navigator.pop(context);
                }
              },
              child: const Text('অনুরোধ করুন', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('পণ্য মুছে ফেলা'),
        content: const Text('আপনি কি নিশ্চিত যে পণ্যটি তালিকা থেকে মুছে ফেলতে চান?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('বাতিল')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context);
              await controller.deleteVendorProduct(productId);
            },
            child: const Text('মুছুন', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
