import 'package:cloud_firestore/cloud_firestore.dart';

class DrivePackageModel {
  final String id;
  final String operatorId;
  final String operatorName;
  final String title;
  final String description;
  final String packageType; // e.g. 'Combo', 'Internet', 'Minutes'
  final double price;
  final double offerPrice;
  final List<String> targetRoles; // Ranks allowed to access (lowercase, e.g. ['customer', 'active customer'])
  final bool status;
  final String validity;
  final DateTime createdAt;

  DrivePackageModel({
    required this.id,
    required this.operatorId,
    required this.operatorName,
    required this.title,
    required this.description,
    required this.packageType,
    required this.price,
    required this.offerPrice,
    required this.targetRoles,
    required this.status,
    required this.validity,
    required this.createdAt,
  });

  /// Maps model properties to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'operatorId': operatorId,
      'operatorName': operatorName,
      'title': title,
      'description': description,
      'packageType': packageType,
      'price': price,
      'offerPrice': offerPrice,
      'targetRoles': targetRoles.map((r) => r.trim().toLowerCase()).toList(),
      'status': status,
      'validity': validity,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Maps model properties to a standard JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operatorId': operatorId,
      'operatorName': operatorName,
      'title': title,
      'description': description,
      'packageType': packageType,
      'price': price,
      'offerPrice': offerPrice,
      'targetRoles': targetRoles,
      'status': status,
      'validity': validity,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates a model instance from a Firestore document snapshot.
  factory DrivePackageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    // Support fallback for older schema if 'minRole' is present instead of 'targetRoles'
    List<String> roles = [];
    if (data['targetRoles'] != null) {
      roles = List<String>.from(data['targetRoles']);
    } else if (data['minRole'] != null) {
      roles = [data['minRole'].toString()];
    } else {
      roles = ['customer'];
    }

    return DrivePackageModel(
      id: doc.id,
      operatorId: data['operatorId'] ?? '',
      operatorName: data['operatorName'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      packageType: data['packageType'] ?? 'Combo',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      offerPrice: (data['offerPrice'] as num?)?.toDouble() ?? 0.0,
      targetRoles: roles,
      status: data['status'] ?? true,
      validity: data['validity'] ?? '30 Days',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Creates a model instance from a standard JSON map.
  factory DrivePackageModel.fromJson(Map<String, dynamic> json) {
    List<String> roles = [];
    if (json['targetRoles'] != null) {
      roles = List<String>.from(json['targetRoles']);
    } else if (json['minRole'] != null) {
      roles = [json['minRole'].toString()];
    } else {
      roles = ['customer'];
    }

    return DrivePackageModel(
      id: json['id'] ?? '',
      operatorId: json['operatorId'] ?? '',
      operatorName: json['operatorName'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      packageType: json['packageType'] ?? 'Combo',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      offerPrice: (json['offerPrice'] as num?)?.toDouble() ?? 0.0,
      targetRoles: roles,
      status: json['status'] ?? true,
      validity: json['validity'] ?? '30 Days',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  DrivePackageModel copyWith({
    String? id,
    String? operatorId,
    String? operatorName,
    String? title,
    String? description,
    String? packageType,
    double? price,
    double? offerPrice,
    List<String>? targetRoles,
    bool? status,
    String? validity,
    DateTime? createdAt,
  }) {
    return DrivePackageModel(
      id: id ?? this.id,
      operatorId: operatorId ?? this.operatorId,
      operatorName: operatorName ?? this.operatorName,
      title: title ?? this.title,
      description: description ?? this.description,
      packageType: packageType ?? this.packageType,
      price: price ?? this.price,
      offerPrice: offerPrice ?? this.offerPrice,
      targetRoles: targetRoles ?? this.targetRoles,
      status: status ?? this.status,
      validity: validity ?? this.validity,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
