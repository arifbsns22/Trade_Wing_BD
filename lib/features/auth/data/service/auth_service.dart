import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:trade_wign_bd/common/services/notification_helper.dart';

import 'dart:math';

class AuthService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // Sign Up a new user
  Future<String> signUpUser({
    required String name,
    required String mobile,
    required String email,
    required String password,
    String? businessCode,
    String role = 'Customer',
  }) async {
    try {
      if (name.isEmpty || mobile.isEmpty || password.isEmpty) {
        return 'সবগুলো প্রয়োজনীয় ঘর সঠিকভাবে পূরণ করুন';
      }

      // Validate businessCode if provided
      if (businessCode != null && businessCode.isNotEmpty) {
        final querySnapshot = await _firestore
            .collection('users')
            .where('referralCode', isEqualTo: businessCode)
            .get();
            
        if (querySnapshot.docs.isEmpty) {
          return 'অকার্যকর বিজনেজ কোড (Invalid Business Code)';
        }
      }

      // Check if user already exists
      final userDoc = await _firestore.collection('users').doc(mobile).get();
      if (userDoc.exists) {
        return 'এই মোবাইল নম্বর দিয়ে ইতিমধ্যে অ্যাকাউন্ট তৈরি করা হয়েছে';
      }

      // Generate a unique 6-digit random number for the referral code
      final random = Random();
      final randomDigits = (100000 + random.nextInt(900000)).toString();
      final referralCode = 'TWBD$randomDigits';

      // Create new user document
      await _firestore.collection('users').doc(mobile).set({
        'name': name,
        'mobile': mobile,
        'email': email,
        'password': password,
        'role': role,
        'referralCode': referralCode,
        if (businessCode != null && businessCode.isNotEmpty)
          'referredBy': businessCode,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Send real-time admin notification
      await NotificationHelper.sendNotification(
        title: 'নতুন ইউজার রেজিস্ট্রেশন! 👤',
        body: 'নতুন ইউজার $name ($mobile) রেজিস্ট্রেশন সম্পন্ন করেছেন।',
        type: 'user_registered',
        isAdmin: true,
      );

      return 'success';
    } catch (e) {
      debugPrint('Registration Error: $e');
      return 'রেজিস্ট্রেশন করতে ব্যর্থ হয়েছে: ${e.toString()}';
    }
  }

  // Sign In an existing user
  Future<Map<String, dynamic>?> signInUser({
    required String mobile,
    required String password,
  }) async {
    try {
      if (mobile.isEmpty || password.isEmpty) {
        return null;
      }

      final userDoc = await _firestore.collection('users').doc(mobile).get();
      if (!userDoc.exists) {
        return {'status': 'not_found', 'message': 'অ্যাকাউন্টটি খুঁজে পাওয়া যায়নি'};
      }

      final data = userDoc.data();
      if (data == null) {
        return {'status': 'error', 'message': 'কোন ডেটা পাওয়া যায়নি'};
      }

      final storedPassword = data['password'] as String?;
      
      // Check if user is blocked
      final isActive = data['isActive'] ?? true;
      if (isActive == false) {
        return {'status': 'blocked', 'message': 'আপনার অ্যাকাউন্টটি ব্লক করা হয়েছে। এডমিনের সাথে যোগাযোগ করুন।'};
      }

      if (storedPassword == password) {
        return {
          'status': 'success',
          'name': data['name'] ?? '',
          'mobile': data['mobile'] ?? '',
          'role': data['role'] ?? 'Customer',
        };
      } else {
        return {'status': 'wrong_password', 'message': 'মোবাইল নম্বর অথবা পাসওয়ার্ডটি ভুল'};
      }
    } catch (e) {
      debugPrint('Login Error: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }
}
