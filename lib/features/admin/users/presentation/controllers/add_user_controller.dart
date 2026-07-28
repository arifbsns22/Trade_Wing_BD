import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/auth/data/service/auth_service.dart';
import 'package:trade_wign_bd/features/admin/users/presentation/controllers/admin_users_controller.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class AddUserController extends GetxController {
  final AuthService _authService = AuthService();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();

  final RxString selectedRole = 'Customer'.obs;
  final RxBool isLoading = false.obs;

  final List<String> roles = [
    'Super Admin',
    'Customer',
    'Vendor',
    'Reseller',
    'Brand Promoter',
    'Sales Partner',
    'Senior Sales Partner',
    'Sub Dealer',
    'Dealer',
    'Senior Dealer',
    'Master Dealer',
  ];

  @override
  void onClose() {
    nameController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> createUser() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    // Auto-generate a fake email since we don't have it on the form, but auth service might want it
    final String generatedEmail =
        '${mobileController.text.trim()}@tradewignbd.com';

    final result = await _authService.signUpUser(
      name: nameController.text.trim(),
      mobile: mobileController.text.trim(),
      password: passwordController.text.trim(),
      email: generatedEmail,
      role: selectedRole.value,
    );

    isLoading.value = false;

    if (result == 'success') {
      Get.snackbar(
  'সফল',
  'ইউজার সফলভাবে তৈরি হয়েছে',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);

      // Refresh AllUserScreen list if AdminUsersController is present
      if (Get.isRegistered<AdminUsersController>()) {
        Get.find<AdminUsersController>().fetchUsers();
      }

      // Clear form
      nameController.clear();
      mobileController.clear();
      passwordController.clear();
      selectedRole.value = 'Customer';
    } else {
      Get.snackbar(
  'ত্রুটি',
  result,
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
    }
  }
}
