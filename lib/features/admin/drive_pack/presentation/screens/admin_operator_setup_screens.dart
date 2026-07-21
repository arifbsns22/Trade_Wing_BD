import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/admin_drive_pack_controller.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class AdminOperatorSetupScreen extends StatefulWidget {
  const AdminOperatorSetupScreen({super.key});

  @override
  State<AdminOperatorSetupScreen> createState() => _AdminOperatorSetupScreenState();
}

class _AdminOperatorSetupScreenState extends State<AdminOperatorSetupScreen> {
  final _controller = Get.put(AdminDrivePackController());
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  XFile? _selectedImage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      Get.snackbar(
        'ত্রুটি',
        'অপারেটর লোগো নির্বাচন করুন।',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: Colors.red.withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final success = await _controller.createOperator(
      name: _nameController.text.trim(),
      imageFile: _selectedImage!,
    );

    if (success) {
      _nameController.clear();
      setState(() {
        _selectedImage = null;
      });
      Get.snackbar(
        'সফল',
        'অপারেটর সফলভাবে তৈরি হয়েছে।',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: AppColors.green.withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } else {
      Get.snackbar(
        'ত্রুটি',
        'অপারেটর তৈরি করতে ব্যর্থ হয়েছে।',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: Colors.red.withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('অপারেটর সেটআপ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.green,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xff034F4b)));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Setup Card
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'নতুন অপারেটর যোগ করুন',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 16),
                        // Operator Name Input
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'অপারেটরের নাম (যেমন: Grameenphone)',
                            labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.green),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'নাম আবশ্যক';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Image Picker Widget
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                            ),
                            child: _selectedImage == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey.shade400),
                                      const SizedBox(height: 8),
                                      Text('লোগো নির্বাচন করতে ট্যাপ করুন', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                    ],
                                  )
                                : Center(
                                    child: AspectRatio(
                                      aspectRatio: 1.0,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: kIsWeb
                                            ? Image.network(
                                                _selectedImage!.path,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.file(
                                                File(_selectedImage!.path),
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Submit Button using AppColors.green
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.green,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _submit,
                            child: const Text(
                              'সংরক্ষণ করুন',
                              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'অপারেটর তালিকা',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 12),

              // Operators List
              _controller.operators.isEmpty
                  ? const Card(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: Text('কোনো অপারেটর পাওয়া যায়নি।')),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _controller.operators.length,
                      itemBuilder: (context, index) {
                        final operator = _controller.operators[index];
                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: AspectRatio(
                                aspectRatio: 1.0,
                                child: ClipOval(
                                  child: Image.network(
                                    operator.logoUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.cell_tower, color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              operator.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () {
                                _showDeleteDialog(operator.id);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        );
      }),
    );
  }

  void _showDeleteDialog(String operatorId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('নিশ্চিত করুন', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('আপনি কি সত্যিই এই অপারেটরটি মুছে ফেলতে চান?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('বাতিল', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _controller.deleteOperator(operatorId);
            },
            child: const Text('মুছে ফেলুন', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
