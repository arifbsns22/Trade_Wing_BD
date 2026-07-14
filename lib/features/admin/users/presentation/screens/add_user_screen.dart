import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import '../controllers/add_user_controller.dart';

class AddUserScreen extends StatelessWidget {
  const AddUserScreen({super.key});

  String _getBanglaRole(String engRole) {
    switch (engRole) {
      case 'Super Admin':
        return 'সুপার এডমিন';
      case 'Customer':
        return 'কাস্টমার';
      case 'Brand Promoter':
        return 'ব্র্যান্ড প্রমোটর';
      case 'Sales Partner':
        return 'সেলস পার্টনার';
      case 'Senior Sales Partner':
        return 'সিনিয়র সেলস পার্টনার';
      case 'Sub Dealer':
        return 'সাব ডিলার';
      case 'Dealer':
        return 'ডিলার';
      case 'Senior Dealer':
        return 'সিনিয়র ডিলার';
      case 'Master Dealer':
        return 'মাস্টার ডিলার';
      default:
        return engRole;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddUserController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: const Text(
          'নতুন ইউজার যোগ করুন',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFFF4F7FE),
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ইউজারের তথ্য',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),

              // Name Field
              TextFormField(
                controller: controller.nameController,
                decoration: const InputDecoration(
                  labelText: 'ইউজারের নাম',
                  hintText: 'উদা: মোঃ আরিফ',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'নাম প্রদান করুন'
                    : null,
              ),
              const SizedBox(height: 16),

              // Mobile Field
              TextFormField(
                controller: controller.mobileController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'মোবাইল নম্বর',
                  hintText: 'উদা: 017XXXXXXXX',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty)
                    return 'মোবাইল নম্বর প্রদান করুন';
                  if (value.length != 11)
                    return 'সঠিক ১১ ডিজিটের মোবাইল নম্বর দিন';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: controller.passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'পাসওয়ার্ড',
                  hintText: 'পাসওয়ার্ড প্রদান করুন',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'পাসওয়ার্ড প্রদান করুন';
                  if (value.length < 6)
                    return 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Liquid Glass Role Dropdown
              Obx(
                () => _LiquidGlassDropdown(
                  items: controller.roles,
                  selectedValue: controller.selectedRole.value,
                  onChanged: (val) => controller.selectedRole.value = val,
                  getBanglaText: _getBanglaRole,
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.createUser(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            'সাবমিট করুন',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiquidGlassDropdown extends StatefulWidget {
  final List<String> items;
  final String selectedValue;
  final Function(String) onChanged;
  final String Function(String) getBanglaText;

  const _LiquidGlassDropdown({
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    required this.getBanglaText,
  });

  @override
  State<_LiquidGlassDropdown> createState() => _LiquidGlassDropdownState();
}

class _LiquidGlassDropdownState extends State<_LiquidGlassDropdown> {
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Button
        GestureDetector(
          onTap: () {
            setState(() {
              isOpen = !isOpen;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.getBanglaText(widget.selectedValue),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
                Icon(
                  isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.black87,
                ),
              ],
            ),
          ),
        ),

        // Dropdown Menu
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: isOpen
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 300),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                        ),
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          children: widget.items.map((item) {
                            final isSelected = widget.selectedValue == item;
                            return InkWell(
                              onTap: () {
                                widget.onChanged(item);
                                setState(() {
                                  isOpen = false;
                                });
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: [
                                            Colors.lightGreen.withValues(
                                              alpha: 0.2,
                                            ),
                                            Colors.transparent,
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        )
                                      : null,
                                ),
                                child: Text(
                                  widget.getBanglaText(item),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.w500
                                        : FontWeight.w300,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
