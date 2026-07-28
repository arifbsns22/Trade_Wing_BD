import 'package:flutter/material.dart';

class UserCountCard extends StatelessWidget {
  final String title;
  final int count;
  final double growth;

  const UserCountCard({
    super.key,
    required this.title,
    required this.count,
    required this.growth,
  });

  String _toBanglaNumber(String number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bangla = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    String result = number;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], bangla[i]);
    }
    return result;
  }

  String _getBanglaRole(String engRole) {
    switch (engRole) {
      case 'Super Admin':
        return 'সুপার এডমিন';
      case 'Customer':
        return 'কাস্টমার';
      case 'Vendor':
        return 'ভেন্ডর';
      case 'Reseller':
        return 'রিসেলার';
      case 'Brand Promoter':
        return 'ব্র্যান্ড প্রমোটর';
      case 'Sales Partner':
        return 'সেলস পার্টনার';
      case 'Senior Sales Partner':
        return 'সিনিয়র সেলস পার্টনার';
      case 'Sub Dealer':
        return 'সাব ডিলার';
      case 'Dealer':
        return 'ডিলার';
      case 'Senior Dealer':
        return 'সিনিয়র ডিলার';
      case 'Master Dealer':
        return 'মাস্টার ডিলার';
      default:
        return engRole;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Formatting logic
    final isPositive = growth >= 0;
    final growthText = isPositive
        ? '+${_toBanglaNumber(growth.toStringAsFixed(1))}%'
        : '${_toBanglaNumber(growth.toStringAsFixed(1))}%';
    final pillColor = isPositive
        ? Colors.green.withValues(alpha: 0.1)
        : Colors.red.withValues(alpha: 0.1);
    final textColor = isPositive ? Colors.green : Colors.red;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;

    final banglaTitle = _getBanglaRole(title);

    // Get an icon based on role (simple mapping)
    IconData roleIcon = Icons.people_outline;
    if (title.contains('Admin')) roleIcon = Icons.admin_panel_settings_outlined;
    if (title.contains('Vendor') || title.contains('Reseller'))
      roleIcon = Icons.storefront_outlined;
    if (title.contains('Sales') || title.contains('Dealer'))
      roleIcon = Icons.store_mall_directory_outlined;
    if (title.contains('Promoter')) roleIcon = Icons.campaign_outlined;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(roleIcon, color: Colors.blue.shade600, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  banglaTitle,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _toBanglaNumber(count.toString()),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: pillColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: textColor, size: 10),
                    const SizedBox(width: 2),
                    Text(
                      growthText,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
