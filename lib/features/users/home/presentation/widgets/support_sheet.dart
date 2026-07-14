import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class SupportSheet extends StatelessWidget {
  const SupportSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'সাপোর্ট এ যোগাযোগ করুন',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              // Lottie Animation
              Lottie.asset(
                'assets/animations/support_animation.json',
                height: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),

              // Contact Options
              _buildContactTile(
                iconWidget: const FaIcon(
                  FontAwesomeIcons.whatsapp,
                  color: Colors.green,
                  size: 28,
                ),
                title: 'WhatsApp',
                subtitle: '+8801805003667',
                color: Colors.green,
                onTap: () async {
                  final Uri url = Uri.parse('https://wa.me/8801805003667');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    Get.snackbar(
                      'Error',
                      'Could not launch WhatsApp',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildContactTile(
                iconWidget: const FaIcon(
                  FontAwesomeIcons.facebook,
                  color: Colors.blue,
                  size: 28,
                ),
                title: 'Facebook',
                subtitle: 'আমাদের ফেইসবুক পেইজ',
                color: Colors.blue,
                onTap: () async {
                  final Uri url = Uri.parse('https://www.facebook.com/tradewingBD');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    Get.snackbar(
                      'Error',
                      'Could not open Facebook',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildContactTile(
                iconWidget: Icon(
                  Icons.call,
                  color: AppColors.primaryColor,
                  size: 28,
                ),
                title: 'Mobile',
                subtitle: '+8801805003667',
                color: AppColors.primaryColor,
                onTap: () async {
                  final Uri url = Uri.parse('tel:+8801805003667');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    Get.snackbar(
                      'Error',
                      'Could not launch phone dialer',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactTile({
    required Widget iconWidget,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            iconWidget,
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}
