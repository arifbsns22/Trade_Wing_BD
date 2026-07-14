import 'dart:convert';
import 'package:flutter/material.dart';

class ProductImageWidget extends StatelessWidget {
  final String imageStr;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double iconSize;

  const ProductImageWidget({
    super.key,
    required this.imageStr,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.iconSize = 48,
  });

  @override
  Widget build(BuildContext context) {
    if (imageStr.isEmpty) {
      return Icon(Icons.image_outlined, size: iconSize, color: Colors.grey.shade300);
    }

    final trimmed = imageStr.trim();

    if (trimmed.startsWith('data:image')) {
      try {
        final commaIndex = trimmed.indexOf(',');
        if (commaIndex != -1) {
          final base64Str = trimmed.substring(commaIndex + 1).trim();
          return Image.memory(
            base64Decode(base64Str),
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.broken_image, size: iconSize, color: Colors.grey.shade400),
          );
        }
      } catch (_) {
        return Icon(Icons.broken_image, size: iconSize, color: Colors.grey.shade400);
      }
    }

    final img = trimmed.split('|').first.split(',').first.trim();
    if (img.startsWith('http') || img.startsWith('https')) {
      return Image.network(
        img,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.broken_image, size: iconSize, color: Colors.grey.shade400),
        loadingBuilder: (_, child, loading) {
          if (loading == null) return child;
          return SizedBox(
            width: width,
            height: height,
            child: Center(
              child: CircularProgressIndicator(
                value: loading.expectedTotalBytes != null
                    ? loading.cumulativeBytesLoaded / loading.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                color: const Color(0xFF034F4B),
              ),
            ),
          );
        },
      );
    }

    return Image.asset(
      img,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) =>
          Icon(Icons.broken_image, size: iconSize, color: Colors.grey.shade400),
    );
  }
}
