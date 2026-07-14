import 'package:flutter/material.dart';
import 'package:trade_wign_bd/features/admin/packages/domain/models/package_model.dart';

class UserPackageCard extends StatelessWidget {
  final SubscriptionPackage package;
  final VoidCallback onUpgrade;

  const UserPackageCard({
    super.key,
    required this.package,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTopChoice = package.isTopChoice;

    // Colors
    final Color bgColor = isTopChoice ? const Color(0xFF0C4A3A) : Colors.white;
    final Color textColor = isTopChoice ? Colors.white : Colors.black87;
    final Color buttonColor = const Color(0xFFDDF067); // lemon
    final Color buttonTextColor = Colors.black87;
    final Color featureTextColor = isTopChoice ? Colors.white : Colors.black87;
    final Color innerCardColor = isTopChoice
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFF9FDF5);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        gradient: isTopChoice
            ? null
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Color(0xFFF3FAD2), // soft lemon gradient for bottom
                ],
              ),
        boxShadow: [
          BoxShadow(
            color: isTopChoice
                ? Colors.black.withValues(alpha: 0.15)
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: !isTopChoice ? Border.all(color: Colors.grey.shade200) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact Banner Image
          if (package.image != null && package.image!.isNotEmpty)
            Image.network(
              package.image!,
              width: double.infinity,
              height: 240,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 240,
                width: double.infinity,
                color: Colors.grey.shade200,
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Name & Badge)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package.name,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (package.description.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              package.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: isTopChoice
                                    ? Colors.white70
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isTopChoice) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.workspace_premium,
                              size: 14,
                              color: Colors.black87,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Top Choice',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),

                // Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '৳${package.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        letterSpacing: -1.0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6, left: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (package.totalMrp > 0 &&
                              package.totalMrp > package.price)
                            Text(
                              'MRP ৳${package.totalMrp.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.lineThrough,
                                color: isTopChoice
                                    ? Colors.white60
                                    : Colors.grey.shade500,
                              ),
                            ),
                          Text(
                            '/one time',
                            style: TextStyle(
                              fontSize: 13,
                              color: isTopChoice
                                  ? Colors.white60
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // BUNDLE PRODUCTS Title
                Text(
                  'PRODUCTS IN THIS BUNDLE :',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: isTopChoice ? Colors.white60 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),

                // Products List
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: innerCardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: package.products.map((product) {
                      final double productTotalMrp =
                          product.mrpPrice * product.quantity;
                      final double productTotalPkgPrice =
                          product.packagePrice * product.quantity;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Quantity Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isTopChoice
                                    ? const Color(0xFFDDF067)
                                    : const Color(0xFF0C4A3A),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${product.quantity} ${product.unit}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: isTopChoice
                                      ? Colors.black87
                                      : Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Product Name & Brand
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: featureTextColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (product.brand.isNotEmpty)
                                    Text(
                                      product.brand,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isTopChoice
                                            ? Colors.white54
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Product Prices
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '৳${productTotalPkgPrice.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: isTopChoice
                                        ? const Color(0xFFDDF067)
                                        : const Color(0xFF0C4A3A),
                                  ),
                                ),
                                if (productTotalMrp > 0 &&
                                    productTotalMrp > productTotalPkgPrice)
                                  Text(
                                    '৳${productTotalMrp.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      decoration: TextDecoration.lineThrough,
                                      color: isTopChoice
                                          ? Colors.white54
                                          : Colors.grey.shade500,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Upgrade Button (Moved to bottom)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: buttonTextColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: isTopChoice ? 0 : 2,
                      shadowColor: Colors.black.withValues(alpha: 0.1),
                    ),
                    onPressed: onUpgrade,
                    child: const Text(
                      'প্যাকেজটি কিনুন',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
}
