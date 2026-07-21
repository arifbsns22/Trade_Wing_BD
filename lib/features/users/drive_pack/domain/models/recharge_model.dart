import 'package:cloud_firestore/cloud_firestore.dart';

class RechargeModel {
  final String id;
  final String operatorId;
  final String operatorName;
  final String mobileNumber;
  final double amount;
  final String userMobile;
  final String userName;
  final String status; // 'pending', 'completed', 'failed'
  final DateTime createdAt;
  final String transactionId;
  final String rechargeType; // 'regular' or 'drive'
  final String? drivePackageId; // Null for regular recharge

  RechargeModel({
    required this.id,
    required this.operatorId,
    required this.operatorName,
    required this.mobileNumber,
    required this.amount,
    required this.userMobile,
    required this.userName,
    required this.status,
    required this.createdAt,
    required this.transactionId,
    required this.rechargeType,
    this.drivePackageId,
  });

  /// Maps model properties to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'operatorId': operatorId,
      'operatorName': operatorName,
      'mobileNumber': mobileNumber,
      'amount': amount,
      'userMobile': userMobile,
      'userName': userName,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'transactionId': transactionId,
      'rechargeType': rechargeType,
      'drivePackageId': drivePackageId,
    };
  }

  /// Maps model properties to a standard JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operatorId': operatorId,
      'operatorName': operatorName,
      'mobileNumber': mobileNumber,
      'amount': amount,
      'userMobile': userMobile,
      'userName': userName,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'transactionId': transactionId,
      'rechargeType': rechargeType,
      'drivePackageId': drivePackageId,
    };
  }

  /// Creates a model instance from a Firestore document snapshot.
  factory RechargeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return RechargeModel(
      id: doc.id,
      operatorId: data['operatorId'] ?? '',
      operatorName: data['operatorName'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      userMobile: data['userMobile'] ?? '',
      userName: data['userName'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      transactionId: data['transactionId'] ?? '',
      rechargeType: data['rechargeType'] ?? 'regular',
      drivePackageId: data['drivePackageId'],
    );
  }

  /// Creates a model instance from a standard JSON map.
  factory RechargeModel.fromJson(Map<String, dynamic> json) {
    return RechargeModel(
      id: json['id'] ?? '',
      operatorId: json['operatorId'] ?? '',
      operatorName: json['operatorName'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      userMobile: json['userMobile'] ?? '',
      userName: json['userName'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      transactionId: json['transactionId'] ?? '',
      rechargeType: json['rechargeType'] ?? 'regular',
      drivePackageId: json['drivePackageId'],
    );
  }

  RechargeModel copyWith({
    String? id,
    String? operatorId,
    String? operatorName,
    String? mobileNumber,
    double? amount,
    String? userMobile,
    String? userName,
    String? status,
    DateTime? createdAt,
    String? transactionId,
    String? rechargeType,
    String? drivePackageId,
  }) {
    return RechargeModel(
      id: id ?? this.id,
      operatorId: operatorId ?? this.operatorId,
      operatorName: operatorName ?? this.operatorName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      amount: amount ?? this.amount,
      userMobile: userMobile ?? this.userMobile,
      userName: userName ?? this.userName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      transactionId: transactionId ?? this.transactionId,
      rechargeType: rechargeType ?? this.rechargeType,
      drivePackageId: drivePackageId ?? this.drivePackageId,
    );
  }
}
