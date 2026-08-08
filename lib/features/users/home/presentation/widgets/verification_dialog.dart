import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import 'package:trade_wign_bd/features/common/services/r2_storage_service.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import 'support_sheet.dart';

/// Verification Status Dialog - Premium design with soft colors and clear indicators
class VerificationStatusDialog extends StatelessWidget {
  final String targetRole;
  final String status;

  const VerificationStatusDialog({
    super.key,
    required this.targetRole,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isReseller = targetRole == 'reseller';
    final roleBangla = isReseller ? 'রিসেলার' : 'ভেন্ডর';
    final accentColor = isReseller
        ? const Color(0xFF08B3AC)
        : const Color(0xFF6366F1);

    Color themeColor;
    Color softBgColor;
    IconData iconData;
    String statusTitle;
    String statusSubtitle;
    String statusBadgeText;

    switch (status.toLowerCase().trim()) {
      case 'pending':
        themeColor = const Color(0xFFD97706); // Warm Amber
        softBgColor = const Color(0xFFFFFBEB);
        iconData = Icons.hourglass_empty_rounded;
        statusTitle = 'আবেদনটি যাচাই করা হচ্ছে';
        statusBadgeText = 'যাচাইধীন';
        statusSubtitle =
            'আপনার $roleBangla অ্যাকাউন্ট সক্রিয় করার আবেদনটি বর্তমানে এডমিন প্যানেলের মাধ্যমে যাচাই করা হচ্ছে। শীঘ্রই এটি অনুমোদিত হলে আপনি আপনার ড্যাশবোর্ডে প্রবেশ করতে পারবেন।';
        break;
      case 'hold':
        themeColor = const Color(0xFF0284C7); // Premium Sky Blue
        softBgColor = const Color(0xFFF0F9FF);
        iconData = Icons.pause_circle_outline_rounded;
        statusTitle = 'আবেদনটি স্থগিত রাখা হয়েছে';
        statusBadgeText = 'স্থগিত';
        statusSubtitle =
            'তথ্য অসম্পূর্ণ থাকায় আপনার $roleBangla আবেদনটি সাময়িকভাবে স্থগিত করা হয়েছে। অনুগ্রহ করে হেল্পলাইনে কল করে অথবা ফেসবুক পেজে যোগাযোগ করে বিস্তারিত জেনে নিন।';
        break;
      default: // rejected
        themeColor = const Color(0xFFDC2626); // Alert Red
        softBgColor = const Color(0xFFFEF2F2);
        iconData = Icons.cancel_outlined;
        statusTitle = 'আবেদনটি বাতিল করা হয়েছে';
        statusBadgeText = 'বাতিল';
        statusSubtitle =
            'দুঃখিত, সঠিক তথ্য না থাকায় আপনার $roleBangla আবেদনটি বাতিল করা হয়েছে। দয়া করে সঠিক ও স্পষ্ট ডকুমেন্টসমূহ আপলোড করে আবার নতুন আবেদন জমা দিন।';
        break;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 12,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Beautiful Top Shaded Shimmer Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [softBgColor, Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    // Glowing Icon Container
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: themeColor.withValues(alpha: 0.15),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(iconData, color: themeColor, size: 38),
                    ),
                    const SizedBox(height: 16),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: softBgColor,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: themeColor.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        statusBadgeText,
                        style: TextStyle(
                          color: themeColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Detail Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      statusTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      statusSubtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Action Buttons Layout
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'বন্ধ করুন',
                          style: TextStyle(
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (status == 'rejected')
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                            Get.dialog(
                              VerificationDialog(targetRole: targetRole),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'আবার আবেদন করুন',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.back();
                            Get.bottomSheet(
                              const SupportSheet(),
                              isScrollControlled: true,
                            );
                          },
                          icon: const Icon(
                            Icons.phone_in_talk_rounded,
                            size: 16,
                          ),
                          label: const Text('হেল্পলাইন'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

/// The multi-step verification form dialog (Highly Premium 2-Step wizard)
class VerificationDialog extends StatefulWidget {
  final String targetRole;

  const VerificationDialog({super.key, required this.targetRole});

  @override
  State<VerificationDialog> createState() => _VerificationDialogState();
}

class _VerificationDialogState extends State<VerificationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nidController = TextEditingController();
  final _tradeLicenseController = TextEditingController();
  final _categoriesController = TextEditingController();

  XFile? _nidFrontImage;
  XFile? _nidBackImage;
  XFile? _selfieImage;

  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  // Step state: 0 = Info step, 1 = Upload step
  int _currentStep = 0;

  Future<void> _pickImage(int imageType) async {
    // imageType: 1 = Front NID, 2 = Back NID, 3 = Selfie
    final source = imageType == 3 ? ImageSource.camera : ImageSource.gallery;
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (imageType == 1) {
          _nidFrontImage = pickedFile;
        } else if (imageType == 2) {
          _nidBackImage = pickedFile;
        } else if (imageType == 3) {
          _selfieImage = pickedFile;
        }
      });
    }
  }

  void _clearImage(int imageType) {
    setState(() {
      if (imageType == 1) {
        _nidFrontImage = null;
      } else if (imageType == 2) {
        _nidBackImage = null;
      } else if (imageType == 3) {
        _selfieImage = null;
      }
    });
  }

  void _goToNextStep() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _currentStep = 1;
      });
    }
  }

  void _goToPreviousStep() {
    setState(() {
      _currentStep = 0;
    });
  }

  void _submit() async {
    if (_nidFrontImage == null ||
        _nidBackImage == null ||
        _selfieImage == null) {
      Get.snackbar(
        'ত্রুটি',
        'দয়া করে আপনার এনআইডির দুই পাশের ছবি এবং নিজের ছবি আপলোড করুন।',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authCtrl = AuthController.instance;
      final mobile = authCtrl.currentUserMobile.value;

      if (mobile.isEmpty) {
        throw Exception('ব্যবহারকারীর মোবাইল নম্বর পাওয়া যায়নি।');
      }

      // Initialize R2 storage
      final r2Service = R2StorageService();

      // Upload images
      final frontPath =
          'verifications/${widget.targetRole}/${mobile}_nid_front.jpg';
      final backPath =
          'verifications/${widget.targetRole}/${mobile}_nid_back.jpg';
      final selfiePath =
          'verifications/${widget.targetRole}/${mobile}_selfie.jpg';

      final frontBytes = await _nidFrontImage!.readAsBytes();
      final backBytes = await _nidBackImage!.readAsBytes();
      final selfieBytes = await _selfieImage!.readAsBytes();

      final frontUrl = await r2Service.uploadBytes(
        bytes: frontBytes,
        destinationPath: frontPath,
        contentType: 'image/jpeg',
      );
      final backUrl = await r2Service.uploadBytes(
        bytes: backBytes,
        destinationPath: backPath,
        contentType: 'image/jpeg',
      );
      final selfieUrl = await r2Service.uploadBytes(
        bytes: selfieBytes,
        destinationPath: selfiePath,
        contentType: 'image/jpeg',
      );

      if (frontUrl == null || backUrl == null || selfieUrl == null) {
        throw Exception(
          'ছবি আপলোড করতে ব্যর্থ হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।',
        );
      }

      final keyPrefix = widget.targetRole;

      // Update Firestore user document
      await FirebaseFirestore.instance.collection('users').doc(mobile).set({
        '${keyPrefix}VerificationStatus': 'pending',
        '${keyPrefix}NidNumber': _nidController.text.trim(),
        '${keyPrefix}TradeLicense': _tradeLicenseController.text.trim(),
        '${keyPrefix}NidFront': frontUrl,
        '${keyPrefix}NidBack': backUrl,
        '${keyPrefix}Selfie': selfieUrl,
        '${keyPrefix}Categories': _categoriesController.text.trim(),
        '${keyPrefix}RequestedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Get.back(); // close form dialog

      Get.defaultDialog(
        title: 'আবেদন জমা হয়েছে',
        titleStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
          fontSize: 15,
        ),
        content: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            'আপনার রিকোয়েস্ট টি এডমিন যাচাই করছেন। যাচাই শেষে আপনি আপডেট দেখতে পারবেন। প্রয়োজনে সাপোর্টে যোগাযোগ করতে পারেন।',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
        ),
        textConfirm: 'ঠিক আছে',
        confirmTextColor: Colors.white,
        buttonColor: AppColors.primaryColor,
        onConfirm: () => Get.back(),
      );
    } catch (e) {
      Get.snackbar(
        'ত্রুটি',
        e.toString().replaceAll('Exception:', '').trim(),
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isReseller = widget.targetRole == 'reseller';
    final title = isReseller ? 'রিসেলার ভেরিফিকেশন' : 'ভেন্ডর ভেরিফিকেশন';

    // Premium theme colors based on role
    final accentColor = isReseller
        ? const Color(0xFF08B3AC)
        : const Color(0xFF6366F1);
    final softBgColor = isReseller
        ? const Color(0xFFF0FDFB)
        : const Color(0xFFEEF2FF);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Form(
              key: _formKey,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Premium Header Bar
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: softBgColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isReseller
                                ? Icons.shopping_bag_outlined
                                : Icons.storefront_outlined,
                            color: accentColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                isReseller
                                    ? 'রিসেলিং শুরু করতে তথ্য দিন'
                                    : 'ভেন্ডর হিসেবে যোগ দিতে তথ্য দিন',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Color(0xFF94A3B8),
                            size: 20,
                          ),
                          onPressed: () => Get.back(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Stepper Progress Bar
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: _currentStep == 1
                                  ? accentColor
                                  : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Conditionally show step layouts
                    _currentStep == 0
                        ? _buildInfoStep(softBgColor, accentColor)
                        : _buildUploadStep(softBgColor, accentColor),
                  ],
                ),
              ),
            ),
          ),
          if (_isSubmitting)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: accentColor),
                    const SizedBox(height: 16),
                    Text(
                      'আবেদন আপলোড হচ্ছে...',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'অনুগ্রহ করে কিছুক্ষণ অপেক্ষা করুন',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // STEP 1 Layout: Text forms
  Widget _buildInfoStep(Color softBg, Color focusColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // NID Number
        _inputLabel('এনআইডি নম্বর (NID Number)*'),
        TextFormField(
          controller: _nidController,
          keyboardType: TextInputType.number,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'এনআইডি নম্বরটি লিখুন';
            if (v.trim().length < 6) return 'এনআইডি নম্বরটি অত্যন্ত ছোট';
            return null;
          },
          style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
          decoration: _inputDecoration(
            'এনআইডি নম্বরটি টাইপ করুন',
            Icons.badge_outlined,
            softBg,
            focusColor,
          ),
        ),
        const SizedBox(height: 12),

        // Trade License
        _inputLabel('ট্রেড লাইসেন্স নম্বর (ঐচ্ছিক)'),
        TextFormField(
          controller: _tradeLicenseController,
          style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
          decoration: _inputDecoration(
            'ট্রেড লাইসেন্স নম্বরটি টাইপ করুন',
            Icons.description_outlined,
            softBg,
            focusColor,
          ),
        ),
        const SizedBox(height: 12),

        // Categories
        _inputLabel('কোন প্রোডাক্ট ক্যাটাগরি নিয়ে কাজ করবেন?*'),
        TextFormField(
          controller: _categoriesController,
          maxLines: 2,
          validator: (v) {
            if (v == null || v.trim().isEmpty)
              return 'কিছু ক্যাটাগরির নাম লিখুন';
            return null;
          },
          style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
          decoration: _inputDecoration(
            'যেমন: থ্রি-পিস, শার্ট, খেলনা, খাবার ইত্যাদি',
            Icons.category_outlined,
            softBg,
            focusColor,
          ),
        ),
        const SizedBox(height: 20),

        // Next Step Button
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: _goToNextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: focusColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'পরবর্তী ধাপ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // STEP 2 Layout: Document images upload
  Widget _buildUploadStep(Color softBg, Color focusColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.photo_library_outlined, size: 16, color: focusColor),
            const SizedBox(width: 6),
            const Text(
              'প্রয়োজনীয় ডকুমেন্টসমূহ আপলোড করুন',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Premium 3-Column Document Picker Grid
        Row(
          children: [
            Expanded(
              child: _imagePickerCard(
                title: 'NID ফ্রন্ট',
                image: _nidFrontImage,
                onTap: () => _pickImage(1),
                onClear: () => _clearImage(1),
                accentColor: focusColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _imagePickerCard(
                title: 'NID ব্যাক',
                image: _nidBackImage,
                onTap: () => _pickImage(2),
                onClear: () => _clearImage(2),
                accentColor: focusColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _imagePickerCard(
                title: 'নিজের ছবি',
                image: _selfieImage,
                onTap: () => _pickImage(3),
                onClear: () => _clearImage(3),
                accentColor: focusColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Control Buttons (Back and Submit)
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _goToPreviousStep,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'পূর্ববর্তী ধাপ',
                  style: TextStyle(
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: focusColor,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'আবেদন জমা দিন',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _inputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String placeholder,
    IconData prefix,
    Color softBg,
    Color focusColor,
  ) {
    return InputDecoration(
      hintText: placeholder,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5),
      prefixIcon: Icon(
        prefix,
        color: focusColor.withValues(alpha: 0.7),
        size: 18,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: focusColor, width: 1.5),
      ),
      errorStyle: const TextStyle(fontSize: 11, height: 0.8),
    );
  }

  Widget _imagePickerCard({
    required String title,
    required XFile? image,
    required VoidCallback onTap,
    required VoidCallback onClear,
    required Color accentColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: image != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kIsWeb
                        ? Image.network(
                            image.path,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : Image.file(
                            File(image.path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: onClear,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_photo_alternate_rounded,
                      color: accentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF475569),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
