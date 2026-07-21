import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:trade_wign_bd/features/admin/traning/domain/models/training_model.dart';
import 'package:trade_wign_bd/features/admin/traning/presentation/controllers/training_controller.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class AddTraningSheet extends StatefulWidget {
  final TrainingModel? trainingToEdit;

  const AddTraningSheet({super.key, this.trainingToEdit});

  @override
  State<AddTraningSheet> createState() => _AddTraningSheetState();
}

class _AddTraningSheetState extends State<AddTraningSheet> {
  final _formKey = GlobalKey<FormState>();
  final TrainingController controller = Get.find<TrainingController>();

  late String _selectedType; // 'physical' or 'video'
  late String _selectedRole; // 'all' or specific role

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _dateController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _locationController;
  late TextEditingController _youtubeUrlController;

  @override
  void initState() {
    super.initState();
    final item = widget.trainingToEdit;

    _selectedType = item?.type ?? 'physical';
    _selectedRole = item?.targetedRole ?? 'all';

    _titleController = TextEditingController(text: item?.title ?? '');
    _descriptionController = TextEditingController(text: item?.description ?? '');
    _dateController = TextEditingController(text: item?.date ?? '');
    _startTimeController = TextEditingController(text: item?.startTime ?? '');
    _endTimeController = TextEditingController(text: item?.endTime ?? '');
    _locationController = TextEditingController(text: item?.location ?? '');
    _youtubeUrlController = TextEditingController(
      text: item?.videoUrl ?? (item?.youtubeVideoId != null ? 'https://youtu.be/${item!.youtubeVideoId}' : ''),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _locationController.dispose();
    _youtubeUrlController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.green,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formatted = DateFormat('dd MMM yyyy').format(picked);
      setState(() {
        _dateController.text = formatted;
      });
    }
  }

  Future<void> _selectTime(TextEditingController timeController) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.green,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formatted = picked.format(context);
      setState(() {
        timeController.text = formatted;
      });
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    String? ytId;
    if (_selectedType == 'video') {
      ytId = TrainingModel.extractYoutubeId(_youtubeUrlController.text);
      if (ytId == null || ytId.isEmpty) {
        Get.snackbar(
          'ত্রুটি',
          'সঠিক ইউটিউব ভিডিও লিংক বা আইডি প্রদান করুন',
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          colorText: Colors.black87,
          borderColor: Colors.red.withValues(alpha: 0.3),
          borderWidth: 1,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return;
      }
    }

    final training = TrainingModel(
      id: widget.trainingToEdit?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _selectedType,
      targetedRole: _selectedRole,
      status: widget.trainingToEdit?.status ?? 'active',
      createdAt: widget.trainingToEdit?.createdAt ?? DateTime.now(),
      date: _selectedType == 'physical' ? _dateController.text.trim() : null,
      startTime: _selectedType == 'physical' ? _startTimeController.text.trim() : null,
      endTime: _selectedType == 'physical' ? _endTimeController.text.trim() : null,
      location: _selectedType == 'physical' ? _locationController.text.trim() : null,
      youtubeVideoId: ytId,
      videoUrl: _selectedType == 'video' ? _youtubeUrlController.text.trim() : null,
    );

    bool success = false;
    if (widget.trainingToEdit != null) {
      success = await controller.updateTraining(widget.trainingToEdit!.id!, training);
    } else {
      success = await controller.addTraining(training);
    }

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.trainingToEdit != null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'সম্পাদনা করুন (ট্রেনিং)' : 'নতুন ট্রেনিং যুক্ত করুন',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.green,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),

