import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/users/vendor/presentation/controllers/vendor_controller.dart';
import 'package:trade_wign_bd/features/admin/ecommerce/domain/models/product_model.dart';

class VendorAddProductScreen extends StatefulWidget {
  final Product? product;
  const VendorAddProductScreen({super.key, this.product});

  @override
  State<VendorAddProductScreen> createState() => _VendorAddProductScreenState();
}

class _VendorAddProductScreenState extends State<VendorAddProductScreen> {
  final VendorController controller = Get.find<VendorController>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _stockCtrl;
  late TextEditingController _imageCtrl;

  String? _selectedCategory;
  String? _selectedBrand;
  String? _selectedType;
  String? _selectedUnit;

  bool get isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.product?.name ?? '');
    _descCtrl = TextEditingController(text: widget.product?.description ?? '');
    _priceCtrl = TextEditingController(
      text: widget.product != null ? widget.product!.regularPrice.toString() : '',
    );
    _stockCtrl = TextEditingController(
      text: widget.product != null ? widget.product!.stock.toString() : '10',
    );
    _imageCtrl = TextEditingController(text: widget.product?.image ?? '');

    // Set initial dropdown values if editing
    if (isEdit) {
      _selectedCategory = widget.product!.category;
      _selectedBrand = widget.product!.brand;
      _selectedType = widget.product!.type;
      _selectedUnit = widget.product!.unit;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          isEdit ? 'পণ্য সংশোধন' : 'নতুন পণ্য যুক্ত করুন',
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Wrapper
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Name
                          _buildLabel('পণ্যের নাম (Product Name)'),
                          TextFormField(
                            controller: _nameCtrl,
                            decoration: _buildInputDecoration('যেমন: প্রিমিয়াম সরিষার তেল'),
                            validator: (val) => val == null || val.trim().isEmpty ? 'পণ্যের নাম লিখুন' : null,
                          ),
                          const SizedBox(height: 16),

                          // Description
                          _buildLabel('পণ্যের বিবরণ (Description)'),
                          TextFormField(
                            controller: _descCtrl,
                            maxLines: 3,
                            decoration: _buildInputDecoration('পণ্যের বিস্তারিত তথ্য এখানে লিখুন...'),
                            validator: (val) => val == null || val.trim().isEmpty ? 'পণ্যের বিবরণ লিখুন' : null,
                          ),
                          const SizedBox(height: 16),

                          // Price & Stock row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('বিক্রয় মূল্য (টাকা)'),
                                    TextFormField(
                                      controller: _priceCtrl,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: _buildInputDecoration('৳ ০.০০'),
                                      validator: (val) {
                                        final num? parsed = num.tryParse(val ?? '');
                                        if (parsed == null || parsed <= 0) {
                                          return 'সঠিক মূল্য দিন';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('স্টক পরিমাণ'),
                                    TextFormField(
                                      controller: _stockCtrl,
                                      keyboardType: TextInputType.number,
                                      decoration: _buildInputDecoration('যেমন: ১০'),
                                      validator: (val) {
                                        final int? parsed = int.tryParse(val ?? '');
                                        if (parsed == null || parsed < 0) {
                                          return 'সঠিক স্টক দিন';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Image Path
                          _buildLabel('পণ্যের ছবি লিংক / নাম'),
                          TextFormField(
                            controller: _imageCtrl,
                            decoration: _buildInputDecoration('assets/products/oil.png বা https://image.link'),
                            validator: (val) => val == null || val.trim().isEmpty ? 'পণ্যের ছবি লিংক দিন' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Config Dropdowns Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'শ্রেণী এবং কনফিগারেশন নির্ধারণ করুন',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 16),

                          // Category
                          _buildLabel('ক্যাটাগরি (Category)'),
                          _buildDropdown<String>(
                            value: _getDropdownMatch(controller.categories, _selectedCategory),
                            items: controller.categories.map((c) {
                              final name = c['name'] as String;
                              return DropdownMenuItem<String>(value: name, child: Text(name));
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedCategory = val),
                            hint: 'ক্যাটাগরি নির্বাচন করুন',
                          ),
                          const SizedBox(height: 14),

                          // Brand
                          _buildLabel('ব্র্যান্ড (Brand)'),
                          _buildDropdown<String>(
                            value: _getDropdownMatch(controller.brands, _selectedBrand),
                            items: controller.brands.map((b) {
                              final name = b['name'] as String;
                              return DropdownMenuItem<String>(value: name, child: Text(name));
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedBrand = val),
                            hint: 'ব্র্যান্ড নির্বাচন করুন',
                          ),
                          const SizedBox(height: 14),

                          // Product Type
                          _buildLabel('পণ্যের ধরন (Product Type)'),
                          _buildDropdown<String>(
                            value: _getDropdownMatch(controller.productTypes, _selectedType),
                            items: controller.productTypes.map((t) {
                              final name = t['name'] as String;
                              return DropdownMenuItem<String>(value: name, child: Text(name));
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedType = val),
                            hint: 'ধরন নির্বাচন করুন',
                          ),
                          const SizedBox(height: 14),

                          // Unit
                          _buildLabel('পরিমাপ ইউনিট (Unit)'),
                          _buildDropdown<String>(
                            value: _getDropdownMatch(controller.units, _selectedUnit),
                            items: controller.units.map((u) {
                              final name = u['name'] as String;
                              return DropdownMenuItem<String>(value: name, child: Text(name));
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedUnit = val),
                            hint: 'ইউনিট নির্বাচন করুন',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF08B3AC),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: _submitForm,
                        child: Text(
                          isEdit ? 'পরিবর্তন সংরক্ষণ করুন' : 'পণ্য তালিকাভুক্ত করুন',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (controller.isSubmittingAction.value)
              Container(
                color: Colors.black12,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
        borderSide: const BorderSide(color: Color(0xFF08B3AC), width: 1.5),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  // Safe helper to check if loaded config matches selected value, avoiding assertion crash
  String? _getDropdownMatch(List<Map<String, dynamic>> list, String? selected) {
    if (selected == null) return null;
    final exists = list.any((item) => (item['name'] as String).toLowerCase() == selected.toLowerCase());
    if (exists) {
      // Return the exact casing from the loaded list
      return list.firstWhere((item) => (item['name'] as String).toLowerCase() == selected.toLowerCase())['name'];
    }
    return null;
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null ||
        _selectedBrand == null ||
        _selectedType == null ||
        _selectedUnit == null) {
      Get.snackbar('ত্রুটি', 'দয়া করে সবগুলো ড্রপডাউন ক্যাটাগরি পূরণ করুন।');
      return;
    }

    final double price = double.parse(_priceCtrl.text.trim());
    final int stock = int.parse(_stockCtrl.text.trim());

    final Product newProduct = Product(
      name: _nameCtrl.text.trim(),
      type: _selectedType!,
      brand: _selectedBrand!,
      category: _selectedCategory!,
      image: _imageCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      stock: stock,
      regularPrice: price,
      discount: 0.0,
      discountType: 'fixed',
      vat: 0.0,
      extraExpenses: 0.0,
      unit: _selectedUnit!,
      sizes: [],
      variants: [],
      status: 'public',
      rolePrices: {
        'Customer': price,
      },
      roleRewards: {},
    );

    bool success;
    if (isEdit) {
      success = await controller.updateVendorProduct(widget.product!.id!, newProduct);
    } else {
      success = await controller.addVendorProduct(newProduct);
    }

    if (success) {
      Get.back();
    }
  }
}
