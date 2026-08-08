import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import '../controllers/admin_settings_controller.dart';

class CustomerWalletTab extends StatelessWidget {
  const CustomerWalletTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminSettingsController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0.5,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.stars_rounded,
                      color: AppColors.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'রিওয়ার্ড পয়েন্ট কনভার্সন রেট',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'কত পয়েন্টে ১ টাকা হবে তা নির্ধারণ করুন। উদাহরণস্বরূপ, ১০০ পয়েন্ট = ১ টাকা হলে এখানে ১০০ লিখুন।',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Obx(() {
                final textController = TextEditingController(
                  text: '${controller.rewardPointsRate.value}',
                );
                // Position cursor at the end
                textController.selection = TextSelection.fromPosition(
                  TextPosition(offset: textController.text.length),
                );

                return TextFormField(
                  controller: textController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'পয়েন্ট রেট (১ টাকার জন্য)',
                    hintText: 'যেমন: ১০০',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.calculate_outlined),
                    suffixText: 'পয়েন্ট = ১ টাকা',
                  ),
                  onChanged: (val) {
                    final rate = int.tryParse(val) ?? 100;
                    controller.rewardPointsRate.value = rate;
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
