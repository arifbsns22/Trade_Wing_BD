import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/admin/ecommerce/domain/models/product_model.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/controllers/cart_controller.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class UserProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final String? heroTag;

  const UserProductCard({super.key, required this.product, this.onTap, this.heroTag});

  Widget _buildProductImage(String imageStr) {
    if (imageStr.isEmpty) {
      return const Icon(Icons.image_outlined, size: 48, color: Colors.grey);
    }

    final trimmed = imageStr.trim();

    // Check if it is a base64 image
    if (trimmed.startsWith('data:image')) {
      try {
        final commaIndex = trimmed.indexOf(',');
        if (commaIndex != -1) {
          final base64Str = trimmed.substring(commaIndex + 1).trim();
          return Image.memory(
            base64Decode(base64Str),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 48),
          );
        }
      } catch (e) {
        debugPrint('Error decoding base64 image: $e');
        return const Icon(Icons.broken_image, size: 48);
      }
    }

    // Otherwise, split by pipe or comma for multiple image paths/URLs
    final img = trimmed.split('|').first.split(',').first.trim();
    if (img.startsWith('http') || img.startsWith('https')) {
      return Image.network(
        img,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 48),
      );
    }
    return Image.asset(
      img,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.broken_image, size: 48),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final CartController cartController = Get.find<CartController>();
    final String productId = product.id ?? product.name;

    return Obx(() {
      final currentRole = authController.currentUserRole.value;
      // Price calculation
      final currentPrice =
          product.rolePrices[currentRole] ??
          product.rolePrices['Customer'] ??
          product.rolePrices['Guest Customer'] ??
          0.0;

      final oldPrice = product.discount > 0
          ? currentPrice + product.discount
          : null;

      // Reward Points
      final rewardPoints =
          product.roleRewards[currentRole] ??
          product.roleRewards['Customer'] ??
          product.roleRewards['Guest Customer'] ??
          0;

      final quantity = cartController.getProductQuantity(productId);

      return GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top: 1:1 Image Section
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAF9),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: Hero(
                        tag: heroTag ?? productId,
                        child: _buildProductImage(product.image),
                      ),
                    ),
                  ),
                  // Discount Pill
                  if (product.discount > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF87171),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '৳${product.discount.toStringAsFixed(0)} OFF',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Bottom: Content Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand Name & Unit Row
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                product.brand.isNotEmpty
                                    ? product.brand
                                    : 'General',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (product.unit.isNotEmpty)
                              Text(
                                product.unit,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Product Name
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Rating & Reward Points
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 12,
                                  color: AppColors.primaryColor,
                                ),
                                const SizedBox(width: 2),
                                const Text(
                                  '0.0',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '(0)',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                            if (rewardPoints > 0)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.wallet_giftcard,
                                    size: 12,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '$rewardPoints Pts',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const Spacer(),

                      // Price & Cart Button Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Price
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (oldPrice != null)
                                  Text(
                                    '৳ ${oldPrice.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey.shade400,
                                      fontWeight: FontWeight.w600,
                                      height: 1.0,
                                    ),
                                  ),
                                Text(
                                  '৳${currentPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Cart Button
                          quantity == 0
                              ? GestureDetector(
                                  onTap: () =>
                                      cartController.addProductToCart(product),
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(14),
                                        bottomRight: Radius.circular(15),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.add_shopping_cart,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(14),
                                      bottomRight: Radius.circular(15),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () => cartController
                                            .decreaseQuantity(productId),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          child: Icon(
                                            Icons.remove,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '$quantity',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => cartController
                                            .addProductToCart(product),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class CurvedCardContainer extends StatelessWidget {
  final Widget child;
  final double width;

  const CurvedCardContainer({
    super.key,
    required this.child,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CurvedCardPainter(),
      child: ClipPath(
        clipper: CurvedCardClipper(),
        child: SizedBox(width: width, child: child),
      ),
    );
  }
}

class CurvedCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return getCurvedCardPath(size);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class CurvedCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = getCurvedCardPath(size);

    // Draw Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.015)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawPath(path.shift(const Offset(0, 4)), shadowPaint);

    // Draw White Background
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, bgPaint);

    // Draw Border
    final borderPaint = Paint()
      ..color = Colors.grey.shade100
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Path getCurvedCardPath(Size size) {
  final path = Path();
  final w = size.width;
  final h = size.height;
  final r = 24.0; // Top corner radius

  // Start at top-left corner (after the radius)
  path.moveTo(r, 0);
  path.lineTo(w - r, 0);
  path.quadraticBezierTo(w, 0, w, r);

  // Right side down to where the bottom curve starts (h - 24)
  path.lineTo(w, h - 24);

  // Bottom curve (Cubic Bezier dipping in the middle)
  // Control points: (w, h + 8) and (0, h + 8)
  path.cubicTo(w, h + 8, 0, h + 8, 0, h - 24);

  // Left side up to top-left corner
  path.lineTo(0, r);
  path.quadraticBezierTo(0, 0, r, 0);

  path.close();
  return path;
}

class CurvedButtonContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  final double height;

  const CurvedButtonContainer({
    super.key,
    required this.child,
    required this.color,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CurvedButtonPainter(color: color),
      child: Container(
        width: double.infinity,
        height: height,
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

class _CurvedButtonPainter extends CustomPainter {
  final Color color;

  _CurvedButtonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // Start at top-left
    path.moveTo(0, 0);

    // Top curve dipping in the middle
    path.cubicTo(w * 0.25, 8, w * 0.75, 8, w, 0);

    // Right side down to bottom-right
    path.lineTo(w, h);

    // Bottom side to bottom-left
    path.lineTo(0, h);

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CurvedButtonPainter oldDelegate) =>
      oldDelegate.color != color;
}
