import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trade_wign_bd/features/admin/settings/presentation/controllers/logo_picker_stub.dart'
    as picker_impl;
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import '../controllers/ecommerce_controller.dart';
import '../../domain/models/product_model.dart';
import 'package:trade_wign_bd/features/common/services/r2_storage_service.dart';

class AddProductScreen extends StatefulWidget {
  final Product? productToEdit;

  const AddProductScreen({super.key, this.productToEdit});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final EcommerceController controller = Get.put(EcommerceController());

  // Main Form Controllers
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _weightController;

  // Selected state
  String _selectedStatus = 'public'; // 'public' -> Active, 'draft' -> Inactive
  List<String> _selectedImages = []; // List of image paths/base64 strings
  List<String> _selectedCategories = []; // Category names
  String? _selectedProductType;
  String? _selectedProductUnit;
  String? _selectedBrand; // Vendor/Brand

  // Pricing Sheet state
  double _price = 0.0;
  double _cost = 0.0;
  double _regularPrice = 0.0;
  double _discountValue = 0.0;
  String _discountType = 'fixed';
  double _vat = 0.0;
  double _extraExpenses = 0.0;
  Map<String, double> _rolePrices = {};
  Map<String, int> _roleRewards = {};

  // Inventory Sheet state
  int _stock = 0;
  String _unit = 'pcs';

  // Other configurations
  List<String> _tags = [];
  List<String> _sizes = [];
  List<String> _variants = [];

  // Image upload helpers
  XFile? _tempPickedFile;
  Uint8List? _tempWebImageBytes;

  bool get _isEditMode => widget.productToEdit != null;

  // List of pre-uploaded/mock images for Content Library
  final List<String> _mockLibraryImages = [
    'assets/images/fan_mock1.png',
    'assets/images/fan_mock2.png',
    'assets/images/ac_mock.png',
    'assets/images/speaker_mock.png',
  ];

