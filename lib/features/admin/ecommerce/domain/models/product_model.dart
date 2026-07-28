import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String? id;
  final String name;
  final String type; // 'medicine' | 'regular' | 'package'
  final String brand;
  final String category;
  final String image;
  final String description;
  final int stock;
  final double regularPrice;
  final double discount;
  final String discountType; // 'fixed' | 'percentage'
  final double vat;
  final double extraExpenses;
  final String unit;
  final List<String> sizes;
  final List<String> variants;
  final String status; // 'public' | 'draft'
  final Map<String, double> rolePrices;
  final Map<String, int> roleRewards;
  final DateTime? createdAt;
  final String? shopName;

  Product({
    this.id,
    required this.name,
    required this.type,
    required this.brand,
    required this.category,
    required this.image,
    required this.description,
    required this.stock,
    this.regularPrice = 0.0,
    required this.discount,
    this.discountType = 'fixed',
    this.vat = 0.0,
    this.extraExpenses = 0.0,
    required this.unit,
    required this.sizes,
    required this.variants,
    required this.status,
    required this.rolePrices,
    required this.roleRewards,
    this.createdAt,
    this.shopName,
  });

  // Convert Firestore DocumentSnapshot to Product object
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    // Parse role prices safely
    final rawPrices = data['rolePrices'] as Map<String, dynamic>? ?? {};
    final Map<String, double> parsedPrices = {};
    rawPrices.forEach((key, value) {
      parsedPrices[key] = (value as num).toDouble();
    });

    // Parse role rewards safely
    final rawRewards = data['roleRewards'] as Map<String, dynamic>? ?? {};
    final Map<String, int> parsedRewards = {};
    rawRewards.forEach((key, value) {
      parsedRewards[key] = (value as num).toInt();
    });

    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? 'regular',
      brand: data['brand'] ?? '',
      category: data['category'] ?? '',
      image: data['image'] ?? '',
      description: data['description'] ?? '',
      stock: (data['stock'] ?? 0) as int,
      regularPrice: ((data['regularPrice'] ?? 0.0) as num).toDouble(),
      discount: ((data['discount'] ?? 0.0) as num).toDouble(),
      discountType: data['discountType'] ?? 'fixed',
      vat: ((data['vat'] ?? 0.0) as num).toDouble(),
      extraExpenses: ((data['extraExpenses'] ?? 0.0) as num).toDouble(),
      unit: data['unit'] ?? '',
      sizes: List<String>.from(data['sizes'] ?? []),
      variants: List<String>.from(data['variants'] ?? []),
      status: data['status'] ?? 'draft',
      rolePrices: parsedPrices,
      roleRewards: parsedRewards,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      shopName: data['shopName'],
    );
  }

  // Convert Product object to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'brand': brand,
      'category': category,
      'image': image,
      'description': description,
      'stock': stock,
      'regularPrice': regularPrice,
      'discount': discount,
      'discountType': discountType,
      'vat': vat,
      'extraExpenses': extraExpenses,
      'unit': unit,
      'sizes': sizes,
      'variants': variants,
      'status': status,
      'rolePrices': rolePrices,
      'roleRewards': roleRewards,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'shopName': shopName,
    };
  }
}
