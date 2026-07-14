import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/controllers/cart_controller.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/widgets/ecommerce_appbar.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import 'package:trade_wign_bd/features/admin/settings/presentation/controllers/admin_settings_controller.dart';
import 'package:trade_wign_bd/common/ui/widgets/customAlertDialogue.dart';
import 'package:trade_wign_bd/common/ui/widgets/buttons/custom_elevated_button.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import 'package:trade_wign_bd/features/users/e-commerce/domain/models/order_model.dart';

class PaymentScreen extends StatefulWidget {
  final double total;
  const PaymentScreen({super.key, required this.total});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'cod';
  String _selectedOfflineGateway = 'bkash';

  // Offline Payment Manual inputs
  final _offlineSenderMobileCtrl = TextEditingController();
  final _offlineTrxIdCtrl = TextEditingController();

  final _nameCtrl = TextEditingController(text: 'Olivia Rhye');
  final _cardCtrl = TextEditingController(text: '1234 1234 1234 1234');
  final _expiryCtrl = TextEditingController(text: '06 / 2024');
  final _cvvCtrl = TextEditingController(text: '•••');

  // Delivery address controllers
  final _addressCtrl = TextEditingController();
  bool _isLoadingAddress = false;
  bool _hasSavedAddress = false;
  bool _editAddressMode = false;
  String _savedAddress = '';

