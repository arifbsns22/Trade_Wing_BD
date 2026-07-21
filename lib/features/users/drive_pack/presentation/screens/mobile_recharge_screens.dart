import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/user_drive_pack_controller.dart';
import '../controllers/mobile_recharge_controller.dart';
import 'package:trade_wign_bd/features/users/drive_pack/domain/models/drive_package_model.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class MobileRechargeScreen extends StatefulWidget {
  final DrivePackageModel? prefilledOffer; // If passed, recharge screen is pre-configured for a drive offer
  const MobileRechargeScreen({super.key, this.prefilledOffer});

  @override
  State<MobileRechargeScreen> createState() => _MobileRechargeScreenState();
}

class _MobileRechargeScreenState extends State<MobileRechargeScreen> {
  final _rechargeController = Get.put(MobileRechargeController());
  final _userPackController = Get.put(UserDrivePackController());

  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _amountController = TextEditingController();

  final List<double> _quickAmounts = [50, 100, 200, 500, 1000];

  @override
  void initState() {
    super.initState();
    
    // Clear selected operator state initially
    _rechargeController.selectedOperator.value = null;

    if (widget.prefilledOffer != null) {
      final offer = widget.prefilledOffer!;
      _amountController.text = offer.offerPrice.toString();
      
      // Auto-assign prefilled operator
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final op = _userPackController.operators.firstWhereOrNull((o) => o.id == offer.operatorId);
        if (op != null) {
          _rechargeController.selectedOperator.value = op;
        }
      });
    }

    // Auto-detect operator whenever phone number changes (typing, pasting, prefilling)
    _numberController.addListener(() {
      _onNumberChanged(_numberController.text);
    });
  }

  void _onNumberChanged(String val) {
    // Dynamic operator detection based on prefixes (e.g. 017 -> GP)
    final detected = _rechargeController.detectOperator(val, _userPackController.operators);
    if (detected != null) {
      _rechargeController.selectedOperator.value = detected;
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_rechargeController.selectedOperator.value == null) {
      Get.snackbar(
        'ত্রুটি',
        'রিচার্জ করতে একটি অপারেটর নির্বাচন করুন।',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: Colors.red.withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    
    // Security check: minimum 50 Tk for regular recharges
    if (widget.prefilledOffer == null && amount < 50) {
      Get.snackbar(
        'ত্রুটি',
        'সর্বনিম্ন রিচার্জ পরিমাণ ৫০ টাকা।',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: Colors.red.withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    _rechargeController.executeRecharge(
      context: context,
      mobileNumber: _numberController.text.trim(),
      amount: amount,
      package: widget.prefilledOffer,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDrivePackage = widget.prefilledOffer != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.green, const Color(0xFF0D9488)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          isDrivePackage ? 'ড্রাইভ অফার রিচার্জ' : 'মোবাইল রিচার্জ',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (_rechargeController.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF08B3AC)));
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display prefilled offer info card if applicable
                if (isDrivePackage) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.green.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'নির্বাচিত অফার বিবরণ',
                              style: TextStyle(
                                color: AppColors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.prefilledOffer!.packageType,
                                style: TextStyle(
                                  color: AppColors.green,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.prefilledOffer!.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.prefilledOffer!.description,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'মূল্য: ৳${widget.prefilledOffer!.offerPrice}',
                              style: TextStyle(
                                color: AppColors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              'মেয়াদ: ${widget.prefilledOffer!.validity}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Number & Amount Panel
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'গ্রাহকের বিবরণ লিখুন',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 16),

                        // Mobile Number Input
                        TextFormField(
                          controller: _numberController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                          ],
                          decoration: InputDecoration(
                            labelText: 'মোবাইল নম্বর (১১ ডিজিট)',
                            labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            hintText: 'যেমন: 017XXXXXXXX',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.phone_iphone_outlined),
                          ),
                          onChanged: _onNumberChanged,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'নম্বর লিখুন';
                            if (!_rechargeController.isValidBangladeshiNumber(val)) {
                              return 'অবৈধ বাংলাদেশী মোবাইল নম্বর';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Amount Input
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          enabled: !isDrivePackage, // Disable editing for prefilled packages
                          decoration: InputDecoration(
                            labelText: 'টাকার পরিমাণ (৳)',
                            labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'পরিমাণ লিখুন';
                            final amt = double.tryParse(val);
                            if (amt == null || amt <= 0) return 'অবৈধ পরিমাণ';
                            return null;
                          },
                        ),
                        if (!isDrivePackage) ...[
                          const SizedBox(height: 12),
                          // Quick selection chips
                          SizedBox(
                            height: 32,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _quickAmounts.length,
                              itemBuilder: (context, idx) {
                                final amt = _quickAmounts[idx];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ChoiceChip(
                                    label: Text('৳${amt.toInt()}'),
                                    selected: false,
                                    backgroundColor: Colors.grey.shade100,
                                    onSelected: (_) {
                                      _amountController.text = amt.toString();
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Operator Grid
                const Text(
                  'মোবাইল অপারেটর',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 12),

                Obx(() {
                  final operatorsList = _userPackController.operators;
                  if (operatorsList.isEmpty) {
                    return const Center(child: Text('অপারেটর পাওয়া যায়নি।'));
                  }

                  // Auto-assign prefilled operator if operators are loaded and selectedOperator is still null
                  if (isDrivePackage && _rechargeController.selectedOperator.value == null) {
                    final prefilledOp = operatorsList.firstWhereOrNull((o) => o.id == widget.prefilledOffer!.operatorId);
                    if (prefilledOp != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _rechargeController.selectedOperator.value = prefilledOp;
                      });
                    }
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.15,
                    ),
                    itemCount: operatorsList.length,
                    itemBuilder: (context, index) {
                      final op = operatorsList[index];
                      final isSelected = _rechargeController.selectedOperator.value?.id == op.id;

                      return Card(
                        color: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isSelected ? AppColors.green : const Color(0xFFE2E8F0),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: isDrivePackage
                              ? null // Disable operator selection if package is pre-configured
                              : () {
                                  _rechargeController.selectedOperator.value = op;
                                },
                          borderRadius: BorderRadius.circular(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: ClipOval(
                                    child: Image.network(
                                      op.logoUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => const Icon(Icons.cell_tower),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                op.name,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? AppColors.green : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),

                const SizedBox(height: 30),

                // Pay Button using AppColors.green
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _submit,
                    child: Text(
                      isDrivePackage
                          ? '৳${widget.prefilledOffer!.offerPrice} পে করুন'
                          : 'রিচার্জ নিশ্চিত করুন',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
