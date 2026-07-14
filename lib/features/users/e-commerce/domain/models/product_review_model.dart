import 'package:cloud_firestore/cloud_firestore.dart';

class ProductReview {
  final String? id;
  final String productId;
  final String userId;
  final String userName;
  final String comment;
  final double rating; // 1.0 to 5.0
  final DateTime createdAt;

  ProductReview({
    this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });

  factory ProductReview.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ProductReview(
      id: doc.id,
      productId: data['productId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      comment: data['comment'] ?? '',
      rating: ((data['rating'] ?? 0.0) as num).toDouble(),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'comment': comment,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
