import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import 'package:trade_wign_bd/features/users/home/presentation/widgets/support_sheet.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/screens/order_history_screen.dart';
import '../controllers/wallet_controller.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _pointsToConvertCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showBalance = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pointsToConvertCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WalletController());
    final authCtrl = AuthController.instance;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'ডিজিটাল মানিব্যাগ',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1E293B),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFF1F5F9), height: 1),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF08B3AC)),
            ),
          );
        }

        final rate = controller.conversionRate.value;
        final netPoints = controller.netPoints.value;
        final takaVal = netPoints / rate;

        return RefreshIndicator(
          onRefresh: () => controller.loadAllData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Greeting Layout
                _buildHeaderGreeting(context, authCtrl),

                const SizedBox(height: 20),

                // 2. Soft Pastel Wallet Balance Card
                _buildBalanceCard(
                  context,
                  controller,
                  netPoints,
                  takaVal,
                  authCtrl,
                ),

                const SizedBox(height: 16),

                // 3. Quick Action Row Card
                _buildQuickActionsRow(context, controller, netPoints),

                const SizedBox(height: 24),

                // 4. Overview Section Title
                const Text(
                  'পয়েন্ট ওভারভিউ',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),

                // 5. Overview Cards (Side-by-Side)
                _buildOverviewCards(context, controller),

                const SizedBox(height: 28),

                // 6. History Section Tabs & Lists
                _buildHistorySection(context, controller),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeaderGreeting(BuildContext context, AuthController authCtrl) {
    final String name = authCtrl.currentUserName.value.isNotEmpty
        ? authCtrl.currentUserName.value
        : 'ইউজার';
    final String mobile = authCtrl.currentUserMobile.value;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFFCD34D), // Golden/Yellow circle
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.face_retouching_natural_rounded,
              color: Color(0xFF78350F),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'হ্যালো, $name',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  mobile,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Soft notification action
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF475569),
                size: 20,
              ),
              onPressed: () {
                // Info snackbar
                Get.snackbar(
                  'তথ্য',
                  'কোনো নতুন নোটিফিকেশন নেই',
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                  colorText: Colors.black87,
                  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
                  borderWidth: 1,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(16),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    WalletController controller,
    int netPoints,
    double takaVal,
    AuthController authCtrl,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFFBEB), // Soft light yellow
            Color(0xFFFEF3C7), // Light amber tint
            Color(0xFFFFF1F2), // Soft pink/rose tint
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFDE68A).withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFCD34D).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'মানিব্যাগ ব্যালেন্স',
                  style: TextStyle(
                    color: Color(0xFF78350F),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showBalance = !_showBalance;
                    });
                  },
                  child: Icon(
                    _showBalance
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: const Color(0xFF78350F).withValues(alpha: 0.7),
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _showBalance
                  ? '৳${controller.walletBalance.value.toStringAsFixed(2)}'
                  : '৳ ••••••••',
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 30,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  authCtrl.currentUserMobile.value,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF78350F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(text: authCtrl.currentUserMobile.value),
                    );
                    Get.snackbar(
                      'সফল',
                      'মোবাইল নাম্বার কপি করা হয়েছে',
                      backgroundColor: Colors.white.withValues(alpha: 0.9),
                      colorText: Colors.black87,
                      borderColor: const Color(
                        0xFF08B3AC,
                      ).withValues(alpha: 0.2),
                      borderWidth: 1,
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(16),
                    );
                  },
                  child: const Icon(
                    Icons.copy_rounded,
                    color: Color(0xFF78350F),
                    size: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsRow(
    BuildContext context,
    WalletController controller,
    int netPoints,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 1. Convert Points button
          _buildActionButton(
            icon: Icons.swap_horizontal_circle_outlined,
            label: 'পয়েন্ট কনভার্ট',
            onTap: () =>
                _showConversionBottomSheet(context, controller, netPoints),
          ),
          // Divider
          Container(height: 35, width: 1.5, color: const Color(0xFFF1F5F9)),
          // 2. Orders List button
          _buildActionButton(
            icon: Icons.receipt_long_rounded,
            label: 'অর্ডার সমূহ',
            onTap: () => Get.to(() => const OrderHistoryScreen()),
          ),
          // Divider
          Container(height: 35, width: 1.5, color: const Color(0xFFF1F5F9)),
          // 3. Support Helpline button
          _buildActionButton(
            icon: Icons.support_agent_rounded,
            label: 'হেল্পলাইন',
            onTap: () =>
                Get.bottomSheet(const SupportSheet(), isScrollControlled: true),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF0F172A), size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards(
    BuildContext context,
    WalletController controller,
  ) {
    return Row(
      children: [
        // Total Earned Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE6FDF9), // Soft Mint
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFCCFBF1), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'মোট অর্জিত পয়েন্ট',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D9488),
                      ),
                    ),
                    Icon(
                      Icons.stars_rounded,
                      color: const Color(0xFF0D9488).withValues(alpha: 0.8),
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${controller.totalEarnedPoints.value} PTS',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'কেনাকাটা থেকে অর্জিত',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF5F9E97),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Converted/Spent Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2), // Soft Rose
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFE4E6), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ব্যয়িত পয়েন্ট',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE11D48),
                      ),
                    ),
                    Icon(
                      Icons.autorenew_rounded,
                      color: const Color(0xFFE11D48).withValues(alpha: 0.8),
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${controller.spentPoints.value} PTS',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'টাকায় রূপান্তর করা হয়েছে',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9F5F6F),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection(
    BuildContext context,
    WalletController controller,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
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
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: const Color(0xFF08B3AC),
                unselectedLabelColor: const Color(0xFF64748B),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'লেনদেন সমূহ'),
                  Tab(text: 'পয়েন্ট অর্জন'),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 360,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionsList(controller),
                _buildPurchaseHistoryList(controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(WalletController controller) {
    if (controller.transactions.isEmpty) {
      return const Center(
        child: Text(
          'কোনো লেনদেন পাওয়া যায়নি',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.transactions.length,
      separatorBuilder: (context, index) =>
          const Divider(color: Color(0xFFF1F5F9), height: 16),
      itemBuilder: (context, index) {
        final tx = controller.transactions[index];
        final type = tx['type'] as String? ?? 'purchase';
        final isConversion = type == 'conversion';
        final double amount = (tx['amount'] ?? 0.0).toDouble();
        final date =
            (tx['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(date);

        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isConversion
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFFFE4E6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isConversion
                    ? Icons.south_west_rounded
                    : Icons.north_east_rounded,
                color: isConversion
                    ? const Color(0xFF15803D)
                    : const Color(0xFFBE123C),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isConversion ? 'পয়েন্ট রূপান্তর' : 'পণ্য ক্রয়',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isConversion ? "+" : "-"} ৳${amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: isConversion
                        ? const Color(0xFF15803D)
                        : const Color(0xFFBE123C),
                  ),
                ),
                if (isConversion)
                  Text(
                    '(${tx['points']} পয়েন্ট)',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildPurchaseHistoryList(WalletController controller) {
    if (controller.purchaseHistory.isEmpty) {
      return const Center(
        child: Text(
          'পয়েন্ট অর্জনের কোনো রেকর্ড নেই',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.purchaseHistory.length,
      separatorBuilder: (context, index) =>
          const Divider(color: Color(0xFFF1F5F9), height: 16),
      itemBuilder: (context, index) {
        final purchase = controller.purchaseHistory[index];
        final orderId = purchase['orderId'] as String;
        final double amount = purchase['amount'] as double;
        final int points = purchase['points'] as int;
        final date =
            (purchase['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        final dateStr = DateFormat('dd MMM yyyy').format(date);

        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.stars_rounded,
                color: Color(0xFFD97706),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'অর্ডার: $orderId',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'মূল্য: ৳${amount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '+$points PTS',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: Color(0xFFD97706),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showConversionBottomSheet(
    BuildContext context,
    WalletController controller,
    int netPoints,
  ) {
    _pointsToConvertCtrl.clear();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.swap_horizontal_circle_outlined,
                        color: Color(0xFF0284C7),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'পয়েন্ট রূপান্তর করুন',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'আপনার অর্জিত লয়্যালটি পয়েন্টকে টাকায় রূপান্তর করে মানিব্যাগে যুক্ত করুন।',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'মোট অর্জিত পয়েন্ট: $netPoints PTS',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF334155),
                      ),
                    ),
                    Text(
                      'কনভার্সন রেট: ${controller.conversionRate.value} PTS = ৳১',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0D9488),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pointsToConvertCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    labelText: 'পয়েন্ট সংখ্যা',
                    hintText: 'যেমন: ১০০',
                    fillColor: const Color(0xFFF8FAFC),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFF08B3AC),
                        width: 1.5,
                      ),
                    ),
                    suffixIcon: TextButton(
                      onPressed: () {
                        _pointsToConvertCtrl.text = '$netPoints';
                      },
                      child: const Text(
                        'সর্বোচ্চ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF08B3AC),
                        ),
                      ),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'পয়েন্ট সংখ্যা লিখুন';
                    }
                    final points = int.tryParse(val);
                    if (points == null || points <= 0) {
                      return 'সদস্য পয়েন্ট দিন';
                    }
                    if (points > netPoints) {
                      return 'পর্যাপ্ত পয়েন্ট নেই';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 4, 135, 131),
                          Color.fromARGB(255, 4, 99, 91),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final points = int.parse(
                            _pointsToConvertCtrl.text.trim(),
                          );
                          Get.back();
                          controller.convertPoints(points);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'কনভার্ট নিশ্চিত করুন',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
