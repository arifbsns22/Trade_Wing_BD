import 'dart:ui';
import 'package:flutter/material.dart';

/// Custom ScrollBehavior to enable horizontal drag scrolling using mouse, trackpad, and touch.
class RoleTimelineScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class RoleBadgets extends StatelessWidget {
  final String userRole;

  const RoleBadgets({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    final normalizedRole = userRole.trim().toLowerCase();
    int activeIndex = 0;

    if (normalizedRole == 'customer') {
      activeIndex = 0;
    } else if (normalizedRole == 'active customer') {
      activeIndex = 1;
    } else if (normalizedRole == 'brand promoter') {
      activeIndex = 2;
    } else if (normalizedRole == 'sales partner') {
      activeIndex = 3;
    } else if (normalizedRole == 'senior sales partner') {
      activeIndex = 4;
    } else if (normalizedRole == 'sub dealer') {
      activeIndex = 5;
    } else if (normalizedRole == 'dealer') {
      activeIndex = 6;
    } else if (normalizedRole == 'senior dealer') {
      activeIndex = 7;
    } else if (normalizedRole == 'master dealer') {
      activeIndex = 8;
    } else if (normalizedRole == 'regional distributor') {
      activeIndex = 9;
    } else if (normalizedRole == 'admin' || normalizedRole == 'super admin') {
      activeIndex = 9; // Unlocked all levels for admins
    }

    final ranks = [
      _RankItem('কাস্টমার', Icons.person_outline),
      _RankItem('সক্রিয় কাস্টমার', Icons.shopping_bag_outlined),
      _RankItem('ব্র্যান্ড প্রমোটার', Icons.campaign_outlined),
      _RankItem('সেলস পার্টনার', Icons.handshake_outlined),
      _RankItem('সিনিয়র সেলস পার্টনার', Icons.business_center_outlined),
      _RankItem('সাব ডিলার', Icons.storefront_outlined),
      _RankItem('ডিলার', Icons.store_outlined),
      _RankItem('সিনিয়র ডিলার', Icons.domain_outlined),
      _RankItem('মাস্টার ডিলার', Icons.workspace_premium_outlined),
      _RankItem('রিজিওনাল ডিস্ট্রিবিউটর', Icons.local_shipping_outlined),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBF24).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.stars, color: Color(0xFFFBBF24), size: 18),
              ),
              const SizedBox(width: 8),
              const Text(
                'মেম্বারশিপ লেভেল',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Horizontally Scrollable Custom Process Timeline
          ScrollConfiguration(
            behavior: RoleTimelineScrollBehavior(),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(ranks.length, (index) {
                    final rank = ranks[index];
                    final bool isCompleted = index <= activeIndex;
                    final bool isCurrent = index == activeIndex;

                    // Soft progressive colors
                    final Color indicatorBgColor = isCompleted
                        ? const Color(0xFFFBBF24).withValues(alpha: 0.15)
                        : const Color(0xFFF1F5F9);
                    
                    final Color iconColor = isCompleted
                        ? const Color(0xFFB45309)
                        : const Color(0xFF94A3B8);

                    final Color borderColor = isCurrent
                        ? const Color(0xFFB45309)
                        : isCompleted
                            ? const Color(0xFFFBBF24).withValues(alpha: 0.5)
                            : const Color(0xFFE2E8F0);

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Node item containing indicator and title label
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: indicatorBgColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: borderColor,
                                  width: isCurrent ? 2.5 : 1.5,
                                ),
                                boxShadow: isCurrent ? [
                                  BoxShadow(
                                    color: const Color(0xFFFBBF24).withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ] : null,
                              ),
                              child: Icon(rank.icon, color: iconColor, size: 18),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 100,
                              child: Text(
                                rank.title,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                  color: isCurrent
                                      ? const Color(0xFFB45309)
                                      : isCompleted
                                          ? const Color(0xFF475569)
                                          : const Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        // Connector line (rendered between nodes, except for the last index)
                        if (index < ranks.length - 1)
                          Container(
                            width: 40,
                            height: 2.0,
                            margin: const EdgeInsets.only(top: 20.0), // Aligns vertically to the badge center
                            color: index < activeIndex
                                ? const Color(0xFFFBBF24)
                                : const Color(0xFFE2E8F0),
                          ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankItem {
  final String title;
  final IconData icon;

  _RankItem(this.title, this.icon);
}
