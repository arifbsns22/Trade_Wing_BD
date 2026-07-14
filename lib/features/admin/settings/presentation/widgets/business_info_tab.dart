import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import 'package:trade_wign_bd/common/ui/widgets/dynamic_app_logo.dart';
import '../controllers/admin_settings_controller.dart';

class BusinessInfoTab extends StatefulWidget {
  const BusinessInfoTab({super.key});

  @override
  State<BusinessInfoTab> createState() => _BusinessInfoTabState();
}

class _BusinessInfoTabState extends State<BusinessInfoTab> {
  late final AdminSettingsController controller;
  late final TextEditingController appNameController;
  late final TextEditingController appEmailController;
  late final TextEditingController appMobileController;
  late final TextEditingController appAddressController;
  late final TextEditingController appCopyrightController;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AdminSettingsController>();
    appNameController = TextEditingController(text: controller.appName.value);
    appEmailController = TextEditingController(text: controller.appEmail.value);
    appMobileController = TextEditingController(text: controller.appMobile.value);
    appAddressController = TextEditingController(text: controller.appAddress.value);
    appCopyrightController = TextEditingController(text: controller.appCopyright.value);
  }

  @override
  void dispose() {
    appNameController.dispose();
    appEmailController.dispose();
    appMobileController.dispose();
    appAddressController.dispose();
    appCopyrightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('সফটওয়্যার তথ্য'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _buildCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  textController: appNameController,
                  title: 'অ্যাপ্লিকেশনের নাম',
                  hint: 'অ্যাপের নাম লিখুন',
                  icon: Icons.branding_watermark_outlined,
                  onChanged: (val) => controller.appName.value = val,
                ),
                _buildTextField(
                  textController: appEmailController,
                  title: 'ইমেইল অ্যাড্রেস',
                  hint: 'ইমেইল লিখুন',
                  icon: Icons.email_outlined,
                  onChanged: (val) => controller.appEmail.value = val,
                ),
                _buildTextField(
                  textController: appMobileController,
                  title: 'মোবাইল নম্বর',
                  hint: 'মোবাইল নম্বর লিখুন',
                  icon: Icons.phone_android_outlined,
                  onChanged: (val) => controller.appMobile.value = val,
                ),
                _buildTextField(
                  textController: appAddressController,
                  title: 'ঠিকানা',
                  hint: 'ঠিকানা লিখুন',
                  icon: Icons.location_on_outlined,
                  onChanged: (val) => controller.appAddress.value = val,
                  maxLines: 3,
                ),
                _buildTextField(
                  textController: appCopyrightController,
                  title: 'কপিরাইট টেক্সট',
                  hint: 'কপিরাইট টেক্সট লিখুন',
                  icon: Icons.copyright_outlined,
                  onChanged: (val) => controller.appCopyright.value = val,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('লোগো সেটিংস'),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 180,
                  padding: const EdgeInsets.all(12),
                  decoration: _buildCardDecoration(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'লাইট মোড লোগো',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Center(
                          child: const DynamicAppLogo(isDark: false, height: 60),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.file_upload_outlined, size: 16),
                        label: const Text('আপলোড', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        onPressed: () => controller.pickLogo('light'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 180,
                  padding: const EdgeInsets.all(12),
                  decoration: _buildCardDecoration(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ডার্ক মোড লোগো',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Center(
                          child: const DynamicAppLogo(isDark: true, height: 60),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.file_upload_outlined, size: 16),
                        label: const Text('আপলোড', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        onPressed: () => controller.pickLogo('dark'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () {
                controller.saveSettings();
              },
              child: const Text('সংরক্ষণ করুন', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 40),
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

  Widget _buildTextField({
    required TextEditingController textController,
    required String title,
    required String hint,
    required IconData icon,
    required Function(String) onChanged,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: textController,
            maxLines: maxLines,
            decoration: InputDecoration(
              prefixIcon: maxLines == 1 ? Icon(icon, size: 20) : null,
              hintText: hint,
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
              ),
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

}
