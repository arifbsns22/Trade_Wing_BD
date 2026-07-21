import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:trade_wign_bd/common/ui/widgets/customAlertDialogue.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import 'package:trade_wign_bd/features/users/drive_pack/data/repositories/drive_pack_repository.dart';
import 'package:trade_wign_bd/features/users/drive_pack/domain/models/operator_model.dart';
import 'package:trade_wign_bd/features/users/drive_pack/domain/models/drive_package_model.dart';
import 'package:trade_wign_bd/features/users/drive_pack/domain/models/recharge_model.dart';
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

    // Strip country code if present (+880 or 880)
    if (cleanNumber.startsWith('880')) {
      cleanNumber = cleanNumber.substring(2);
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
    // Banglalink: 019, 014
    // Teletalk: 015
    // Airtel: 016
    String detectedName = '';
    if (prefix == '017' || prefix == '013') {
      detectedName = 'Grameenphone';
    } else if (prefix == '018' || prefix == '016') {
      detectedName = 'Robi'; // Robi and Airtel combined
    } else if (prefix == '019' || prefix == '014') {
      detectedName = 'Banglalink';
    } else if (prefix == '015') {
      detectedName = 'Teletalk';
    }

    if (detectedName.isEmpty) return null;
    return operators.firstWhereOrNull(
      (op) => op.name.toLowerCase().contains(detectedName.toLowerCase()),
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
              'দুঃখিত, মোবাইল রিচার্জ করার জন্য ইন্টারনেট সংযোগ প্রয়োজন।',
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
      );

      await _repository.createRecharge(recharge);

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
}
