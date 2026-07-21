import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_drive_pack_controller.dart';
import 'package:trade_wign_bd/features/users/drive_pack/domain/models/drive_package_model.dart';
import 'package:trade_wign_bd/features/users/drive_pack/domain/models/operator_model.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class AdminOfferCreationScreen extends StatefulWidget {
  final DrivePackageModel?
  editOfferData; // If passed, screen will open in Edit Mode
  const AdminOfferCreationScreen({super.key, this.editOfferData});

  @override
  State<AdminOfferCreationScreen> createState() =>
      _AdminOfferCreationScreenState();
}

class _AdminOfferCreationScreenState extends State<AdminOfferCreationScreen> {
  final _controller = Get.put(AdminDrivePackController());
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _offerPriceController = TextEditingController();

  OperatorModel? _selectedOperator;
  String _selectedPackageType = 'Combo';
  List<String> _selectedRoles = [
    'customer',
  ]; // Supports targeting multiple roles
  String _selectedValidity = '30 Days'; // Expiry choices drop-down value
  bool _isActive = true;
  bool _isEditMode = false;

  final List<String> _packageTypes = ['Combo', 'Internet', 'Minutes'];

  // Strict Expiry Choices from user instructions
  final List<Map<String, String>> _validityChoices = [
    {'key': '12 Hours', 'label': '12 Hours (১২ ঘণ্টা)'},
    {'key': '1 Day', 'label': '1 Day (১ দিন)'},
    {'key': '3 Days', 'label': '3 Days (৩ দিন)'},
    {'key': '5 Days', 'label': '5 Days (৫ দিন)'},
    {'key': '7 Days', 'label': '7 Days (৭ দিন)'},
    {'key': '10 Days', 'label': '10 Days (১০ দিন)'},
    {'key': '15 Days', 'label': '15 Days (১৫ দিন)'},
    {'key': '30 Days', 'label': '30 Days (৩০ দিন)'},
    {'key': '45 Days', 'label': '45 Days (৪৫ দিন)'},
    {'key': '60 Days', 'label': '60 Days (৬০ দিন)'},
  ];

