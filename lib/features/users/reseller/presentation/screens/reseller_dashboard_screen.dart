import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import 'package:trade_wign_bd/features/auth/presentation/screens/login_screen.dart';
import 'package:trade_wign_bd/features/users/home/presentation/widgets/verification_dialog.dart';
import 'package:trade_wign_bd/features/users/reseller/presentation/controllers/reseller_controller.dart';
import 'package:trade_wign_bd/features/users/reseller/presentation/widgets/reseller_widgets.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class ResellerDashboardScreen extends StatefulWidget {
  const ResellerDashboardScreen({super.key});

  @override
  State<ResellerDashboardScreen> createState() => _ResellerDashboardScreenState();
}

class _ResellerDashboardScreenState extends State<ResellerDashboardScreen> {
  final ResellerController controller = Get.put(ResellerController());
  final AuthController _authController = Get.find<AuthController>();
  int _activeTabIndex = 0; // 0: Market, 1: Basket, 2: Orders, 3: Withdrawals

  Future<void> _checkAndHandleResellerStatus() async {
    final role = _authController.currentUserRole.value.toLowerCase().trim();
    
    // If user cancelled login or still guest, do nothing
    if (_authController.currentUserMobile.value.trim().isEmpty ||
        ['guest customer', 'guest', ''].contains(role)) {
      return;
    }

    // If already verified or admin, just rebuild to show dashboard
    if (role == 'reseller' || role == 'admin' || role == 'super admin') {
      setState(() {});
      return;
    }

    // Otherwise, check Firestore status
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final mobile = _authController.currentUserMobile.value.trim();
      final doc = await FirebaseFirestore.instance.collection('users').doc(mobile).get();
      Get.back(); // Dismiss loading

      if (doc.exists) {
        final data = doc.data() ?? {};
        final status = (data['resellerVerificationStatus'] ?? '').toString().toLowerCase().trim();

        if (status == 'approved') {
          _authController.currentUserRole.value = 'reseller';
          setState(() {}); // Rebuild to show dashboard
        } else if (status == 'pending' || status == 'hold' || status == 'rejected') {
          Get.back(); // Pop ResellerDashboardScreen
          Get.dialog(VerificationStatusDialog(targetRole: 'reseller', status: status));
        } else {
          Get.back(); // Pop ResellerDashboardScreen
          Get.dialog(const VerificationDialog(targetRole: 'reseller'));
        }
      } else {
        Get.back(); // Pop ResellerDashboardScreen
        Get.dialog(const VerificationDialog(targetRole: 'reseller'));
      }
    } catch (e) {
      Get.back(); // Dismiss loading
      Get.back(); // Pop ResellerDashboardScreen
      Get.snackbar(
        'ত্রুটি',
        'সার্ভার সংযোগে সমস্যা হয়েছে: $e',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'রিসেলার ড্যাশবোর্ড',
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
        final isGuest = _authController.currentUserMobile.value.trim().isEmpty ||
            ['guest customer', 'guest', ''].contains(_authController.currentUserRole.value.toLowerCase().trim());

        if (isGuest) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.storefront_outlined,
                      size: 80,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'রিসেলার ড্যাশবোর্ডে আপনাকে স্বাগতম!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'রিসেলিং পণ্য দেখতে এবং বিক্রি করতে অনুগ্রহ করে লগইন করুন।',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        Get.to(() => const LoginScreen(returnBack: true))?.then((value) {
                          _checkAndHandleResellerStatus();
                        });
                      },
                      child: const Text(
                        'লগইন করুন',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.resellerMobile.isEmpty) {
          return const Center(child: Text('অনুগ্রহ করে লগইন করুন।'));
        }
        return RefreshIndicator(
          onRefresh: () async {
            controller.setupListeners();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Stats Header Grid (Responsive layout)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 600;
                    return GridView.count(
                      crossAxisCount: isWide ? 4 : 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: isWide ? 2.0 : 2.1,
                      children: [
                        ResellerStatCard(
                          title: 'বিক্রির যোগ্য পণ্য',
                          value: '${controller.availableProductsCount.value} টি',
                          subtitle: 'উপলব্ধ পণ্য',
                          icon: Icons.storefront_outlined,
                          backgroundColor: const Color(0xFFFFF3E0),
                          borderColor: const Color(0xFFFFE0B2),
                          themeColor: const Color(0xFFE65100),
                        ),
                        ResellerStatCard(
                          title: 'বাসকেটের পণ্য',
                          value: '${controller.basketCount.value} টি',
                          subtitle: 'আমার বাসকেট',
                          icon: Icons.shopping_basket_outlined,
                          backgroundColor: const Color(0xFFE0F7FA),
                          borderColor: const Color(0xFFB2EBF2),
                          themeColor: const Color(0xFF00796B),
                        ),
                        ResellerStatCard(
                          title: 'পেন্ডিং অর্ডার',
                          value: '${controller.pendingOrdersCount.value} টি',
                          subtitle: 'অপেক্ষমাণ কাস্টমার অর্ডার',
                          icon: Icons.pending_actions_outlined,
                          backgroundColor: const Color(0xFFF3E5F5),
                          borderColor: const Color(0xFFE1BEE7),
                          themeColor: const Color(0xFF6A1B9A),
                        ),
                        ResellerStatCard(
                          title: 'সম্পন্ন অর্ডার',
                          value: '${controller.completedOrdersCount.value} টি',
                          subtitle: 'সফলভাবে ডেলিভারড',
                          icon: Icons.done_all_outlined,
                          backgroundColor: const Color(0xFFE8F5E9),
                          borderColor: const Color(0xFFC8E6C9),
                          themeColor: const Color(0xFF2E7D32),
                        ),
                        ResellerStatCard(
                          title: 'মোট অর্জিত লাভ',
                          value: '৳${controller.reactiveTotalProfit.value.toStringAsFixed(2)}',
                          subtitle: 'মোট অর্জিত লাভ',
                          icon: Icons.monetization_on_outlined,
                          backgroundColor: const Color(0xFFE8EAF6),
                          borderColor: const Color(0xFFC5CAE9),
                          themeColor: const Color(0xFF283593),
                        ),
                        ResellerStatCard(
                          title: 'উত্তোলনযোগ্য ব্যালেন্স',
                          value: '৳${controller.withdrawAvailableAmount.value.toStringAsFixed(2)}',
                          subtitle: 'উত্তোলনযোগ্য রিসেলার ব্যালেন্স',
                          icon: Icons.account_balance_wallet_outlined,
                          backgroundColor: const Color(0xFFFCE4EC),
                          borderColor: const Color(0xFFF8BBD0),
                          themeColor: const Color(0xFFC2185B),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // 2. Custom Styled Tab Switcher
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTabButton(0, 'পণ্য মার্কেট', Icons.store_rounded),
                        _buildTabButton(
                          1,
                          'আমার বাসকেট',
                          Icons.shopping_bag_rounded,
                        ),
                        _buildTabButton(
                          2,
                          'আমার অর্ডারসমূহ',
                          Icons.receipt_long_rounded,
                        ),
                        _buildTabButton(
                          3,
                          'উত্তোলন / লাভ',
                          Icons.monetization_on_rounded,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Tab Contents
                _buildActiveTabContent(),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primaryColor : Colors.black54,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? AppColors.primaryColor : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTabContent() {
    switch (_activeTabIndex) {
      case 0:
        return _buildMarketTab();
      case 1:
        return _buildBasketTab();
      case 2:
        return _buildOrdersTab();
      case 3:
        return _buildWithdrawalsTab();
      default:
        return const SizedBox();
    }
  }

  // MARK: - Tab Views

  Widget _buildMarketTab() {
    if (controller.isLoadingProducts.value) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.productsAvailable.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: Text('এই মুহূর্তে রিসেলার মূল্যের কোনো পণ্য উপলব্ধ নেই।'),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.productsAvailable.length,
      itemBuilder: (context, index) {
        final product = controller.productsAvailable[index];
        final isAdded = controller.basketItems.any(
          (item) => item['productId'] == product.id,
        );

        return MarketProductCard(
          product: product,
          isAdded: isAdded,
          onAddTap: () => controller.addToBasket(product),
          onRemoveTap: () => controller.removeFromBasket(product.id!),
        );
      },
    );
  }

  Widget _buildBasketTab() {
    if (controller.isLoadingBasket.value) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.basketItems.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: Text('আপনার বাসকেট খালি। পণ্য মার্কেট থেকে পণ্য যোগ করুন।'),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.basketItems.length,
      itemBuilder: (context, index) {
        final item = controller.basketItems[index];
        return BasketItemCard(
          item: item,
          onRemoveTap: () => controller.removeFromBasket(item['productId']),
          onUpdatePrice: (newPrice) =>
              controller.updateCustomPrice(item['productId'], newPrice),
        );
      },
    );
  }

  Widget _buildOrdersTab() {
    if (controller.isLoadingOrders.value) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.resellerOrders.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: Text('আপনার কোনো বিক্রয়কৃত অর্ডার নেই।'),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.resellerOrders.length,
      itemBuilder: (context, index) {
        final order = controller.resellerOrders[index];

        // Calculate profit dynamically from the items
        double profit = 0.0;
        for (var item in order.items) {
          final double customPrice = (item['price'] as num?)?.toDouble() ?? 0.0;
          final double vendorPrice =
              (item['vendorPrice'] as num?)?.toDouble() ?? 0.0;
          final int qty = (item['quantity'] as num?)?.toInt() ?? 1;

          if (vendorPrice > 0) {
            profit += (customPrice - vendorPrice) * qty;
          } else {
            // fallback cost margin
            profit += (customPrice * 0.15) * qty;
          }
        }

        return ResellerOrderCard(order: order, resellerProfit: profit);
      },
    );
  }

  Widget _buildWithdrawalsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profit summary & Request button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'উত্তোলনযোগ্য ব্যালেন্স',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    '৳${controller.withdrawAvailableAmount.value.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.outbox_rounded),
                  label: const Text(
                    'উত্তোলনের অনুরোধ পাঠান',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: controller.withdrawAvailableAmount.value > 0
                      ? () => _showWithdrawalRequestDialog(context)
                      : null,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'উত্তোলন ইতিহাস',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),

        if (controller.isLoadingWithdrawals.value)
          const Center(child: CircularProgressIndicator())
        else if (controller.withdrawals.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 30.0),
              child: Text('আপনার কোনো পূর্ববর্তী উত্তোলন রেকর্ড নেই।'),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.withdrawals.length,
            itemBuilder: (context, index) {
              final w = controller.withdrawals[index];
              return WithdrawalCard(w: w);
            },
          ),
      ],
    );
  }

  // MARK: - Sheets & Dialogs

  void _showWithdrawalRequestDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final numCtrl = TextEditingController();
    final bankCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'উত্তোলনের অনুরোধ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'অ্যাকাউন্ট নাম (Account Name)',
                  ),
                ),
                TextField(
                  controller: numCtrl,
                  decoration: const InputDecoration(
                    labelText: 'অ্যাকাউন্ট নম্বর / মোবাইল ব্যাংকিং নম্বর',
                  ),
                ),
                TextField(
                  controller: bankCtrl,
                  decoration: const InputDecoration(
                    labelText:
                        'ব্যাংক / গেটওয়ে নাম (যেমন: Bkash, Nagad, DBBL)',
                  ),
                ),
                TextField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'উত্তোলনের পরিমাণ (৳)',
                    helperText:
                        'সর্বোচ্চ: ৳${controller.withdrawAvailableAmount.value.toStringAsFixed(2)}',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('বাতিল', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
              onPressed: () async {
                final double? amt = double.tryParse(amountCtrl.text);
                if (nameCtrl.text.isEmpty ||
                    numCtrl.text.isEmpty ||
                    bankCtrl.text.isEmpty ||
                    amt == null ||
                    amt <= 0) {
                  Get.snackbar(
                    'ত্রুটি',
                    'দয়া করে সবগুলো তথ্য সঠিকভাবে প্রদান করুন।',
                  );
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
              child: const Text(
                'সাবমিট',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

}