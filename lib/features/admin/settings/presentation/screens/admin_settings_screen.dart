import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import '../controllers/admin_settings_controller.dart';
import '../widgets/business_info_tab.dart';
import '../widgets/payment_tab.dart';
import '../widgets/customer_wallet_tab.dart';
import '../widgets/others_tab.dart';
import '../widgets/vendor_commission_tab.dart';
import '../widgets/reseller_commission_tab.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminSettingsController());

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text(
            'অ্যাপ্লিকেশন সেটিংস',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.black87,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: Colors.white,
          elevation: 0.5,
          shadowColor: Colors.black.withValues(alpha: 0.1),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: Colors.black54,
            indicatorColor: AppColors.primaryColor,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(text: 'সফটওয়্যার তথ্য'),
              Tab(text: 'পেমেন্ট তথ্য'),
              Tab(text: 'কাস্টমার'),
              Tab(text: 'অন্যান্য'),
              Tab(text: 'ভেন্ডর'),
              Tab(text: 'রিসেলার'),
            ],
          ),
          actions: [
            Obx(
              () => controller.isLoading.value
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.only(right: 16.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF08B3AC),
                            ),
                          ),
                        ),
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.save_rounded,
                        color: AppColors.primaryColor,
                      ),
                      onPressed: () {
                        controller.saveSettings();
                      },
                      tooltip: 'সংরক্ষণ করুন',
                    ),
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            BusinessInfoTab(),
            PaymentTab(),
            CustomerWalletTab(),
            OthersTab(),
            VendorCommissionTab(),
            ResellerCommissionTab(),
          ],
        ),
      ),
    );
  }
}