  // Ranks configuration mapping from AGENTS.md
  final List<Map<String, String>> _roleRanks = [
    {'key': 'customer', 'label': 'কাস্টমার'},
    {'key': 'active customer', 'label': 'সক্রিয় কাস্টমার'},
    {'key': 'brand promoter', 'label': 'ব্র্যান্ড প্রমোটার'},
    {'key': 'sales partner', 'label': 'সেলস পার্টনার'},
    {'key': 'senior sales partner', 'label': 'সিনিয়র সেলস পার্টনার'},
    {'key': 'sub dealer', 'label': 'সাব ডিলার'},
    {'key': 'dealer', 'label': 'ডিলার'},
    {'key': 'senior dealer', 'label': 'সিনিয়র ডিলার'},
    {'key': 'master dealer', 'label': 'মাস্টার ডিলার'},
    {'key': 'regional distributor', 'label': 'রিজিওনাল ডিস্ট্রিবিউটর'},
  ];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.editOfferData != null;
    if (_isEditMode) {
      final data = widget.editOfferData!;
      _titleController.text = data.title;
      _descController.text = data.description;
      _priceController.text = data.price.toString();
      _offerPriceController.text = data.offerPrice.toString();
      _selectedValidity = data.validity;
      _selectedPackageType = data.packageType;
      _selectedRoles = List<String>.from(data.targetRoles);
      _isActive = data.status;

      // Select the operator from list if found
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_controller.operators.isNotEmpty) {
          setState(() {
            _selectedOperator = _controller.operators.firstWhereOrNull(
              (o) => o.id == data.operatorId,
            );
          });
        }
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedOperator == null) {
      Get.snackbar(
        'ত্রুটি',
        'দয়া করে একটি অপারেটর নির্বাচন করুন।',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: Colors.red.withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    if (_selectedRoles.isEmpty) {
      Get.snackbar(
        'ত্রুটি',
        'দয়া করে অন্তত একটি মেম্বারশিপ লেভেল নির্বাচন করুন।',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: Colors.red.withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final offerPrice =
        double.tryParse(_offerPriceController.text.trim()) ?? 0.0;

    bool success = false;
    if (_isEditMode) {
      success = await _controller.editOffer(
        id: widget.editOfferData!.id,
        operatorId: _selectedOperator!.id,
        operatorName: _selectedOperator!.name,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        packageType: _selectedPackageType,
        price: price,
        offerPrice: offerPrice,
        targetRoles: _selectedRoles,
        validity: _selectedValidity,
        status: _isActive,
      );
    } else {
      success = await _controller.createOffer(
        operatorId: _selectedOperator!.id,
        operatorName: _selectedOperator!.name,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        packageType: _selectedPackageType,
        price: price,
        offerPrice: offerPrice,
        targetRoles: _selectedRoles,
        validity: _selectedValidity,
        status: _isActive,
      );
    }

    if (success) {
      Get.snackbar(
        'সফল',
        _isEditMode
            ? 'অফারটি সফলভাবে আপডেট করা হয়েছে।'
            : 'অফারটি সফলভাবে তৈরি করা হয়েছে।',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: AppColors.green.withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      if (_isEditMode) {
        Get.back(); // Return to previous screen
      } else {
        _clearForm();
      }
    } else {
      Get.snackbar(
        'ত্রুটি',
        'অপারেশনটি সম্পন্ন করা যায়নি।',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: Colors.red.withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descController.clear();
    _priceController.clear();
    _offerPriceController.clear();
    setState(() {
      _selectedOperator = null;
      _selectedPackageType = 'Combo';
      _selectedRoles = ['customer'];
      _selectedValidity = '30 Days';
      _isActive = true;
    });
  }

  String _getRoleLabelsJoined(List<String> roles) {
    return roles
        .map((r) {
          final found = _roleRanks.firstWhereOrNull((item) => item['key'] == r);
          return found != null ? found['label']! : r;
        })
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'অফার সংশোধন' : 'ড্রাইভ অফার তৈরি',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.green,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xff034F4b)),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Setup Card Form
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditMode
                              ? 'অফারের বিবরণ সংশোধন করুন'
                              : 'নতুন ড্রাইভ অফারের বিবরণ লিখুন',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Operator Selector
                        DropdownButtonFormField<OperatorModel>(
                          value: _selectedOperator,
                          hint: const Text('অপারেটর নির্বাচন করুন'),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: _controller.operators.map((operator) {
                            return DropdownMenuItem<OperatorModel>(
                              value: operator,
                              child: Row(
                                children: [
                                  // operator logo wrapped in AspectRatio 1:1
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: AspectRatio(
                                      aspectRatio: 1.0,
                                      child: ClipOval(
                                        child: Image.network(
                                          operator.logoUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => const Icon(
                                            Icons.cell_tower,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(operator.name),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedOperator = val;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Title
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText:
                                'অফারের শিরোনাম (যেমন: 50 GB + 1000 Min)',
                            labelStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty)
                              return 'শিরোনাম আবশ্যক';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Description
                        TextFormField(
                          controller: _descController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText:
                                'অফারের বিস্তারিত বিবরণ (শর্তাবলী ইত্যাদি)',
                            labelStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty)
                              return 'বিবরণ আবশ্যক';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Row for price, offer price
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _priceController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: InputDecoration(
                                  labelText: 'প্যাকেজ মূল্য (৳)',
                                  labelStyle: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty)
                                    return 'আবশ্যক';
                                  if (double.tryParse(val) == null)
                                    return 'অবৈধ সংখ্যা';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _offerPriceController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: InputDecoration(
                                  labelText: 'অফার মূল্য (৳)',
                                  labelStyle: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty)
                                    return 'আবশ্যক';
                                  if (double.tryParse(val) == null)
                                    return 'অবৈধ সংখ্যা';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Row for package type and validity choice dropdown
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedPackageType,
                                decoration: InputDecoration(
                                  labelText: 'প্যাকেজের ধরন',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                items: _packageTypes.map((type) {
                                  return DropdownMenuItem<String>(
                                    value: type,
                                    child: Text(type),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedPackageType = val ?? 'Combo';
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedValidity,
                                decoration: InputDecoration(
                                  labelText: 'মেয়াদ/স্থায়িত্ব',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                items: _validityChoices.map((choice) {
                                  return DropdownMenuItem<String>(
                                    value: choice['key'],
                                    child: Text(choice['label']!),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedValidity = val ?? '30 Days';
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Targeted Membership Levels selection (Business Club - Multi target)
                        const Text(
                          'টার্গেটেড মেম্বারশিপ লেভেল সমূহ (একাধিক নির্বাচনযোগ্য)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: _roleRanks.map((role) {
                              final bool isSelected = _selectedRoles.contains(
                                role['key'],
                              );
                              return FilterChip(
                                label: Text(
                                  role['label']!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: AppColors.green,
                                checkmarkColor: Colors.white,
                                showCheckmark: true,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      if (!_selectedRoles.contains(
                                        role['key'],
                                      )) {
                                        _selectedRoles.add(role['key']!);
                                      }
                                    } else {
                                      if (_selectedRoles.length > 1) {
                                        _selectedRoles.remove(role['key']);
                                      }
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Status Toggle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'অফারটি সক্রিয় আছে',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            Switch(
                              value: _isActive,
                              activeColor: AppColors.green,
                              onChanged: (val) {
                                setState(() {
                                  _isActive = val;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Submit Button using AppColors.green
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _submit,
                            child: Text(
                              _isEditMode
                                  ? 'অফার সংশোধন সম্পন্ন করুন'
                                  : 'অফার সংরক্ষণ করুন',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Show lists of offers below ONLY if not in Edit mode
              if (!_isEditMode) ...[
                const SizedBox(height: 28),
                const Text(
                  'বিদ্যমান অফার সমূহ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                _controller.offers.isEmpty
                    ? const Card(
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: Text('কোনো অফার পাওয়া যায়নি।')),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _controller.offers.length,
                        itemBuilder: (context, index) {
                          final offer = _controller.offers[index];
                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.green.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          offer.operatorName,
                                          style: TextStyle(
                                            color: AppColors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              color: Colors.blue,
                                            ),
                                            onPressed: () {
                                              Get.to(
                                                () => AdminOfferCreationScreen(
                                                  editOfferData: offer,
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              _showDeleteConfirm(offer.id);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    offer.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    offer.description,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const Divider(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'দামি: ৳${offer.offerPrice} (৳${offer.price})',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        'মেয়াদ: ${offer.validity} | লেভেল: ${_getRoleLabelsJoined(offer.targetRoles)}',
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ],
          ),
        );
      }),
    );
  }

  void _showDeleteConfirm(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'নিশ্চিত করুন',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('আপনি কি সত্যিই এই অফারটি মুছে ফেলতে চান?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('বাতিল', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _controller.deleteOffer(id);
            },
            child: const Text(
              'মুছে ফেলুন',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
