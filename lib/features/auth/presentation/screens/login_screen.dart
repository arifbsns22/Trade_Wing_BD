import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

import 'package:trade_wign_bd/common/ui/widgets/customAlertDialogue.dart';
import 'package:trade_wign_bd/common/ui/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:trade_wign_bd/common/ui/widgets/auth/custom_auth_header_logo.dart';
import 'package:trade_wign_bd/common/ui/widgets/auth/custom_auth_header_text.dart';
import 'package:trade_wign_bd/common/ui/widgets/auth/custom_text_form_field.dart';
import 'package:trade_wign_bd/common/ui/widgets/buttons/custom_elevated_button.dart';
import 'package:trade_wign_bd/common/ui/widgets/buttons/custom_outline_button.dart';
import 'package:trade_wign_bd/features/admin/dashboard/presentation/screens/admin_home_page.dart';
import 'package:trade_wign_bd/features/common/bottom_navbar_menu.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import 'package:trade_wign_bd/features/admin/settings/presentation/controllers/admin_settings_controller.dart';
import '../controllers/auth_controller.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool returnBack;

  const LoginScreen({super.key, this.returnBack = false});

  static const String name = 'login-screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();
  final AdminSettingsController _settingsController = Get.put(
    AdminSettingsController(),
  );

  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final bool canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      if (mounted) {
        setState(() {
          _canCheckBiometrics = canAuthenticate;
        });
      }
    } catch (e) {
      debugPrint('Error checking biometrics: $e');
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    if (kIsWeb || !_canCheckBiometrics) {
      if (!mounted) return;
      customAlertDialogue(
        context: context,
        title: 'দুংখিত',
        greetingsIcon: Icons.error_outline,
        greetings: kIsWeb
            ? 'এই অ্যাপটি ওয়েবে বায়োমেট্রিক লগইন সমর্থন করে না।'
            : 'আপনার ডিভাইসে বায়োমেট্রিক লগইন সমর্থন করে না।',
        isErrorDialogue: true,
        actions: [
          CustomButton(text: 'ঠিক আছে', onTap: () => Navigator.pop(context)),
        ],
      );
      return;
    }

    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason:
            'বায়োমেট্রিক লগইনের জন্য ফিঙ্গারপ্রিন্ট বা ফেস স্ক্যান করুন',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );

      if (didAuthenticate) {
        final loginResult = await _authController.biometricLogin();

        if (loginResult == 'success') {
          final role = _authController.currentUserRole.value;
          if (role == 'Super Admin' || role == 'Admin') {
            Get.offAll(() => const AdminDashboardScreen());
          } else if (widget.returnBack) {
            Get.back();
          } else {
            Get.offAll(() => const BottomNavBarMenu());
          }
        } else if (loginResult == 'no_credentials') {
          if (!mounted) return;
          customAlertDialogue(
            context: context,
            title: 'ব্যর্থ হয়েছে',
            greetingsIcon: Icons.error_outline,
            greetings:
                'বায়োমেট্রিক লগইনের জন্য প্রথমে পাসওয়ার্ড দিয়ে অন্তত একবার লগইন করুন।',
            isErrorDialogue: true,
            actions: [
              CustomButton(
                text: 'ঠিক আছে',
                onTap: () => Navigator.pop(context),
              ),
            ],
          );
        } else {
          if (!mounted) return;
          customAlertDialogue(
            context: context,
            title: 'ব্যর্থ হয়েছে',
            greetingsIcon: Icons.error_outline,
            greetings: loginResult,
            isErrorDialogue: true,
            actions: [
              CustomButton(
                text: 'ঠিক আছে',
                onTap: () => Navigator.pop(context),
              ),
            ],
          );
        }
      }
    } catch (e) {
      debugPrint('Error authenticating with biometrics: $e');
      if (!mounted) return;
      String errorMessage = 'বায়োমেট্রিক লগইন ব্যর্থ হয়েছে।';
      final errorStr = e.toString();
      if (errorStr.contains('noCredentialsSet') ||
          errorStr.contains('NotEnrolled')) {
        errorMessage =
            'আপনার ডিভাইসে কোনো ফিঙ্গারপ্রিন্ট বা পিন সেট করা নেই। দয়া করে ডিভাইসের সেটিংসে গিয়ে এটি সেটআপ করুন।';
      } else if (errorStr.contains('LockedOut') ||
          errorStr.contains('PermanentlyLockedOut')) {
        errorMessage =
            'অতিরিক্ত চেষ্টার কারণে বায়োমেট্রিক লক হয়ে গেছে। অনুগ্রহ করে পরে আবার চেষ্টা করুন।';
      }

      customAlertDialogue(
        context: context,
        title: 'ব্যর্থ হয়েছে',
        greetingsIcon: Icons.error_outline,
        greetings: errorMessage,
        isErrorDialogue: true,
        actions: [
          CustomButton(text: 'ঠিক আছে', onTap: () => Navigator.pop(context)),
        ],
      );
    }
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final mobile = _mobileController.text.trim();
    final password = _passwordController.text;

    if (mobile.isEmpty || password.isEmpty) {
      customAlertDialogue(
        context: context,
        title: 'ভুল হয়েছে',
        greetingsIcon: Icons.error_outline,
        greetings: 'দয়া করে মোবাইল নম্বর এবং পাসওয়ার্ড পূরণ করুন।',
        isErrorDialogue: true,
        actions: [
          CustomButton(text: 'ঠিক আছে', onTap: () => Navigator.pop(context)),
        ],
      );
      return;
    }

    final result = await _authController.login(
      mobile: mobile,
      password: password,
    );

    if (result == 'success') {
      final role = _authController.currentUserRole.value;
      if (role == 'Super Admin' || role == 'Admin') {
        Get.offAll(() => const AdminDashboardScreen());
      } else if (widget.returnBack) {
        Get.back();
      } else {
        Get.offAll(() => const BottomNavBarMenu());
      }
    } else {
      if (!mounted) return;
      customAlertDialogue(
        context: context,
        title: 'ব্যর্থ হয়েছে',
        greetingsIcon: Icons.error_outline,
        greetings: result,
        isErrorDialogue: true,
        actions: [
          CustomButton(
            text: 'আবার চেষ্টা করুন',
            onTap: () => Navigator.pop(context),
          ),
        ],
      );
    }
  }

  Future<void> _handleGuestLogin() async {
    await _authController.loginAsGuest();
    Get.offAll(() => const BottomNavBarMenu());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const PrimaryHeaderContainer(child: CustomAuthHeaderLogo()),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const CustomAuthHeaderText(
                    title: 'লগইন করুন',
                    subTitle:
                        'লগইন করতে নিচে আপনার মোবাইল নম্বর ও ৬ ডিজিটের পাসওয়ার্ডটি লিখুন',
                  ),
                  const SizedBox(height: 20),
                  CustomTextFormField(
                    controller: _mobileController,
                    labelText: 'মোবাইল',
                    hintText: 'মোবাইল নম্বর লিখুন',
                    prefixIcon: const Icon(Icons.phone),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  CustomTextFormField(
                    controller: _passwordController,
                    labelText: 'পাসওয়ার্ড',
                    hintText: 'পাসওয়ার্ড লিখুন',
                    prefixIcon: const Icon(Icons.lock),
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  Obx(() {
                    if (_authController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: CustomOutlineButton(
                                text: 'রেজিস্টার',
                                onTap: () {
                                  Get.to(() => const RegisterScreen());
                                },
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: CustomButton(
                                text: 'লগইন',
                                onTap: _handleLogin,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 60),
                        IconButton(
                          color: AppColors.primaryColor,
                          onPressed: _authenticateWithBiometrics,
                          icon: Icon(
                            Icons.fingerprint,
                            size: 60,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        Text(
                          'দ্রুত ও নিরাপদে লগইন করতে বায়োমেট্রিক ব্যবহার করুন',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 120),
                  Obx(() {
                    if (_settingsController.appCopyright.value.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Text(
                          _settingsController.appCopyright.value,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
