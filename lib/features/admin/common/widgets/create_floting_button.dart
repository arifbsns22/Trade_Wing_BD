import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/common/ui/widgets/buttons/custom_floating_action_button.dart';
import 'package:trade_wign_bd/features/admin/ecommerce/presentation/screens/add_product_screen.dart';
import 'package:trade_wign_bd/features/admin/users/presentation/screens/add_user_screen.dart';
import 'package:trade_wign_bd/features/admin/settings/presentation/screens/admin_settings_screen.dart';

class CreateFloatingButton extends StatelessWidget {
  const CreateFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomFloatingActionButton(
      heroTag: 'admin_create_fab',
      onPressed: () => _showCreateBottomSheet(context),
    );
  }

  void _showCreateBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bottom sheet header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'নতুন যোগ করুন',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      fontFamily: 'Hind Siliguri',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.black54,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 1. Order Option
              _buildCreateMenuTile(
                icon: Icons.shopping_bag_outlined,
                iconColor: const Color(0xFFF97316),
                iconBgColor: const Color(0xFFFFF7ED),
                title: 'নতুন অর্ডার',
                subtitle: 'গ্রাহকের জন্য নতুন অর্ডার তৈরি করুন',
                onTap: () {
                  Navigator.pop(context);
                  Get.snackbar(
  'অর্ডার',
  'নতুন অর্ডার তৈরির পেইজ মডিউল নির্মাণাধীন রয়েছে',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
                },
              ),
              const SizedBox(height: 12),

              // 2. Product Option
              _buildCreateMenuTile(
                icon: Icons.inventory_2_outlined,
                iconColor: const Color(0xFF0D9488),
                iconBgColor: const Color(0xFFF0FDF4),
                title: 'নতুন প্রোডাক্ট',
                subtitle: 'ইনভেন্টরিতে নতুন প্রোডাক্ট যুক্ত করুন',
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => const AddProductScreen());
                },
              ),
              const SizedBox(height: 12),

              // 3. Customer Option
              _buildCreateMenuTile(
                icon: Icons.person_outline_rounded,
                iconColor: const Color(0xFF2563EB),
                iconBgColor: const Color(0xFFEFF6FF),
                title: 'নতুন ইউজার/গ্রাহক',
                subtitle: 'সিস্টেমে নতুন গ্রাহক/ইউজার যুক্ত করুন',
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => const AddUserScreen());
                },
              ),
              const SizedBox(height: 12),

              // 4. Promotion Option
              _buildCreateMenuTile(
                icon: Icons.percent_rounded,
                iconColor: const Color(0xFFDC2626),
                iconBgColor: const Color(0xFFFEF2F2),
                title: 'নতুন প্রমোশন',
                subtitle: 'ডিসকাউন্ট ক্যাম্পেইন বা অফার তৈরি করুন',
                onTap: () {
                  Navigator.pop(context);
                  Get.snackbar(
  'প্রমোশন',
  'নতুন প্রমোশন তৈরির পেইজ মডিউল নির্মাণাধীন রয়েছে',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
                },
              ),
              const SizedBox(height: 12),

              // 5. More Option
              _buildCreateMenuTile(
                icon: Icons.settings_outlined,
                iconColor: const Color(0xFF475569),
                iconBgColor: const Color(0xFFF1F5F9),
                title: 'অন্যান্য সেটিংস',
                subtitle: 'অ্যাপস ও বিজনেস সেটিংস পরিবর্তন করুন',
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => const AdminSettingsScreen());
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCreateMenuTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      fontFamily: 'Hind Siliguri',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Hind Siliguri',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
