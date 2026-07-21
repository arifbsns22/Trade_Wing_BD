import 'package:cloud_firestore/cloud_firestore.dart';

class OperatorModel {
  final String id;
  final String name;
  final String logoUrl;
  final bool status;
  final DateTime createdAt;

  OperatorModel({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.status,
    required this.createdAt,
  });

  /// Maps model properties to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'logoUrl': logoUrl,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Maps model properties to a standard JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates a model instance from a Firestore document snapshot.
  factory OperatorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return OperatorModel(
      id: doc.id,
      name: data['name'] ?? '',
      logoUrl: data['logoUrl'] ?? '',
      status: data['status'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Creates a model instance from a standard JSON map.
  factory OperatorModel.fromJson(Map<String, dynamic> json) {
    return OperatorModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
      status: json['status'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  OperatorModel copyWith({
    String? id,
    String? name,
    String? logoUrl,
    bool? status,
    DateTime? createdAt,
  }) {
    return OperatorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
