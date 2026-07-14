import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<void> syncUserOrders() async {
  final firestore = FirebaseFirestore.instance;
  
  try {
    debugPrint('Starting order sync...');
    
    // Fetch all orders
    final ordersSnapshot = await firestore.collection('orders').get();
    
    // Map of mobile -> {count, amount}
    final Map<String, Map<String, dynamic>> userTotals = {};
    
    for (var doc in ordersSnapshot.docs) {
      final data = doc.data();
      final mobile = data['userMobile'];
      if (mobile == null) continue;
      
      final amount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
      
      if (!userTotals.containsKey(mobile)) {
        userTotals[mobile] = {'count': 0, 'amount': 0.0};
      }
      
      userTotals[mobile]!['count'] = (userTotals[mobile]!['count'] as int) + 1;
      userTotals[mobile]!['amount'] = (userTotals[mobile]!['amount'] as double) + amount;
    }
    
    // Now update all users
    final usersSnapshot = await firestore.collection('users').get();
    
    int updatedCount = 0;
    for (var doc in usersSnapshot.docs) {
      final mobile = doc.id;
      final totals = userTotals[mobile] ?? {'count': 0, 'amount': 0.0};
      
      await firestore.collection('users').doc(mobile).update({
        'totalOrders': totals['count'],
        'totalOrderAmount': totals['amount'],
        // Also initialize isActive if missing
        'isActive': doc.data().containsKey('isActive') ? doc.data()['isActive'] : true,
      });
      updatedCount++;
    }
    
    debugPrint('Successfully synced orders for $updatedCount users!');
  } catch (e) {
    debugPrint('Error syncing user orders: $e');
  }
}
