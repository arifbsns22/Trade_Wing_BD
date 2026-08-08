import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import 'package:trade_wign_bd/features/admin/packages/domain/models/package_model.dart';
import 'package:trade_wign_bd/features/admin/settings/presentation/controllers/admin_settings_controller.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import 'package:trade_wign_bd/features/common/profile/presentation/controllers/admin_profile_controller.dart';
import 'package:trade_wign_bd/features/users/e-commerce/domain/models/order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trade_wign_bd/common/services/notification_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showPackagePaymentSheet(
  BuildContext context,
  SubscriptionPackage package,
) async {
  final authCtrl = AuthController.instance;
  final mobile = authCtrl.currentUserMobile.value;

  // Force user to update address if empty
  if (mobile.isNotEmpty) {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(mobile).get();
      final address = doc.data()?['address'] as String?;
      
      if (address == null || address.trim().isEmpty) {
        Get.snackbar(
  'সতর্কতা',
  'প্যাকেজ কেনার আগে অনুগ্রহ করে "আমার প্রোফাইল" -> "আমার ঠিকানা" থেকে আপনার ঠিকানা আপডেট করুন।',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
        return;
      }
    } catch (e) {
      debugPrint('Error checking address: $e');
    }
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _PackagePaymentSheet(package: package),
  );
}

class _PackagePaymentSheet extends StatefulWidget {
  final SubscriptionPackage package;
  const _PackagePaymentSheet({required this.package});

  @override
  State<_PackagePaymentSheet> createState() => _PackagePaymentSheetState();
}

