import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import 'package:trade_wign_bd/features/auth/presentation/screens/login_screen.dart';
import 'package:trade_wign_bd/features/common/profile/presentation/controllers/admin_profile_controller.dart';
import 'package:trade_wign_bd/features/users/club/presentation/widgets/universal_tree.dart';
import 'package:trade_wign_bd/features/users/club/presentation/widgets/role_badgets.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import 'package:trade_wign_bd/features/users/club/data/models/user_badge_promot_model.dart';

class BusinessClubScreen extends StatefulWidget {
  const BusinessClubScreen({super.key});

  @override
  State<BusinessClubScreen> createState() => _BusinessClubScreenState();
}

class _BusinessClubScreenState extends State<BusinessClubScreen>
    with SingleTickerProviderStateMixin {
  final AuthController _authController = AuthController.instance;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isGuest =
        _authController.currentUserMobile.value.isEmpty ||
        _authController.currentUserRole.value == 'Guest Customer';

    // If the user is a guest, show a premium login prompt
    if (isGuest) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'বিজনেজ ক্লাব',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E293B),
          elevation: 0,
        ),
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
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
                    Icons.business_center_outlined,
                    size: 80,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'বিজনেজ ক্লাবে আপনাকে স্বাগতম!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'বিজনেজ ক্লাবে যোগ দিয়ে আপনার বিজনেজ নেটওয়ার্ক ও বোনাস ট্র্যাক করতে অনুগ্রহ করে লগইন করুন।',
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
                      Get.to(() => const LoginScreen(returnBack: true))?.then((
                        value,
                      ) {
                        // Rebuild after returning to see if logged in
                        setState(() {});
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
        ),
      );
    }

    // Instantiating Profile Controller to get user's referral code and metrics
    final AdminProfileController profileController = Get.put(
      AdminProfileController(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'বিজনেজ ক্লাব',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primaryColor,
          indicatorWeight: 3,
          tabs: const [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_tree_outlined),
                  SizedBox(width: 8),
                  Text('আমার নেটওয়ার্ক'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.dashboard_customize_outlined),
                  SizedBox(width: 8),
                  Text('সংক্ষিপ্ত বিবরণ'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.workspace_premium_outlined),
                  SizedBox(width: 8),
                  Text('প্রমোশন'),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: Obx(() {
        if (profileController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        final String rootCode = profileController.referralCode.value;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: RoleBadgets(
                userRole: _authController.currentUserRole.value,
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Universal Tree Widget
                  rootCode == 'N/A' || rootCode.isEmpty
                      ? const Center(
                          child: Text('রেফারেল কোড লোড হতে ব্যর্থ হয়েছে।'),
                        )
                      : UniversalTreeWidget(rootReferralCode: rootCode),

                  // Tab 2: Overview / Statistics Dashboard
                  _buildOverviewTab(profileController),

                  // Tab 3: Promotion Tab
                  _buildPromotionTab(profileController),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildOverviewTab(AdminProfileController controller) {
    String formatCardNumber(String code) {
      if (code == 'N/A' || code.isEmpty) return code;
      String spaced = '';
      for (int i = 0; i < code.length; i++) {
        spaced += code[i];
        if (i == 3 || i == 7) {
          spaced += '   ';
        } else {
          spaced += ' ';
        }
      }
      return spaced.toUpperCase();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Intro Card styled as a premium Credit Card
          AspectRatio(
            aspectRatio: 1.586, // Standard Credit Card proportions
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0F172A), // Midnight Dark Slate
                    Color(0xFF1E1B4B), // Deep Imperial Indigo/Purple
                    Color(0xFF2E1065), // Royal Violet
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E1B4B).withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // Concentric Gold Watermark Rings (Royal Branding Detail)
                    Positioned(
                      top: -80,
                      right: -80,
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(
                              0xFFFBBF24,
                            ).withValues(alpha: 0.08),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(
                              0xFFFBBF24,
                            ).withValues(alpha: 0.05),
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -100,
                      left: -40,
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(
                              0xFFFBBF24,
                            ).withValues(alpha: 0.05),
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),

                    // Card Contents
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top Row: Royal Shield Crest, Brand & Gold Chip
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFFBBF24,
                                      ).withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons
                                          .workspace_premium, // Gold premium crest icon
                                      color: Color(0xFFFBBF24),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'TRADE WIGN BD',
                                        style: TextStyle(
                                          color: Color(
                                            0xFFFBBF24,
                                          ), // Royal Gold
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 2.0,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black45,
                                              offset: Offset(0, 1.5),
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'BUSINESS CLUB MEMBERSHIP',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // Gold SIM chip
                              Container(
                                width: 42,
                                height: 32,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFDE047),
                                      Color(0xFFCA8A04),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black26,
                                      width: 0.8,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: GridView.count(
                                    crossAxisCount: 3,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    children: List.generate(
                                      6,
                                      (i) => Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.black12,
                                            width: 0.4,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Middle Row: Spaced Card Number (Business Code)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'আপনার বিজনেজ কোড',
                                style: TextStyle(
                                  color: Color(0xFFFBBF24), // Shiny gold label
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                formatCardNumber(controller.referralCode.value),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800, // Thick emboss
                                  letterSpacing: 2.0,
                                  fontFamily:
                                      'Courier', // Monospaced credit card look
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // Bottom Row: Holder Name, Mobile & Copy Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Left: Name
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'CARD HOLDER',
                                      style: TextStyle(
                                        color: Color(0xFFFBBF24), // Gold label
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      controller.name.value.toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black45,
                                            offset: Offset(0, 1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Middle: Mobile
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'MOBILE',
                                      style: TextStyle(
                                        color: Color(0xFFFBBF24), // Gold label
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      controller.mobile.value,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black45,
                                            offset: Offset(0, 1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Right: Gold Glassmorphic Copy Button
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: controller.copyReferralCode,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFFBBF24,
                                      ).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(
                                          0xFFFBBF24,
                                        ).withValues(alpha: 0.4),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.copy,
                                          size: 14,
                                          color: Color(0xFFFBBF24),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'কপি',
                                          style: TextStyle(
                                            color: Color(0xFFFBBF24),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'আমার পরিসংখ্যান',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  Icons.card_giftcard,
                  'রিওয়ার্ড পয়েন্ট',
                  '${controller.totalRewardPoints.value} Pt',
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  Icons.shopping_bag_outlined,
                  'মোট ক্রয়মূল্য',
                  '৳${controller.totalPurchasedAmount.value.toStringAsFixed(1)}',
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Business Club Information/Guide
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primaryColor),
                    const SizedBox(width: 8),
                    const Text(
                      'বিজনেজ ক্লাব কীভাবে কাজ করে?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildGuideStep(
                  '১',
                  'আপনার নিজস্ব বিজনেজ কোডটি কপি করে বন্ধুদের সাথে শেয়ার করুন।',
                ),
                _buildGuideStep(
                  '২',
                  'তারা আপনার কোড দিয়ে রেজিস্ট্রেশন করলে তারা আপনার ডাউনলাইন নেটওয়ার্কের ১ম স্তরে যুক্ত হবে।',
                ),
                _buildGuideStep(
                  '৩',
                  'আপনার ডাউনলাইনের সদস্যরা কোনো কেনাকাটা করলে আপনার অ্যাকাউন্টে স্বয়ংক্রিয়ভাবে রিওয়ার্ড বোনাস যোগ হবে।',
                ),
                _buildGuideStep(
                  '৪',
                  'আপনার নেটওয়ার্ক যত বড় হবে, আপনার প্যাসিভ ইনকাম ও পদোন্নতির সুযোগ তত বৃদ্ধি পাবে।',
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideStep(
    String step,
    String description, {
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Column: Step Badge and Vertical Line
          Column(
            children: [
              // Circular Badge
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryColor.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  step,
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              // Connecting Line
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.primaryColor.withValues(alpha: 0.15),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Right Column: Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC), // soft slate white card
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF334155),
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionTab(AdminProfileController controller) {
    return FutureBuilder<Map<String, dynamic>>(
      future: UserBadgePromoteService.fetchPromotionMetrics(
        _authController.currentUserMobile.value,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError ||
            snapshot.data == null ||
            snapshot.data!['success'] == false) {
          final err =
              snapshot.data?['message'] ?? 'তথ্য লোড করতে সমস্যা হয়েছে।';
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                err,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final String currentRole = data['role'] ?? 'Customer';
        final bool packagePurchased = data['packagePurchased'] ?? false;
        final int directCustomers = data['directCustomers'] ?? 0;
        final int activeCustomers = data['activeCustomers'] ?? 0;
        final int brandPromoters = data['brandPromoters'] ?? 0;
        final int salesPartners = data['salesPartners'] ?? 0;
        final int seniorSalesPartners = data['seniorSalesPartners'] ?? 0;
        final int subDealers = data['subDealers'] ?? 0;
        final int dealers = data['dealers'] ?? 0;
        final int seniorDealers = data['seniorDealers'] ?? 0;
        final int masterDealers = data['masterDealers'] ?? 0;

        final currentIdx = UserBadgePromoteService.badgesSequence.indexWhere(
          (b) =>
              b.badgeName.toLowerCase().trim() ==
              currentRole.toLowerCase().trim(),
        );

        if (currentIdx == -1) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 64,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'আপনার বর্তমান ব্যাজ: $currentRole',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'বিশেষ রোল (যেমন: এডমিন, ভেন্ডর, রিসেলার) সমূহের জন্য প্রমোশন প্রোগ্রাম প্রযোজ্য নয়।',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        final currentBadge = UserBadgePromoteService.badgesSequence[currentIdx];

        if (currentIdx >= UserBadgePromoteService.badgesSequence.length - 1) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.workspace_premium,
                    size: 80,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'অভিনন্দন! আপনি সর্বোচ্চ ব্যাজে আছেন!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'আপনার বর্তমান ব্যাজ: ${currentBadge.banglaLabel}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'আপনি মেম্বারশিপ এবং নেটওয়ার্কের সর্বোচ্চ ধাপে পৌঁছে গেছেন। আমাদের সাথে থাকার জন্য ধন্যবাদ!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, height: 1.5),
                  ),
                ],
              ),
            ),
          );
        }

        final nextBadge =
            UserBadgePromoteService.badgesSequence[currentIdx + 1];

        // List of conditions to build
        final List<Map<String, dynamic>> conditionsList = [];

        // 1. Package Purchase
        if (nextBadge.requiresPackagePurchase) {
          conditionsList.add({
            'name': 'প্যাকেজ ক্রয়',
            'current': packagePurchased ? 1 : 0,
            'target': 1,
            'unit': 'ক্রয়',
            'isBool': true,
          });
        }

        // 2. Direct Customers
        if (nextBadge.requiredDirectCustomers > 0) {
          conditionsList.add({
            'name': 'সরাসরি কাস্টমার রেফার',
            'current': directCustomers,
            'target': nextBadge.requiredDirectCustomers,
            'unit': 'জন',
            'isBool': false,
          });
        }

        // 3. Active Customers
        if (nextBadge.requiredActiveCustomers > 0) {
          conditionsList.add({
            'name': 'সক্রিয় কাস্টমার (ডাউনলাইন)',
            'current': activeCustomers,
            'target': nextBadge.requiredActiveCustomers,
            'unit': 'জন',
            'isBool': false,
          });
        }

        // 4. Brand Promoters
        if (nextBadge.requiredBrandPromoters > 0) {
          conditionsList.add({
            'name': 'ব্র্যান্ড প্রমোটার (ডাউনলাইন)',
            'current': brandPromoters,
            'target': nextBadge.requiredBrandPromoters,
            'unit': 'জন',
            'isBool': false,
          });
        }

        // 5. Sales Partners
        if (nextBadge.requiredSalesPartners > 0) {
          conditionsList.add({
            'name': 'সেলস পার্টনার (ডাউনলাইন)',
            'current': salesPartners,
            'target': nextBadge.requiredSalesPartners,
            'unit': 'জন',
            'isBool': false,
          });
        }

        // 6. Senior Sales Partners
        if (nextBadge.requiredSeniorSalesPartners > 0) {
          conditionsList.add({
            'name': 'সিনিয়র সেলস পার্টনার',
            'current': seniorSalesPartners,
            'target': nextBadge.requiredSeniorSalesPartners,
            'unit': 'জন',
            'isBool': false,
          });
        }

        // 7. Sub Dealers
        if (nextBadge.requiredSubDealers > 0) {
          conditionsList.add({
            'name': 'সাব ডিলার (ডাউনলাইন)',
            'current': subDealers,
            'target': nextBadge.requiredSubDealers,
            'unit': 'জন',
            'isBool': false,
          });
        }

        // 8. Dealers
        if (nextBadge.requiredDealers > 0) {
          conditionsList.add({
            'name': 'ডিলার (ডাউনলাইন)',
            'current': dealers,
            'target': nextBadge.requiredDealers,
            'unit': 'জন',
            'isBool': false,
          });
        }

        // 9. Senior Dealers
        if (nextBadge.requiredSeniorDealers > 0) {
          conditionsList.add({
            'name': 'সিনিয়র ডিলার (ডাউনলাইন)',
            'current': seniorDealers,
            'target': nextBadge.requiredSeniorDealers,
            'unit': 'জন',
            'isBool': false,
          });
        }

        // 10. Master Dealers
        if (nextBadge.requiredMasterDealers > 0) {
          conditionsList.add({
            'name': 'মাস্টার ডিলার (ডাউনলাইন)',
            'current': masterDealers,
            'target': nextBadge.requiredMasterDealers,
            'unit': 'জন',
            'isBool': false,
          });
        }

        double totalProgressSum = 0.0;
        for (var cond in conditionsList) {
          final double p = cond['target'] > 0
              ? (cond['current'] / cond['target']).clamp(0.0, 1.0)
              : 0.0;
          totalProgressSum += p;
        }

        final double overallProgress = conditionsList.isNotEmpty
            ? totalProgressSum / conditionsList.length
            : 0.0;
        final int score = (overallProgress * 100).round();

        final isQualified = nextBadge.isQualified(
          packagePurchased: packagePurchased,
          directCustomers: directCustomers,
          activeCustomers: activeCustomers,
          brandPromoters: brandPromoters,
          salesPartners: salesPartners,
          seniorSalesPartners: seniorSalesPartners,
          subDealers: subDealers,
          dealers: dealers,
          seniorDealers: seniorDealers,
          masterDealers: masterDealers,
        );

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 16.0,
            bottom: 80.0,
          ),
          child: Column(
            children: [
              // Premium Card Container matching the requested design
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.white, Color(0xFFFBFDFD)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: const Color(0xFFEEF2F6), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF08B3AC).withValues(alpha: 0.04), // soft brand color glow
                      blurRadius: 32,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Header Row: Title & Next Target
                    Row(
                      children: [
                        // Neon/Vibrant Rounded Icon Container
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111827), // deep premium dark
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getIconForName(nextBadge.iconName),
                            color: const Color(0xFFD4FC34), // Neon green/lime
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'প্রমোশন স্কোর',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'লক্ষ্য: ${nextBadge.banglaLabel}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Central Radial Dashed Arc Progress Dial
                    Center(
                      child: SizedBox(
                        width: 220,
                        height: 210,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Soft glow halo behind the score
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFF84CC16).withValues(alpha: 0.08),
                                    const Color(0xFF84CC16).withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                            // Dashed Arc CustomPaint
                            Positioned.fill(
                              child: CustomPaint(
                                painter: ArcProgressPainter(
                                  progress: overallProgress,
                                ),
                              ),
                            ),
                            // Score text and stats in the middle of Arc
                            Padding(
                              padding: const EdgeInsets.only(top: 24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$score',
                                    style: const TextStyle(
                                      fontSize: 60,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF111827),
                                      letterSpacing: -1.5,
                                      height: 1.0,
                                    ),
                                  ),
                                  const Text(
                                    'out of 100',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF9CA3AF),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Score vs Avg Neon Capsule Pill
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFF3FAD6,
                                      ), // light neon green background
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.arrow_upward,
                                          size: 11,
                                          color: Color(0xFF84CC16),
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          '$score% অর্জিত',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF4F7A0F),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Arc extreme limits labels
                            const Positioned(
                              left: 36,
                              bottom: 12,
                              child: Text(
                                '0',
                                style: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Positioned(
                              right: 36,
                              bottom: 12,
                              child: Text(
                                '100',
                                style: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Middle Description / Motivation Text
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF4B5563),
                              height: 1.5,
                            ),
                            children: [
                              const TextSpan(text: 'আপনার পরবর্তী ব্যাজ '),
                              TextSpan(
                                text: nextBadge.banglaLabel,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const TextSpan(
                                text: ' অর্জনের জন্য আপনার অর্জিত স্কোর ',
                              ),
                              TextSpan(
                                text: '$score%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF84CC16),
                                ),
                              ),
                              const TextSpan(text: 'সম্পন্ন হয়েছে।'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Color(0xFFF1F5F9), height: 1),
                    const SizedBox(height: 24),

                    // Section Header: WHAT SHAPED IT
                    const Text(
                      'অগ্রগতির বিবরণ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9CA3AF),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // List of horizontal progress bars matching reference
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: conditionsList.length,
                      itemBuilder: (context, index) {
                        final cond = conditionsList[index];
                        final double condProgress = cond['target'] > 0
                            ? (cond['current'] / cond['target']).clamp(0.0, 1.0)
                            : 0.0;
                        final bool isDone = cond['current'] >= cond['target'];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: isDone
                                ? const Color(0xFFF0FDF4) // Soft mint green background
                                : const Color(0xFFF8FAFC), // Soft slate background
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDone
                                  ? const Color(0xFFBBF7D0) // Light green border
                                  : const Color(0xFFE2E8F0), // Light slate border
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Condition Name
                              Expanded(
                                flex: 3,
                                child: Text(
                                  cond['name'],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isDone ? const Color(0xFF166534) : const Color(0xFF374151),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Capsule progress bar
                              Expanded(
                                flex: 4,
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: isDone ? const Color(0xFFDCFCE7) : const Color(0xFFE2E8F0),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      widthFactor: condProgress,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: isDone
                                                ? [const Color(0xFF10B981), const Color(0xFF84CC16)] // Emerald to Lime
                                                : [const Color(0xFF3B82F6), const Color(0xFF08B3AC)], // Blue to Teal
                                          ),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Score/Real Numbers
                              SizedBox(
                                width: cond['isBool'] ? 60 : 70,
                                child: Text(
                                  cond['isBool']
                                      ? (isDone ? 'সম্পন্ন' : 'অসম্পন্ন')
                                      : '${cond['current']}/${cond['target']}',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: isDone ? const Color(0xFF166534) : const Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isQualified
                        ? AppColors.green
                        : Colors.grey.shade300,
                    foregroundColor: isQualified
                        ? Colors.white
                        : Colors.grey.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: isQualified ? 2 : 0,
                  ),
                  onPressed: isQualified
                      ? () async {
                          Get.dialog(
                            const Center(child: CircularProgressIndicator()),
                            barrierDismissible: false,
                          );
                          final res =
                              await UserBadgePromoteService.checkAndPromoteUser(
                                _authController.currentUserMobile.value,
                              );
                          Get.back(); // Dismiss loading
                          if (res['success'] == true) {
                            Get.defaultDialog(
                              title: 'অভিনন্দন! 🎉',
                              content: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                child: Text(
                                  res['message'],
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              confirm: ElevatedButton(
                                onPressed: () {
                                  Get.back();
                                  setState(() {}); // Rebuild
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                ),
                                child: const Text(
                                  'ঠিক আছে',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          } else {
                            Get.snackbar(
                              'প্রমোশন ব্যর্থ',
                              res['message'],
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.9,
                              ),
                              colorText: Colors.black87,
                              borderColor: const Color(
                                0xFF08B3AC,
                              ).withValues(alpha: 0.2),
                              borderWidth: 1,
                              snackPosition: SnackPosition.BOTTOM,
                              margin: const EdgeInsets.all(16),
                            );
                          }
                        }
                      : null,
                  child: Text(
                    isQualified ? 'ব্যাজ আপগ্রেড করুন' : 'শর্তাবলী পূরণ হয়নি',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconForName(String name) {
    switch (name) {
      case 'person_outline':
        return Icons.person_outline;
      case 'shopping_bag_outlined':
        return Icons.shopping_bag_outlined;
      case 'campaign_outlined':
        return Icons.campaign_outlined;
      case 'handshake_outlined':
        return Icons.handshake_outlined;
      case 'business_center_outlined':
        return Icons.business_center_outlined;
      case 'storefront_outlined':
        return Icons.storefront_outlined;
      case 'store_outlined':
        return Icons.store_outlined;
      case 'domain_outlined':
        return Icons.domain_outlined;
      case 'workspace_premium_outlined':
        return Icons.workspace_premium_outlined;
      case 'local_shipping_outlined':
        return Icons.local_shipping_outlined;
      default:
        return Icons.verified;
    }
  }
}

class ArcProgressPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0

  ArcProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 10);
    final radius = math.min(size.width, size.height) / 2 - 16;

    // Paint for background inactive dashes
    final inactivePaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Sweeping angle from 140 degrees to 400 degrees (260 degree sweep)
    const double startAngle = 140 * math.pi / 180;
    const double sweepAngle = 260 * math.pi / 180;

    // Number of dashes to draw
    const int totalDashes = 36;
    final int activeDashes = (progress * totalDashes).round();

    for (int i = 0; i < totalDashes; i++) {
      final double angle = startAngle + (i / (totalDashes - 1)) * sweepAngle;

      // Draw each dash as a small line segment along the circle path
      final double innerRadius = radius - 8;
      final double outerRadius = radius + 2;

      final double innerX = center.dx + innerRadius * math.cos(angle);
      final double innerY = center.dy + innerRadius * math.sin(angle);
      final double outerX = center.dx + outerRadius * math.cos(angle);
      final double outerY = center.dy + outerRadius * math.sin(angle);

      final isDashActive = i < activeDashes && activeDashes > 0;
      
      // Calculate color dynamically for active dashes (Lerping from Cyan to Lime Green)
      final Color activeColor = Color.lerp(
        const Color(0xFF06B6D4), // Soft Cyan
        const Color(0xFF84CC16), // Lime Green
        i / totalDashes,
      )!;

      final paintToUse = isDashActive
          ? (Paint()
            ..color = activeColor
            ..strokeWidth = 4.5
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round)
          : inactivePaint;

      canvas.drawLine(
        Offset(innerX, innerY),
        Offset(outerX, outerY),
        paintToUse,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
