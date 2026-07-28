import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_settings_controller.dart';

class ResellerCommissionTab extends StatelessWidget {
  const ResellerCommissionTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminSettingsController>();
    final commissionController = TextEditingController(
      text: controller.resellerCommission.value.toStringAsFixed(1),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4.0, bottom: 10.0),
            child: Text(
              'রিসেলার সেটিংস',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.percent_rounded, color: Colors.indigo),
                    SizedBox(width: 12),
                    Text(
                      'রিসেলার কমিশন (%)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'রিসেলার বিক্রির উপর অ্যাডমিনের কমিশন হার নির্ধারণ করুন। এই পরিমাণটি অর্ডার সম্পন্ন হলে মোট বিক্রয় মূল্য থেকে কেটে নেওয়া হবে।',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: commissionController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: 'যেমন: ৫.০',
                          suffixText: '%',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (val) {
                          final double? parsed = double.tryParse(val);
                          if (parsed != null) {
                            controller.resellerCommission.value = parsed;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
