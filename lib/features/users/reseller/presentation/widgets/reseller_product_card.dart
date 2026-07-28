import 'package:flutter/material.dart';
import 'package:trade_wign_bd/features/admin/ecommerce/domain/models/product_model.dart';

class ResellerProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const ResellerProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final image = product.image;
    final isDraft = product.status == 'draft';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: image.isNotEmpty
                      ? (image.startsWith('http')
                          ? Image.network(image, fit: BoxFit.cover)
                          : Image.asset(image, fit: BoxFit.cover))
                      : Container(
                          color: const Color(0xFFF1F5F9),
                          child: const Icon(Icons.image_outlined, color: Colors.grey),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Name and stock details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'স্টক: ${product.stock} ${product.unit}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: product.stock > 0 ? Colors.green.shade600 : Colors.redAccent,
                      ),
                    ),
                    Text(
                      'শ্রেণী: ${product.category} | ব্র্যান্ড: ${product.brand}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              // Price Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('বিক্রয় মূল্য', style: TextStyle(fontSize: 9, color: Colors.grey)),
                  Text(
                    '৳${product.regularPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF08B3AC)),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 20),
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isDraft ? Icons.unpublished_outlined : Icons.check_circle_outline_rounded,
                    size: 14,
                    color: isDraft ? Colors.grey : Colors.green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isDraft ? 'ড্রাফট' : 'পাবলিক',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDraft ? Colors.grey : Colors.green,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Toggle Status (Publish/Unpublish)
                  IconButton(
                    icon: Icon(
                      isDraft ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.blueGrey,
                      size: 20,
                    ),
                    tooltip: isDraft ? 'পাবলিশ করুন' : 'আন-পাবলিশ করুন',
                    onPressed: onToggleStatus,
                  ),
                  // Edit
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Color(0xFF08B3AC), size: 20),
                    tooltip: 'সম্পাদনা',
                    onPressed: onEdit,
                  ),
                  // Delete
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                    tooltip: 'মুছে ফেলুন',
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
