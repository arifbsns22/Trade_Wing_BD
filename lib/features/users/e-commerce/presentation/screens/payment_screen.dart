import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trade_wign_bd/common/services/notification_helper.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/controllers/cart_controller.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/widgets/ecommerce_appbar.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import 'package:trade_wign_bd/features/admin/settings/presentation/controllers/admin_settings_controller.dart';
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

  // Delivery selection states
  String _selectedDeliveryProvider = '';
  bool _isInsideDhaka = true;
  double _deliveryCharge = 0.0;

  // New Address selection states and controllers
  String? _selectedDivision;
  String? _selectedDistrict;
  final _houseCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _postcodeCtrl = TextEditingController();

  final Map<String, List<String>> _bangladeshAddressData = {
    'ঢাকা বিভাগ': [
      'ঢাকা জেলা',
      'ফরিদপুর জেলা',
      'গাজীপুর জেলা',
      'গোপালগঞ্জ জেলা',
      'কিশোরগঞ্জ জেলা',
      'মাদারীপুর জেলা',
      'মানিকগঞ্জ জেলা',
      'মুন্সীগঞ্জ জেলা',
      'নারায়ণগঞ্জ জেলা',
      'নরসিংদী জেলা',
      'রাজবাড়ী জেলা',
      'শরীয়তপুর জেলা',
      'টাঙ্গাইল জেলা'
    ],
    'খুলনা বিভাগ': [
      'বাগেরহাট জেলা',
      'চুয়াডাঙ্গা জেলা',
      'যশোর জেলা',
      'ঝিনাইদহ জেলা',
      'খুলনা জেলা',
      'কুষ্টিয়া জেলা',
      'মাগুরা জেলা',
      'মেহেরপুর জেলা',
      'নড়াইল জেলা',
      'সাতক্ষীরা জেলা'
    ],
    'চট্টগ্রাম বিভাগ': [
      'বান্দরবান জেলা',
      'ব্রাহ্মণবাড়িয়া জেলা',
      'চাঁদপুর জেলা',
      'চট্টগ্রাম জেলা',
      'কুমিল্লা জেলা',
      'কক্সবাজার জেলা',
      'ফেনী জেলা',
      'খাগড়াছড়ি জেলা',
      'লক্ষ্মীপুর জেলা',
      'নোয়াখালী জেলা',
      'রাঙ্গামাটি পার্বত্য জেলা'
    ],
    'রাজশাহী বিভাগ': [
      'বগুড়া জেলা',
      'জয়পুরহাট জেলা',
      'নওগাঁ জেলা',
      'নাটোর জেলা',
      'চাঁপাইনবাবগঞ্জ জেলা',
      'পাবনা জেলা',
      'রাজশাহী জেলা',
      'সিরাজগঞ্জ জেলা'
    ],
    'সিলেট বিভাগ': [
      'হবিগঞ্জ জেলা',
      'মৌলভীবাজার জেলা',
      'সুনামগঞ্জ জেলা',
      'সিলেট জেলা'
    ],
    'রংপুর বিভাগ': [
      'দিনাজপুর জেলা',
      'গাইবান্ধা জেলা',
      'কুড়িগ্রাম জেলা',
      'লালমনিরহাট জেলা',
      'নীলফামারী জেলা',
      'পঞ্চগড় জেলা',
      'রংপুর জেলা',
      'ঠাকুরগাঁও জেলা'
    ],
    'ময়মনসিংহ বিভাগ': [
      'জামালপুর জেলা',
      'ময়মনসিংহ জেলা',
      'নেত্রকোণা জেলা',
      'শেরপুর জেলা'
    ],
    'বরিশাল বিভাগ': [
      'বরগুনা জেলা',
      'বরিশাল জেলা',
      'ভোলা জেলা',
      'ঝালকাঠি জেলা',
      'পটুয়াখালী জেলা',
      'পিরোজপুর জেলা'
    ]
  };

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
  double _walletBalance = 0.0;
  bool _useWalletBalance = false;

  @override
  void initState() {
    super.initState();
    _fetchUserAddress();
    _fetchWalletBalance();
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
    _houseCtrl.dispose();
    _areaCtrl.dispose();
    _postcodeCtrl.dispose();
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
          _parseAddressDetails(address);
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

  void _parseAddressDetails(String addr) {
    final houseMatch = RegExp(r'বাসা:\s*([^,]+)').firstMatch(addr);
    final streetMatch = RegExp(r'(রাস্তা|এলাকা):\s*([^,]+)').firstMatch(addr);
    final cityMatch = RegExp(r'(শহর|জেলা):\s*([^,]+)').firstMatch(addr);
    final divisionMatch = RegExp(r'বিভাগ:\s*([^,]+)').firstMatch(addr);
    final postcodeMatch = RegExp(r'পোস্টকোড:\s*([^,]+)').firstMatch(addr);

    if (houseMatch != null) {
      _houseCtrl.text = houseMatch.group(1)!.trim();
    }
    if (streetMatch != null) {
      _areaCtrl.text = streetMatch.group(2)!.trim();
    }
    if (postcodeMatch != null) {
      _postcodeCtrl.text = postcodeMatch.group(1)!.trim();
    }

    if (divisionMatch != null) {
      final div = divisionMatch.group(1)!.trim();
      if (_bangladeshAddressData.containsKey(div)) {
        _selectedDivision = div;
      }
    }

    if (cityMatch != null && _selectedDivision != null) {
      final dist = cityMatch.group(2)!.trim();
      final list = _bangladeshAddressData[_selectedDivision];
      if (list != null && list.contains(dist)) {
        _selectedDistrict = dist;
        _isInsideDhaka = (dist == 'ঢাকা জেলা');
      }
    }
  }

  Future<void> _fetchWalletBalance() async {
    final AuthController authCtrl = Get.find<AuthController>();
    if (authCtrl.currentUserRole.value == 'Guest Customer') {
      return;
    }
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(authCtrl.currentUserMobile.value)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data() ?? {};
        setState(() {
          _walletBalance = (data['walletBalance'] ?? 0.0).toDouble();
        });
      }
    } catch (e) {
      debugPrint("Error fetching wallet balance: $e");
    }
  }

  double _calculateCartTotalWeight() {
    final cartCtrl = Get.find<CartController>();
    double totalWeight = 0.0;
    for (final product in cartCtrl.cartProductList) {
      final int qty = cartCtrl.getProductQuantity(product.id ?? product.name);
      totalWeight += (product.weight * qty);
    }
    return totalWeight;
  }

  double _calculateDeliveryCharge() {
    final adminSettings = Get.isRegistered<AdminSettingsController>()
        ? Get.find<AdminSettingsController>()
        : Get.put(AdminSettingsController());

    if (_selectedDeliveryProvider == 'manual') {
      if (adminSettings.isWeightWiseChargeActive.value) {
        final double totalWeight = _calculateCartTotalWeight();
        final double baseWeight = adminSettings.weightBaseMax.value;
        final double baseCharge = _isInsideDhaka 
            ? adminSettings.weightBaseChargeInside.value 
            : adminSettings.weightBaseChargeOutside.value;
            
        if (totalWeight <= baseWeight) {
          return baseCharge;
        } else {
          final double extraWeight = totalWeight - baseWeight;
          final int extraKg = extraWeight.ceil();
          return baseCharge + (extraKg * adminSettings.weightPerKgChargeExtra.value);
        }
      } else {
        return _isInsideDhaka ? 60.0 : 120.0;
      }
    } else if (_selectedDeliveryProvider == 'steadfast') {
      return _isInsideDhaka ? 60.0 : 120.0;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authCtrl = Get.find<AuthController>();
    final adminSettings = Get.isRegistered<AdminSettingsController>()
        ? Get.find<AdminSettingsController>()
        : Get.put(AdminSettingsController());

    if (_selectedDeliveryProvider.isEmpty) {
      if (adminSettings.isManualDeliveryActive.value) {
        _selectedDeliveryProvider = 'manual';
      } else if (adminSettings.isSteadfastActive.value) {
        _selectedDeliveryProvider = 'steadfast';
      }
    }

    return Obx(() {
      final double deliveryCost = _calculateDeliveryCharge();
      final double totalWithDelivery = widget.total + deliveryCost;
      final double walletDiscount = _useWalletBalance ? (_walletBalance > totalWithDelivery ? totalWithDelivery : _walletBalance) : 0.0;
      final double finalTotal = totalWithDelivery - walletDiscount;

      _deliveryCharge = deliveryCost;

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
                          // 1. Division Dropdown
                          _inputLabel('বিভাগ *'),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _selectedDivision,
                            decoration: _dropdownDecor('বিভাগ নির্বাচন করুন'),
                            items: _bangladeshAddressData.keys.map((division) {
                              return DropdownMenuItem<String>(
                                value: division,
                                child: Text(division, style: const TextStyle(fontSize: 14)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedDivision = val;
                                _selectedDistrict = null; // Reset district
                              });
                            },
                          ),
                          const SizedBox(height: 14),

                          // 2. District Dropdown
                          _inputLabel('জেলা *'),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _selectedDistrict,
                            decoration: _dropdownDecor('জেলা নির্বাচন করুন'),
                            items: _selectedDivision == null
                                ? []
                                : _bangladeshAddressData[_selectedDivision]!.map((district) {
                                    return DropdownMenuItem<String>(
                                      value: district,
                                      child: Text(district, style: const TextStyle(fontSize: 14)),
                                    );
                                  }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedDistrict = val;
                                if (val != null) {
                                  _isInsideDhaka = (val == 'ঢাকা জেলা');
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 14),

                          // 3. Area Name
                          _inputLabel('এলাকার নাম *'),
                          const SizedBox(height: 6),
                          _cardTextField(
                            controller: _areaCtrl,
                            hint: 'যেমন: নতুন বাজার / উত্তর বাড্ডা',
                          ),
                          const SizedBox(height: 14),

                          // 4. House Name/Number
                          _inputLabel('বাসার নাম/নাম্বার *'),
                          const SizedBox(height: 6),
                          _cardTextField(
                            controller: _houseCtrl,
                            hint: 'যেমন: কিরণ টাওয়ার, ফ্ল্যাট ৪বি',
                          ),
                          const SizedBox(height: 14),

                          // 5. Post code / Zip code
                          _inputLabel('পোস্টকোড / জিপকোড *'),
                          const SizedBox(height: 6),
                          _cardTextField(
                            controller: _postcodeCtrl,
                            hint: 'যেমন: ১২১২',
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ],
                    ),
            ),
            const SizedBox(height: 20),
            _buildDeliverySelectionSection(adminSettings),
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
             // ── Wallet Balance ────────────────────────────────────────
            if (authCtrl.currentUserRole.value != 'Guest Customer' && _walletBalance > 0) ...[
              const SizedBox(height: 20),
              _sectionLabel('মানিব্যাগ ব্যালেন্স'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: _cardDecor(),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF08B3AC)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '৳${_walletBalance.toStringAsFixed(2)} ব্যবহার করুন',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'অর্ডার থেকে এই অর্থ ছাড় পাওয়া যাবে।',
                            style: TextStyle(fontSize: 11, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _useWalletBalance,
                      onChanged: (val) {
                        setState(() {
                          _useWalletBalance = val;
                        });
                      },
                      activeTrackColor: AppColors.primaryColor,
                    ),
                  ],
                ),
              ),
            ],
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
                  _summaryRow(
                    'ডেলিভারি ফি${adminSettings.isWeightWiseChargeActive.value && _selectedDeliveryProvider == 'manual' ? ' (ওজন: ${_calculateCartTotalWeight().toStringAsFixed(1)} KG)' : ''}',
                    _deliveryCharge > 0.0 ? '৳${_deliveryCharge.toStringAsFixed(2)}' : 'ফ্রি 🎁',
                  ),
                  const SizedBox(height: 8),
                  if (_useWalletBalance && walletDiscount > 0.0) ...[
                    _summaryRow(
                      'মানিব্যাগ ডিসকাউন্ট',
                      '- ৳${walletDiscount.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 8),
                  ],
                  Divider(color: Colors.grey.shade100),
                  const SizedBox(height: 8),
                  _summaryRow(
                    'মোট',
                    '৳${finalTotal.toStringAsFixed(2)}',
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
                          ? 'রেজিস্ট্রেশন করুন এবং অর্ডার দিন ৳${finalTotal.toStringAsFixed(2)}'
                          : 'অর্ডার নিশ্চিত করুন ৳${finalTotal.toStringAsFixed(2)}',
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
    });
  }

  Future<void> _handlePlaceOrder() async {
    final AuthController authCtrl = Get.find<AuthController>();

    // 0. Address Validation & Compilation
    String compiledAddress;
    if (_editAddressMode || authCtrl.currentUserRole.value == 'Guest Customer') {
      if (_selectedDivision == null ||
          _selectedDistrict == null ||
          _areaCtrl.text.trim().isEmpty ||
          _houseCtrl.text.trim().isEmpty ||
          _postcodeCtrl.text.trim().isEmpty) {
        Get.snackbar(
          'ঠিকানা প্রয়োজন',
          'অনুগ্রহ করে ঠিকানার সবগুলি প্রয়োজনীয় ঘর পূরণ করুন।',
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          colorText: Colors.black87,
          borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
          borderWidth: 1,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return;
      }
      compiledAddress = 'বাসা: ${_houseCtrl.text.trim()}, এলাকা: ${_areaCtrl.text.trim()}, জেলা: $_selectedDistrict, বিভাগ: $_selectedDivision, পোস্টকোড: ${_postcodeCtrl.text.trim()}';
    } else {
      compiledAddress = _savedAddress;
    }

    _addressCtrl.text = compiledAddress;

    if (_selectedMethod == 'offline') {
      if (_offlineSenderMobileCtrl.text.trim().isEmpty ||
          _offlineTrxIdCtrl.text.trim().isEmpty) {
        Get.snackbar(
          'ত্রুটি',
          'অনুগ্রহ করে মোবাইল নম্বর এবং TrxID প্রদান করুন।',
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          colorText: Colors.black87,
          borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
          borderWidth: 1,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
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
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          colorText: Colors.black87,
          borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
          borderWidth: 1,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return;
      }
      if (password.length < 6) {
        Get.snackbar(
          'ত্রুটি',
          'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে।',
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          colorText: Colors.black87,
          borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
          borderWidth: 1,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return;
      }
      if (password != confirmPassword) {
        Get.snackbar(
          'ত্রুটি',
          'পাসওয়ার্ড এবং কনফার্ম পাসওয়ার্ড মেলেনি।',
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          colorText: Colors.black87,
          borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
          borderWidth: 1,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return;
      }
      if (!_regAcceptTerms) {
        Get.snackbar(
          'ত্রুটি',
          'দয়া করে শর্তাবলী মেনে নেওয়ার ঘরে টিক দিন।',
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          colorText: Colors.black87,
          borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
          borderWidth: 1,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
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
              .update({'address': compiledAddress});
          // Proceed to confirm order
          await _confirmOrder();
        } else {
          setState(() => _isConfirming = false);
          Get.snackbar(
            'লগইন ব্যর্থ',
            'স্বয়ংক্রিয় লগইন ব্যর্থ হয়েছে। অনুগ্রহ করে লগইন করুন।',
            backgroundColor: Colors.white.withValues(alpha: 0.9),
            colorText: Colors.black87,
            borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
            borderWidth: 1,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
          );
        }
      } else {
        setState(() => _isConfirming = false);
        Get.snackbar(
          'রেজিস্ট্রেশন ব্যর্থ',
          regResult,
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          colorText: Colors.black87,
          borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
          borderWidth: 1,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    } else {
      setState(() => _isConfirming = true);

      // Save delivery address to user's profile in Firestore
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(authCtrl.currentUserMobile.value)
            .update({'address': compiledAddress});
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

    final double subtotal = widget.total;
    final double deliveryCost = _deliveryCharge;
    final double totalWithDelivery = subtotal + deliveryCost;
    final double discount = _useWalletBalance ? (_walletBalance > totalWithDelivery ? totalWithDelivery : _walletBalance) : 0.0;
    final double finalTotal = totalWithDelivery - discount;

    // Save to Firestore
    try {
      if (discount > 0.0) {
        final userRef = FirebaseFirestore.instance.collection('users').doc(authCtrl.currentUserMobile.value);
        await userRef.update({
          'walletBalance': FieldValue.increment(-discount),
        });

        // Add a wallet transaction document
        await userRef.collection('wallet_transactions').add({
          'type': 'purchase',
          'amount': discount,
          'createdAt': FieldValue.serverTimestamp(),
          'description': 'অর্ডারে ডিসকাউন্ট হিসেবে ব্যবহার করা হয়েছে (ID: $orderId)।',
        });
      }

      final orderModel = OrderModel(
        orderId: orderId,
        userMobile: authCtrl.currentUserMobile.value,
        userName: authCtrl.currentUserName.value,
        address: _addressCtrl.text.trim(),
        items: itemsData,
        totalAmount: finalTotal,
        rewardPointsEarned: totalRewardPoints,
        walletDiscount: discount,
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
        deliveryProvider: _selectedDeliveryProvider == 'steadfast' ? 'Steadfast' : 'Manual',
      );

      // Check if this order contains a vendor product
      String? vendorMobile;
      double totalVendorProfit = 0.0;
      double totalVendorPurchasePrice = 0.0;
      bool isVendorOrder = false;

      // Get the reseller commission percentage
      double resellerCommissionPercent = 5.0;
      try {
        final settingsDoc = await FirebaseFirestore.instance.collection('app_settings').doc('global').get();
        if (settingsDoc.exists) {
          resellerCommissionPercent = (settingsDoc.data()?['resellerCommission'] as num?)?.toDouble() ?? 5.0;
        }
      } catch (e) {
        debugPrint("Error loading reseller commission setting: $e");
      }

      String? resellerMobile;
      double totalResellerEarnings = 0.0;
      double totalAdminCommission = 0.0;
      bool isResellerOrder = false;

      for (final item in itemsData) {
        final pId = item['productId'] as String?;
        if (pId != null) {
          if (pId.startsWith('vendor_')) {
            isVendorOrder = true;
            try {
              final prodDoc = await FirebaseFirestore.instance.collection('products').doc(pId).get();
              if (prodDoc.exists) {
                final pData = prodDoc.data();
                if (pData != null) {
                  vendorMobile = pData['vendorMobile'] as String?;
                  final double vendorPrice = (pData['vendorPrice'] as num?)?.toDouble() ?? 0.0;
                  final double customerPrice = (item['price'] as num?)?.toDouble() ?? 0.0;
                  final int qty = (item['quantity'] as num?)?.toInt() ?? 1;
                  totalVendorProfit += (customerPrice - vendorPrice) * qty;
                  totalVendorPurchasePrice += vendorPrice * qty;
                }
              }
            } catch (e) {
              debugPrint("Error fetching vendor product details: $e");
            }
          } else if (pId.startsWith('reseller_')) {
            isResellerOrder = true;
            try {
              final prodDoc = await FirebaseFirestore.instance.collection('products').doc(pId).get();
              if (prodDoc.exists) {
                final pData = prodDoc.data();
                if (pData != null) {
                  resellerMobile = pData['resellerMobile'] as String?;
                  final double customerPrice = (item['price'] as num?)?.toDouble() ?? 0.0;
                  final int qty = (item['quantity'] as num?)?.toInt() ?? 1;
                  final double itemTotal = customerPrice * qty;
                  final double comm = (itemTotal * resellerCommissionPercent) / 100.0;
                  totalAdminCommission += comm;
                  totalResellerEarnings += (itemTotal - comm);
                }
              }
            } catch (e) {
              debugPrint("Error fetching reseller product details: $e");
            }
          }
        }
      }

      final Map<String, dynamic> orderMap = orderModel.toMap();
      orderMap['deliveryCharge'] = _deliveryCharge;

      if (isVendorOrder && vendorMobile != null) {
        orderMap['vendorMobile'] = vendorMobile;
        orderMap['vendorProfit'] = totalVendorProfit;
        orderMap['vendorPurchasePrice'] = totalVendorPurchasePrice;
        orderMap['isVendorOrder'] = true;
      }

      if (isResellerOrder && resellerMobile != null) {
        orderMap['resellerMobile'] = resellerMobile;
        orderMap['resellerEarnings'] = totalResellerEarnings;
        orderMap['adminCommission'] = totalAdminCommission;
        orderMap['isResellerOrder'] = true;
      }

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .set(orderMap);

      // Send real-time notification to Admin
      await NotificationHelper.sendNotification(
        title: 'নতুন অর্ডার এসেছে! 🛒',
        body: 'গ্রাহক ${orderModel.userName} ৳${orderModel.totalAmount.toStringAsFixed(2)} মূল্যের একটি অর্ডার দিয়েছেন।',
        type: 'new_order',
        isAdmin: true,
      );
    } catch (e) {
      setState(() => _isConfirming = false);
      Get.snackbar(
  'ত্রুটি',
  'অর্ডার সংরক্ষণ করতে সমস্যা হয়েছে: $e',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
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
      '৳${finalTotal.toStringAsFixed(2)} মূল্যের আপনার অর্ডারটি সফলভাবে গ্রহণ করা হয়েছে।',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
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

  InputDecoration _dropdownDecor(String hint) {
    return InputDecoration(
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    );
  }

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

  Widget _buildDeliverySelectionSection(AdminSettingsController adminSettings) {
    final List<Map<String, dynamic>> activeProviders = [];
    if (adminSettings.isManualDeliveryActive.value) {
      activeProviders.add({
        'id': 'manual',
        'name': adminSettings.manualDeliveryName.value,
        'time': adminSettings.manualDeliveryTime.value,
        'icon': Icons.directions_run_rounded,
      });
    }
    if (adminSettings.isSteadfastActive.value) {
      activeProviders.add({
        'id': 'steadfast',
        'name': 'Steadfast Courier',
        'time': '২-৪ দিন',
        'icon': Icons.airport_shuttle_rounded,
      });
    }

    if (_selectedDeliveryProvider.isEmpty && activeProviders.isNotEmpty) {
      _selectedDeliveryProvider = activeProviders.first['id']!;
    }

    if (activeProviders.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('ডেলিভারি এরিয়া ও কুরিয়ার নির্বাচন'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecor(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _inputLabel('ডেলিভারি এলাকা *'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('ঢাকার ভিতরে (৳৬০)', style: TextStyle(fontWeight: FontWeight.bold))),
                      selected: _isInsideDhaka,
                      selectedColor: AppColors.primaryColor.withValues(alpha: 0.15),
                      labelStyle: TextStyle(color: _isInsideDhaka ? AppColors.primaryColor : Colors.black87),
                      checkmarkColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: _isInsideDhaka ? AppColors.primaryColor : Colors.grey.shade300),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _isInsideDhaka = true;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('ঢাকার বাইরে (৳১২০)', style: TextStyle(fontWeight: FontWeight.bold))),
                      selected: !_isInsideDhaka,
                      selectedColor: AppColors.primaryColor.withValues(alpha: 0.15),
                      labelStyle: TextStyle(color: !_isInsideDhaka ? AppColors.primaryColor : Colors.black87),
                      checkmarkColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: !_isInsideDhaka ? AppColors.primaryColor : Colors.grey.shade300),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _isInsideDhaka = false;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _inputLabel('পছন্দসই কুরিয়ার প্রোভাইডার নির্বাচন করুন *'),
              const SizedBox(height: 8),
              Column(
                children: activeProviders.map((provider) {
                  final bool isSelected = _selectedDeliveryProvider == provider['id'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDeliveryProvider = provider['id'];
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryColor.withValues(alpha: 0.05) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryColor : Colors.grey.shade200,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            provider['icon'] as IconData,
                            color: isSelected ? AppColors.primaryColor : Colors.grey.shade600,
                            size: 22,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provider['name'] as String,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isSelected ? AppColors.primaryColor : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'আনুমানিক সময়: ${provider['time']}',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle_rounded, color: AppColors.primaryColor, size: 20)
                          else
                            Icon(Icons.circle_outlined, color: Colors.grey.shade300, size: 20),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
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