              // 1. Training Type Selector (Radio Buttons in Card Container)
              const Text(
                'ট্রেনিংয়ের ধরন নির্বাচন করুন',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeRadioTile(
                      label: 'ফিজিক্যাল মিটিং',
                      value: 'physical',
                      icon: Icons.groups_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeRadioTile(
                      label: 'ভিডিও ট্রেনিং',
                      value: 'video',
                      icon: Icons.play_circle_outline_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Training Title
              _buildTextField(
                controller: _titleController,
                label: 'ট্রেনিংয়ের নাম',
                hint: 'যেমন: রিজিওনাল ডিলার স্পেশাল ট্রেনিং',
                icon: Icons.title_rounded,
                validator: (val) => val == null || val.trim().isEmpty ? 'ট্রেনিংয়ের নাম লিখুন' : null,
              ),
              const SizedBox(height: 14),

              // 3. Targeted User Role Dropdown
              const Text(
                'টার্গেটেড ইউজার রোল',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRole,
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down_rounded, color: AppColors.green),
                    items: TrainingController.roleMap.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(
                          entry.value,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedRole = val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 4. Conditional Fields (Physical vs Video)
              if (_selectedType == 'physical') ...[
                // Date Picker
                _buildTextField(
                  controller: _dateController,
                  label: 'তারিখ',
                  hint: 'তারিখ সিলেক্ট করুন',
                  icon: Icons.calendar_today_rounded,
                  readOnly: true,
                  onTap: _selectDate,
                  validator: (val) => val == null || val.trim().isEmpty ? 'তারিখ দিন' : null,
                ),
                const SizedBox(height: 14),

                // Start & End Time
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _startTimeController,
                        label: 'শুরুর সময়',
                        hint: '১০:০০ AM',
                        icon: Icons.access_time_rounded,
                        readOnly: true,
                        onTap: () => _selectTime(_startTimeController),
                        validator: (val) => val == null || val.trim().isEmpty ? 'সময় দিন' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _endTimeController,
                        label: 'শেষের সময়',
                        hint: '১২:৩০ PM',
                        icon: Icons.access_time_filled_rounded,
                        readOnly: true,
                        onTap: () => _selectTime(_endTimeController),
                        validator: (val) => val == null || val.trim().isEmpty ? 'সময় দিন' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Location Field
                _buildTextField(
                  controller: _locationController,
                  label: 'স্থান / ভেন্যু / কনফারেন্স লিংক',
                  hint: 'যেমন: হোটেল শেরাটন, ঢাকা অথবা জুম মিটিং লিংক',
                  icon: Icons.location_on_outlined,
                  validator: (val) => val == null || val.trim().isEmpty ? 'স্থান/ঠিকানা দিন' : null,
                ),
                const SizedBox(height: 14),
              ] else ...[
                // YouTube Video Link
                _buildTextField(
                  controller: _youtubeUrlController,
                  label: 'ইউটিউব ভিডিও লিংক বা ভিডিও আইডি',
                  hint: 'যেমন: https://www.youtube.com/watch?v=dQw4w9WgXcQ',
                  icon: Icons.play_circle_fill_rounded,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'ইউটিউব লিংক দিন';
                    }
                    if (TrainingModel.extractYoutubeId(val) == null) {
                      return 'সঠিক ইউটিউব লিংক প্রদান করুন';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
              ],

              // 5. Description
              _buildTextField(
                controller: _descriptionController,
                label: 'বিবরণ',
                hint: 'ট্রেনিংয়ের মূল আলোচনা ও নির্দেশনা সংক্ষেপে লিখুন...',
                icon: Icons.description_outlined,
                maxLines: 3,
                validator: (val) => val == null || val.trim().isEmpty ? 'বিবরণ লিখুন' : null,
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  icon: Icon(isEdit ? Icons.check_circle_outline : Icons.add_circle_outline),
                  label: Text(
                    isEdit ? 'আপডেট করুন' : 'ট্রেনিং সংরক্ষণ করুন',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeRadioTile({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _selectedType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.green.withValues(alpha: 0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.green : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.green : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.green : Colors.black87,
                ),
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _selectedType,
              activeColor: AppColors.green,
              onChanged: (val) {
                if (val != null) setState(() => _selectedType = val);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: Icon(icon, color: AppColors.green, size: 20),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.green, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
