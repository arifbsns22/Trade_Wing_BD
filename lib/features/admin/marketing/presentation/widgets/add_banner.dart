import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import '../controllers/banner_controller.dart';

class AddBannerWidget extends StatefulWidget {
  const AddBannerWidget({super.key});

  @override
  State<AddBannerWidget> createState() => _AddBannerWidgetState();
}

class _AddBannerWidgetState extends State<AddBannerWidget> {
  final BannerController _controller = Get.find<BannerController>();
  final TextEditingController _titleController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String _selectedBannerType = 'Default';
  final List<String> _bannerTypes = ['Default', 'Target Role wise'];

  final List<Map<String, String>> _availableRoles = [
    {'key': 'Customer', 'name': 'গ্রাহক'},
    {'key': 'Guest Customer', 'name': 'অতিথি গ্রাহক'},
    {'key': 'Brand Promoter', 'name': 'ব্র্যান্ড প্রমোটর'},
    {'key': 'Sales Partner', 'name': 'সেলস পার্টনার'},
    {'key': 'Senior Sales Partner', 'name': 'সিনিয়র সেলস পার্টনার'},
    {'key': 'Sub Dealer', 'name': 'সাব ডিলার'},
    {'key': 'Dealer', 'name': 'ডিলার'},
    {'key': 'Senior Dealer', 'name': 'সিনিয়র ডিলার'},
    {'key': 'Master Dealer', 'name': 'মাস্টার ডিলার'},
    {'key': 'Super Admin', 'name': 'সুপার এডমিন'},
  ];
  final List<String> _selectedRoles = [];

  XFile? _selectedImage;
  DateTime? _startDate;
  DateTime? _expiryDate;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _selectDateTime(BuildContext context, bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      if (!context.mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.primaryColor,
                onPrimary: Colors.white,
                onSurface: Colors.black87,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          if (isStartDate) {
            _startDate = fullDateTime;
          } else {
            _expiryDate = fullDateTime;
          }
        });
      }
    }
  }

  void _submit() async {
    if (_titleController.text.trim().isEmpty) {
      Get.snackbar(
        'ত্রুটি',
        'দয়া করে ব্যানারের টাইটেল দিন',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    if (_selectedImage == null) {
      Get.snackbar(
        'ত্রুটি',
        'দয়া করে একটি ব্যানার ছবি নির্বাচন করুন',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    if (_selectedBannerType == 'Target Role wise' && _selectedRoles.isEmpty) {
      Get.snackbar(
        'ত্রুটি',
        'দয়া করে অন্তত একটি টার্গেট রোল নির্বাচন করুন',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final success = await _controller.addBanner(
      title: _titleController.text.trim(),
      bannerType: _selectedBannerType,
      targetRoles: _selectedBannerType == 'Target Role wise'
          ? _selectedRoles
          : [],
      imageFile: _selectedImage!,
      startDate: _startDate,
      expiryDate: _expiryDate,
    );

    if (success) {
      setState(() {
        _titleController.clear();
        _selectedBannerType = 'Default';
        _selectedRoles.clear();
        _selectedImage = null;
        _startDate = null;
        _expiryDate = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.art_track_outlined, color: Colors.black87),
                const SizedBox(width: 8),
                const Text(
                  "নতুন ব্যানার যুক্ত করুন",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tabs Mockup
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        'এড করুন',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'নাম দিন',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'নতুন ব্যানারের নাম দিন',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Banner Type
                const Text(
                  'ব্যানারের ধরন',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedBannerType,
                      isExpanded: true,
                      items: _bannerTypes.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedBannerType = val;
                            if (val == 'Default') _selectedRoles.clear();
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Target Role (conditional)
                if (_selectedBannerType == 'Target Role wise') ...[
                  const Text(
                    'Target Roles',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _availableRoles.map((roleMap) {
                      final roleKey = roleMap['key']!;
                      final roleName = roleMap['name']!;
                      final isSelected = _selectedRoles.contains(roleKey);
                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedRoles.remove(roleKey);
                            } else {
                              _selectedRoles.add(roleKey);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryColor
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            roleName,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade800,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 20),

                // Date & Time Scheduling
                const Text(
                    'সময় নির্ধারণ (সরাসরি চালু করতে খালি রাখুন)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 500;
                      final startBtn = InkWell(
                        onTap: () => _selectDateTime(context, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: AppColors.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _startDate == null
                                      ? 'শুরুর তারিখ ও সময়'
                                      : DateFormat(
                                          'dd MMM yyyy, hh:mm a',
                                        ).format(_startDate!),
                                  style: TextStyle(
                                    color: _startDate == null
                                        ? Colors.grey.shade600
                                        : Colors.black87,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_startDate != null)
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _startDate = null),
                                  child: const Icon(
                                    Icons.clear,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );

                      final expiryBtn = InkWell(
                        onTap: () => _selectDateTime(context, false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _expiryDate == null
                                      ? 'শেষের তারিখ ও সময়'
                                      : DateFormat(
                                          'dd MMM yyyy, hh:mm a',
                                        ).format(_expiryDate!),
                                  style: TextStyle(
                                    color: _expiryDate == null
                                        ? Colors.grey.shade600
                                        : Colors.black87,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_expiryDate != null)
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _expiryDate = null),
                                  child: const Icon(
                                    Icons.clear,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );

                      if (isWide) {
                        return Row(
                          children: [
                            Expanded(child: startBtn),
                            const SizedBox(width: 16),
                            Expanded(child: expiryBtn),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            startBtn,
                            const SizedBox(height: 12),
                            expiryBtn,
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Banner Image
                  Row(
                    children: [
                      const Text(
                        'ব্যানার ইমেজ ',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '* ( Ratio 3:1 )',
                        style: TextStyle(
                          color: Colors.red.shade400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: _selectedImage == null
                          ? const Center(
                              child: Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.grey,
                              ),
                            )
                          : kIsWeb
                          ? Image.network(
                              _selectedImage!.path,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(_selectedImage!.path),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Choose File',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _selectedImage?.name ?? 'No file chosen',
                            style: TextStyle(color: Colors.grey.shade500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: _controller.isLoading.value ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _controller.isLoading.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Save Banner',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
      ),
    );
  }
}
