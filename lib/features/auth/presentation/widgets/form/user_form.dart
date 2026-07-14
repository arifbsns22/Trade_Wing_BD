import 'package:flutter/material.dart';
import 'package:trade_wign_bd/common/ui/widgets/auth/custom_text_form_field.dart';
import 'package:trade_wign_bd/common/ui/widgets/custom_checkMark_text.dart';

class UserForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController mobileController;
  final TextEditingController emailController;
  final TextEditingController businessCodeController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool acceptTerms;
  final ValueChanged<bool?> onAcceptTermsChanged;

  const UserForm({
    super.key,
    required this.nameController,
    required this.mobileController,
    required this.emailController,
    required this.businessCodeController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.acceptTerms,
    required this.onAcceptTermsChanged,
  });

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextFormField(
          controller: widget.nameController,
          labelText: 'সম্পূর্ণ নাম',
          hintText: 'আপনার নাম লিখুন',
          prefixIcon: const Icon(Icons.person),
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          controller: widget.mobileController,
          labelText: 'মোবাইল',
          hintText: 'মোবাইল নম্বর লিখুন',
          prefixIcon: const Icon(Icons.phone),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          controller: widget.emailController,
          labelText: 'ই-মেইল',
          hintText: 'আপনার ইমেইল নম্বর লিখুন (ঐচ্ছিক)',
          prefixIcon: const Icon(Icons.email),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          controller: widget.businessCodeController,
          labelText: 'বিজনেজ কোড',
          hintText: 'বিজনেজ কোড লিখুন (ঐচ্ছিক)',
          prefixIcon: const Icon(Icons.business_center),
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          controller: widget.passwordController,
          labelText: 'পাসওয়ার্ড',
          hintText: 'কমপক্ষে ৬ সংখ্যার একটি পাসওয়ার্ড লিখুন',
          prefixIcon: const Icon(Icons.lock),
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          controller: widget.confirmPasswordController,
          labelText: 'কনফার্ম পাসওয়ার্ড',
          hintText: 'পাসওয়ার্ডটি আবার লিখুন',
          prefixIcon: const Icon(Icons.lock_clock),
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
        ),
        const SizedBox(height: 10),
        CustomCheckMarkText(
          text: 'সকল শর্তাবলী মেনে নিচ্ছি',
          value: widget.acceptTerms,
          onChanged: widget.onAcceptTermsChanged,
        ),
      ],
    );
  }
}
