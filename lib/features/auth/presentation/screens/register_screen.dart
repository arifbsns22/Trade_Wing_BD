import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/common/ui/widgets/customAlertDialogue.dart';
import 'package:trade_wign_bd/common/ui/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:trade_wign_bd/common/ui/widgets/auth/custom_auth_header_logo.dart';
import 'package:trade_wign_bd/common/ui/widgets/auth/custom_auth_header_text.dart';
import 'package:trade_wign_bd/common/ui/widgets/buttons/custom_elevated_button.dart';
import 'package:trade_wign_bd/common/ui/widgets/buttons/custom_outline_button.dart';
import '../widgets/form/user_form.dart';
import '../controllers/auth_controller.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const String name = 'registration-screen';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _businessCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _acceptTerms = false;

  final AuthController _authController = Get.find<AuthController>();

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _businessCodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final mobile = _mobileController.text.trim();
    final email = _emailController.text.trim();
    final businessCode = _businessCodeController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || mobile.isEmpty || password.isEmpty) {
      customAlertDialogue(
        context: context,
        title: 'ভুল হয়েছে',
        greetingsIcon: Icons.error_outline,
        greetings: 'দয়া করে সবগুলি প্রয়োজনীয় ঘর পূরণ করুন।',
        isErrorDialogue: true,
        actions: [
          CustomButton(
            text: 'ঠিক আছে',
            onTap: () => Navigator.pop(context),
          )
        ],
      );
      return;
    }

    if (password.length < 6) {
      customAlertDialogue(
        context: context,
        title: 'ভুল হয়েছে',
        greetingsIcon: Icons.error_outline,
        greetings: 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে।',
        isErrorDialogue: true,
        actions: [
          CustomButton(
            text: 'ঠিক আছে',
            onTap: () => Navigator.pop(context),
          )
        ],
      );
      return;
    }

    if (password != confirmPassword) {
      customAlertDialogue(
        context: context,
        title: 'ভুল হয়েছে',
        greetingsIcon: Icons.error_outline,
        greetings: 'পাসওয়ার্ড এবং কনফার্ম পাসওয়ার্ড মেলেনি।',
        isErrorDialogue: true,
        actions: [
          CustomButton(
            text: 'ঠিক আছে',
            onTap: () => Navigator.pop(context),
          )
        ],
      );
      return;
    }

    if (!_acceptTerms) {
      customAlertDialogue(
        context: context,
        title: 'ভুল হয়েছে',
        greetingsIcon: Icons.error_outline,
        greetings: 'দয়া করে শর্তাবলী মেনে নেওয়ার ঘরে টিক দিন।',
        isErrorDialogue: true,
        actions: [
          CustomButton(
            text: 'ঠিক আছে',
            onTap: () => Navigator.pop(context),
          )
        ],
      );
      return;
    }

    final result = await _authController.register(
      name: name,
      mobile: mobile,
      email: email,
      businessCode: businessCode,
      password: password,
    );

    if (result == 'success') {
      customAlertDialogue(
        context: context,
        title: 'আলহামদুলিল্লাহ',
        greetingsIcon: Icons.done,
        greetings: 'আপনার রেজিস্ট্রেশন সফলভাবে সম্পন্ন হয়েছে।',
        actions: [
          CustomButton(
            text: 'লগইন করুন',
            onTap: () {
              Navigator.pop(context); // Close dialog
              Get.offAll(() => const LoginScreen());
            },
          )
        ],
      );
    } else {
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
          )
        ],
      );
    }
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  const CustomAuthHeaderText(
                    title: 'রেজিস্টার করুন',
                    subTitle: 'রেজিস্ট্রেশন করতে নিচের তথ্যগুলো সঠিকভাবে পূরণ করুন',
                  ),
                  const SizedBox(height: 20),
                  UserForm(
                    nameController: _nameController,
                    mobileController: _mobileController,
                    emailController: _emailController,
                    businessCodeController: _businessCodeController,
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                    acceptTerms: _acceptTerms,
                    onAcceptTermsChanged: (value) {
                      setState(() {
                        _acceptTerms = value ?? false;
                      });
                    },
                  ),
                  const SizedBox(height: 30),
                  Obx(() {
                    if (_authController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: CustomOutlineButton(
                            text: 'লগইন',
                            onTap: () {
                              Get.offAll(() => const LoginScreen());
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: CustomButton(
                            text: 'রেজিস্টার',
                            onTap: _handleRegister,
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