  @override
  void initState() {
    super.initState();

    final p = widget.productToEdit;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _weightController = TextEditingController(text: (p?.weight ?? 1.0).toString());
    _selectedStatus = p?.status ?? 'public';

    // Parse image list
    _selectedImages = _parseImages(p?.image ?? '');

    if (p?.category != null && p!.category.isNotEmpty) {
      _selectedCategories = [p.category];
    }
    _selectedBrand = p?.brand;

    if (p?.type != null && p!.type.isNotEmpty) {
      _selectedProductType = p.type;
    }

    if (p?.unit != null && p!.unit.isNotEmpty) {
      _selectedProductUnit = p.unit;
      _unit = p.unit;
    }

    // Pricing
    _rolePrices = Map<String, double>.from(p?.rolePrices ?? {});
    _roleRewards = Map<String, int>.from(p?.roleRewards ?? {});
    _price = _rolePrices['Customer'] ?? _rolePrices['Vendor'] ?? _rolePrices['Guest Customer'] ?? 0.0;

    _regularPrice = p?.regularPrice ?? _price;
    _discountValue = p?.discount ?? 0.0;
    _discountType = p?.discountType ?? 'fixed';
    _vat = p?.vat ?? 0.0;
    _extraExpenses = p?.extraExpenses ?? 0.0;

    // Try to guess cost from margin if available or set to cost-like ratio
    _cost = p != null ? _price * 0.8 : 0.0;

    // Inventory
    _stock = p?.stock ?? 0;

    // Variants
    _sizes = List<String>.from(p?.sizes ?? []);
    _variants = List<String>.from(p?.variants ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  List<String> _parseImages(String imageStr) {
    if (imageStr.isEmpty) return [];
    if (imageStr.contains('|')) {
      return imageStr
          .split('|')
          .map((img) => img.trim())
          .where((img) => img.isNotEmpty)
          .toList();
    }
    if (imageStr.startsWith('data:image')) {
      return [imageStr];
    }
    if (imageStr.contains(',')) {
      return imageStr
          .split(',')
          .map((img) => img.trim())
          .where((img) => img.isNotEmpty)
          .toList();
    }
    return [imageStr];
  }

  // Pick local file (Web & Native)
  Future<void> _pickLocalImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (file != null) {
        setState(() {
          _tempPickedFile = file;
        });

        if (kIsWeb) {
          final bytes = await file.readAsBytes();
          setState(() {
            _tempWebImageBytes = bytes;
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  // Prepares the picked image string
  Future<String> _processLocalImageString() async {
    if (_tempPickedFile == null) return '';
    if (kIsWeb && _tempWebImageBytes != null) {
      return 'data:image/png;base64,${base64Encode(_tempWebImageBytes!)}';
    } else {
      return _tempPickedFile!.path;
    }
  }

  // Form Submit Action
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategories.isEmpty) {
      Get.snackbar(
  'ত্রুটি',
  'দয়া করে কমপক্ষে একটি ক্যাটাগরি নির্বাচন করুন',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
      return;
    }

    if (_selectedImages.isEmpty) {
      Get.snackbar(
  'ত্রুটি',
  'দয়া করে পণ্যের ছবি যোগ করুন',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
      return;
    }

    if (_selectedProductType == null) {
      Get.snackbar(
  'ত্রুটি',
  'দয়া করে পণ্যের টাইপ নির্বাচন করুন',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
      return;
    }

    if (_unit.isEmpty) {
      Get.snackbar(
  'ত্রুটি',
  'দয়া করে পণ্যের একক (Unit) দিন',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
      return;
    }

    if (_regularPrice <= 0) {
      Get.snackbar(
  'ত্রুটি',
  'দয়া করে পণ্যের সঠিক মূল্য দিন',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
      return;
    }

    // inventory (_stock) is required (already has default 0, which is valid for out of stock, but if we wanted to force > 0 we could. We'll assume >= 0 is fine, so it's always valid as 0 or more).

    // Set fallback pricing for Customer if rolePrices is empty
    if (_rolePrices.isEmpty ||
        _rolePrices['Customer'] == null ||
        _rolePrices['Customer']! <= 0) {
      _rolePrices['Customer'] = _price;
    }

    // Show custom progress dialog matching the video
    _showProgressDialog(context);

    try {
      final List<String> uploadedUrls = [];
      final r2Service = R2StorageService();

      for (int i = 0; i < _selectedImages.length; i++) {
        final img = _selectedImages[i];
        if (img.startsWith('http') || img.startsWith('assets/')) {
          uploadedUrls.add(img);
        } else {
          Uint8List bytes;
          String extension = 'png';
          if (img.startsWith('data:image')) {
            final commaIndex = img.indexOf(',');
            final base64Data = img.substring(commaIndex + 1);
            bytes = base64Decode(base64Data);
          } else {
            final file = File(img);
            bytes = await file.readAsBytes();
            extension = img.split('.').last.toLowerCase();
          }

          final String destination = 'products/product_${DateTime.now().millisecondsSinceEpoch}_$i.$extension';
          final String? imageUrl = await r2Service.uploadBytes(
            bytes: bytes,
            destinationPath: destination,
            contentType: 'image/$extension',
          );

          if (imageUrl != null) {
            uploadedUrls.add(imageUrl);
          } else {
            throw Exception('R2 product image upload failed');
          }
        }
      }

      final imageString = uploadedUrls.join('|');

      final productData = Product(
        name: _nameController.text.trim(),
        type: 'regular', // default type
        brand: _selectedBrand!,
        category: _selectedCategories.first, // use primary category
        image: imageString,
        description: _descriptionController.text.trim(),
        stock: _stock,
        regularPrice: _regularPrice,
        discount: _discountValue,
        discountType: _discountType,
        vat: _vat,
        extraExpenses: _extraExpenses,
        unit: _unit,
        sizes: _sizes,
        variants: _variants,
        status: _selectedStatus,
        rolePrices: _rolePrices,
        roleRewards: _roleRewards,
        weight: double.tryParse(_weightController.text.trim()) ?? 1.0,
        createdAt: _isEditMode
            ? widget.productToEdit!.createdAt
            : DateTime.now(),
      );

      // Simulate a small network delay for the gorgeous progress screen feel
      await Future.delayed(const Duration(seconds: 2));

      bool success;
      if (_isEditMode) {
        success = await controller.updateProduct(
          widget.productToEdit!.id!,
          productData,
        );
      } else {
        success = await controller.addProduct(productData);
      }

      // Close loading dialog
      Navigator.pop(context);

      if (success) {
        // Redirection with a snackbar message
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context); // Close dialog if crash
      Get.snackbar(
        'ব্যর্থতা',
        'পণ্য আপলোড করতে সমস্যা হয়েছে: $e',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  // Smart Auto-Fill pricing logic
  void _autoFillRolePrices(double basePrice) {
    setState(() {
      _rolePrices['Vendor'] = double.parse(
        (basePrice * 0.85).toStringAsFixed(2),
      ); // Vendor rate (15% discount)
      _rolePrices['Customer'] = basePrice;
      _rolePrices['Brand Promoter'] = double.parse(
        (basePrice * 0.95).toStringAsFixed(2),
      ); // 5% discount
      _rolePrices['Sales Partner'] = double.parse(
        (basePrice * 0.90).toStringAsFixed(2),
      ); // 10% discount
      _rolePrices['Senior Sales Partner'] = double.parse(
        (basePrice * 0.85).toStringAsFixed(2),
      ); // 15% discount
      _rolePrices['Sub Dealer'] = double.parse(
        (basePrice * 0.80).toStringAsFixed(2),
      ); // 20% discount
      _rolePrices['Dealer'] = double.parse(
        (basePrice * 0.75).toStringAsFixed(2),
      ); // 25% discount
      _rolePrices['Senior Dealer'] = double.parse(
        (basePrice * 0.70).toStringAsFixed(2),
      ); // 30% discount
      _rolePrices['Master Dealer'] = double.parse(
        (basePrice * 0.65).toStringAsFixed(2),
      ); // 35% discount
      _rolePrices['Super Admin'] = double.parse(
        (basePrice * 0.60).toStringAsFixed(2),
      ); // 40% discount

      // Auto-fill Reward Points: 1 point per 10 BDT
      final int basePoints = (basePrice / 10).round();
      for (var role in [
        'Vendor',
        'Customer',
        'Brand Promoter',
        'Sales Partner',
        'Senior Sales Partner',
        'Sub Dealer',
        'Dealer',
        'Senior Dealer',
        'Master Dealer',
        'Super Admin',
      ]) {
        _roleRewards[role] = basePoints;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditMode ? 'Edit Product' : 'Create Product',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Media Section
              RichText(
                text: const TextSpan(
                  text: 'Media',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Add Media Row
              InkWell(
                onTap: () => _showAddMediaBottomSheet(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.image_search_rounded,
                          color: Color(0xFF64748B),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Add Media',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Add media for this product. Image Ratio 1:1',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Horizontal selected images row
              if (_selectedImages.isNotEmpty)
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      final img = _selectedImages[index];
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 12, top: 4),
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: _buildThumbnailImage(img),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImages.removeAt(index);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.black87,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),

              // 2. Product Title input
              RichText(
                text: const TextSpan(
                  text: 'Product Title',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: _buildFormFieldDecoration('Enter product title'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'দয়া করে পণ্যের নাম দিন' : null,
              ),
              const SizedBox(height: 20),

              // 3. Status selection (Active / Inactive)
              RichText(
                text: const TextSpan(
                  text: 'Status',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      value: 'public',
                      groupValue: _selectedStatus,
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.primaryColor,
                      onChanged: (val) =>
                          setState(() => _selectedStatus = val!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text(
                        'Inactive',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      value: 'draft',
                      groupValue: _selectedStatus,
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.primaryColor,
                      onChanged: (val) =>
                          setState(() => _selectedStatus = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 4. Description text area
              const Text(
                'Descriptions',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: _buildFormFieldDecoration('Product description'),
              ),
              const SizedBox(height: 24),

              // 5. Configurable Rows
              // Product Type row
              _buildConfigItemTile(
                icon: Icons.category_outlined,
                title: 'Product Type',
                isRequired: true,
                subtitle: _selectedProductType ?? 'Select Product Type',
                onAddTap: () => _showProductTypeBottomSheet(context),
              ),
              const SizedBox(height: 12),

              // Category row
              _buildConfigItemTile(
                icon: Icons.grid_view_rounded,
                title: 'Category',
                isRequired: true,
                subtitle: _selectedCategories.isEmpty
                    ? 'Add Category'
                    : _selectedCategories.join(', '),
                onAddTap: () => _showCategoryBottomSheet(context),
              ),
              const SizedBox(height: 12),

              // Product Unit row
              _buildConfigItemTile(
                icon: Icons.straighten_outlined,
                title: 'Product Unit',
                isRequired: true,
                subtitle: _selectedProductUnit ?? 'Select Unit',
                onAddTap: () => _showProductUnitBottomSheet(context),
              ),
              const SizedBox(height: 12),

              // Product Weight row
              _buildConfigItemTile(
                icon: Icons.monitor_weight_outlined,
                title: 'Product Weight (ওজন)',
                isRequired: true,
                subtitle: _weightController.text.isEmpty
                    ? 'Add Weight (default: 1.0 KG)'
                    : '${_weightController.text} KG',
                onAddTap: () => _showWeightBottomSheet(context),
              ),
              const SizedBox(height: 12),

              // Price row
              _buildConfigItemTile(
                icon: Icons.local_offer_outlined,
                title: 'Price',
                isRequired: true,
                subtitle: _price <= 0.0
                    ? 'Add Price'
                    : 'Price: ৳${_price.toStringAsFixed(2)}  •  Cost: ৳${_cost.toStringAsFixed(2)}',
                onAddTap: () => _showPricingBottomSheet(context),
              ),
              const SizedBox(height: 12),

              // Inventory row
              _buildConfigItemTile(
                icon: Icons.warehouse_outlined,
                title: 'Inventory',
                isRequired: true,
                subtitle: _stock <= 0 ? 'Add Stock' : 'Stock: $_stock',
                onAddTap: () => _showInventoryBottomSheet(context),
              ),
              const SizedBox(height: 12),

              // Vendor/Brand row
              _buildConfigItemTile(
                icon: Icons.apartment_outlined,
                title: 'Vendor/Brand',
                subtitle: _selectedBrand ?? 'Select Vendor/Brand',
                buttonText: '+ Sync',
                onAddTap: () => _showVendorBottomSheet(context),
              ),
              const SizedBox(height: 12),

              // Tags row
              _buildConfigItemTile(
                icon: Icons.tag_rounded,
                title: 'Tags',
                subtitle: _tags.isEmpty ? 'No Tag' : _tags.join(', '),
                onAddTap: () => _showTagsBottomSheet(context),
              ),
              const SizedBox(height: 12),

              // Variant row
              _buildConfigItemTile(
                icon: Icons.style_outlined,
                title: 'Variant',
                subtitle: _sizes.isEmpty && _variants.isEmpty
                    ? 'Add variant for this product'
                    : 'Sizes: ${_sizes.join(",")}, Variants: ${_variants.join(",")}',
                onAddTap: () => _showVariantBottomSheet(context),
              ),
              const SizedBox(height: 36),

              // 6. Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _submitForm,
                      child: Text(
                        _isEditMode ? 'Save Changes' : 'Add Product',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Common decoration for TextFormField
  InputDecoration _buildFormFieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
      ),
    );
  }

  // Configuration item tile builder
  Widget _buildConfigItemTile({
    required IconData icon,
    required String title,
    required String subtitle,
    String buttonText = '+ Add',
    bool isRequired = false,
    required VoidCallback onAddTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF64748B), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: title,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      if (isRequired)
                        const TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red, fontSize: 13),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onAddTap,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryColor,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  // Renders correct thumbnail image preview
  Widget _buildThumbnailImage(String imgStr) {
    if (imgStr.startsWith('data:image') ||
        (!imgStr.startsWith('assets') &&
            !imgStr.contains('http') &&
            !imgStr.contains('/'))) {
      try {
        final cleanBase = imgStr.contains(',') ? imgStr.split(',')[1] : imgStr;
        return Image.memory(base64Decode(cleanBase), fit: BoxFit.cover);
      } catch (_) {}
    }
    if (imgStr.startsWith('http') || imgStr.startsWith('https')) {
      return Image.network(imgStr, fit: BoxFit.cover);
    }
    if (!kIsWeb) {
      final localFile = File(
        'c:\\Users\\mohos\\OneDrive\\Desktop\\trade_wign_bd\\$imgStr',
      );
      if (localFile.existsSync()) {
        return Image.file(localFile, fit: BoxFit.cover);
      }
    }
    return Image.asset(
      imgStr,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.image),
    );
  }

  // 1. Add Media Bottom Sheet
  void _showAddMediaBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add Media',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Upload New Rows
              Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.blue,
                      ),
                    ),
                    title: const Text(
                      'Take a photo',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Take a photo shot from your camera'),
                    onTap: () async {
                      await _pickLocalImage();
                      if (_tempPickedFile != null) {
                        final path = await _processLocalImageString();
                        setState(() {
                          _selectedImages.add(path);
                        });
                        Navigator.pop(context);
                      }
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.photo_library_outlined,
                        color: Colors.green,
                      ),
                    ),
                    title: const Text(
                      'Choose from gallery',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Select file from your gallery'),
                    onTap: () async {
                      await _pickLocalImage();
                      if (_tempPickedFile != null) {
                        final path = await _processLocalImageString();
                        setState(() {
                          _selectedImages.add(path);
                        });
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Product Type Bottom Sheet
  void _showProductTypeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Product Type',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: Obx(() {
                  return ListView.builder(
                    itemCount: controller.productTypes.length,
                    itemBuilder: (context, index) {
                      final type = controller.productTypes[index];
                      final name = type['name'] as String;
                      return ListTile(
                        title: Text(name),
                        trailing: _selectedProductType == name
                            ? Icon(
                                Icons.check_rounded,
                                color: AppColors.primaryColor,
                              )
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedProductType = name;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  // Product Unit Bottom Sheet
  void _showProductUnitBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Product Unit',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: Obx(() {
                  return ListView.builder(
                    itemCount: controller.units.length,
                    itemBuilder: (context, index) {
                      final unit = controller.units[index];
                      final name = unit['name'] as String;
                      return ListTile(
                        title: Text(name),
                        trailing: _selectedProductUnit == name
                            ? Icon(
                                Icons.check_rounded,
                                color: AppColors.primaryColor,
                              )
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedProductUnit = name;
                            _unit = name;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  // 2. Category Bottom Sheet
  void _showCategoryBottomSheet(BuildContext context) {
    String searchCat = '';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          height: MediaQuery.of(context).size.height * 0.6,
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              final filteredCats = controller.categories.where((cat) {
                return (cat['name'] as String).toLowerCase().contains(
                  searchCat.toLowerCase(),
                );
              }).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Search category
                  TextFormField(
                    onChanged: (val) {
                      setSheetState(() => searchCat = val);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search_rounded),
                      isDense: true,
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.add_circle_outline_rounded,
                          color: AppColors.primaryColor,
                        ),
                        onPressed: () {
                          // Quick add dialog
                          _showQuickAddCategoryDialog(context, setSheetState);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: filteredCats.map((cat) {
                          final name = cat['name'] as String;
                          final isSelected = _selectedCategories.contains(name);
                          return FilterChip(
                            label: Text(name),
                            selected: isSelected,
                            onSelected: (selected) {
                              setSheetState(() {
                                if (selected) {
                                  _selectedCategories.add(name);
                                } else {
                                  _selectedCategories.remove(name);
                                }
                              });
                              setState(() {});
                            },
                            selectedColor: const Color(
                              0xFFF95B30,
                            ).withValues(alpha: 0.15),
                            checkmarkColor: AppColors.primaryColor,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // Quick dialog to add category
  void _showQuickAddCategoryDialog(
    BuildContext context,
    StateSetter setSheetState,
  ) {
    final textController = TextEditingController();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'নতুন ক্যাটাগরি তৈরি',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextFormField(
          controller: textController,
          decoration: const InputDecoration(labelText: 'ক্যাটাগরির নাম'),
        ),
        actions: [
          TextButton(child: const Text('বাতিল'), onPressed: () => Get.back()),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('তৈরি করুন'),
            onPressed: () async {
              if (textController.text.trim().isNotEmpty) {
                await controller.addCategory(
                  textController.text.trim(),
                  productTypeId: '',
                );
                setSheetState(() {});
                Get.back();
              }
            },
          ),
        ],
      ),
    );
  }

  // 3. Pricing Bottom Sheet
  void _showPricingBottomSheet(BuildContext context) {
    final regularPriceController = TextEditingController(
      text: _regularPrice > 0.0 ? _regularPrice.toString() : '',
    );
    final discountValueController = TextEditingController(
      text: _discountValue > 0.0 ? _discountValue.toString() : '',
    );
    final vatController = TextEditingController(
      text: _vat > 0.0 ? _vat.toString() : '',
    );
    final expensesController = TextEditingController(
      text: _extraExpenses > 0.0 ? _extraExpenses.toString() : '',
    );
    final costController = TextEditingController(
      text: _cost > 0.0 ? _cost.toString() : '',
    );

    // Local Pricing Sheet state variables
    double localRegularPrice = _regularPrice;
    double localDiscountValue = _discountValue;
    String localDiscountType = _discountType;
    double localVat = _vat;
    double localExtraExpenses = _extraExpenses;
    double localCost = _cost;
    bool isRolePricingExpanded = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            // Live Selling Price calculation
            double calculatedDiscount = localDiscountType == 'fixed'
                ? localDiscountValue
                : (localRegularPrice * localDiscountValue / 100);

            double localSellingPrice =
                localRegularPrice -
                calculatedDiscount +
                localVat +
                localExtraExpenses;
            if (localSellingPrice < 0)
              localSellingPrice = 0; // Prevent negative price

            // Live Margin & Profit calculations
            final profit = localSellingPrice - localCost;
            final marginPct = localSellingPrice > 0.0
                ? (profit / localSellingPrice) * 100
                : 0.0;
            final showAiRecommendation =
                localCost > 0.0 && localSellingPrice < (localCost * 1.3);

            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pricing',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          const Text(
                            'Regular Price',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: regularPriceController,
                            keyboardType: TextInputType.number,
                            decoration: _buildFormFieldDecoration('৳ 0.00'),
                            onChanged: (val) {
                              setSheetState(() {
                                localRegularPrice = double.tryParse(val) ?? 0.0;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            'Discount',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: discountValueController,
                                  keyboardType: TextInputType.number,
                                  decoration: _buildFormFieldDecoration('0.00'),
                                  onChanged: (val) {
                                    setSheetState(() {
                                      localDiscountValue =
                                          double.tryParse(val) ?? 0.0;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  height:
                                      48, // matching text field height roughly
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: localDiscountType,
                                      isExpanded: true,
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'fixed',
                                          child: Text('৳ Fixed'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'percentage',
                                          child: Text('% Pct'),
                                        ),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          setSheetState(() {
                                            localDiscountType = val;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'VAT / Tax',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: vatController,
                                      keyboardType: TextInputType.number,
                                      decoration: _buildFormFieldDecoration(
                                        '৳ 0.00',
                                      ),
                                      onChanged: (val) {
                                        setSheetState(() {
                                          localVat =
                                              double.tryParse(val) ?? 0.0;
                                        });
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
                                    const Text(
                                      'Extra Expenses',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: expensesController,
                                      keyboardType: TextInputType.number,
                                      decoration: _buildFormFieldDecoration(
                                        '৳ 0.00',
                                      ),
                                      onChanged: (val) {
                                        setSheetState(() {
                                          localExtraExpenses =
                                              double.tryParse(val) ?? 0.0;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            'Cost per item',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: costController,
                            keyboardType: TextInputType.number,
                            decoration: _buildFormFieldDecoration('৳ 0.00'),
                            onChanged: (val) {
                              setSheetState(() {
                                localCost = double.tryParse(val) ?? 0.0;
                              });
                            },
                          ),
                          const SizedBox(height: 20),

                          // Final Selling Price Display
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primaryColor.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Final Selling Price',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  '৳${localSellingPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Calculation Cards (Margin & Profit side by side)
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Margin',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${marginPct.toStringAsFixed(2)}%',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Profit',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '৳${profit.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Dynamic AI recommendation alert
                          if (showAiRecommendation)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFFCA5A5),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.auto_awesome_rounded,
                                    color: Colors.redAccent,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'AI Review Analysis',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Price too low! Increase your profit. AI recommends a price between ৳${(localCost * 1.3).toStringAsFixed(0)} - ৳${(localCost * 1.5).toStringAsFixed(0)} for better value.',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 20),

                          // 10 Roles Expandable pricing
                          InkWell(
                            onTap: () {
                              setSheetState(() {
                                isRolePricingExpanded = !isRolePricingExpanded;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Advanced Role-Wise pricing',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Icon(
                                  isRolePricingExpanded
                                      ? Icons.expand_less_rounded
                                      : Icons.expand_more_rounded,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          if (isRolePricingExpanded) ...[
                            // Auto-Fill Helper button
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(
                                    0xFFF95B30,
                                  ).withValues(alpha: 0.1),
                                  foregroundColor: AppColors.primaryColor,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.flash_on_rounded,
                                  size: 16,
                                ),
                                label: const Text(
                                  'Auto-Fill All Roles',
                                  style: TextStyle(fontSize: 12),
                                ),
                                onPressed: () {
                                  _autoFillRolePrices(localSellingPrice);
                                  // Refresh dialog state
                                  setSheetState(() {});
                                },
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Inputs for roles
                            ...[
                              'Vendor',
                              'Customer',
                              'Brand Promoter',
                              'Sales Partner',
                              'Senior Sales Partner',
                              'Sub Dealer',
                              'Dealer',
                              'Senior Dealer',
                              'Master Dealer',
                              'Super Admin',
                            ].map((role) {
                              final isVendor = role == 'Vendor';
                              final double currentPrice =
                                  _rolePrices[role] ?? 0.0;
                              final int currentPoints = _roleRewards[role] ?? 0;

                              final rolePriceController = TextEditingController(
                                text: currentPrice > 0
                                    ? currentPrice.toString()
                                    : '',
                              );
                              final rolePointsController =
                                  TextEditingController(
                                    text: currentPoints > 0
                                        ? currentPoints.toString()
                                        : '',
                                  );

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: isVendor
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFFFEF3C7),
                                            Color(0xFFFFFBEB),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isVendor ? null : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isVendor
                                        ? const Color(0xFFF59E0B)
                                        : const Color(0xFFE2E8F0),
                                    width: isVendor ? 1.5 : 1.0,
                                  ),
                                  boxShadow: isVendor
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFFF59E0B)
                                                .withValues(alpha: 0.15),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            if (isVendor) ...[
                                              const Icon(
                                                Icons.storefront_rounded,
                                                size: 16,
                                                color: Color(0xFFD97706),
                                              ),
                                              const SizedBox(width: 6),
                                            ],
                                            Text(
                                              role,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: isVendor ? 14 : 13,
                                                color: isVendor
                                                    ? const Color(0xFF92400E)
                                                    : const Color(0xFF1E293B),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (isVendor)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF59E0B),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                              '★ Vendor Exclusive',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: rolePriceController,
                                            keyboardType: TextInputType.number,
                                            decoration:
                                                _buildFormFieldDecoration(
                                                  'Price (৳)',
                                                ),
                                            onChanged: (val) {
                                              _rolePrices[role] =
                                                  double.tryParse(val) ?? 0.0;
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: TextFormField(
                                            controller: rolePointsController,
                                            keyboardType: TextInputType.number,
                                            decoration:
                                                _buildFormFieldDecoration(
                                                  'Rewards (pt)',
                                                ),
                                            onChanged: (val) {
                                              _roleRewards[role] =
                                                  int.tryParse(val) ?? 0;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _regularPrice = localRegularPrice;
                              _discountValue = localDiscountValue;
                              _discountType = localDiscountType;
                              _vat = localVat;
                              _extraExpenses = localExtraExpenses;
                              _price = localSellingPrice;
                              _cost = localCost;
                              if (_rolePrices['Customer'] == null ||
                                  _rolePrices['Customer'] == 0) {
                                _rolePrices['Customer'] = _price;
                              }
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 4. Inventory Bottom Sheet
  void _showInventoryBottomSheet(BuildContext context) {
    final stockController = TextEditingController(
      text: _stock > 0 ? _stock.toString() : '',
    );
    final unitController = TextEditingController(text: _unit);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Inventory',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                'Stock (Quantity)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: _buildFormFieldDecoration('0'),
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _stock = int.tryParse(stockController.text) ?? 0;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWeightBottomSheet(BuildContext context) {
    final localWeightCtrl = TextEditingController(
      text: _weightController.text,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Product Weight',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                'Weight in KG (কেজিতে ওজন)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: localWeightCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _buildFormFieldDecoration('যেমন: 1.0'),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _weightController.text = localWeightCtrl.text;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 6. Vendor Bottom Sheet
  void _showVendorBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Vendor / Brand',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: Obx(() {
                  return ListView.builder(
                    itemCount: controller.brands.length,
                    itemBuilder: (context, index) {
                      final brand = controller.brands[index];
                      final name = brand['name'] as String;
                      return ListTile(
                        title: Text(name),
                        trailing: _selectedBrand == name
                            ? Icon(
                                Icons.check_rounded,
                                color: AppColors.primaryColor,
                              )
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedBrand = name;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  // 7. Tags Bottom Sheet
  void _showTagsBottomSheet(BuildContext context) {
    final tagController = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add Tags',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: tagController,
                          decoration: _buildFormFieldDecoration('Tag name'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (tagController.text.trim().isNotEmpty) {
                            setSheetState(() {
                              _tags.add(tagController.text.trim());
                            });
                            setState(() {});
                            tagController.clear();
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tags.map((tag) {
                      return Chip(
                        label: Text(tag),
                        deleteIcon: const Icon(Icons.close_rounded, size: 14),
                        onDeleted: () {
                          setSheetState(() {
                            _tags.remove(tag);
                          });
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Done'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // 8. Variant Bottom Sheet
  void _showVariantBottomSheet(BuildContext context) {
    final sizeController = TextEditingController();
    final variantController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add Variant',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 10),

                  // Sizes section
                  const Text(
                    'Sizes (e.g. S, M, L)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: sizeController,
                          decoration: _buildFormFieldDecoration('Add Size'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (sizeController.text.trim().isNotEmpty) {
                            setSheetState(
                              () => _sizes.add(sizeController.text.trim()),
                            );
                            setState(() {});
                            sizeController.clear();
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: _sizes
                        .map(
                          (s) => Chip(
                            label: Text(s),
                            onDeleted: () =>
                                setSheetState(() => _sizes.remove(s)),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),

                  // Color/other variants section
                  const Text(
                    'Variants (e.g. Red, Blue, Vanilla)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: variantController,
                          decoration: _buildFormFieldDecoration('Add Variant'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (variantController.text.trim().isNotEmpty) {
                            setSheetState(
                              () =>
                                  _variants.add(variantController.text.trim()),
                            );
                            setState(() {});
                            variantController.clear();
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: _variants
                        .map(
                          (v) => Chip(
                            label: Text(v),
                            onDeleted: () =>
                                setSheetState(() => _variants.remove(v)),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Done'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // Gorgeous custom progress dialog matching the video ("Please wait a minute. Creating Products")
  void _showProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Spinner inside a nice card outline
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const CircularProgressIndicator(
                    strokeWidth: 3.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF0D9488),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Please wait a minute',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Creating Products',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
