import 'package:flutter/material.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class ReferralCodeCard extends StatelessWidget {
  final String code;
  final VoidCallback onCopy;
  final String role;
  final VoidCallback? onCustomerTap;

  const ReferralCodeCard({
    super.key,
    required this.code,
    required this.onCopy,
    required this.role,
    this.onCustomerTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isCustomer =
        role.toLowerCase() == 'customer' ||
        role.toLowerCase() == 'guest customer';

    return GestureDetector(
      onTap: isCustomer ? onCustomerTap : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.people_outline_rounded,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'বিজনেজ কোড',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: isCustomer
                  ? Text(
                      "বিজনেজ কোড পেতে হলে 'আয় করুন' পেজ থেকে যে কোন একটা প্যাকেজ ক্রয় করতে হবে।বিস্তারিত জানতে এখানে ক্লিক করুন",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryColor,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            code,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: onCopy,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.copy_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'কপি করুন',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
