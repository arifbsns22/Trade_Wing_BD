import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminUsersController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxBool isLoading = true.obs;
  final RxList<Map<String, dynamic>> usersList = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredUsersList = <Map<String, dynamic>>[].obs;
  
  // Store stats for each role: {role: string, count: int, growth: double}
  final RxList<Map<String, dynamic>> roleStats = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      final snapshot = await _firestore.collection('users').orderBy('createdAt', descending: true).get();
      
      final users = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      usersList.value = users;
      filteredUsersList.value = users;
      
      _calculateRoleStats(users);
    } catch (e) {
      debugPrint('Error fetching users: $e');
      Get.snackbar(
  'ত্রুটি',
  'ইউজারদের তথ্য আনতে সমস্যা হচ্ছে',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateRoleStats(List<Map<String, dynamic>> users) {
    final Map<String, List<Map<String, dynamic>>> usersByRole = {};
    final roles = [
      'Super Admin', 'Customer', 'Brand Promoter',
      'Sales Partner', 'Senior Sales Partner', 'Sub Dealer',
      'Dealer', 'Senior Dealer', 'Master Dealer'
    ];

    for (var role in roles) {
      usersByRole[role] = [];
    }

    for (var user in users) {
      final role = user['role'] ?? 'Customer';
      if (usersByRole.containsKey(role)) {
        usersByRole[role]!.add(user);
      }
    }

    final now = DateTime.now();
    final startOfThisMonth = DateTime(now.year, now.month, 1);
    final startOfLastMonth = DateTime(now.year, now.month - 1, 1);

    final List<Map<String, dynamic>> stats = [];

    for (var role in roles) {
      final roleUsers = usersByRole[role]!;
      final total = roleUsers.length;

      // Count users created this month
      int createdThisMonth = 0;
      int createdLastMonth = 0;

      for (var user in roleUsers) {
        if (user['createdAt'] != null && user['createdAt'] is Timestamp) {
          final createdAt = (user['createdAt'] as Timestamp).toDate();
          if (createdAt.isAfter(startOfThisMonth) || createdAt.isAtSameMomentAs(startOfThisMonth)) {
            createdThisMonth++;
          } else if ((createdAt.isAfter(startOfLastMonth) || createdAt.isAtSameMomentAs(startOfLastMonth)) && createdAt.isBefore(startOfThisMonth)) {
            createdLastMonth++;
          }
        }
      }

      // Calculate MoM growth based on NEW signups
      double growth = 0.0;
      if (createdLastMonth == 0 && createdThisMonth > 0) {
        growth = 100.0;
      } else if (createdLastMonth > 0) {
        growth = ((createdThisMonth - createdLastMonth) / createdLastMonth) * 100;
      }

      stats.add({
        'role': role,
        'count': total,
        'growth': growth,
      });
    }

    roleStats.value = stats;
  }

  void searchUsers(String query) {
    if (query.isEmpty) {
      filteredUsersList.value = usersList;
    } else {
      final lowercaseQuery = query.toLowerCase();
      filteredUsersList.value = usersList.where((user) {
        final name = (user['name'] ?? '').toString().toLowerCase();
        final mobile = (user['mobile'] ?? '').toString().toLowerCase();
        return name.contains(lowercaseQuery) || mobile.contains(lowercaseQuery);
      }).toList();
    }
  }

  Future<void> toggleUserStatus(String mobile, bool currentStatus) async {
    try {
      final newStatus = !currentStatus;
      await _firestore.collection('users').doc(mobile).update({
        'isActive': newStatus,
      });
      // Update locally
      final index = usersList.indexWhere((u) => u['mobile'] == mobile);
      if (index != -1) {
        usersList[index]['isActive'] = newStatus;
        usersList.refresh();
        searchUsers(''); // Re-apply filter
      }
      Get.snackbar(
  'সফল',
  newStatus ? 'ইউজারকে একটিভ করা হয়েছে' : 'ইউজারকে ব্লক করা হয়েছে',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
    } catch (e) {
      Get.snackbar(
  'ত্রুটি',
  'স্ট্যাটাস আপডেট করতে ব্যর্থ হয়েছে',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
    }
  }

  Future<void> syncUserOrders() async {
    try {
      isLoading.value = true;
      
      // Fetch all orders
      final ordersSnapshot = await _firestore.collection('orders').get();
      
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
      final usersSnapshot = await _firestore.collection('users').get();
      
      int updatedCount = 0;
      for (var doc in usersSnapshot.docs) {
        final mobile = doc.id;
        final totals = userTotals[mobile] ?? {'count': 0, 'amount': 0.0};
        
        await _firestore.collection('users').doc(mobile).update({
          'totalOrders': totals['count'],
          'totalOrderAmount': totals['amount'],
          // Also initialize isActive if missing
          'isActive': doc.data().containsKey('isActive') ? doc.data()['isActive'] : true,
        });
        updatedCount++;
      }
      
      Get.snackbar(
  'সফল',
  '$updatedCount ইউজারের অর্ডার ডেটা সিংক হয়েছে!',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
      
      // Re-fetch users to reflect changes
      await fetchUsers();
      
    } catch (e) {
      debugPrint('Error syncing user orders: $e');
      Get.snackbar(
  'ত্রুটি',
  'ডেটা সিংক করতে সমস্যা হয়েছে',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
      isLoading.value = false;
    }
  }
}
