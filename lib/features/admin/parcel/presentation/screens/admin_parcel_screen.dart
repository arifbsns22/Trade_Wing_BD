import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import 'package:trade_wign_bd/features/admin/settings/presentation/screens/admin_settings_screen.dart';
import 'package:trade_wign_bd/features/admin/settings/presentation/controllers/admin_settings_controller.dart';
import '../widgets/parcel_balance_card.dart';
import '../widgets/parcel_date_filter.dart';
import '../widgets/parcel_provider_card.dart';
import '../widgets/parcel_stats_grid.dart';

class AdminParcelScreen extends StatefulWidget {
  const AdminParcelScreen({super.key});

  @override
  State<AdminParcelScreen> createState() => _AdminParcelScreenState();
}

class _AdminParcelScreenState extends State<AdminParcelScreen> {
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
    _loadProviderStatus();
  }

  Future<void> _loadProviderStatus() async {
    final controller = Get.isRegistered<AdminSettingsController>()
        ? Get.find<AdminSettingsController>()
        : Get.put(AdminSettingsController());
    await controller.loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AdminSettingsController>()
        ? Get.find<AdminSettingsController>()
        : Get.put(AdminSettingsController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Ultra-premium soft background
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        color: AppColors.primaryColor,
        backgroundColor: Colors.white,
        strokeWidth: 2.5,
        onRefresh: () async {
          await _loadProviderStatus();
        },
        child: Obx(() {
          final bool isSteadfastActive = controller.isSteadfastActive.value;
          final int activeCount = isSteadfastActive ? 1 : 0;
          final int inactiveCount = 2 - activeCount;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Header Banner ───
                _buildHeaderBanner(),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Provider Summary Row ───
                      _buildProviderSummaryRow(
                        activeCount: activeCount,
                        inactiveCount: inactiveCount,
                      ),
                      const SizedBox(height: 24),

                      // ─── Merchant Balance Section ───
                      _sectionHeader('মার্চেন্ট ব্যালেন্স', subtitle: 'সক্রিয় প্রোভাইডারদের লাইভ অ্যাকাউন্ট ব্যালেন্স'),
                      const SizedBox(height: 12),
                      const ParcelBalanceCard(),
                      const SizedBox(height: 24),

                      // ─── All Providers Section ───
                      _sectionHeader('ডেলিভারি প্রোভাইডার সমূহ', subtitle: 'সংযুক্ত ও সম্ভাব্য ডেলিভারি গেটওয়েসমূহ'),
                      const SizedBox(height: 12),
                      ParcelProviderCard(
                        providerName: 'Steadfast Courier Limited',
                        description: 'স্টেডফাস্ট কুরিয়ার ডেলিভারি প্রোভাইডার',
                        isActive: isSteadfastActive,
                        icon: Icons.airport_shuttle_rounded,
                      ),
                    const SizedBox(height: 12),
                    const ParcelProviderCard(
                      providerName: 'পাঠাও কুরিয়ার (Pathao)',
                      description: 'পাঠাও ডেলিভারি প্রোভাইডার - শীঘ্রই আসছে',
                      isActive: false,
                      isPlaceholder: true,
                      icon: Icons.local_shipping_outlined,
                    ),
                    const SizedBox(height: 12),
                    const ParcelProviderCard(
                      providerName: 'রেডএক্স কুরিয়ার (RedX)',
                      description: 'রেডএক্স ডেলিভারি প্রোভাইডার - শীঘ্রই আসছে',
                      isActive: false,
                      isPlaceholder: true,
                      icon: Icons.delivery_dining_outlined,
                    ),
                    const SizedBox(height: 28),

                    // ─── Date Filter Section ───
                    _sectionHeader('পার্সেল রিপোর্ট ও পরিসংখ্যান', subtitle: 'নির্দিষ্ট তারিখ অনুযায়ী পার্সেলের লাইভ ট্র্যাকিং রিপোর্ট'),
                    const SizedBox(height: 12),
                    ParcelDateRangeFilter(
                      onApply: (from, to) {
                        setState(() {
                          _from = from;
                          _to = to;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // ─── Stats Grid ───
                    ParcelStatsGrid(from: _from, to: _to),
                    const SizedBox(height: 28),

                    // ─── Quick Settings Link ───
                    _buildSettingsLink(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    ),
  );
}

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        color: const Color(0xFF0F172A),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'পার্সেল ড্যাশবোর্ড',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0F172A),
          letterSpacing: -0.3,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            Get.to(() => const AdminSettingsScreen());
          },
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.settings_outlined,
              color: AppColors.primaryColor,
              size: 20,
            ),
          ),
          tooltip: 'ডেলিভারি সেটিংস',
        ),
        const SizedBox(width: 12),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.grey.shade100,
        ),
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withValues(alpha: 0.95),
            const Color(0xFF034D4A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.local_shipping_rounded,
              size: 110,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'কুরিয়ার পোর্টাল',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'পার্সেল ও কুরিয়ার ট্র্যাকিং',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'আপনার কুরিয়ার পার্টনারদের ব্যালেন্স ও ডেলিভারি স্ট্যাটাস রিয়েল-টাইমে পর্যবেক্ষণ করুন।',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProviderSummaryRow({
    required int activeCount,
    required int inactiveCount,
  }) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'সক্রিয় গেটওয়ে',
            value: activeCount.toString(),
            icon: Icons.check_circle_rounded,
            iconBg: Colors.green.shade50,
            iconColor: Colors.green,
            valueColor: Colors.green.shade700,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            label: 'নিষ্ক্রিয় গেটওয়ে',
            value: inactiveCount.toString(),
            icon: Icons.offline_bolt_rounded,
            iconBg: Colors.amber.shade50,
            iconColor: Colors.amber.shade800,
            valueColor: Colors.amber.shade800,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            label: 'মোট প্রোভাইডার',
            value: '3',
            icon: Icons.local_shipping_rounded,
            iconBg: AppColors.primaryColor.withValues(alpha: 0.08),
            iconColor: AppColors.primaryColor,
            valueColor: AppColors.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSettingsLink() {
    return GestureDetector(
      onTap: () => Get.to(() => const AdminSettingsScreen()),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primaryColor.withValues(alpha: 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.settings_suggest_rounded,
                color: AppColors.primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ডেলিভারি কনফিগারেশন পরিবর্তন করুন',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'এপিআই কী, সিক্রেট কী ও ডেলিভারি মেথড আপডেট করুন',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.primaryColor,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color valueColor;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: valueColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
