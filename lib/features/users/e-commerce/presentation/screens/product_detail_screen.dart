import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trade_wign_bd/features/admin/ecommerce/domain/models/product_model.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import 'package:trade_wign_bd/features/users/e-commerce/domain/models/product_review_model.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/controllers/cart_controller.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/controllers/product_review_controller.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/screens/cart_screen.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/widgets/ecommerce_appbar.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/widgets/product_image_widget.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/widgets/review_dialog_widget.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final String? heroTag;

  const ProductDetailScreen({super.key, required this.product, this.heroTag});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _addedController;
  late Animation<double> _addedAnimation;
  bool _descExpanded = false;
  int _localQty = 0;

  late final CartController _cartController;
  late final AuthController _authController;
  late final ProductReviewController _reviewController;
  late final String _productId;

  @override
  void initState() {
    super.initState();
    _cartController = Get.find<CartController>();
    _authController = Get.find<AuthController>();
    _reviewController = Get.find<ProductReviewController>();
    _productId = widget.product.id ?? widget.product.name;
    _localQty = _cartController.getProductQuantity(_productId);

    _addedController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _addedAnimation = CurvedAnimation(
      parent: _addedController,
      curve: Curves.elasticOut,
    );

    // Load reviews
    _reviewController.fetchReviews(_productId);
  }

  @override
  void dispose() {
    _addedController.dispose();
    super.dispose();
  }

  double _getPrice() {
    final role = _authController.currentUserRole.value;
    return widget.product.rolePrices[role] ??
        widget.product.rolePrices['Customer'] ??
        widget.product.rolePrices['Guest Customer'] ??
        0.0;
  }

  void _increment() {
    setState(() => _localQty++);
    _cartController.addProductToCart(widget.product);
    _addedController.forward(from: 0);
  }

  void _decrement() {
    if (_localQty > 0) {
      setState(() => _localQty--);
      _cartController.decreaseQuantity(_productId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final priceStr = _getPrice().toStringAsFixed(2);
    final priceParts = priceStr.split('.');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: EcommerceAppBar(
        title: 'পণ্যের বিবরণ',
        onCartTap: () => Get.to(
          () => const CartScreen(),
          transition: Transition.rightToLeft,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero Image Card ──────────────────────────────────
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      children: [
                        // Pull indicator at top
                        Positioned(
                          top: 10,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 36,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                        Hero(
                          tag: widget.heroTag ?? _productId,
                          child: ProductImageWidget(
                            imageStr: product.image,
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            iconSize: 80,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Product Info ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + Unit
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                            height: 1.2,
                          ),
                        ),
                        if (product.unit.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            product.unit,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),

                        // Price + Fast Delivery
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Obx(() {
                              final price = _getPrice();
                              final ps = price.toStringAsFixed(2).split('.');

                              final role =
                                  _authController.currentUserRole.value;
                              final rewardPoints =
                                  widget.product.roleRewards[role] ?? 0;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (widget.product.regularPrice > price)
                                    Text(
                                      '৳${widget.product.regularPrice.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.grey.shade500,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '৳',
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.green,
                                        ),
                                      ),
                                      Text(
                                        ps[0],
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.green,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          '.${ps[1]}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.green,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (rewardPoints > 0) ...[
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.stars_rounded,
                                            color: Colors.orange,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$rewardPoints পয়েন্ট',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            }),
                            const Spacer(),
                            // Fast delivery badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3EEFF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.bolt_rounded,
                                    color: Color(0xFF7C3AED),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'দ্রুত ডেলিভারি',
                                    style: TextStyle(
                                      color: const Color(
                                        0xFF7C3AED,
                                      ).withValues(alpha: 0.9),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Variants + Rating row
                        Row(
                          children: [
                            // Variant color circles
                            if (product.variants.isNotEmpty) ...[
                              ...List.generate(
                                product.variants.length.clamp(0, 4),
                                (i) {
                                  final colors = [
                                    const Color(0xFF7C3AED),
                                    const Color(0xFFE07C39),
                                    const Color(0xFF034F4B),
                                    const Color(0xFFE11471),
                                  ];
                                  return Container(
                                    margin: const EdgeInsets.only(right: 6),
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: colors[i % colors.length],
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: colors[i % colors.length]
                                              .withValues(alpha: 0.4),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                            const Spacer(),
                            // Rating
                            Obx(() {
                              final avg = _reviewController.getAverageRating(
                                _productId,
                              );
                              final reviewCount = _reviewController
                                  .getReviews(_productId)
                                  .length;
                              return GestureDetector(
                                onTap: _showReviewsSheet,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Color(0xFFF59E0B),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      avg > 0
                                          ? '${avg.toStringAsFixed(1)} রেটিং'
                                          : 'এখনও কোনো রেটিং নেই',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    if (reviewCount > 0) ...[
                                      const SizedBox(width: 4),
                                      Text(
                                        '($reviewCount)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Divider
                        Divider(color: Colors.grey.shade100, thickness: 1.5),
                        const SizedBox(height: 12),

                        // Description
                        const Text(
                          'এই পণ্য সম্পর্কে',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedCrossFade(
                          firstChild: Text(
                            product.description.isNotEmpty
                                ? product.description
                                : '১০০% সন্তুষ্টির নিশ্চয়তা। যদি আপনার কোনো সমস্যা যেমন নিখোঁজ, খারাপ আইটেম, দেরিতে পৌঁছানো, অপেশাদার পরিষেবা হয়...',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              height: 1.6,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          secondChild: Text(
                            product.description.isNotEmpty
                                ? product.description
                                : '১০০% সন্তুষ্টির নিশ্চয়তা। যদি আপনার কোনো সমস্যা যেমন নিখোঁজ, খারাপ আইটেম, দেরিতে পৌঁছানো, অপেশাদার পরিষেবা হয়, তবে আপনাকে ক্ষতিপূরণ দেওয়া হবে। সহায়তার জন্য দয়া করে সাপোর্টে যোগাযোগ করুন।',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              height: 1.6,
                            ),
                          ),
                          crossFadeState: _descExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 300),
                        ),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _descExpanded = !_descExpanded),
                          child: Text(
                            _descExpanded ? 'কম দেখান' : 'আরও পড়ুন',
                            style: const TextStyle(
                              color: Color(0xFF034F4B),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Reviews Section ───────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'গ্রাহকের মতামত',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            TextButton(
                              onPressed: _showWriteReviewDialog,
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF034F4B),
                                textStyle: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text('+ রিভিউ লিখুন'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Obx(() {
                          final reviews = _reviewController.getReviews(
                            _productId,
                          );
                          if (reviews.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  'এখনও কোনো রিভিউ নেই। প্রথম রিভিউটি লিখুন!',
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: reviews
                                .take(3)
                                .map((r) => _ReviewTile(review: r))
                                .toList(),
                          );
                        }),

                        if (_reviewController.getReviews(_productId).length > 3)
                          Center(
                            child: TextButton(
                              onPressed: _showReviewsSheet,
                              child: const Text(
                                'সবগুলো রিভিউ দেখুন',
                                style: TextStyle(color: Color(0xFF034F4B)),
                              ),
                            ),
                          ),

                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Action Bar ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Quantity Stepper
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200, width: 1.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _StepperButton(
                        icon: Icons.remove,
                        onTap: _decrement,
                        enabled: _localQty > 0,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '$_localQty',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.green,
                          ),
                        ),
                      ),
                      _StepperButton(
                        icon: Icons.add,
                        onTap: _increment,
                        enabled: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Add to Cart button
                Expanded(
                  child: ScaleTransition(
                    scale: _addedAnimation.drive(Tween(begin: 1.0, end: 1.05)),
                    child: GestureDetector(
                      onTap: () {
                        if (_localQty == 0) {
                          _increment();
                        }
                        Get.to(
                          () => const CartScreen(),
                          transition: Transition.rightToLeft,
                        );
                      },
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.cartArrowDown,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'কার্টে যোগ করুন',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'সবগুলো রিভিউ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF034F4B),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(() {
                  final reviews = _reviewController.getReviews(_productId);
                  if (reviews.isEmpty) {
                    return const Center(child: Text('এখনও কোনো রিভিউ নেই।'));
                  }
                  return ListView.builder(
                    controller: ctrl,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: reviews.length,
                    itemBuilder: (_, i) => _ReviewTile(review: reviews[i]),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWriteReviewDialog() {
    showDialog(
      context: context,
      builder: (_) => ReviewDialogWidget(
        productId: _productId,
        reviewController: _reviewController,
      ),
    );
  }
}

// ─────────────────────────────────────────
// Helper Widgets
// ─────────────────────────────────────────

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _StepperButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 48,
        height: 52,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 22,
          color: enabled ? const Color(0xFF034F4B) : Colors.grey.shade300,
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final ProductReview review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF034F4B).withValues(alpha: 0.1),
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: Color(0xFF034F4B),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < review.rating.round()
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 13,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(review.createdAt),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
  }
}
