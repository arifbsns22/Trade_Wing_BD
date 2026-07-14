import 'package:cloud_firestore/cloud_firestore.dart';

class PackageProduct {
  final String name;
  final String brand;
  final int quantity;
  final String unit;
  final double mrpPrice;
  final double packagePrice;

  PackageProduct({
    required this.name,
    required this.brand,
    required this.quantity,
    this.unit = 'pcs',
    required this.mrpPrice,
    required this.packagePrice,
  });

  factory PackageProduct.fromMap(Map<String, dynamic> map) {
    return PackageProduct(
      name: map['name'] ?? '',
      brand: map['brand'] ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      unit: map['unit'] ?? 'pcs',
      mrpPrice: (map['mrpPrice'] as num?)?.toDouble() ?? 0.0,
      packagePrice: (map['packagePrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brand': brand,
      'quantity': quantity,
      'unit': unit,
      'mrpPrice': mrpPrice,
      'packagePrice': packagePrice,
    };
  }
}

class SubscriptionPackage {
  final String? id;
  final String name;
  final String? image;
  final String description;
  final List<PackageProduct> products;
  final String status; // 'public' or 'draft'
  final DateTime? createdAt;
  final String upgradeRole;
  final bool isTopChoice;

  // We can compute total MRP and total Package Price dynamically
  double get price => products.fold(0, (sum, p) => sum + (p.packagePrice * p.quantity));
  double get totalMrp => products.fold(0, (sum, p) => sum + (p.mrpPrice * p.quantity));

  SubscriptionPackage({
    this.id,
    required this.name,
    this.image,
    required this.description,
    required this.products,
    this.status = 'public',
    this.createdAt,
    this.upgradeRole = 'Active Customer',
    this.isTopChoice = false,
  });

  factory SubscriptionPackage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    // Parse products array
    final List<dynamic> productsData = data['products'] ?? [];
    final List<PackageProduct> parsedProducts = productsData
        .map((p) => PackageProduct.fromMap(p as Map<String, dynamic>))
        .toList();

    return SubscriptionPackage(
      id: doc.id,
      name: data['name'] ?? '',
      image: data['image'],
      description: data['description'] ?? '',
      products: parsedProducts,
      status: data['status'] ?? 'public',
      upgradeRole: data['upgradeRole'] ?? 'Active Customer',
      isTopChoice: data['isTopChoice'] ?? false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'image': image,
      'price': price, // Save calculated total price to Firestore
      'totalMrp': totalMrp, // Save total MRP to Firestore
      'description': description,
      'products': products.map((p) => p.toMap()).toList(),
      'status': status,
      'upgradeRole': upgradeRole,
      'isTopChoice': isTopChoice,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
