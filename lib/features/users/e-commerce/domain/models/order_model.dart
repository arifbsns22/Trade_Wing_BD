import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled
}

enum PaymentStatus {
  pending,
  verified,
  failed
}

class OrderModel {
  final String orderId;
  final String userMobile;
  final String userName;
  final String address;
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final int rewardPointsEarned;
  final double walletDiscount;
  final String paymentMethod;
  final String? offlineGateway;
  final String? offlineTrxId;
  final String? offlineSenderMobile;
  final OrderStatus orderStatus;
  final PaymentStatus paymentStatus;
  final DateTime createdAt;

  // Metadata fields for vendor/reseller support
  final bool isVendorOrder;
  final String? vendorMobile;
  final double vendorProfit;
  final double vendorPurchasePrice;
  final bool isResellerOrder;
  final String? resellerMobile;
  final double resellerEarnings;
  final double adminCommission;

  // Delivery integration fields
  final String? deliveryProvider;
  final String? consignmentId;
  final String? trackingCode;
  final String? deliveryStatus;

  OrderModel({
    required this.orderId,
    required this.userMobile,
    required this.userName,
    required this.address,
    required this.items,
    required this.totalAmount,
    required this.rewardPointsEarned,
    this.walletDiscount = 0.0,
    required this.paymentMethod,
    this.offlineGateway,
    this.offlineTrxId,
    this.offlineSenderMobile,
    this.orderStatus = OrderStatus.pending,
    this.paymentStatus = PaymentStatus.pending,
    required this.createdAt,
    this.isVendorOrder = false,
    this.vendorMobile,
    this.vendorProfit = 0.0,
    this.vendorPurchasePrice = 0.0,
    this.isResellerOrder = false,
    this.resellerMobile,
    this.resellerEarnings = 0.0,
    this.adminCommission = 0.0,
    this.deliveryProvider,
    this.consignmentId,
    this.trackingCode,
    this.deliveryStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userMobile': userMobile,
      'userName': userName,
      'address': address,
      'items': items,
      'totalAmount': totalAmount,
      'rewardPointsEarned': rewardPointsEarned,
      'walletDiscount': walletDiscount,
      'paymentMethod': paymentMethod,
      'offlineGateway': offlineGateway,
      'offlineTrxId': offlineTrxId,
      'offlineSenderMobile': offlineSenderMobile,
      'orderStatus': orderStatus.name,
      'paymentStatus': paymentStatus.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'isVendorOrder': isVendorOrder,
      'vendorMobile': vendorMobile,
      'vendorProfit': vendorProfit,
      'vendorPurchasePrice': vendorPurchasePrice,
      'isResellerOrder': isResellerOrder,
      'resellerMobile': resellerMobile,
      'resellerEarnings': resellerEarnings,
      'adminCommission': adminCommission,
      'deliveryProvider': deliveryProvider,
      'consignmentId': consignmentId,
      'trackingCode': trackingCode,
      'deliveryStatus': deliveryStatus,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String docId) {
    return OrderModel(
      orderId: map['orderId'] ?? docId,
      userMobile: map['userMobile'] ?? '',
      userName: map['userName'] ?? '',
      address: map['address'] ?? '',
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      rewardPointsEarned: map['rewardPointsEarned'] ?? 0,
      walletDiscount: (map['walletDiscount'] ?? 0.0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? '',
      offlineGateway: map['offlineGateway'],
      offlineTrxId: map['offlineTrxId'],
      offlineSenderMobile: map['offlineSenderMobile'],
      orderStatus: _parseOrderStatus(map['orderStatus']),
      paymentStatus: _parsePaymentStatus(map['paymentStatus']),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isVendorOrder: map['isVendorOrder'] ?? false,
      vendorMobile: map['vendorMobile'],
      vendorProfit: (map['vendorProfit'] ?? 0.0).toDouble(),
      vendorPurchasePrice: (map['vendorPurchasePrice'] ?? 0.0).toDouble(),
      isResellerOrder: map['isResellerOrder'] ?? false,
      resellerMobile: map['resellerMobile'],
      resellerEarnings: (map['resellerEarnings'] ?? 0.0).toDouble(),
      adminCommission: (map['adminCommission'] ?? 0.0).toDouble(),
      deliveryProvider: map['deliveryProvider'],
      consignmentId: map['consignmentId']?.toString(),
      trackingCode: map['trackingCode'],
      deliveryStatus: map['deliveryStatus'],
    );
  }

  static OrderStatus _parseOrderStatus(String? status) {
    switch (status) {
      case 'processing': return OrderStatus.processing;
      case 'shipped': return OrderStatus.shipped;
      case 'delivered': return OrderStatus.delivered;
      case 'cancelled': return OrderStatus.cancelled;
      case 'pending':
      default: return OrderStatus.pending;
    }
  }

  static PaymentStatus _parsePaymentStatus(String? status) {
    switch (status) {
      case 'verified': return PaymentStatus.verified;
      case 'failed': return PaymentStatus.failed;
      case 'pending':
      default: return PaymentStatus.pending;
    }
  }
}
