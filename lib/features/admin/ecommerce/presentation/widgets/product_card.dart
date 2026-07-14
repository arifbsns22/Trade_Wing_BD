import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../domain/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Determine display price (default to Customer)
    final double displayPrice =
        product.rolePrices['Customer'] ??
        product.rolePrices['Guest Customer'] ??
        0.0;

    // Determine variant text
    String variantText = 'Regular';
    if (product.variants.isNotEmpty) {
      variantText = product.variants.first;
    } else if (product.sizes.isNotEmpty) {
      variantText = product.sizes.first;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Thumbnail Image (Left)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 80,
              width: 80,
              color: Colors.grey.shade50,
              child: _buildProductImage(product.image),
            ),
          ),
          const SizedBox(width: 16),

          // 2. Info Column (Center)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badges Row
                Row(
                  children: [
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: product.status == 'public'
                            ? Colors.green.withValues(alpha: 0.08)
                            : Colors.orange.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: product.status == 'public'
                                  ? Colors.green
                                  : Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            product.status == 'public' ? 'Active' : 'Inactive',
                            style: TextStyle(
                              color: product.status == 'public'
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Stock Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: product.stock > 0
                            ? Colors.blue.withValues(alpha: 0.08)
                            : Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        product.stock > 0 ? 'In Stock' : 'Out of Stock',
                        style: TextStyle(
                          color: product.stock > 0
                              ? Colors.blue.shade700
                              : Colors.red.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Product Name
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Price
                Text(
                  '৳${displayPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1A1A1A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // Variant • Stock
                Text(
                  '$variantText  •  ${product.stock} stocks',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // 3. Actions Button (Right)
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade400),
            padding: EdgeInsets.zero,
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              } else if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('এডিট করুন', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('ডিলিট করুন', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<String> _parseImages(String imageStr) {
    if (imageStr.isEmpty) return [];
    if (imageStr.contains('|')) {
      return imageStr
          .split('|')
          .map((img) => img.trim())
          .where((img) => img.isNotEmpty)
          .toList();
    }
    if (imageStr.startsWith('data:image')) {
      return [imageStr];
    }
    if (imageStr.contains(',')) {
      return imageStr
          .split(',')
          .map((img) => img.trim())
          .where((img) => img.isNotEmpty)
          .toList();
    }
    return [imageStr];
  }

  // Helper: Renders base64, multiple images, asset, file, or placeholder
  Widget _buildProductImage(String imageStr) {
    final images = _parseImages(imageStr);
    if (images.isEmpty) {
      return const Icon(Icons.image_outlined, size: 32, color: Colors.grey);
    }

    final firstImage = images.first;
    if (firstImage.isEmpty) {
      return const Icon(Icons.image_outlined, size: 32, color: Colors.grey);
    }

    if (firstImage.startsWith('data:image') ||
        (!firstImage.startsWith('assets') &&
            !firstImage.contains('http') &&
            !firstImage.contains('/'))) {
      try {
        final base64Clean = firstImage.contains(',')
            ? firstImage.split(',')[1]
            : firstImage;
        return Image.memory(
          base64Decode(base64Clean),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image_outlined, size: 32),
        );
      } catch (_) {}
    }

    if (firstImage.startsWith('http') || firstImage.startsWith('https')) {
      return Image.network(
        firstImage,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.broken_image_outlined, size: 32),
      );
    }

    if (!kIsWeb) {
      final localFile = File(
        'c:\\Users\\mohos\\OneDrive\\Desktop\\trade_wign_bd\\$firstImage',
      );
      if (localFile.existsSync()) {
        return Image.file(localFile, fit: BoxFit.cover);
      }
    }

    return Image.asset(
      firstImage,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.image_outlined, size: 32, color: Colors.grey),
    );
  }
}
