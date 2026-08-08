import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import 'package:trade_wign_bd/common/services/steadfast_service.dart';
import '../controllers/admin_settings_controller.dart';

class DeliverySettingsTab extends StatelessWidget {
  const DeliverySettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminSettingsController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4.0, bottom: 12.0),
            child: Text(
              'ডেলিভারি প্রোভাইডার সেটিংস',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),

          // 1. Manual Delivery Card
          _buildManualDeliveryCard(context, controller),

          const SizedBox(height: 16),

          // 2. Steadfast Courier Card
          _buildSteadfastCard(context, controller),

          const SizedBox(height: 16),

          // 3. Pathao Courier Card (Placeholder)
          _buildPlaceholderCard(
            title: 'পাঠাও কুরিয়ার (Pathao)',
            description:
                'পাঠাও কুরিয়ার ডেলিভারি এপিআই ইন্টিগ্রেশন। শীঘ্রই আসছে।',
            icon: Icons.local_shipping_outlined,
          ),

          const SizedBox(height: 16),

          // 4. RedX Courier Card (Placeholder)
          _buildPlaceholderCard(
            title: 'রেডএক্স কুরিয়ার (RedX)',
            description:
                'রেডএক্স কুরিয়ার ডেলিভারি এপিআই ইন্টিগ্রেশন। শীঘ্রই আসছে।',
            icon: Icons.delivery_dining_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildManualDeliveryCard(
    BuildContext context,
    AdminSettingsController controller,
  ) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    Icons.directions_run_rounded,
                    color: AppColors.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ম্যানুয়াল ডেলিভারি (Manual Delivery)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'নিজস্ব ডেলিভারি বা লোকাল ডেলিভারি সার্ভিস সক্রিয় করুন',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(
                  () => Switch(
                    value: controller.isManualDeliveryActive.value,
                    activeTrackColor: AppColors.primaryColor,
                    onChanged: (val) {
                      controller.isManualDeliveryActive.value = val;
                    },
                  ),
                ),
              ],
            ),

            Obx(() {
              if (!controller.isManualDeliveryActive.value) {
                return const SizedBox.shrink();
              }

              final nameCtrl = TextEditingController(
                text: controller.manualDeliveryName.value,
              );
              nameCtrl.selection = TextSelection.fromPosition(
                TextPosition(offset: nameCtrl.text.length),
              );

              final timeCtrl = TextEditingController(
                text: controller.manualDeliveryTime.value,
              );
              timeCtrl.selection = TextSelection.fromPosition(
                TextPosition(offset: timeCtrl.text.length),
              );

              return Column(
                children: [
                  const Divider(height: 24),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText:
                          'ডেলিভারি মেথডের নাম (যেমন: ম্যানুয়াল ডেলিভারি)',
                      prefixIcon: const Icon(Icons.edit_road_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (val) =>
                        controller.manualDeliveryName.value = val,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: timeCtrl,
                    decoration: InputDecoration(
                      labelText: 'আনুমানিক সময় (যেমন: ২-৩ দিন)',
                      prefixIcon: const Icon(Icons.access_time_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (val) =>
                        controller.manualDeliveryTime.value = val,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () =>
                        _showWeightWiseChargeBottomSheet(context, controller),
                    icon: const Icon(
                      Icons.monitor_weight_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: const Text(
                      'ওজন ভিত্তিক ডেলিভারি চার্জ সেটআপ করুন',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showWeightWiseChargeBottomSheet(
    BuildContext context,
    AdminSettingsController controller,
  ) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ওজন ভিত্তিক ডেলিভারি চার্জ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ওজন ভিত্তিক চার্জ সক্রিয় করুন',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'পার্সেলের ওজনের ওপর ভিত্তি করে ডেলিভারি চার্জ হিসাব হবে',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () => Switch(
                      value: controller.isWeightWiseChargeActive.value,
                      activeTrackColor: AppColors.primaryColor,
                      onChanged: (val) {
                        controller.isWeightWiseChargeActive.value = val;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (!controller.isWeightWiseChargeActive.value)
                  return const SizedBox.shrink();

                final baseWeightCtrl = TextEditingController(
                  text: controller.weightBaseMax.value.toString(),
                );
                baseWeightCtrl.selection = TextSelection.fromPosition(
                  TextPosition(offset: baseWeightCtrl.text.length),
                );

                final baseChargeInsideCtrl = TextEditingController(
                  text: controller.weightBaseChargeInside.value.toString(),
                );
                baseChargeInsideCtrl.selection = TextSelection.fromPosition(
                  TextPosition(offset: baseChargeInsideCtrl.text.length),
                );

                final baseChargeOutsideCtrl = TextEditingController(
                  text: controller.weightBaseChargeOutside.value.toString(),
                );
                baseChargeOutsideCtrl.selection = TextSelection.fromPosition(
                  TextPosition(offset: baseChargeOutsideCtrl.text.length),
                );

                final extraChargeCtrl = TextEditingController(
                  text: controller.weightPerKgChargeExtra.value.toString(),
                );
                extraChargeCtrl.selection = TextSelection.fromPosition(
                  TextPosition(offset: extraChargeCtrl.text.length),
                );

                return Column(
                  children: [
                    TextFormField(
                      controller: baseWeightCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'বেস ওজন সীমা (Base Weight Limit in KG)',
                        hintText: 'যেমন: 1.0',
                        prefixIcon: const Icon(Icons.scale_rounded),
                        suffixText: 'KG',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (val) {
                        final double? value = double.tryParse(val);
                        if (value != null) {
                          controller.weightBaseMax.value = value;
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: baseChargeInsideCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: 'বেস চার্জ (শহরের ভিতরে)',
                              hintText: 'যেমন: 60.0',
                              prefixIcon: const Icon(Icons.home_work_rounded),
                              suffixText: '৳',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (val) {
                              final double? value = double.tryParse(val);
                              if (value != null) {
                                controller.weightBaseChargeInside.value = value;
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: baseChargeOutsideCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: 'বেস চার্জ (শহরের বাইরে)',
                              hintText: 'যেমন: 120.0',
                              prefixIcon: const Icon(Icons.public_rounded),
                              suffixText: '৳',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (val) {
                              final double? value = double.tryParse(val);
                              if (value != null) {
                                controller.weightBaseChargeOutside.value =
                                    value;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: extraChargeCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText:
                            'প্রতি অতিরিক্ত কেজি চার্জ (Extra Charge Per KG)',
                        hintText: 'যেমন: 20.0',
                        prefixIcon: const Icon(Icons.add_box_rounded),
                        suffixText: '৳/KG',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (val) {
                        final double? value = double.tryParse(val);
                        if (value != null) {
                          controller.weightPerKgChargeExtra.value = value;
                        }
                      },
                    ),
                  ],
                );
              }),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'সম্পন্ন করুন',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildSteadfastCard(
    BuildContext context,
    AdminSettingsController controller,
  ) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    Icons.airport_shuttle_rounded,
                    color: AppColors.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Steadfast Courier Limited',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'স্টেডফাস্ট কুরিয়ার ডেলিভারি এপিআই কনফিগারেশন',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      FutureBuilder<double?>(
                        future: SteadfastService.getBalance(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 4.0),
                              child: Text(
                                'ব্যালেন্স চেক করা হচ্ছে...',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          }
                          if (snapshot.hasData && snapshot.data != null) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'মার্চেন্ট ব্যালেন্স: ৳${snapshot.data!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
                Obx(
                  () => Switch(
                    value: controller.isSteadfastActive.value,
                    activeTrackColor: AppColors.primaryColor,
                    onChanged: (val) {
                      controller.isSteadfastActive.value = val;
                    },
                  ),
                ),
              ],
            ),

            Obx(() {
              if (!controller.isSteadfastActive.value) {
                return const SizedBox.shrink();
              }

              final apiKeyCtrl = TextEditingController(
                text: controller.steadfastApiKey.value,
              );
              apiKeyCtrl.selection = TextSelection.fromPosition(
                TextPosition(offset: apiKeyCtrl.text.length),
              );

              final secretKeyCtrl = TextEditingController(
                text: controller.steadfastSecretKey.value,
              );
              secretKeyCtrl.selection = TextSelection.fromPosition(
                TextPosition(offset: secretKeyCtrl.text.length),
              );

              final baseUrlCtrl = TextEditingController(
                text: controller.steadfastBaseUrl.value,
              );
              baseUrlCtrl.selection = TextSelection.fromPosition(
                TextPosition(offset: baseUrlCtrl.text.length),
              );

              return Column(
                children: [
                  const Divider(height: 24),
                  const Text(
                    'স্টেডফাস্ট মার্চেন্ট প্যানেল থেকে প্রাপ্ত এপিআই কী ও সিক্রেট কী প্রদান করুন।',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: apiKeyCtrl,
                    decoration: InputDecoration(
                      labelText: 'API Key (এপিআই কী)',
                      hintText: 'যেমন: 1m9mwrrws...',
                      prefixIcon: const Icon(Icons.key_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (val) => controller.steadfastApiKey.value = val,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: secretKeyCtrl,
                    decoration: InputDecoration(
                      labelText: 'Secret Key (সিক্রেট কী)',
                      hintText: 'যেমন: y196ftazv...',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (val) =>
                        controller.steadfastSecretKey.value = val,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: baseUrlCtrl,
                    decoration: InputDecoration(
                      labelText: 'Base URL (বেস ইউআরএল)',
                      hintText: 'যেমন: https://portal.packzy.com/api/v1',
                      prefixIcon: const Icon(Icons.link_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (val) => controller.steadfastBaseUrl.value = val,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderCard({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Card(
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.grey.shade400, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
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
