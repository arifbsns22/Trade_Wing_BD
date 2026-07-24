import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  final String id;
  final String title;
  final String bannerType;
  final List<String> targetRoles;
  final String imageUrl;
  final bool isFeatured;
  final bool status;
  final DateTime? startDate;
  final DateTime? expiryDate;
  final Timestamp? createdAt;

  BannerModel({
    required this.id,
    required this.title,
    required this.bannerType,
    required this.targetRoles,
    required this.imageUrl,
    this.isFeatured = false,
    this.status = true,
    this.startDate,
    this.expiryDate,
    this.createdAt,
  });

  factory BannerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BannerModel(
      id: doc.id,
      title: data['title'] ?? '',
      bannerType: data['bannerType'] ?? 'Default',
      targetRoles: List<String>.from(data['targetRoles'] ?? []),
      imageUrl: data['imageUrl'] ?? '',
      isFeatured: data['isFeatured'] ?? false,
      status: data['status'] ?? true,
      startDate: data['startDate'] != null
          ? (data['startDate'] as Timestamp).toDate()
          : null,
      expiryDate: data['expiryDate'] != null
          ? (data['expiryDate'] as Timestamp).toDate()
          : null,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'bannerType': bannerType,
      'targetRoles': targetRoles,
      'imageUrl': imageUrl,
      'isFeatured': isFeatured,
      'status': status,
      if (startDate != null) 'startDate': Timestamp.fromDate(startDate!),
      if (expiryDate != null) 'expiryDate': Timestamp.fromDate(expiryDate!),
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}
