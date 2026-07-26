import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:trade_wign_bd/common/ui/widgets/customAlertDialogue.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import 'package:trade_wign_bd/features/admin/settings/presentation/controllers/admin_settings_controller.dart';
import 'package:trade_wign_bd/features/users/drive_pack/data/repositories/drive_pack_repository.dart';
import 'package:trade_wign_bd/features/users/drive_pack/domain/models/operator_model.dart';
import 'package:trade_wign_bd/features/users/drive_pack/domain/models/drive_package_model.dart';
import 'package:trade_wign_bd/features/users/drive_pack/domain/models/recharge_model.dart';
import 'package:trade_wign_bd/common/services/notification_helper.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class MobileRechargeController extends GetxController {
  final DrivePackRepository _repository = DrivePackRepository();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final AuthController _authController = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final Rx<OperatorModel?> selectedOperator = Rx<OperatorModel?>(null);

  // Bangladeshi Operator Prefix Checkers
  bool isValidBangladeshiNumber(String number) {
    if (number.length != 11) return false;
    final regExp = RegExp(r'^01[3-9]\d{8}$');
    return regExp.hasMatch(number);
  }

  /// Evaluates operator based on number prefix
  OperatorModel? detectOperator(String number, List<OperatorModel> operators) {
    // Strip non-digit characters
    String cleanNumber = number.replaceAll(RegExp(r'\D'), '');

    // Strip country code if present (+880 or 880 or 88)
    if (cleanNumber.startsWith('880')) {
      cleanNumber = cleanNumber.substring(3);
    } else if (cleanNumber.startsWith('88')) {
      cleanNumber = cleanNumber.substring(2);
    }

    // Ensure it starts with 0
    if (cleanNumber.isNotEmpty && !cleanNumber.startsWith('0')) {
      cleanNumber = '0$cleanNumber';
    }

    if (cleanNumber.length < 3) return null;
    final prefix = cleanNumber.substring(0, 3);

    // GP: 017, 013
    // Robi: 018
    // Airtel: 016
    // Banglalink: 019, 014
    // Teletalk: 015
    String detectedName = '';
    List<String> keywords = [];

    if (prefix == '017' || prefix == '013') {
      detectedName = 'Grameenphone';
      keywords = ['grameenphone', 'grameen', 'gp', '017', '013', 'গ্রামীন', 'গ্রামীণ'];
    } else if (prefix == '018') {
      detectedName = 'Robi';
      keywords = ['robi', '018', 'রবি'];
    } else if (prefix == '016') {
      detectedName = 'Airtel';
      keywords = ['airtel', '016', 'এয়ারটেল', 'এয়ারটেল'];
    } else if (prefix == '019' || prefix == '014') {
      detectedName = 'Banglalink';
      keywords = ['banglalink', 'bangla', 'bl', '019', '014', 'বাংলালিংক'];
    } else if (prefix == '015') {
      detectedName = 'Teletalk';
      keywords = ['teletalk', 'taletalk', 'tele', 'tale', '015', 'টেলিটক', 'টিলিটক'];
    }

    if (keywords.isEmpty) return null;

    if (operators.isNotEmpty) {
      final match = operators.firstWhereOrNull((op) {
        final nameLower = op.name.trim().toLowerCase();
        final idLower = op.id.trim().toLowerCase();

        return keywords.any((kw) {
          if (kw == 'gp' || kw == 'bl') {
            return nameLower == kw || idLower == kw || nameLower.startsWith(kw);
          }
          return nameLower.contains(kw) ||
              kw.contains(nameLower) ||
              idLower.contains(kw) ||
              kw.contains(idLower);
        });
      });

      if (match != null) return match;
    }

    // Fallback: If no operator document in Firestore matches, return a default local OperatorModel
    // so that valid prefixes like 015 ALWAYS detect Teletalk!
    return OperatorModel(
      id: detectedName.toLowerCase(),
      name: detectedName,
      logoUrl: '',
      status: true,
      createdAt: DateTime.now(),
    );
  }

  Future<void> executeRecharge({
    required BuildContext context,
    required String mobileNumber,
    required double amount,
    DrivePackageModel? package,
  }) async {
    try {
      isLoading.value = true;

      // 1. Network Interceptor Safeguard
      bool isOffline = false;
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        isOffline =
            connectivityResult.contains(ConnectivityResult.none) ||
            connectivityResult.isEmpty;
      } catch (e) {
        debugPrint('Connectivity check failed: $e. Falling back to online.');
        isOffline = false;
      }

      if (isOffline) {
        isLoading.value = false;
        // Block and throw custom Bangla dialog
        customAlertDialogue(
          context: context,
          title: 'সংযোগ বিচ্ছিন্ন',
          greetingsIcon: Icons.wifi_off_outlined,
          greetings:
              'দুঃখিত, মোবাইল রিচার্জ করার জন্য internet সংযোগ প্রয়োজন।',
          isErrorDialogue: true,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'ঠিক আছে',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
        return;
      }

      // Check offline payment settings dynamically
      final settingsCtrl = Get.put(AdminSettingsController());
      await settingsCtrl.loadSettings();
      
      String paymentMethod = 'wallet';
      String? offlineGateway;
      String? offlineSenderMobile;
      String? offlineTrxId;

      if (settingsCtrl.isOfflinePaymentActive.value) {
        isLoading.value = false;
        final offlineDetails = await _showOfflinePaymentSheet(context, amount);
        if (offlineDetails == null) {
          return; // User cancelled
        }
        isLoading.value = true;
        paymentMethod = 'offline';
        offlineGateway = offlineDetails['gateway'];
        offlineSenderMobile = offlineDetails['sender'];
        offlineTrxId = offlineDetails['trxId'];
      }

      // 2. Account Password Security Verification
      final bool isAuthenticated = await _showPasswordConfirmationDialog(
        context,
      );

      if (!isAuthenticated) {
        isLoading.value = false;
        Get.snackbar(
          'ব্যর্থ',
          'নিরাপত্তা যাচাইকরণ সম্পন্ন করা যায়নি। রিচার্জ বাতিল করা হয়েছে।',
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          colorText: Colors.black87,
          borderColor: Colors.red.withValues(alpha: 0.2),
          borderWidth: 1,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return;
      }

      // 3. Online: Send payload safely through repository to record transaction ledger
      final op = selectedOperator.value;
      if (op == null) {
        isLoading.value = false;
        Get.snackbar(
          'ত্রুটি',
          'দয়া করে অপারেটর নির্বাচন করুন।',
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          colorText: Colors.black87,
          borderColor: Colors.red.withValues(alpha: 0.2),
          borderWidth: 1,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return;
      }

      final String txnId =
          'TXN_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';

      final recharge = RechargeModel(
        id: '',
        operatorId: op.id,
        operatorName: op.name,
        mobileNumber: mobileNumber,
        amount: amount,
        userMobile: _authController.currentUserMobile.value,
        userName: _authController.currentUserName.value,
        status: 'pending',
        createdAt: DateTime.now(),
        transactionId: txnId,
        rechargeType: package != null ? 'drive' : 'regular',
        drivePackageId: package?.id,
        paymentMethod: paymentMethod,
        offlineGateway: offlineGateway,
        offlineSenderMobile: offlineSenderMobile,
        offlineTrxId: offlineTrxId,
      );

      await _repository.createRecharge(recharge);

      // Send push notification to Admin via Firestore
      final bool isDrive = recharge.rechargeType == 'drive';
      await NotificationHelper.sendNotification(
        title: isDrive ? 'নতুন ড্রাইভ অফার অর্ডার' : 'নতুন মোবাইল রিচার্জ অনুরোধ',
        body: '${recharge.userName} (${recharge.userMobile}) ৳${recharge.amount} রিচার্জের অনুরোধ পাঠিয়েছেন। নম্বর: ${recharge.mobileNumber}',
        type: isDrive ? 'drive_order' : 'mobile_recharge',
        userMobile: recharge.userMobile,
        isAdmin: true,
      );

      isLoading.value = false;

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle_outline, color: AppColors.green),
              const SizedBox(width: 8),
              const Text(
                'অনুরোধ সফল',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'আপনার মোবাইল রিচার্জের অনুরোধটি গ্রহণ করা হয়েছে। কিছুক্ষণের মধ্যে টাকা যোগ হয়ে যাবে। প্রয়োজনে আমাদের সাপোর্টে যোগাযোগ করুন। \nঅপারেটর: ${op.name}\nনম্বর: $mobileNumber\nপরিমাণ: ৳$amount\nআইডি: $txnId',
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                Get.back(); // Back to offers dashboard
              },
              child: const Text(
                'ঠিক আছে',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Recharge execution error: $e');
      isLoading.value = false;
      Get.snackbar(
        'ত্রুটি',
        'রিচার্জ অনুরোধ পাঠাতে সমস্যা হয়েছে। দয়া করে আবার চেষ্টা করুন।',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: Colors.red.withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  /// Password validation dialog
  Future<bool> _showPasswordConfirmationDialog(BuildContext context) async {
    final passwordController = TextEditingController();
    bool isConfirmed = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'নিরাপত্তা পাসওয়ার্ড লিখুন',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'মোবাইল রিচার্জ সম্পন্ন করতে আপনার অ্যাকাউন্ট পাসওয়ার্ডটি লিখুন।',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                labelText: 'পাসওয়ার্ড',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
            onPressed: () async {
              final enteredPass = passwordController.text.trim();
              if (enteredPass.isEmpty) {
                Get.snackbar(
                  'ত্রুটি',
                  'পাসওয়ার্ডটি লিখুন।',
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                  colorText: Colors.black87,
                  borderColor: const Color(
                    0xFF08B3AC,
                  ).withValues(alpha: 0.2), // AppColors.primaryColor
                  borderWidth: 1,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(16),
                );
                return;
              }

              final isValid = await _authController.verifyUserPassword(
                enteredPass,
              );
              if (isValid) {
                isConfirmed = true;
                Navigator.pop(ctx);
              } else {
                Get.snackbar(
                  'ভুল পাসওয়ার্ড',
                  'আপনার প্রবেশ করানো পাসওয়ার্ডটি সঠিক নয়। আবার চেষ্টা করুন।',
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                  colorText: Colors.black87,
                  borderColor: Colors.red.withValues(alpha: 0.2),
                  borderWidth: 1,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(16),
                );
              }
            },
            child: const Text(
              'নিশ্চিত করুন',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    return isConfirmed;
  }

  Future<Map<String, String>?> _showOfflinePaymentSheet(
    BuildContext context,
    double amount,
  ) async {
    final settingsCtrl = Get.find<AdminSettingsController>();
    final formKey = GlobalKey<FormState>();
    final senderMobileCtrl = TextEditingController();
    final trxIdCtrl = TextEditingController();
    String selectedGateway = 'bkash';

    return await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            Widget gatewayTab(String gatewayId, String iconPath, String label) {
              final bool isSelected = selectedGateway == gatewayId;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selectedGateway = gatewayId),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            iconPath,
                            height: 24,
                            width: 40,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox.shrink(),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            label,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.black87 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            Widget offlineInstruction(int step, String text, [String? highlightText]) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$step. ',
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    Expanded(
                      child: highlightText != null
                          ? Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  text,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.pink,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    highlightText,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              text,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                    ),
                  ],
                ),
              );
            }

            Widget cardTextField({
              required TextEditingController controller,
              required String hint,
              TextInputType keyboardType = TextInputType.text,
            }) => TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              validator: (v) => v!.isEmpty ? 'এই ঘরটি পূরণ করুন' : null,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primaryColor),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            );

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'পেমেন্ট বিবরণ (Offline Payment)',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'মোট পরিশোধের পরিমাণ: ৳${amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(12),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  gatewayTab(
                                    'bkash',
                                    'assets/color_icons/finance/BKash-Icon-Logo.wine.png',
                                    'bKash',
                                  ),
                                  gatewayTab(
                                    'nagad',
                                    'assets/color_icons/finance/Nagad-Logo.wine.png',
                                    'Nagad',
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(16),
                              child: Obx(
                                () => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    offlineInstruction(
                                      1,
                                      'আপনার ${selectedGateway == 'bkash' ? 'bKash' : 'Nagad'} অ্যাপ ওপেন করুন',
                                    ),
                                    offlineInstruction(
                                      2,
                                      'সিলেক্ট করুন',
                                      selectedGateway == 'bkash'
                                          ? settingsCtrl.bkashPaymentOption.value
                                          : settingsCtrl.nagadPaymentOption.value,
                                    ),
                                    offlineInstruction(
                                      3,
                                      'আমাদের ${selectedGateway == 'bkash' ? settingsCtrl.bkashAccountType.value : settingsCtrl.nagadAccountType.value} অ্যাকাউন্ট নম্বরটি দিন',
                                      selectedGateway == 'bkash'
                                          ? settingsCtrl.bkashAccountNumber.value
                                          : settingsCtrl.nagadAccountNumber.value,
                                    ),
                                    offlineInstruction(
                                      4,
                                      'মোট বিলের পরিমাণটি দিন',
                                      '${amount.toStringAsFixed(2)} টাকা',
                                    ),
                                    offlineInstruction(
                                      5,
                                      'এবার আপনার পিন নম্বরটি দিন',
                                    ),
                                    offlineInstruction(
                                      6,
                                      'পেমেন্ট করতে ট্যাপ করে ধরে রাখুন',
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'যে নম্বর থেকে টাকা পাঠিয়েছেন',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    cardTextField(
                                      controller: senderMobileCtrl,
                                      hint: 'যেমন: 01XXXXXXXXX',
                                      keyboardType: TextInputType.phone,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'ট্রানজ্যাকশন আইডি (TrxID)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    cardTextField(
                                      controller: trxIdCtrl,
                                      hint: 'যেমন: 8N77DAK99L',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              Navigator.pop(ctx, {
                                'gateway': selectedGateway,
                                'sender': senderMobileCtrl.text.trim(),
                                'trxId': trxIdCtrl.text.trim(),
                              });
                            }
                          },
                          child: const Text(
                            'পেমেন্ট নিশ্চিত করুন',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
