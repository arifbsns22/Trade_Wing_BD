import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/admin/common/widgets/create_floting_button.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import '../controllers/ecommerce_controller.dart';
import 'add_product_screen.dart';
import 'dart:convert';
import 'package:trade_wign_bd/features/common/profile/presentation/controllers/admin_profile_controller.dart';
import '../widgets/product_card.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final EcommerceController controller = Get.put(EcommerceController());
  final AdminProfileController profileController = Get.put(
    AdminProfileController(),
  );

  String _searchQuery = '';
  String _selectedStatusFilter = 'all'; // 'all' | 'public' | 'draft'
  String _selectedCategoryFilter = 'all'; // 'all' | categoryName
  String _sortBy =
      'newest'; // 'newest' | 'name_asc' | 'name_desc' | 'stock_asc' | 'stock_desc'

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
        title: const Text(
          'Products',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Obx(() {
              final hasPic = profileController.profilePicture.value.isNotEmpty;
              ImageProvider? imageProvider;
              if (hasPic) {
                final picVal = profileController.profilePicture.value;
                if (picVal.startsWith('http')) {
                  imageProvider = NetworkImage(picVal);
                } else {
                  try {
                    imageProvider = MemoryImage(
                      base64Decode(picVal.split(',').last),
                    );
                  } catch (e) {
                    debugPrint('Error decoding base64 avatar: $e');
                  }
                }
              }

              final nameStr = profileController.name.value;
              final initials = nameStr.isNotEmpty
                  ? nameStr
                        .trim()
                        .split(' ')
                        .map((e) => e.isNotEmpty ? e.substring(0, 1) : '')
                        .where((e) => e.isNotEmpty)
                        .take(2)
                        .join()
                        .toUpperCase()
                  : '';

              return CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF1E293B),
                backgroundImage: imageProvider,
                child: imageProvider == null
                    ? Text(
                        initials.isEmpty ? 'AD' : initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              );
            }),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: const CreateFloatingButton(),
      body: Column(
        children: [
          // 1. Search Bar Area
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                // Search Input with inline scanner & sort
                TextFormField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 15,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.grey.shade400,
                    ),
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 80,
                      maxWidth: 96,
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.qr_code_scanner_rounded,
                            color: Colors.grey.shade500,
                            size: 20,
                          ),
                          onPressed: () {
                            Get.snackbar(
                              'স্ক্যানার',
                              'বারকোড স্ক্যানার মডিউল চালু হচ্ছে...',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.tune_rounded,
                            color: Colors.grey.shade500,
                            size: 20,
                          ),
                          onPressed: () => _showSortBottomSheet(context),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Filters Row
                Row(
                  children: [
                    _buildDropdownFilterChip(
                      label: _selectedStatusFilter == 'all'
                          ? 'Status ▾'
                          : 'Status: ${_selectedStatusFilter == 'public' ? 'Active' : 'Inactive'} ▾',
                      onTap: () => _showStatusFilterBottomSheet(context),
                      isActive: _selectedStatusFilter != 'all',
                    ),
                    const SizedBox(width: 8),
                    _buildDropdownFilterChip(
                      label: _selectedCategoryFilter == 'all'
                          ? 'Category ▾'
                          : 'Category: $_selectedCategoryFilter ▾',
                      onTap: () => _showCategoryFilterBottomSheet(context),
                      isActive: _selectedCategoryFilter != 'all',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Product List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFF95B30),
                    ),
                  ),
                );
              }

              // Apply search, filters & sort
              var filteredList = controller.products.where((product) {
                final matchesSearch =
                    product.name.toLowerCase().contains(_searchQuery) ||
                    product.brand.toLowerCase().contains(_searchQuery) ||
                    product.category.toLowerCase().contains(_searchQuery);
                final matchesStatus =
                    _selectedStatusFilter == 'all' ||
                    product.status == _selectedStatusFilter;
                final matchesCategory =
                    _selectedCategoryFilter == 'all' ||
                    product.category == _selectedCategoryFilter;
                return matchesSearch && matchesStatus && matchesCategory;
              }).toList();

              // Apply Sorting
              if (_sortBy == 'name_asc') {
                filteredList.sort((a, b) => a.name.compareTo(b.name));
              } else if (_sortBy == 'name_desc') {
                filteredList.sort((a, b) => b.name.compareTo(a.name));
              } else if (_sortBy == 'stock_asc') {
                filteredList.sort((a, b) => a.stock.compareTo(b.stock));
              } else if (_sortBy == 'stock_desc') {
                filteredList.sort((a, b) => b.stock.compareTo(a.stock));
              } else {
                // newest
                filteredList.sort((a, b) {
                  final da = a.createdAt ?? DateTime.now();
                  final db = b.createdAt ?? DateTime.now();
                  return db.compareTo(da);
                });
              }

              if (filteredList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'কোনো পণ্য পাওয়া যায়নি!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                physics: const BouncingScrollPhysics(),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final product = filteredList[index];
                  return ProductCard(
                    product: product,
                    onEdit: () {
                      Get.to(() => AddProductScreen(productToEdit: product));
                    },
                    onDelete: () {
                      _showDeleteConfirmation(
                        context,
                        product.id!,
                        product.name,
                      );
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // Dropdown filter chip helper
  Widget _buildDropdownFilterChip({
    required String label,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFF95B30).withValues(alpha: 0.08)
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? const Color(0xFFF95B30).withValues(alpha: 0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFFF95B30) : Colors.black87,
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Show status filter bottom sheet
  void _showStatusFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Select Status',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              _buildFilterOption('All Statuses', 'all', _selectedStatusFilter, (
                val,
              ) {
                setState(() => _selectedStatusFilter = val);
                Navigator.pop(context);
              }),
              _buildFilterOption('Active', 'public', _selectedStatusFilter, (
                val,
              ) {
                setState(() => _selectedStatusFilter = val);
                Navigator.pop(context);
              }),
              _buildFilterOption('Inactive', 'draft', _selectedStatusFilter, (
                val,
              ) {
                setState(() => _selectedStatusFilter = val);
                Navigator.pop(context);
              }),
            ],
          ),
        );
      },
    );
  }

  // Show category filter bottom sheet
  void _showCategoryFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Select Category',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _buildFilterOption(
                      'All Categories',
                      'all',
                      _selectedCategoryFilter,
                      (val) {
                        setState(() => _selectedCategoryFilter = val);
                        Navigator.pop(context);
                      },
                    ),
                    ...controller.categories.map((cat) {
                      final name = cat['name'] as String;
                      return _buildFilterOption(
                        name,
                        name,
                        _selectedCategoryFilter,
                        (val) {
                          setState(() => _selectedCategoryFilter = val);
                          Navigator.pop(context);
                        },
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Show sorting options bottom sheet
  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Sort By',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              _buildFilterOption('Newest Created', 'newest', _sortBy, (val) {
                setState(() => _sortBy = val);
                Navigator.pop(context);
              }),
              _buildFilterOption('Name: A to Z', 'name_asc', _sortBy, (val) {
                setState(() => _sortBy = val);
                Navigator.pop(context);
              }),
              _buildFilterOption('Name: Z to A', 'name_desc', _sortBy, (val) {
                setState(() => _sortBy = val);
                Navigator.pop(context);
              }),
              _buildFilterOption('Stock: Low to High', 'stock_asc', _sortBy, (
                val,
              ) {
                setState(() => _sortBy = val);
                Navigator.pop(context);
              }),
              _buildFilterOption('Stock: High to Low', 'stock_desc', _sortBy, (
                val,
              ) {
                setState(() => _sortBy = val);
                Navigator.pop(context);
              }),
            ],
          ),
        );
      },
    );
  }

  // Filter option helper list tile
  Widget _buildFilterOption(
    String label,
    String value,
    String currentValue,
    ValueChanged<String> onChanged,
  ) {
    final bool isSelected = value == currentValue;
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFFF95B30) : Colors.black87,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_rounded, color: Color(0xFFF95B30))
          : null,
      onTap: () => onChanged(value),
    );
  }

  // Delete product confirmation
  void _showDeleteConfirmation(
    BuildContext context,
    String productId,
    String productName,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'পণ্যটি মুছে ফেলুন?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('আপনি কি নিশ্চিত যে "$productName" মুছতে চান?'),
        actions: [
          TextButton(
            child: const Text('বাতিল', style: TextStyle(color: Colors.grey)),
            onPressed: () => Get.back(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('মুছে ফেলুন'),
            onPressed: () {
              controller.deleteProduct(productId);
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}
