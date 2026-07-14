import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import '../controllers/admin_settings_controller.dart';

class OthersTab extends StatelessWidget {
  const OthersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminSettingsController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('উন্নত সিস্টেম কনফিগারেশন'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: _buildCardDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.construction_rounded, color: Colors.orange),
                    SizedBox(width: 12),
                    Text(
                      'সিস্টেম মেইনটেন্যান্স মোড',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
                Obx(() => Switch(
                      value: controller.isMaintenanceMode.value,
                      activeTrackColor: AppColors.primaryColor,
                      onChanged: (value) {
                        controller.isMaintenanceMode.value = value;
                        controller.saveSettings();
                      },
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
