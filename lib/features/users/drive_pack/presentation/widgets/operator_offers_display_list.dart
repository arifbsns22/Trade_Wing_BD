import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import '../controllers/user_drive_pack_controller.dart';
import '../screens/mobile_recharge_screens.dart';

class OperatorOffersDisplayList extends StatelessWidget {
  final String operatorId;
  const OperatorOffersDisplayList({super.key, required this.operatorId});

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

  String _getRoleLabelsJoined(List<String> roles) {
    return roles.map((r) => _getRoleLabel(r)).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserDrivePackController>();
    final authController = Get.find<AuthController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF08B3AC)),
        );
      }

      if (controller.hasError.value) {
        return const Center(
          child: Text('অফার লোড করতে সমস্যা হয়েছে। দয়া করে আবার চেষ্টা করুন।'),
        );
      }

      // Filter offers for the specific operatorId passed, and active category
      final offers = controller.allOffers.where((offer) {
        final matchesOperator = offer.operatorId == operatorId;
        final matchesCategory =
            controller.selectedCategory.value == 'All' ||
            offer.packageType == controller.selectedCategory.value;
        return matchesOperator && matchesCategory && offer.status;
      }).toList();

      if (offers.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40.0),
            child: Text('এই ক্যাটাগরিতে কোনো অফার নেই।'),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final offer = offers[index];

          // Secure Multi-Role Evaluation
          final userRole = authController.currentUserRole.value
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
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: hasAccess
                    ? () {
                        // Navigate to Mobile Recharge screen prefilled with offer details
                        Get.to(
                          () => MobileRechargeScreen(prefilledOffer: offer),
                        );
                      }
                    : () {
                        // Inform user they lack the required membership level
                        Get.snackbar(
                          'লকড অফার',
                          'এই অফারটি আপনার মেম্বারশিপ লেভেলের জন্য প্রযোজ্য নয়। অফারটি পেতে হলে আপনার লেভেল ${_getRoleLabelsJoined(offer.targetRoles)}-এর যেকোনো একটি হতে হবে।',
                          backgroundColor: Colors.white.withValues(alpha: 0.9),
                          colorText: Colors.black87,
                          borderColor: Colors.amber.withValues(alpha: 0.4),
                          borderWidth: 1,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                        );
                      },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Stack(
                    children: [
                      // Lock Blur Overlay if unauthorized
                      if (!hasAccess)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.lock,
                                      color: Colors.amber,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${_getRoleLabel(offer.targetRoles.first)} ইত্যাদি স্তরের জন্য',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Normal Item Row
                      Row(
                        children: [
                          // Left Icon
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: offer.packageType == 'Internet'
                                  ? const Color(0xFFF0FDFA)
                                  : offer.packageType == 'Minutes'
                                  ? const Color(0xFFEFF6FF)
                                  : const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              offer.packageType == 'Internet'
                                  ? Icons.language
                                  : offer.packageType == 'Minutes'
                                  ? Icons.phone_callback
                                  : Icons.card_giftcard,
                              color: offer.packageType == 'Internet'
                                  ? const Color(0xFF0D9488)
                                  : offer.packageType == 'Minutes'
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFFEA580C),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Text Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  offer.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_outlined,
                                      color: Colors.grey.shade400,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      offer.validity,
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      Icons.people_outline,
                                      color: Colors.grey.shade400,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        _getRoleLabelsJoined(offer.targetRoles),
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 11,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                if (offer.description.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    offer.description,
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Price details
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (cashback > 0)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '৳$cashback ক্যাশব্যাক!',
                                    style: const TextStyle(
                                      color: Color(0xFF15803D),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              Text(
                                '৳${offer.offerPrice}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                '৳${offer.price}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade400,
                                  decoration: TextDecoration.lineThrough,
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
            ),
          );
        },
      );
    });
  }
}
