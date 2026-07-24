import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import 'package:trade_wign_bd/features/auth/presentation/screens/login_screen.dart';
import '../controllers/user_drive_pack_controller.dart';
import '../widgets/operator_offers_display_list.dart';
import '../widgets/mobile_recharge.dart';
import 'mobile_recharge_screens.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class UserDrivePackScreen extends StatefulWidget {
  const UserDrivePackScreen({super.key});

  @override
  State<UserDrivePackScreen> createState() => _UserDrivePackScreenState();
}

class _UserDrivePackScreenState extends State<UserDrivePackScreen> {
  final _controller = Get.put(UserDrivePackController());
  final _authController = Get.find<AuthController>();

  String _getRoleLabel(String roleKey) {
    final normalized = roleKey.trim().toLowerCase();
    switch (normalized) {
      case 'customer':
        return 'কাস্টমার';
      case 'active customer':
        return 'সক্রিয় কাস্টমার';
      case 'brand promoter':
        return 'ব্র্যান্ড প্রমোটার';
      case 'sales partner':
        return 'সেলস পার্টনার';
      case 'senior sales partner':
        return 'সিনিয়র সেলস পার্টনার';
      case 'sub dealer':
        return 'সাব ডিলার';
      case 'dealer':
        return 'ডিলার';
      case 'senior dealer':
        return 'সিনিয়র ডিলার';
      case 'master dealer':
        return 'মাস্টার ডিলার';
      case 'regional distributor':
        return 'রিজিওনাল ডিস্ট্রিবিউটর';
      default:
        return roleKey;
    }
  }

