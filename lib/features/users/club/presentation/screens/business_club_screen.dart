import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import 'package:trade_wign_bd/features/auth/presentation/screens/login_screen.dart';
import 'package:trade_wign_bd/features/common/profile/presentation/controllers/admin_profile_controller.dart';
import 'package:trade_wign_bd/features/users/club/presentation/widgets/universal_tree.dart';
import 'package:trade_wign_bd/features/users/club/presentation/widgets/role_badgets.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

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
    _tabController = TabController(length: 2, vsync: this);
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: RoleBadgets(userRole: _authController.currentUserRole.value),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Universal Tree Widget
                  rootCode == 'N/A' || rootCode.isEmpty
                      ? const Center(child: Text('রেফারেল কোড লোড হতে ব্যর্থ হয়েছে।'))
                      : UniversalTreeWidget(rootReferralCode: rootCode),

                  // Tab 2: Overview / Statistics Dashboard
                  _buildOverviewTab(profileController),
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
}
