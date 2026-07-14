import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/admin/ecommerce/domain/models/product_model.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/controllers/cart_controller.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/screens/payment_screen.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/widgets/ecommerce_appbar.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/widgets/product_image_widget.dart';
import 'package:trade_wign_bd/features/auth/presentation/screens/login_screen.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _promoVisible = true;

  @override
  Widget build(BuildContext context) {
    final CartController cartCtrl = Get.find<CartController>();
    final AuthController authCtrl = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: EcommerceAppBar(
        title: 'আমার কার্ট',
        onCartTap: null, // already on cart screen
      ),
      body: Obx(() {
        final cartItems = cartCtrl.cartItems;
        final cartProducts = cartCtrl.cartProductList;

        if (cartItems.isEmpty) {
          return _buildEmptyCart();
        }

        // Group products by brand
        final Map<String, List<Product>> grouped = {};
        for (final product in cartProducts) {
          final brand = product.brand.isNotEmpty ? product.brand : 'আনব্র্যান্ডেড';
          grouped.putIfAbsent(brand, () => []).add(product);
        }

        final role = authCtrl.currentUserRole.value;
        final total = cartCtrl.totalPrice();

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Share cart banner
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.grey.shade100,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'G',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Trade Wign BD',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.green,
                                  ),
                                ),
                                Text(
                                  'নতুন শেয়ারড কার্টের মাধ্যমে একসাথে শপিং করুন',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'কার্ট শেয়ার করুন',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Grouped store sections
                    ...grouped.entries.map((entry) {
                      return _StoreSection(
                        storeName: entry.key,
                        products: entry.value,
                        role: role,
                        cartCtrl: cartCtrl,
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Bottom area: promo + checkout
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Promo banner
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    child: _promoVisible
                        ? Container(
                            margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAFBF0),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.green.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  '🎁',
                                  style: TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'এই অর্ডারে দ্রুত ডেলিভারি পান',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.green,
                                        ),
                                      ),
                                      Text(
                                        'আপনার অর্ডার ডেলিভারি হতে ২-৩ কর্মদিবস সময় লাগতে পারে।',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _promoVisible = false),
                                  child: Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  // Checkout button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                    child: GestureDetector(
                      onTap: () {
                        if (authCtrl.currentUserRole.value ==
                            'Guest Customer') {
                          Get.snackbar(
                            'লগইন প্রয়োজন',
                            'অর্ডার সম্পন্ন করতে প্রথমে আপনার অ্যাকাউন্টে লগইন করুন।',
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.9,
                            ),
                            colorText: Colors.black87,
                            borderColor: AppColors.primaryColor.withValues(
                              alpha: 0.2,
                            ),
                            borderWidth: 1,
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                          );
                          Get.to(
                            () => const LoginScreen(returnBack: true),
                            transition: Transition.rightToLeft,
                          );
                        } else {
                          Get.to(
                            () => PaymentScreen(total: total),
                            transition: Transition.rightToLeft,
                          );
                        }
                      },
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_checkout_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'চেকআউট  ৳${total.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'আপনার কার্টটি খালি',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'শুরু করতে কিছু পণ্য যোগ করুন',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'শপিং চালিয়ে যান',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Store Section Widget
// ─────────────────────────────────────────
class _StoreSection extends StatefulWidget {
  final String storeName;
  final List<Product> products;
  final String role;
  final CartController cartCtrl;

  const _StoreSection({
    required this.storeName,
    required this.products,
    required this.role,
    required this.cartCtrl,
  });

  @override
  State<_StoreSection> createState() => _StoreSectionState();
}

class _StoreSectionState extends State<_StoreSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(
                    Icons.storefront_rounded,
                    size: 20,
                    color: AppColors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.storeName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: widget.products.map((p) {
                return _CartItemRow(
                  product: p,
                  role: widget.role,
                  cartCtrl: widget.cartCtrl,
                );
              }).toList(),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Cart Item Row Widget
// ─────────────────────────────────────────
class _CartItemRow extends StatelessWidget {
  final Product product;
  final String role;
  final CartController cartCtrl;

  const _CartItemRow({
    required this.product,
    required this.role,
    required this.cartCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final productId = product.id ?? product.name;
    final price =
        product.rolePrices[role] ??
        product.rolePrices['Customer'] ??
        product.rolePrices['Guest Customer'] ??
        0.0;

    return Obx(() {
      final qty = cartCtrl.getProductQuantity(productId);

      return Column(
        children: [
          Divider(
            height: 1,
            color: Colors.grey.shade100,
            indent: 14,
            endIndent: 14,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info icon
                Padding(
                  padding: const EdgeInsets.only(top: 2, right: 8),
                  child: Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ),

                // Product image
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: ProductImageWidget(
                    imageStr: product.image,
                    fit: BoxFit.contain,
                    iconSize: 28,
                  ),
                ),
                const SizedBox(width: 10),

                // Name + unit + price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (product.unit.isNotEmpty)
                        Text(
                          product.unit,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        '৳${price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                // Quantity controls
                Container(
                  height: 32,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => cartCtrl.decreaseQuantity(productId),
                        child: Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.remove,
                            size: 16,
                            color: AppColors.green,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          '$qty',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.green,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => cartCtrl.addProductToCart(product),
                        child: Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.add,
                            size: 16,
                            color: AppColors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Replace row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Row(
              children: [
                const SizedBox(width: 24),
                Icon(
                  Icons.swap_horiz_rounded,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 6),
                Text(
                  'পরিবর্তন করুন ',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                Text(
                  product.category.isNotEmpty
                      ? product.category
                      : 'অনুরূপ আইটেম দিয়ে',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 14,
                  color: AppColors.green,
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