  IconData _getRoleIcon(String roleKey) {
    final normalized = roleKey.trim().toLowerCase();
    switch (normalized) {
      case 'customer':
        return Icons.person_outline;
      case 'active customer':
        return Icons.shopping_bag_outlined;
      case 'brand promoter':
        return Icons.campaign_outlined;
      case 'sales partner':
        return Icons.handshake_outlined;
      case 'senior sales partner':
        return Icons.business_center_outlined;
      case 'sub dealer':
        return Icons.storefront_outlined;
      case 'dealer':
        return Icons.store_outlined;
      case 'senior dealer':
        return Icons.domain_outlined;
      case 'master dealer':
        return Icons.workspace_premium_outlined;
      case 'regional distributor':
        return Icons.local_shipping_outlined;
      default:
        return Icons.person_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.green, const Color(0xFF0D9488)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'ড্রাইভ প্যাকেজ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),

      ),
      body: Obx(() {
        final isGuest = _authController.currentUserMobile.value.isEmpty ||
            _authController.currentUserRole.value.toLowerCase() == 'guest customer';

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
                      Icons.phone_iphone_outlined,
                      size: 80,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'ড্রাইভ প্যাকেজে আপনাকে স্বাগতম!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ড্রাইভ অফার দেখতে এবং রিচার্জ করতে অনুগ্রহ করে লগইন করুন।',
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
          );
        }

        if (_controller.isLoading.value && _controller.operators.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF08B3AC)),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Premium User Membership Card Banner
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientTtBWithPrimary,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.25),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    children: [
                      // Decorative background circles
                      Positioned(
                        right: -30,
                        top: -30,
                        child: CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      Positioned(
                        right: 20,
                        bottom: -40,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white.withValues(alpha: 0.03),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'নিরাপদে ও সহজে নানান অফার উপভোগ করুন',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Obx(() {
                                    final roleKey =
                                        _authController.currentUserRole.value;
                                    return Row(
                                      children: [
                                        Icon(
                                          _getRoleIcon(roleKey),
                                          color: const Color(
                                            0xFFFCD34D,
                                          ), // Golden highlight
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _getRoleLabel(roleKey),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                  const SizedBox(height: 8),
                                  Text(
                                    'বিশেষ ক্যাশব্যাক এবং আকর্ষণীয় রিচার্জ অফার উপভোগ করুন!',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.workspace_premium,
                                color: Color(0xFFFCD34D),
                                size: 36,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const QuickRechargeWidget(),
              const SizedBox(height: 16),

              // 2. Operator Select Row Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'মোবাইল অপারেটর সমূহ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 98,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _controller.operators.length,
                  itemBuilder: (context, index) {
                    final operator = _controller.operators[index];
                    return Obx(() {
                      final isSelected =
                          _controller.selectedOperatorId.value == operator.id;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                        child: GestureDetector(
                          onTap: () {
                            _controller.selectedOperatorId.value = operator.id;
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 78,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.green
                                    : const Color(0xFFE2E8F0),
                                width: isSelected ? 1.8 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.green.withValues(alpha: 0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Opacity(
                              opacity: isSelected ? 1.0 : 0.65,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.green
                                                : Colors.grey.shade100,
                                            width: 1,
                                          ),
                                        ),
                                        child: SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: ClipOval(
                                            child: Image.network(
                                              operator.logoUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, e, s) =>
                                                  const Icon(Icons.cell_tower),
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: AppColors.green,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 1),
                                            ),
                                            child: const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 8,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    operator.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? AppColors.green
                                          : const Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),

              const SizedBox(height: 16),

              // 4. Category Choice Chips & All Offers for Selected Operator
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() {
                          final opName =
                              _controller.selectedOperator?.name ?? 'অপারেটর';
                          return Row(
                            children: [
                              Container(
                                width: 4,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: AppColors.green,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$opName অফার সমূহ',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          );
                        }),
                        const SizedBox(height: 12),
                        // Category chips
                        SizedBox(
                          height: 38,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            children: ['All', 'Combo', 'Internet', 'Minutes']
                                .map((cat) {
                                  return Obx(() {
                                    final isSel =
                                        _controller.selectedCategory.value ==
                                        cat;
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: ChoiceChip(
                                        label: Text(
                                          cat == 'All' ? 'সব' : cat,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isSel
                                                ? Colors.white
                                                : Colors.black87,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        selected: isSel,
                                        selectedColor: AppColors.green,
                                        backgroundColor: Colors.grey.shade100,
                                        onSelected: (selected) {
                                          if (selected) {
                                            _controller.selectedCategory.value =
                                                cat;
                                          }
                                        },
                                      ),
                                    );
                                  });
                                })
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      final opId = _controller.selectedOperatorId.value;
                      if (opId.isEmpty) {
                        return const Center(
                          child: Text('অপারেটর লোড হচ্ছে...'),
                        );
                      }
                      return OperatorOffersDisplayList(operatorId: opId);
                    }),
                  ],
                ),
              ),
            

              // 3. Recently Added (4x2 matrix)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.green,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'সম্প্রতি যুক্ত করা অফার',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Get.to(() => const AllOffersListScreen());
                      },
                      child: Row(
                        children: [
                          Text(
                            'আরও দেখুন',
                            style: TextStyle(
                              color: AppColors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Obx(() {
                final recentList = _controller.recentOffers;
                if (recentList.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('কোনো সাম্প্রতিক অফার নেই।'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.28,
                  ),
                  itemCount: recentList.length,
                  itemBuilder: (context, idx) {
                    final offer = recentList[idx];
                    final op = _controller.operators.firstWhereOrNull(
                      (o) => o.id == offer.operatorId,
                    );
                    final double cashback = offer.price - offer.offerPrice;

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.015),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () {
                            Get.to(
                              () => MobileRechargeScreen(prefilledOffer: offer),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header: Operator & Type
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (op != null)
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.grey.shade100,
                                            width: 1,
                                          ),
                                        ),
                                        child: ClipOval(
                                          child: Image.network(
                                            op.logoUrl,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    else
                                      const Icon(Icons.phone_iphone, size: 16, color: Colors.grey),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: offer.packageType == 'Internet'
                                            ? const Color(0xFFE6FDF9)
                                            : offer.packageType == 'Minutes'
                                                ? const Color(0xFFEFF6FF)
                                                : const Color(0xFFFFF7ED),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        offer.packageType,
                                        style: TextStyle(
                                          color: offer.packageType == 'Internet'
                                              ? const Color(0xFF0D9488)
                                              : offer.packageType == 'Minutes'
                                                  ? const Color(0xFF2563EB)
                                                  : const Color(0xFFEA580C),
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Title
                                Text(
                                  offer.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                // Description (fills blank space beautifully)
                                Text(
                                  offer.description.isNotEmpty 
                                      ? offer.description 
                                      : 'অফারটির বিবরণ পেতে ক্লিক করুন',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: Colors.grey.shade500,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                // Footer details
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '৳${offer.offerPrice}',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.green,
                                              ),
                                            ),
                                            if (offer.price > offer.offerPrice) ...[
                                              const SizedBox(width: 4),
                                              Text(
                                                '৳${offer.price.toInt()}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey.shade400,
                                                  decoration: TextDecoration.lineThrough,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        if (cashback > 0)
                                          Text(
                                            '৳${cashback.toInt()} ক্যাশব্যাক',
                                            style: const TextStyle(
                                              fontSize: 9,
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        offer.validity,
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),

              const SizedBox(height: 16),


],
          ),
        );
      }),
    );
  }
}

/// See More / Infinite Vertical List Page for Drive Offers
class AllOffersListScreen extends StatefulWidget {
  const AllOffersListScreen({super.key});

  @override
  State<AllOffersListScreen> createState() => _AllOffersListScreenState();
}

class _AllOffersListScreenState extends State<AllOffersListScreen> {
  final _controller = Get.find<UserDrivePackController>();
  final _scrollController = ScrollController();
  final int _pageSize = 10;
  final RxInt _visibleCount = 10.obs;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (_visibleCount.value < _controller.filteredOffers.length) {
          _visibleCount.value += _pageSize;
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _getRoleLabelsJoined(List<String> roles) {
    return roles.map((r) => _getRoleLabel(r)).join(', ');
  }

  String _getRoleLabel(String roleKey) {
    final normalized = roleKey.trim().toLowerCase();
    switch (normalized) {
      case 'customer':
        return 'কাস্টমার';
      case 'active customer':
        return 'সক্রিয় কাস্টমার';
      case 'brand promoter':
        return 'ব্র্যান্ড প্রমোটার';
      case 'sales partner':
        return 'সেলস পার্টনার';
      case 'senior sales partner':
        return 'সিনিয়র সেলস পার্টনার';
      case 'sub dealer':
        return 'সাব ডিলার';
      case 'dealer':
        return 'ডিলার';
      case 'senior dealer':
        return 'সিনিয়র ডিলার';
      case 'master dealer':
        return 'মাস্টার ডিলার';
      case 'regional distributor':
        return 'রিজিওনাল ডিস্ট্রিবিউটর';
      default:
        return roleKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.green, const Color(0xFF0D9488)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'সকল ড্রাইভ অফার তালিকা',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Filter section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['All', 'Combo', 'Internet', 'Minutes'].map((cat) {
                return Obx(() {
                  final isSel = _controller.selectedCategory.value == cat;
                  return ChoiceChip(
                    label: Text(
                      cat == 'All' ? 'সব অফার' : cat,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSel ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    selected: isSel,
                    selectedColor: AppColors.green,
                    backgroundColor: Colors.grey.shade100,
                    onSelected: (selected) {
                      if (selected) {
                        _controller.selectedCategory.value = cat;
                        _visibleCount.value = _pageSize; // Reset pagination
                      }
                    },
                  );
                });
              }).toList(),
            ),
          ),

          // Scrollable List
          Expanded(
            child: Obx(() {
              final allFiltered = _controller.filteredOffers;
              if (allFiltered.isEmpty) {
                return const Center(child: Text('কোনো অফার পাওয়া যায়নি।'));
              }

              final displayCount = _visibleCount.value < allFiltered.length
                  ? _visibleCount.value
                  : allFiltered.length;

              return ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount:
                    displayCount +
                    (_visibleCount.value < allFiltered.length ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == displayCount) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF08B3AC),
                        ),
                      ),
                    );
                  }

                  final offer = allFiltered[index];
                  // Secure access check
                  final userRole = AuthController.instance.currentUserRole.value
                      .trim()
                      .toLowerCase();
                  final bool hasAccess =
                      offer.targetRoles.any(
                        (r) => r.trim().toLowerCase() == userRole,
                      ) ||
                      userRole == 'admin' ||
                      userRole == 'super admin';
                  final double cashback = offer.price - offer.offerPrice;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.01),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: hasAccess
                          ? () => Get.to(
                              () => MobileRechargeScreen(prefilledOffer: offer),
                            )
                          : () {
                              Get.snackbar(
                                'লকড অফার',
                                'এই অফারটি আপনার মেম্বারশিপ লেভেলের জন্য প্রযোজ্য নয়। অফারটি পেতে হলে আপনার লেভেল ${_getRoleLabelsJoined(offer.targetRoles)}-এর যেকোনো একটি হতে হবে।',
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.9,
                                ),
                                colorText: Colors.black87,
                                borderColor: Colors.amber.withValues(
                                  alpha: 0.4,
                                ),
                                borderWidth: 1,
                                snackPosition: SnackPosition.BOTTOM,
                                margin: const EdgeInsets.all(16),
                              );
                            },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Stack(
                          children: [
                            if (!hasAccess)
                              Positioned.fill(
                                child: Container(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black87,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Requires: ${_getRoleLabel(offer.targetRoles.first)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            Row(
                              children: [
                                Icon(
                                  offer.packageType == 'Internet'
                                      ? Icons.language
                                      : offer.packageType == 'Minutes'
                                      ? Icons.phone_callback
                                      : Icons.card_giftcard,
                                  color: AppColors.green,
                                  size: 24,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        offer.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'অপারেটর: ${offer.operatorName} | মেয়াদ: ${offer.validity}',
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (cashback > 0)
                                      Text(
                                        'ক্যাশব্যাক: ৳$cashback',
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    Text(
                                      '৳${offer.offerPrice}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
