import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/admin/ecommerce/presentation/controllers/ecommerce_controller.dart';
import 'package:trade_wign_bd/features/admin/ecommerce/domain/models/product_model.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/controllers/cart_controller.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/screens/cart_screen.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({super.key});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar>
    with SingleTickerProviderStateMixin {
  final EcommerceController controller = Get.put(EcommerceController());
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  String _searchQuery = '';
  List<Map<String, dynamic>> _suggestions = [];
  bool _isOverlayVisible = false;

  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _updateSuggestions();
      } else {
        _hideOverlay();
      }
    });
  }

  @override
  void dispose() {
    _hideOverlay();
    _searchController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _updateSuggestions() {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      _suggestions = [];
      _hideOverlay();
      return;
    }

    final List<Map<String, dynamic>> tempSuggestions = [];

    // 1. Matches in Products (by name)
    final matchedProducts = controller.products
        .where((p) => p.name.toLowerCase().contains(query))
        .take(4)
        .toList();
    for (var p in matchedProducts) {
      tempSuggestions.add({
        'type': 'product',
        'title': p.name,
        'subtitle':
            'Product • ৳${(p.rolePrices['Customer'] ?? 0.0).toStringAsFixed(2)}',
        'data': p,
      });
    }

    // 2. Matches in Categories
    final matchedCategories = controller.categories
        .where((c) => (c['name'] as String).toLowerCase().contains(query))
        .take(3)
        .toList();
    for (var c in matchedCategories) {
      tempSuggestions.add({
        'type': 'category',
        'title': c['name'] as String,
        'subtitle': 'Category',
        'data': c['name'] as String,
      });
    }

    // 3. Matches in Brands
    final matchedBrands = controller.brands
        .where((b) => (b['name'] as String).toLowerCase().contains(query))
        .take(3)
        .toList();
    for (var b in matchedBrands) {
      tempSuggestions.add({
        'type': 'brand',
        'title': b['name'] as String,
        'subtitle': 'Brand',
        'data': b['name'] as String,
      });
    }

    setState(() {
      _suggestions = tempSuggestions;
    });

    if (_suggestions.isNotEmpty && _focusNode.hasFocus) {
      _showOverlay();
    } else {
      _hideOverlay();
    }
  }

  void _showOverlay() {
    if (_isOverlayVisible) {
      _overlayEntry?.markNeedsBuild();
      return;
    }

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOverlayVisible = true;
    });
    _animationController.forward();
  }

  void _hideOverlay() {
    if (!_isOverlayVisible) return;
    _animationController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      if (mounted) {
        setState(() {
          _isOverlayVisible = false;
        });
      }
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width - 64, // Align with the search field width
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 6),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            shadowColor: Colors.black.withValues(alpha: 0.2),
            child: SizeTransition(
              sizeFactor: _expandAnimation,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 280),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    IconData icon;
                    Color iconColor;

                    switch (suggestion['type']) {
                      case 'product':
                        icon = Icons.inventory_2_outlined;
                        iconColor = const Color(0xFF08B3AC);
                        break;
                      case 'category':
                        icon = Icons.category_outlined;
                        iconColor = Colors.orange;
                        break;
                      case 'brand':
                        icon = Icons.branding_watermark_outlined;
                        iconColor = Colors.blue;
                        break;
                      default:
                        icon = Icons.search_rounded;
                        iconColor = Colors.grey;
                    }

                    return ListTile(
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: iconColor.withValues(alpha: 0.08),
                        child: Icon(icon, size: 16, color: iconColor),
                      ),
                      title: Text(
                        suggestion['title'],
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        suggestion['subtitle'],
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      dense: true,
                      onTap: () {
                        _focusNode.unfocus();
                        _hideOverlay();
                        _handleSuggestionTap(suggestion);
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSuggestionTap(Map<String, dynamic> suggestion) {
    if (suggestion['type'] == 'product') {
      final Product product = suggestion['data'] as Product;
      _showProductDetailDialog(product);
    } else {
      final String filterValue = suggestion['data'] as String;
      final String filterType = suggestion['type'];
      _showFilteredProductsDialog(filterType, filterValue);
    }
  }

  void _showProductDetailDialog(Product product) {
    final price =
        product.rolePrices['Customer'] ??
        product.rolePrices['Guest Customer'] ??
        0.0;

    final List<String> images = product.image
        .split(RegExp(r'[|,]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (images.isEmpty) {
      images.add('');
    }

    int selectedImageIndex = 0;
    int qty = 1;
    bool isDescriptionExpanded = false;
    final isOutOfStock = product.stock <= 0;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          width: 760,
          color: Colors.white,
          child: Stack(
            children: [
              // Content (built first in Stack so it sits underneath the close button)
              StatefulBuilder(
                builder: (context, setState) {
                  // Left Section (Image + Thumbnails)
                  final leftSection = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Main Image Container
                      Container(
                        height: 240,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade100,
                            width: 1.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: _buildProductImage(
                              images[selectedImageIndex],
                            ),
                          ),
                        ),
                      ),
                      if (images.length > 1) ...[
                        const SizedBox(height: 12),
                        // Thumbnails Row
                        SizedBox(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: images.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final isSelected = index == selectedImageIndex;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedImageIndex = index;
                                  });
                                },
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryColor
                                          : Colors.grey.shade200,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: _buildProductImage(images[index]),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  );

                  // Right Section (Information)
                  final rightSection = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Category + Verified check mark
                      Row(
                        children: [
                          Text(
                            product.category.isNotEmpty
                                ? product.category
                                : "Daily Care",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.verified,
                            color: AppColors.primaryColor,
                            size: 14,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Product Name & In Stock Badge
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isOutOfStock
                                  ? Colors.red.shade50
                                  : const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isOutOfStock ? "Out of Stock" : "In Stock",
                              style: TextStyle(
                                color: isOutOfStock
                                    ? Colors.red.shade600
                                    : const Color(0xFF2563EB),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Ratings & Reviews row
                      Row(
                        children: [
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < 4 ? Icons.star : Icons.star_border,
                                color: const Color(0xFFFBBF24),
                                size: 16,
                              );
                            }),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            "(4.0)",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "|",
                            style: TextStyle(color: Colors.grey.shade300),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "2 Reviews",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Price
                      Text(
                        '৳${price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Description (collapsible / read more)
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: isDescriptionExpanded
                                  ? product.description
                                  : (product.description.length > 100
                                        ? '${product.description.substring(0, 100)}...'
                                        : product.description),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                height: 1.4,
                              ),
                            ),
                            if (product.description.length > 100)
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isDescriptionExpanded =
                                          !isDescriptionExpanded;
                                    });
                                  },
                                  child: Text(
                                    isDescriptionExpanded
                                        ? ' Show less'
                                        : 'Read more',
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Unit: Pcs
                      Row(
                        children: [
                          Text(
                            "Unit: ",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            product.unit.isNotEmpty ? product.unit : "Pcs",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Quantity & Total Price row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Quantity Selector
                          Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove,
                                    size: 16,
                                    color: Color(0xFF64748B),
                                  ),
                                  onPressed: () {
                                    if (qty > 1) {
                                      setState(() {
                                        qty--;
                                      });
                                    }
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                  ),
                                ),
                                Text(
                                  qty.toString().padLeft(2, '0'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    size: 16,
                                    color: Color(0xFF64748B),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      qty++;
                                    });
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Total Price
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "Total Price: ",
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 13,
                                  ),
                                ),
                                TextSpan(
                                  text: "৳${(price * qty).toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Action Buttons Row
                      Row(
                        children: [
                          // Buy Now
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor
                                    .withValues(
                                      alpha: 0.15,
                                    ), // Light primary color
                                foregroundColor:
                                    AppColors.green, // Dark green text
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                minimumSize: const Size(0, 44),
                              ),
                              onPressed: () {
                                final cartCtrl = Get.find<CartController>();
                                final id = product.id ?? product.name;
                                cartCtrl.addProductToCart(product);
                                cartCtrl.setQuantity(id, qty);
                                Get.back(); // close dialog
                                Get.to(
                                  () => const CartScreen(),
                                  transition: Transition.rightToLeft,
                                );
                              },
                              child: const Text(
                                'Buy Now',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Add to Cart
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors
                                    .primaryColor, // Solid primary color
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                minimumSize: const Size(0, 44),
                              ),
                              onPressed: () {
                                final cartCtrl = Get.find<CartController>();
                                final id = product.id ?? product.name;
                                cartCtrl.addProductToCart(product);
                                cartCtrl.setQuantity(id, qty);
                                Get.back(); // close dialog
                                Get.snackbar(
  'Added to Cart',
  '${product.name} has been added to your cart.',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
                              },
                              child: const Text(
                                'Add to Cart',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 500;
                        if (isWide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(width: 250, child: leftSection),
                              const SizedBox(width: 24),
                              Expanded(child: rightSection),
                            ],
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              leftSection,
                              const SizedBox(height: 20),
                              rightSection,
                            ],
                          );
                        }
                      },
                    ),
                  );
                },
              ),
              // Close button (placed last so it renders on top of the content stack)
              Positioned(
                right: 12,
                top: 12,
                child: IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: () => Get.back(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilteredProductsDialog(String type, String value) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${type.capitalizeFirst}: $value',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Get.back(),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const Divider(height: 20),
              Expanded(
                child: Obx(() {
                  final filtered = controller.products.where((p) {
                    if (type == 'brand') {
                      return p.brand.toLowerCase() == value.toLowerCase();
                    } else {
                      return p.category.toLowerCase() == value.toLowerCase();
                    }
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('No products found'));
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final product = filtered[index];
                      final price =
                          product.rolePrices['Customer'] ??
                          product.rolePrices['Guest Customer'] ??
                          0.0;
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 44,
                                height: 44,
                                color: Colors.white,
                                child: _buildProductImage(product.image),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    product.brand,
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '৳${price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFF08B3AC),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        String tempCategory = 'all';
        String tempBrand = 'all';
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Products',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 32,
                    child: Obx(() {
                      final list =
                          <Map<String, dynamic>>[
                            {'id': 'all', 'name': 'All Categories'},
                          ] +
                          controller.categories.toList();
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final item = list[index];
                          final name = item['name'] as String;
                          final id = item['id'] as String;
                          final isSelected =
                              (id == 'all' && tempCategory == 'all') ||
                              (name == tempCategory);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(name),
                              selected: isSelected,
                              onSelected: (selected) {
                                setModalState(() {
                                  tempCategory = id == 'all' ? 'all' : name;
                                });
                              },
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              selectedColor: const Color(0xFF08B3AC),
                              backgroundColor: const Color(0xFFF1F5F9),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Brands',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 32,
                    child: Obx(() {
                      final list =
                          <Map<String, dynamic>>[
                            {'id': 'all', 'name': 'All Brands'},
                          ] +
                          controller.brands.toList();
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final item = list[index];
                          final name = item['name'] as String;
                          final id = item['id'] as String;
                          final isSelected =
                              (id == 'all' && tempBrand == 'all') ||
                              (name == tempBrand);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(name),
                              selected: isSelected,
                              onSelected: (selected) {
                                setModalState(() {
                                  tempBrand = id == 'all' ? 'all' : name;
                                });
                              },
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              selectedColor: const Color(0xFF08B3AC),
                              backgroundColor: const Color(0xFFF1F5F9),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: const Size(double.infinity, 44),
                          ),
                          onPressed: () {
                            setModalState(() {
                              tempCategory = 'all';
                              tempBrand = 'all';
                            });
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF08B3AC),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: const Size(double.infinity, 44),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _showFilteredResultsDialog(tempCategory, tempBrand);
                          },
                          child: const Text('Apply'),
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

  void _showFilteredResultsDialog(String category, String brand) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filtered Products',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Get.back(),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const Divider(height: 20),
              Expanded(
                child: Obx(() {
                  final filtered = controller.products.where((p) {
                    final matchesCategory =
                        category == 'all' ||
                        p.category.toLowerCase() == category.toLowerCase();
                    final matchesBrand =
                        brand == 'all' ||
                        p.brand.toLowerCase() == brand.toLowerCase();
                    return matchesCategory && matchesBrand;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text('No products found matching filters'),
                    );
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final product = filtered[index];
                      final price =
                          product.rolePrices['Customer'] ??
                          product.rolePrices['Guest Customer'] ??
                          0.0;
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 44,
                                height: 44,
                                color: Colors.white,
                                child: _buildProductImage(product.image),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${product.brand} • ${product.category}',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '৳${price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFF08B3AC),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(String imageStr) {
    if (imageStr.isEmpty) {
      return const Icon(Icons.image_outlined, color: Colors.grey, size: 24);
    }
    final img = imageStr.split('|').first.split(',').first.trim();
    if (img.startsWith('data:image')) {
      try {
        final clean = img.contains(',') ? img.split(',')[1] : img;
        return Image.memory(
          base64Decode(clean),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image, size: 24),
        );
      } catch (_) {}
    }
    if (img.startsWith('http') || img.startsWith('https')) {
      return Image.network(
        img,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 24),
      );
    }
    return Image.asset(
      img,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.image_outlined, size: 24, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 1. Search Field
        Expanded(
          child: CompositedTransformTarget(
            link: _layerLink,
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              style: const TextStyle(color: Colors.black87, fontSize: 15),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
                _updateSuggestions();
              },
              decoration: InputDecoration(
                hintText: 'পণ্যের নাম কিংবা ক্যাটাগরি খুঁজুন',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                          _updateSuggestions();
                        },
                        child: const Icon(
                          Icons.clear_rounded,
                          color: Colors.grey,
                          size: 18,
                        ),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                isDense: true,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // 2. Filter Circle Button (Clean and Minimal Dark Theme)
        GestureDetector(
          onTap: _showFilterBottomSheet,
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.tune_rounded,
              color: AppColors.primaryColor,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