class _PackagePaymentSheetState extends State<_PackagePaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nidController = TextEditingController();
  final _tradeLicenseController = TextEditingController();
  final _offlineTrxIdCtrl = TextEditingController();
  final _offlineSenderMobileCtrl = TextEditingController();

  File? _nidFrontImage;
  File? _nidBackImage;
  String _selectedOfflineGateway = 'bkash';

  final ImagePicker _picker = ImagePicker();
  final AdminSettingsController _settingsController = Get.put(
    AdminSettingsController(),
  );

  bool get _isCustomer {
    final role = AuthController.instance.currentUserRole.value.toLowerCase();
    return role == 'customer' || role == 'guest customer';
  }

  Future<void> _pickImage(bool isFront) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isFront) {
          _nidFrontImage = File(pickedFile.path);
        } else {
          _nidBackImage = File(pickedFile.path);
        }
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_isCustomer && (_nidFrontImage == null || _nidBackImage == null)) {
        Get.snackbar(
  'ত্রুটি',
  'এনআইডি এর সামনের এবং পেছনের ছবি আপলোড করুন',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
        return;
      }

      Get.back(); // close sheet

      final authCtrl = AuthController.instance;
      final mobile = authCtrl.currentUserMobile.value;
      final orderId = 'PKG-${DateTime.now().millisecondsSinceEpoch}';

      if (mobile.isNotEmpty) {
        try {
          String userAddress = 'Digital Delivery (Package Upgrade)';
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(mobile).get();
          if (userDoc.exists) {
            final data = userDoc.data();
            if (data != null && data['address'] != null && data['address'].toString().isNotEmpty) {
              userAddress = data['address'].toString();
            }
          }

          // Add the package purchase as an order using OrderModel
          final orderModel = OrderModel(
            orderId: orderId,
            userMobile: mobile,
            userName: authCtrl.currentUserName.value,
            address: userAddress,
            items: [
              {
                'productName': 'Package: ${widget.package.name}',
                'quantity': 1,
                'price': widget.package.price,
                'image': widget.package.image ?? '',
              }
            ],
            totalAmount: widget.package.price,
            rewardPointsEarned: 0,
            paymentMethod: 'offline',
            offlineGateway: _selectedOfflineGateway,
            offlineTrxId: _offlineTrxIdCtrl.text,
            offlineSenderMobile: _offlineSenderMobileCtrl.text,
            orderStatus: OrderStatus.pending,
            paymentStatus: PaymentStatus.pending,
            createdAt: DateTime.now(),
          );

          await FirebaseFirestore.instance
              .collection('orders')
              .doc(orderId)
              .set(orderModel.toMap());

          // Send admin notification
          await NotificationHelper.sendNotification(
            title: 'নতুন প্যাকেজ অর্ডার! 📦',
            body: '${authCtrl.currentUserName.value} (${authCtrl.currentUserMobile.value}) ৳${widget.package.price} মূল্যের "${widget.package.name}" প্যাকেজটি কেনার অর্ডার করেছেন।',
            type: 'package_order',
            userMobile: authCtrl.currentUserMobile.value,
            isAdmin: true,
          );
        } catch (e) {
          debugPrint('Error creating package order: $e');
        }
      }

      if (_isCustomer) {
        if (mobile.isNotEmpty) {
          try {
            // Retrieve user's referral code and count referrals
            final userDoc = await FirebaseFirestore.instance.collection('users').doc(mobile).get();
            final userData = userDoc.data() ?? {};
            final myReferralCode = (userData['referralCode'] as String? ?? '').trim();

            int directCount = 0;
            if (myReferralCode.isNotEmpty) {
              final refsSnapshot = await FirebaseFirestore.instance
                  .collection('users')
                  .where('referredBy', isEqualTo: myReferralCode)
                  .get();
              directCount = refsSnapshot.docs.length;
            }

            final has30Refs = directCount >= 30;

            final Map<String, dynamic> updateData = {
              'packagePurchased': true,
              'nidNumber': _nidController.text,
              'tradeLicense': _tradeLicenseController.text,
            };

            if (has30Refs) {
              updateData['role'] = 'Active Customer';
            }

            await FirebaseFirestore.instance
                .collection('users')
                .doc(mobile)
                .set(updateData, SetOptions(merge: true));

            if (has30Refs) {
              authCtrl.currentUserRole.value = 'Active Customer';
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('userRole', 'Active Customer');
            }

            final profileCtrl = Get.put(AdminProfileController());
            await profileCtrl.fetchAdminProfile();

            Get.defaultDialog(
              title: has30Refs ? 'অভিনন্দন!' : 'পেমেন্ট সফল!',
              titleStyle: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.primaryColor,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    has30Refs
                        ? 'আপনি সফলভাবে Active Customer এ উন্নীত হয়েছেন।'
                        : 'আপনার মেম্বারশিপ প্যাকেজ কেনা সম্পন্ন হয়েছে! সক্রিয় কাস্টমার হতে আপনার কমপক্ষে ৩০ জন রেফারেল প্রয়োজন (আপনার বর্তমান রেফারেল: $directCount)।',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'আপনার বিজনেস কোড:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    profileCtrl.referralCode.value,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: AppColors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'এখন থেকে প্যাকেজ কেনার সময় আর NID বা Trade License এর প্রয়োজন হবে না।',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ],
              ),
              confirm: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                ),
                child: const Text('ঠিক আছে', style: TextStyle(color: Colors.white)),
              ),
            );
          } catch (e) {
            debugPrint('Error updating role: $e');
          }
        }
      } else {
        Get.snackbar(
  'সফল',
  'পেমেন্ট রিকোয়েস্ট পাঠানো হয়েছে। এডমিন যাচাই করার পর আপনার প্যাকেজটি সক্রিয় হবে।',
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

  @override
  Widget build(BuildContext context) {
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
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Upgrade to ${widget.package.name} (৳${widget.package.price.toStringAsFixed(0)})',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (_isCustomer) ...[
                // 1. NID Number
                _inputLabel('NID Number (এনআইডি নম্বর)'),
                const SizedBox(height: 6),
                _cardTextField(
                  controller: _nidController,
                  hint: 'এনআইডি নম্বর দিন',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),

                // 2. Trade Licence
                _inputLabel('Trade Licence Number (ঐচ্ছিক)'),
                const SizedBox(height: 6),
                _cardTextField(
                  controller: _tradeLicenseController,
                  hint: 'Trade Licence Number',
                ),
                const SizedBox(height: 20),

                // 3 & 4. NID Images
                Row(
                  children: [
                    Expanded(
                      child: _buildImageUploadBox(
                        title: 'NID Front',
                        image: _nidFrontImage,
                        onTap: () => _pickImage(true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildImageUploadBox(
                        title: 'NID Back',
                        image: _nidBackImage,
                        onTap: () => _pickImage(false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // 100% Exact Gateway UI from payment_screen.dart
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    // Gateway Selection Tabs (bKash & Nagad)
                    Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          _gatewayTab(
                            'bkash',
                            'assets/color_icons/finance/BKash-Icon-Logo.wine.png',
                            'bKash',
                          ),
                          _gatewayTab(
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
                            _offlineInstruction(
                              1,
                              'আপনার ${_selectedOfflineGateway == 'bkash' ? 'bKash' : 'Nagad'} অ্যাপ ওপেন করুন',
                            ),
                            _offlineInstruction(
                              2,
                              'সিলেক্ট করুন',
                              _selectedOfflineGateway == 'bkash'
                                  ? _settingsController.bkashPaymentOption.value
                                  : _settingsController
                                        .nagadPaymentOption
                                        .value,
                            ),
                            _offlineInstruction(
                              3,
                              'আমাদের ${_selectedOfflineGateway == 'bkash' ? _settingsController.bkashAccountType.value : _settingsController.nagadAccountType.value} অ্যাকাউন্ট নম্বরটি দিন',
                              _selectedOfflineGateway == 'bkash'
                                  ? _settingsController.bkashAccountNumber.value
                                  : _settingsController
                                        .nagadAccountNumber
                                        .value,
                            ),
                            _offlineInstruction(
                              4,
                              'মোট বিলের পরিমাণটি দিন',
                              '${widget.package.price.toStringAsFixed(2)} টাকা',
                            ),
                            _offlineInstruction(
                              5,
                              'এবার আপনার পিন নম্বরটি দিন',
                            ),
                            _offlineInstruction(
                              6,
                              'পেমেন্ট করতে ট্যাপ করে ধরে রাখুন',
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'সম্পন্ন হয়েছে! আপনি একটি কনফার্মেশন মেসেজ পাবেন।',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _inputLabel('মোবাইল নম্বর'),
                            const SizedBox(height: 6),
                            _cardTextField(
                              controller: _offlineSenderMobileCtrl,
                              hint: 'যে নম্বর থেকে টাকা পাঠিয়েছেন',
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 12),
                            _inputLabel('ট্রানজ্যাকশন আইডি (TrxID)'),
                            const SizedBox(height: 6),
                            _cardTextField(
                              controller: _offlineTrxIdCtrl,
                              hint: 'ট্রানজ্যাকশন আইডি',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _submit,
                  child: const Text(
                    'কনফার্ম পেমেন্ট ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Widget _inputLabel(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 12,
      color: Colors.grey.shade600,
      fontWeight: FontWeight.w600,
    ),
  );

  Widget _cardTextField({
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

  Widget _gatewayTab(String gatewayId, String iconPath, String label) {
    final bool isSelected = _selectedOfflineGateway == gatewayId;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedOfflineGateway = gatewayId),
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

  Widget _offlineInstruction(int step, String text, [String? highlightText]) {
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

  Widget _buildImageUploadBox({
    required String title,
    required File? image,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: kIsWeb
                    ? Image.network(image.path, fit: BoxFit.cover)
                    : Image.file(image, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.grey.shade400,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
      ),
    );
  }
}
