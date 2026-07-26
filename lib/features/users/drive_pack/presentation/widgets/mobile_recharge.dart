import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/users/drive_pack/presentation/controllers/mobile_recharge_controller.dart';
import 'package:trade_wign_bd/features/users/drive_pack/presentation/controllers/user_drive_pack_controller.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class QuickRechargeWidget extends StatefulWidget {
  const QuickRechargeWidget({super.key});

  @override
  State<QuickRechargeWidget> createState() => _QuickRechargeWidgetState();
}

class _QuickRechargeWidgetState extends State<QuickRechargeWidget> {
  final _rechargeController = Get.put(MobileRechargeController());
  final _userPackController = Get.find<UserDrivePackController>();

  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _amountController = TextEditingController();

  final List<double> _quickAmounts = [50, 100, 200, 500, 1000];

  @override
  void initState() {
    super.initState();
    // Auto-detect operator whenever phone number changes
    _numberController.addListener(_onNumberChanged);

    // Re-evaluate if operators stream in from Firestore
    ever(_userPackController.operators, (_) => _onNumberChanged());
  }

  void _onNumberChanged() {
    final text = _numberController.text.trim();
    final detected = _rechargeController.detectOperator(
      text,
      _userPackController.operators,
    );
    _rechargeController.selectedOperator.value = detected;
  }

  @override
  void dispose() {
    _numberController.dispose();
    _amountController.dispose();
    super.dispose();
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
    if (amount < 50) {
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.04),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.flash_on,
                      color: AppColors.green,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'মোবাইল রিচার্জ করুন',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
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
                  labelStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                  hintText: 'যেমন: 017XXXXXXXX',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.phone_iphone_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'নম্বর লিখুন';
                  if (!_rechargeController.isValidBangladeshiNumber(val)) {
                    return 'অবৈধ বাংলাদেশী মোবাইল নম্বর';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Dynamic Operator Preview Row
              Obx(() {
                final op = _rechargeController.selectedOperator.value;
                if (op == null) return const SizedBox.shrink();

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: ClipOval(
                            child: op.logoUrl.isNotEmpty
                                ? Image.network(
                                    op.logoUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.cell_tower_rounded,
                                      size: 14,
                                      color: AppColors.green,
                                    ),
                                  )
                                : Icon(
                                    Icons.cell_tower_rounded,
                                    size: 14,
                                    color: AppColors.green,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'শনাক্তকৃত অপারেটর: ${op.name}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Amount Input
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'টাকার পরিমাণ (৳)',
                  labelStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                  hintText: 'যেমন: ৫০, ১০০, ২০০...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.wallet_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'পরিমাণ লিখুন';
                  final amt = double.tryParse(val);
                  if (amt == null || amt < 50)
                    return 'সর্বনিম্ন ৫০ টাকা আবশ্যক';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Suggestion Chips (50, 100, 200, 500, 1000)
              SizedBox(
                height: 34,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _quickAmounts.length,
                  itemBuilder: (context, idx) {
                    final amt = _quickAmounts[idx];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ActionChip(
                        label: Text(
                          '৳${amt.toInt()}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onPressed: () {
                          _amountController.text = amt.toInt().toString();
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),

              // Pay Bill Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _submit,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.payment, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'পে বিল করুন',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