  // Registration controllers for inline guest sign-up
  final _regNameCtrl = TextEditingController();
  final _regMobileCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPasswordCtrl = TextEditingController();
  final _regConfirmPasswordCtrl = TextEditingController();
  bool _regAcceptTerms = false;

  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    _fetchUserAddress();
  }

  @override
  void dispose() {
    _offlineSenderMobileCtrl.dispose();
    _offlineTrxIdCtrl.dispose();
    _nameCtrl.dispose();
    _cardCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _addressCtrl.dispose();
    _regNameCtrl.dispose();
    _regMobileCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPasswordCtrl.dispose();
    _regConfirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchUserAddress() async {
    final AuthController authCtrl = Get.find<AuthController>();
    if (authCtrl.currentUserRole.value == 'Guest Customer') {
      setState(() {
        _hasSavedAddress = false;
        _editAddressMode = true;
      });
      return;
    }

    setState(() => _isLoadingAddress = true);
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(authCtrl.currentUserMobile.value)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data();
        final address = data?['address'] as String?;
        if (address != null && address.trim().isNotEmpty) {
          setState(() {
            _savedAddress = address;
            _addressCtrl.text = address;
            _hasSavedAddress = true;
            _editAddressMode = false;
          });
        } else {
          setState(() {
            _hasSavedAddress = false;
            _editAddressMode = true;
          });
        }
      } else {
        setState(() {
          _hasSavedAddress = false;
          _editAddressMode = true;
        });
      }
    } catch (e) {
      debugPrint("Error fetching user address: $e");
    } finally {
      setState(() => _isLoadingAddress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authCtrl = Get.find<AuthController>();
    final adminSettings = Get.isRegistered<AdminSettingsController>()
        ? Get.find<AdminSettingsController>()
        : Get.put(AdminSettingsController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: EcommerceAppBar(title: 'পেমেন্ট'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Delivery Section ──────────────────────────────────────
            _sectionLabel('ডেলিভারি ঠিকানা'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecor(),
              child: _isLoadingAddress
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_hasSavedAddress && !_editAddressMode) ...[
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.green.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.location_on_rounded,
                                  color: AppColors.green,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      authCtrl.currentUserName.value.isNotEmpty
                                          ? authCtrl.currentUserName.value
                                          : 'প্রাপক',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'মোবাইল: ${authCtrl.currentUserMobile.value}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      'ঠিকানা: $_savedAddress',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() => _editAddressMode = true);
                                },
                                icon: Icon(
                                  Icons.edit_outlined,
                                  size: 14,
                                  color: AppColors.green,
                                ),
                                label: Text(
                                  'পরিবর্তন',
                                  style: TextStyle(
                                    color: AppColors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          // Editable Address Input Field
                          Row(
                            children: [
                              Icon(
                                Icons.location_city_rounded,
                                color: AppColors.green,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ডেলিভারি ঠিকানা',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.green,
                                ),
                              ),
                              if (_hasSavedAddress) ...[
                                const Spacer(),
                                TextButton(
                                  onPressed: () {
                                    setState(() => _editAddressMode = false);
                                  },
                                  child: const Text(
                                    'বাতিল',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 10),
                          _cardTextField(
                            controller: _addressCtrl,
                            hint: 'এখানে আপনার ডেলিভারি ঠিকানা লিখুন...',
                            maxLines: 2,
                          ),
                        ],
                      ],
                    ),
            ),
            const SizedBox(height: 20),

            // ── Inline Guest Registration (if guest) ────────────────────
            if (authCtrl.currentUserRole.value == 'Guest Customer') ...[
              _sectionLabel('অর্ডার করতে অ্যাকাউন্ট খুলুন'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _cardDecor(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'গেস্ট ব্যবহারকারীরা অর্ডার করতে পারবেন না। অর্ডার সম্পন্ন করতে নিচে রেজিস্ট্রেশন করুন।',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _inputLabel('পুরো নাম *'),
                    const SizedBox(height: 6),
                    _cardTextField(
                      controller: _regNameCtrl,
                      hint: 'আপনার পুরো নাম লিখুন',
                    ),
                    const SizedBox(height: 12),

                    _inputLabel('মোবাইল নম্বর *'),
                    const SizedBox(height: 6),
                    _cardTextField(
                      controller: _regMobileCtrl,
                      hint: 'আপনার মোবাইল নম্বর লিখুন',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),

                    _inputLabel('ইমেইল (ঐচ্ছিক)'),
                    const SizedBox(height: 6),
                    _cardTextField(
                      controller: _regEmailCtrl,
                      hint: 'আপনার ইমেইল ঠিকানা লিখুন (ঐচ্ছিক)',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),

                    _inputLabel('পাসওয়ার্ড *'),
                    const SizedBox(height: 6),
                    _cardTextField(
                      controller: _regPasswordCtrl,
                      hint: 'কমপক্ষে ৬ অক্ষর',
                      obscure: true,
                    ),
                    const SizedBox(height: 12),

                    _inputLabel('পাসওয়ার্ড নিশ্চিত করুন *'),
                    const SizedBox(height: 6),
                    _cardTextField(
                      controller: _regConfirmPasswordCtrl,
                      hint: 'আপনার পাসওয়ার্ডটি পুনরায় লিখুন',
                      obscure: true,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Checkbox(
                          value: _regAcceptTerms,
                          activeColor: AppColors.primaryColor,
                          onChanged: (val) {
                            setState(() => _regAcceptTerms = val ?? false);
                          },
                        ),
                        const Expanded(
                          child: Text(
                            'আমি সমস্ত শর্তাবলী মেনে নিচ্ছি',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Payment Method ────────────────────────────────────────
            _sectionLabel('পেমেন্ট পদ্ধতি'),
            const SizedBox(height: 10),
            Obx(() {
              final activeMethods = <Map<String, dynamic>>[];
              if (adminSettings.isCodActive.value) {
                activeMethods.add({
                  'id': 'cod',
                  'label': adminSettings.codName.value,
                  'icon': Icons.money_outlined,
                  'color': AppColors.green,
                });
              }
              if (adminSettings.isDigitalPaymentActive.value) {
                activeMethods.add({
                  'id': 'digital',
                  'label': adminSettings.digitalPaymentName.value,
                  'icon': Icons.payment_outlined,
                  'color': const Color(0xFF1A56DB),
                });
              }
              if (adminSettings.isOfflinePaymentActive.value) {
                activeMethods.add({
                  'id': 'offline',
                  'label': adminSettings.offlinePaymentName.value,
                  'icon': Icons.account_balance_outlined,
                  'color': const Color(0xFFEB001B),
                });
              }

              // Ensure selected method is valid, default to first available
              if (activeMethods.isNotEmpty &&
                  !activeMethods.any((m) => m['id'] == _selectedMethod)) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() => _selectedMethod = activeMethods.first['id']);
                });
              }

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: _cardDecor(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Method chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: activeMethods.map((m) {
                          final selected = _selectedMethod == m['id'];
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedMethod = m['id']),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primaryColor
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.primaryColor
                                      : Colors.grey.shade200,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    m['icon'],
                                    size: 20,
                                    color: selected ? Colors.white : m['color'],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    m['label'],
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: selected
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // Offline Payment Gateway Manual Input & Instructions
                    if (_selectedMethod == 'offline') ...[
                      const SizedBox(height: 20),
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
                              child: Column(
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
                                        ? adminSettings.bkashPaymentOption.value
                                        : adminSettings
                                              .nagadPaymentOption
                                              .value,
                                  ),
                                  _offlineInstruction(
                                    3,
                                    'আমাদের ${_selectedOfflineGateway == 'bkash' ? adminSettings.bkashAccountType.value : adminSettings.nagadAccountType.value} অ্যাকাউন্ট নম্বরটি দিন',
                                    _selectedOfflineGateway == 'bkash'
                                        ? adminSettings.bkashAccountNumber.value
                                        : adminSettings
                                              .nagadAccountNumber
                                              .value,
                                  ),
                                  _offlineInstruction(
                                    4,
                                    'মোট বিলের পরিমাণটি দিন',
                                    '${widget.total.toStringAsFixed(2)} টাকা',
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
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),

            // ── Order Summary ─────────────────────────────────────────
            _sectionLabel('অর্ডারের সারাংশ'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecor(),
              child: Column(
                children: [
                  _summaryRow(
                    'সাবটোটাল',
                    '৳${widget.total.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 8),
                  _summaryRow('ডেলিভারি ফি', 'ফ্রি 🎁'),
                  const SizedBox(height: 8),
                  Divider(color: Colors.grey.shade100),
                  const SizedBox(height: 8),
                  _summaryRow(
                    'মোট',
                    '৳${widget.total.toStringAsFixed(2)}',
                    bold: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Confirm button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: _isConfirming ? null : _handlePlaceOrder,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 56,
            decoration: BoxDecoration(
              color: _isConfirming ? AppColors.green : AppColors.green,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: _isConfirming
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primaryColor,
                      ),
                    )
                  : Text(
                      authCtrl.currentUserRole.value == 'Guest Customer'
                          ? 'রেজিস্ট্রেশন করুন এবং অর্ডার দিন ৳${widget.total.toStringAsFixed(2)}'
                          : 'অর্ডার নিশ্চিত করুন ৳${widget.total.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePlaceOrder() async {
    final AuthController authCtrl = Get.find<AuthController>();

    if (_selectedMethod == 'offline') {
      if (_offlineSenderMobileCtrl.text.trim().isEmpty ||
          _offlineTrxIdCtrl.text.trim().isEmpty) {
        Get.snackbar(
          'ত্রুটি',
          'অনুগ্রহ করে মোবাইল নম্বর এবং TrxID প্রদান করুন।',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }
    }

    // 1. If Guest, perform Inline Registration first
    if (authCtrl.currentUserRole.value == 'Guest Customer') {
      final name = _regNameCtrl.text.trim();
      final mobile = _regMobileCtrl.text.trim();
      final email = _regEmailCtrl.text.trim();
      final password = _regPasswordCtrl.text;
      final confirmPassword = _regConfirmPasswordCtrl.text;

      if (name.isEmpty || mobile.isEmpty || password.isEmpty) {
        Get.snackbar(
          'ত্রুটি',
          'দয়া করে সবগুলি প্রয়োজনীয় ঘর পূরণ করুন।',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }
      if (password.length < 6) {
        Get.snackbar(
          'ত্রুটি',
          'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে।',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }
      if (password != confirmPassword) {
        Get.snackbar(
          'ত্রুটি',
          'পাসওয়ার্ড এবং কনফার্ম পাসওয়ার্ড মেলেনি।',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }
      if (!_regAcceptTerms) {
        Get.snackbar(
          'ত্রুটি',
          'দয়া করে শর্তাবলী মেনে নেওয়ার ঘরে টিক দিন।',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }

      setState(() => _isConfirming = true);

      // Register the user
      final regResult = await authCtrl.register(
        name: name,
        mobile: mobile,
        email: email,
        password: password,
      );

      if (regResult == 'success') {
        // Automatically login the new user
        final loginResult = await authCtrl.login(
          mobile: mobile,
          password: password,
        );
        if (loginResult == 'success') {
          // Save typed address to profile
          await FirebaseFirestore.instance
              .collection('users')
              .doc(mobile)
              .update({'address': _addressCtrl.text.trim()});
          // Proceed to confirm order
          await _confirmOrder();
        } else {
          setState(() => _isConfirming = false);
          Get.snackbar(
            'লগইন ব্যর্থ',
            'স্বয়ংক্রিয় লগইন ব্যর্থ হয়েছে। অনুগ্রহ করে লগইন করুন।',
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
      } else {
        setState(() => _isConfirming = false);
        Get.snackbar(
          'রেজিস্ট্রেশন ব্যর্থ',
          regResult,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } else {
      // 2. Logged in user: Verify address
      final address = _addressCtrl.text.trim();
      if (address.isEmpty) {
        Get.snackbar(
          'ঠিকানা প্রয়োজন',
          'অনুগ্রহ করে আপনার ডেলিভারি ঠিকানা লিখুন।',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }

      setState(() => _isConfirming = true);

      // Save delivery address to user's profile in Firestore
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(authCtrl.currentUserMobile.value)
            .update({'address': address});
      } catch (e) {
        debugPrint("Error updating address: $e");
      }

      await _confirmOrder();
    }
  }

  Future<void> _confirmOrder() async {
    final authCtrl = Get.find<AuthController>();
    final cartCtrl = Get.find<CartController>();

    // Generate Order ID
    final String orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';

    // Calculate Reward Points & Prepare Items Map
    int totalRewardPoints = 0;
    List<Map<String, dynamic>> itemsData = [];

    for (final product in cartCtrl.cartProductList) {
      final int qty = cartCtrl.getProductQuantity(product.id ?? product.name);
      if (qty > 0) {
        final reward =
            product.roleRewards[authCtrl.currentUserRole.value] ??
            product.roleRewards['Customer'] ??
            0;
        totalRewardPoints += (reward * qty);
        itemsData.add({
          'productId': product.id,
          'productName': product.name,
          'price':
              product.rolePrices[authCtrl.currentUserRole.value] ??
              product.rolePrices['Customer'] ??
              0.0,
          'quantity': qty,
          'image': product.image,
        });
      }
    }

    // Save to Firestore
    try {
      final orderModel = OrderModel(
        orderId: orderId,
        userMobile: authCtrl.currentUserMobile.value,
        userName: authCtrl.currentUserName.value,
        address: _addressCtrl.text.trim(),
        items: itemsData,
        totalAmount: widget.total,
        rewardPointsEarned: totalRewardPoints,
        paymentMethod: _selectedMethod,
        offlineGateway: _selectedMethod == 'offline'
            ? _selectedOfflineGateway
            : null,
        offlineTrxId: _selectedMethod == 'offline'
            ? _offlineTrxIdCtrl.text.trim()
            : null,
        offlineSenderMobile: _selectedMethod == 'offline'
            ? _offlineSenderMobileCtrl.text.trim()
            : null,
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .set(orderModel.toMap());
    } catch (e) {
      setState(() => _isConfirming = false);
      Get.snackbar(
        'ত্রুটি',
        'অর্ডার সংরক্ষণ করতে সমস্যা হয়েছে: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isConfirming = false);

    // Clear cart
    try {
      cartCtrl.clearCart();
    } catch (_) {}

    Get.until((route) => route.isFirst); // go back to home

    Get.snackbar(
      '🎉 অর্ডার সফল হয়েছে!',
      '৳${widget.total.toStringAsFixed(2)} মূল্যের আপনার অর্ডারটি সফলভাবে গ্রহণ করা হয়েছে।',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFBEF264),
      colorText: AppColors.green,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      duration: const Duration(seconds: 4),
    );
  }

  BoxDecoration _cardDecor() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: Colors.grey.shade100, width: 1.5),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: Color(0xFF1A1A1A),
    ),
  );

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
    bool obscure = false,
    int maxLines = 1,
  }) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscure,
    maxLines: maxLines,
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

  Widget _summaryRow(String label, String value, {bool bold = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: bold ? const Color(0xFF1A1A1A) : Colors.grey.shade600,
          fontWeight: bold ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontSize: 13,
          color: bold ? AppColors.green : Colors.grey.shade700,
          fontWeight: bold ? FontWeight.bold : FontWeight.w600,
        ),
      ),
    ],
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
}

class _PaymentMethodData {
  final String label;
  final IconData? icon;
  final String? assetLabel;
  final Color color;

  _PaymentMethodData({
    required this.label,
    this.icon,
    this.assetLabel,
    required this.color,
  });
}
