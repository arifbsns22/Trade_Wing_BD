import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trade_wign_bd/features/admin/settings/presentation/controllers/logo_picker_stub.dart' as picker_impl;
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class ConfigItemManager extends StatefulWidget {
  final String title;
  final String hintText;
  final List<Map<String, dynamic>> items;
  final List<Map<String, dynamic>>? productTypes; // If provided, shows dropdown
  final bool hideImagePicker; // Useful for Units which don't need an image
  final bool isLoading;
  final Function(String name, String imageBase64, String? productTypeId, String status) onAdd;
  final Function(String id, String name, String imageBase64, String? productTypeId, String status) onUpdate;
  final Function(String id) onDelete;

  const ConfigItemManager({
    super.key,
    required this.title,
    required this.hintText,
    required this.items,
    this.productTypes,
    this.hideImagePicker = false,
    required this.isLoading,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<ConfigItemManager> createState() => _ConfigItemManagerState();
}

class _ConfigItemManagerState extends State<ConfigItemManager> {
  final TextEditingController _textController = TextEditingController();
  String _imageBase64 = '';
  String? _selectedProductTypeId;
  String _selectedStatus = 'public';

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? file = await picker_impl.pickLogoImage();
      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _imageBase64 = 'data:image/png;base64,${base64Encode(bytes)}';
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  IconData _getRandomIcon(String seed) {
    final List<IconData> icons = [
      Icons.category_outlined,
      Icons.shopping_bag_outlined,
      Icons.style_outlined,
      Icons.local_offer_outlined,
      Icons.grid_view_rounded,
      Icons.widgets_outlined,
      Icons.dashboard_customize_outlined,
      Icons.storefront_outlined,
    ];
    final index = seed.hashCode.abs() % icons.length;
    return icons[index];
  }

  ImageProvider? _getListItemImageProvider(String imgStr) {
    if (imgStr.isEmpty) return null;
    if (imgStr.startsWith('data:image')) {
      try {
        final clean = imgStr.contains(',') ? imgStr.split(',')[1] : imgStr;
        return MemoryImage(base64Decode(clean));
      } catch (_) {
        return null;
      }
    }
    if (imgStr.startsWith('http') || imgStr.startsWith('https')) {
      return NetworkImage(imgStr);
    }
    if (imgStr.startsWith('assets/')) {
      return AssetImage(imgStr);
    }
    try {
      return MemoryImage(base64Decode(imgStr));
    } catch (_) {
      return null;
    }
  }

  Widget _buildImage(String imgStr) {
    if (imgStr.startsWith('data:image')) {
      try {
        final clean = imgStr.contains(',') ? imgStr.split(',')[1] : imgStr;
        return Image.memory(base64Decode(clean), fit: BoxFit.cover);
      } catch (_) {}
    }
    if (imgStr.startsWith('http') || imgStr.startsWith('https')) {
      return Image.network(imgStr, fit: BoxFit.cover);
    }
    return Image.asset(imgStr, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.image));
  }

  void _handleAdd() {
    final name = _textController.text.trim();
    if (name.isEmpty) return;
    if (widget.productTypes != null && _selectedProductTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('অনুগ্রহ করে প্রোডাক্ট টাইপ নির্বাচন করুন')));
      return;
    }

    widget.onAdd(name, _imageBase64, _selectedProductTypeId, _selectedStatus);
    
    _textController.clear();
    setState(() {
      _imageBase64 = '';
      _selectedProductTypeId = null;
      _selectedStatus = 'public';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Input Row with Image Picker
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!widget.hideImagePicker) ...[
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200, width: 1.5),
                      ),
                      child: _imageBase64.isNotEmpty
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: _buildImage(_imageBase64),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _imageBase64 = '';
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, size: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined, size: 18, color: Colors.grey.shade400),
                                const SizedBox(height: 4),
                                Text(
                                  'ছবি',
                                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],

                // Text field and Selectors
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _textController,
                              decoration: InputDecoration(
                                hintText: widget.hintText,
                                isDense: true,
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: AppColors.primaryColor),
                                ),
                              ),
                            ),
                          ),
                          if (widget.productTypes != null) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                value: _selectedProductTypeId,
                                hint: const Text('টাইপ', style: TextStyle(fontSize: 13)),
                                decoration: InputDecoration(
                                  isDense: true,
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey.shade200),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey.shade200),
                                  ),
                                ),
                                items: widget.productTypes!.map((type) {
                                  return DropdownMenuItem<String>(
                                    value: type['id'],
                                    child: Text(type['name'] ?? '', style: const TextStyle(fontSize: 13)),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedProductTypeId = val;
                                  });
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          elevation: 0,
                        ),
                        onPressed: _handleAdd,
                        child: const Text('যুক্ত করুন', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Item List
            if (widget.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (widget.items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Text(
                    'কোনো আইটেম পাওয়া যায়নি',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  ),
                ),
              )
            else
              Container(
                constraints: const BoxConstraints(maxHeight: 350),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: widget.items.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    final imgStr = item['image'] ?? '';
                    final imageProvider = !widget.hideImagePicker ? _getListItemImageProvider(imgStr) : null;
                    final status = item['status'] ?? 'public';
                    final isPublic = status == 'public';

                    String? typeName;
                    if (widget.productTypes != null && item['productTypeId'] != null) {
                      final pType = widget.productTypes!.firstWhere((e) => e['id'] == item['productTypeId'], orElse: () => {});
                      typeName = pType['name'];
                    }

                    return ListTile(
                      leading: !widget.hideImagePicker
                          ? CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.primaryColor.withValues(alpha: 0.08),
                              backgroundImage: imageProvider,
                              child: imageProvider == null
                                  ? Icon(_getRandomIcon(item['name'] ?? ''), size: 18, color: AppColors.primaryColor)
                                  : null,
                            )
                          : CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.primaryColor.withValues(alpha: 0.08),
                              child: Text(
                                (item['name'] ?? 'U').toString().substring(0, 1).toUpperCase(),
                                style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                              ),
                            ),
                      title: Text(
                        item['name'] ?? '',
                        style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600),
                      ),
                      subtitle: typeName != null
                          ? Text('Type: $typeName', style: TextStyle(fontSize: 12, color: Colors.grey.shade600))
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      dense: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.scale(
                            scale: 0.75,
                            child: Switch(
                              value: isPublic,
                              activeColor: AppColors.primaryColor,
                              onChanged: (val) {
                                widget.onUpdate(
                                  item['id'],
                                  item['name'],
                                  item['image'] ?? '',
                                  item['productTypeId'],
                                  val ? 'public' : 'disable',
                                );
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 18),
                            onPressed: () {
                              _showEditDialog(context, item);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                            onPressed: () {
                              _showConfirmDeleteDialog(context, item['id'], item['name']);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> item) {
    final TextEditingController editController = TextEditingController(text: item['name']);
    String editImageBase64 = item['image'] ?? '';
    String? editProductTypeId = item['productTypeId'];
    String editStatus = item['status'] ?? 'public';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickEditImage() async {
              try {
                final XFile? file = await picker_impl.pickLogoImage();
                if (file != null) {
                  final bytes = await file.readAsBytes();
                  setDialogState(() {
                    editImageBase64 = 'data:image/png;base64,${base64Encode(bytes)}';
                  });
                }
              } catch (e) {
                debugPrint('Error picking image: $e');
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('এডিট করুন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!widget.hideImagePicker) ...[
                      GestureDetector(
                        onTap: pickEditImage,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200, width: 1.5),
                          ),
                          child: editImageBase64.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: _buildImage(editImageBase64),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo_outlined, size: 24, color: Colors.grey.shade400),
                                    const SizedBox(height: 4),
                                    Text('পরিবর্তন', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: editController,
                      decoration: InputDecoration(
                        labelText: 'নাম',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (widget.productTypes != null) ...[
                      DropdownButtonFormField<String>(
                        value: editProductTypeId,
                        decoration: InputDecoration(
                          labelText: 'প্রোডাক্ট টাইপ',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          isDense: true,
                        ),
                        items: widget.productTypes!.map((type) {
                          return DropdownMenuItem<String>(
                            value: type['id'],
                            child: Text(type['name'] ?? ''),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setDialogState(() {
                            editProductTypeId = val;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    DropdownButtonFormField<String>(
                      value: editStatus,
                      decoration: InputDecoration(
                        labelText: 'স্ট্যাটাস',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'public', child: Text('Public')),
                        DropdownMenuItem(value: 'disable', child: Text('Disable')),
                      ],
                      onChanged: (val) {
                        setDialogState(() {
                          if (val != null) editStatus = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('বাতিল', style: TextStyle(color: Colors.grey.shade600)),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor, foregroundColor: Colors.white),
                  onPressed: () {
                    final newName = editController.text.trim();
                    if (newName.isEmpty) return;
                    if (widget.productTypes != null && editProductTypeId == null) return;
                    
                    Navigator.pop(context);
                    widget.onUpdate(
                      item['id'],
                      newName,
                      editImageBase64,
                      editProductTypeId,
                      editStatus,
                    );
                  },
                  child: const Text('সংরক্ষণ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showConfirmDeleteDialog(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('নিশ্চিত করুন', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('আপনি কি নিশ্চিত যে আপনি "$name" আইটেমটি মুছে ফেলতে চান?'),
        actions: [
          TextButton(
            child: Text('না', style: TextStyle(color: Colors.grey.shade600)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('হ্যাঁ', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete(id);
            },
          ),
        ],
      ),
    );
  }
}
