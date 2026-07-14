import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import 'package:trade_wign_bd/features/common/services/r2_storage_service.dart';
import '../../domain/models/package_model.dart';
import '../controllers/package_controller.dart';

void showAddPackageSheet(
  BuildContext context, {
  SubscriptionPackage? packageToEdit,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _AddPackageSheet(packageToEdit: packageToEdit),
  );
}

class _AddPackageSheet extends StatefulWidget {
  final SubscriptionPackage? packageToEdit;

  const _AddPackageSheet({this.packageToEdit});

  @override
  State<_AddPackageSheet> createState() => _AddPackageSheetState();
}

class _AddPackageSheetState extends State<_AddPackageSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Product Form Controllers
  final _prodNameCtrl = TextEditingController();
  final _prodBrandCtrl = TextEditingController();
  final _prodQtyCtrl = TextEditingController(text: '1');
  final _prodUnitCtrl = TextEditingController(text: 'pcs');
  final _prodMrpCtrl = TextEditingController();
  final _prodPkgPriceCtrl = TextEditingController();

  List<PackageProduct> _products = [];
  String _status = 'public';
  bool _isTopChoice = false;
  
  XFile? _selectedImageFile;
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;

  final PackageController _packageController = Get.find<PackageController>();
  final R2StorageService _r2Service = Get.put(R2StorageService());
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.packageToEdit != null) {
      _nameController.text = widget.packageToEdit!.name;
      _descriptionController.text = widget.packageToEdit!.description;
      _products = List.from(widget.packageToEdit!.products);
      _status = widget.packageToEdit!.status;
      _isTopChoice = widget.packageToEdit!.isTopChoice;
      _uploadedImageUrl = widget.packageToEdit!.image;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _prodNameCtrl.dispose();
    _prodBrandCtrl.dispose();
    _prodQtyCtrl.dispose();
    _prodUnitCtrl.dispose();
    _prodMrpCtrl.dispose();
    _prodPkgPriceCtrl.dispose();
    super.dispose();
  }
  
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImageFile = pickedFile;
      });
    }
  }

  void _addProduct() {
    if (_prodNameCtrl.text.trim().isEmpty || _prodPkgPriceCtrl.text.trim().isEmpty) {
      Get.snackbar(
  'ত্রুটি',
  'পণ্যের নাম এবং প্যাকেজ মূল্য দিন',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
      return;
    }
    
    final product = PackageProduct(
      name: _prodNameCtrl.text.trim(),
      brand: _prodBrandCtrl.text.trim(),
      quantity: int.tryParse(_prodQtyCtrl.text.trim()) ?? 1,
      unit: _prodUnitCtrl.text.trim().isEmpty ? 'pcs' : _prodUnitCtrl.text.trim(),
      mrpPrice: double.tryParse(_prodMrpCtrl.text.trim()) ?? 0.0,
      packagePrice: double.tryParse(_prodPkgPriceCtrl.text.trim()) ?? 0.0,
    );

    setState(() {
      _products.add(product);
      _prodNameCtrl.clear();
      _prodBrandCtrl.clear();
      _prodQtyCtrl.text = '1';
      _prodUnitCtrl.text = 'pcs';
      _prodMrpCtrl.clear();
      _prodPkgPriceCtrl.clear();
    });
  }

  void _editProduct(int index) {
    final p = _products[index];
    setState(() {
      _prodNameCtrl.text = p.name;
      _prodBrandCtrl.text = p.brand;
      _prodQtyCtrl.text = p.quantity.toString();
      _prodUnitCtrl.text = p.unit;
      _prodMrpCtrl.text = p.mrpPrice == 0 ? '' : p.mrpPrice.toString();
      _prodPkgPriceCtrl.text = p.packagePrice == 0 ? '' : p.packagePrice.toString();
      _products.removeAt(index);
    });
  }

  void _removeProduct(int index) {
    setState(() {
      _products.removeAt(index);
    });
  }

  double get _totalMrp => _products.fold(0, (sum, p) => sum + (p.mrpPrice * p.quantity));
  double get _totalPackagePrice => _products.fold(0, (sum, p) => sum + (p.packagePrice * p.quantity));

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_products.isEmpty) {
        Get.snackbar(
  'ত্রুটি',
  'কমপক্ষে একটি প্রোডাক্ট যোগ করুন',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
        return;
      }
      
      if (_uploadedImageUrl == null && _selectedImageFile == null) {
        Get.snackbar(
  'ত্রুটি',
  'প্যাকেজের জন্য একটি ছবি দিন',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
        return;
      }

      setState(() => _isUploadingImage = true);

      String? finalImageUrl = _uploadedImageUrl;

      if (_selectedImageFile != null) {
        try {
          final bytes = await _selectedImageFile!.readAsBytes();
          final ext = _selectedImageFile!.path.split('.').last;
          final fileName = 'package_${DateTime.now().millisecondsSinceEpoch}.$ext';
          final url = await _r2Service.uploadBytes(
            bytes: bytes,
            destinationPath: 'packages/$fileName',
            contentType: 'image/$ext',
          );
          if (url == null) throw Exception('Image upload failed');
          finalImageUrl = url;
        } catch (e) {
          setState(() => _isUploadingImage = false);
          Get.snackbar(
  'Upload Error',
  e.toString(),
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

      final package = SubscriptionPackage(
        id: widget.packageToEdit?.id,
        name: _nameController.text.trim(),
        image: finalImageUrl,
        description: _descriptionController.text.trim(),
        products: _products,
        status: _status,
        isTopChoice: _isTopChoice,
        createdAt: widget.packageToEdit?.createdAt,
      );

      bool success;
      if (widget.packageToEdit != null) {
        success = await _packageController.updatePackage(package.id!, package);
      } else {
        success = await _packageController.addPackage(package);
      }

      setState(() => _isUploadingImage = false);

      if (success) {
        Get.back(); // close sheet
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.packageToEdit != null
                        ? 'প্যাকেজ এডিট করুন'
                        : 'নতুন প্যাকেজ যোগ করুন',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Image Upload
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: _selectedImageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: kIsWeb
                                ? Image.network(_selectedImageFile!.path, fit: BoxFit.cover)
                                : Image.file(File(_selectedImageFile!.path), fit: BoxFit.cover),
                          )
                        : _uploadedImageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(_uploadedImageUrl!, fit: BoxFit.cover),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, color: Colors.grey.shade400),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Image (1:1)',
                                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration(
                  'প্যাকেজের নাম (উদাঃ প্রিমিয়াম বান্ডেল)',
                ),
                validator: (v) => v!.isEmpty ? 'নাম দিন' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: _buildInputDecoration('সংক্ষিপ্ত বিবরণ (ঐচ্ছিক)'),
              ),
              const SizedBox(height: 16),

              const Text(
                'প্রোডাক্টসমূহ (Products)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),

              // Product Form
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _prodNameCtrl,
                            decoration: _buildInputDecoration('প্রোডাক্ট নাম'),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _prodBrandCtrl,
                            decoration: _buildInputDecoration('ব্র্যান্ড'),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _prodQtyCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDecoration('Qty'),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _prodUnitCtrl,
                            decoration: _buildInputDecoration('Unit (kg, pcs)'),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _prodMrpCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDecoration('MRP (৳)'),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _prodPkgPriceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDecoration('Pkg Price (৳)'),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: Icon(Icons.add, color: AppColors.primaryColor, size: 18),
                        label: Text('প্রোডাক্ট যোগ করুন', style: TextStyle(color: AppColors.primaryColor)),
                        onPressed: _addProduct,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (_products.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: _products.asMap().entries.map((e) {
                      final p = e.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('${p.quantity} ${p.unit}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                  if (p.brand.isNotEmpty)
                                    Text(
                                      p.brand,
                                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '৳${(p.packagePrice * p.quantity).toStringAsFixed(0)}',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.green),
                                ),
                                if (p.mrpPrice > 0)
                                  Text(
                                    '৳${(p.mrpPrice * p.quantity).toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => _editProduct(e.key),
                              child: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => _removeProduct(e.key),
                              child: const Icon(Icons.cancel, color: Colors.redAccent, size: 20),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Total Summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('মোট প্যাকেজ মূল্য:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '৳${_totalPackagePrice.toStringAsFixed(2)}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryColor),
                          ),
                          if (_totalMrp > 0)
                            Text(
                              'MRP: ৳${_totalMrp.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey, decoration: TextDecoration.lineThrough),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              Row(
                children: [
                  const Text(
                    'স্ট্যাটাস:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  ChoiceChip(
                    label: const Text('সক্রিয়'),
                    selected: _status == 'public',
                    onSelected: (val) => setState(() => _status = 'public'),
                    selectedColor: AppColors.primaryColor.withValues(
                      alpha: 0.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('নিষ্ক্রিয়'),
                    selected: _status == 'draft',
                    onSelected: (val) => setState(() => _status = 'draft'),
                    selectedColor: Colors.orange.withValues(alpha: 0.2),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  const Text(
                    'Top Choice (সেরা পছন্দ):',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  Switch(
                    value: _isTopChoice,
                    activeColor: AppColors.primaryColor,
                    onChanged: (val) => setState(() => _isTopChoice = val),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: Obx(
                  () => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _packageController.isLoading.value || _isUploadingImage
                        ? null
                        : _submit,
                    child: _packageController.isLoading.value || _isUploadingImage
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                          )
                        : Text(
                            widget.packageToEdit != null
                                ? 'আপডেট করুন'
                                : 'সেভ করুন',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.primaryColor),
      ),
    );
  }
}
