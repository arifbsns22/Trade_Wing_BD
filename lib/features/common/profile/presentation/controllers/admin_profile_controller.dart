import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:trade_wign_bd/features/common/services/r2_storage_service.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';

class AdminProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = AuthController.instance;

  // Reactive states
  final RxBool isLoading = false.obs;
  final RxString name = ''.obs;
  final RxString email = ''.obs;
  final RxString mobile = ''.obs;
  final RxString referralCode = ''.obs;
  final RxString profilePicture = ''.obs;
  final RxString address = ''.obs;
  final RxInt totalRewardPoints = 0.obs;
  final RxDouble totalPurchasedAmount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAdminProfile();
  }

  // Fetch admin profile from Firestore
  Future<void> fetchAdminProfile() async {
    final String currentMobile = _authController.currentUserMobile.value;
    if (currentMobile.isEmpty) {
      // Fallback to local auth controller state if mobile is empty
      name.value = _authController.currentUserName.value;
      mobile.value = '';
      email.value = '';
      referralCode.value = 'N/A';
      return;
    }

    try {
      isLoading.value = true;
      final doc = await _firestore.collection('users').doc(currentMobile).get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          name.value = data['name'] ?? _authController.currentUserName.value;
          mobile.value = data['mobile'] ?? currentMobile;
          email.value = data['email'] ?? '';
          profilePicture.value = data['profilePicture'] ?? '';
          address.value = data['address'] ?? '';
          // Dynamically calculate from orders
          try {
            final ordersSnapshot = await _firestore
                .collection('orders')
                .where('userMobile', isEqualTo: currentMobile)
                .get();

            int calculatedPoints = 0;
            double calculatedAmount = 0.0;

            for (var orderDoc in ordersSnapshot.docs) {
              final orderData = orderDoc.data();
              if (orderData['orderStatus'] != 'cancelled') {
                calculatedPoints +=
                    (orderData['rewardPointsEarned'] ?? 0) as int;
                calculatedAmount += (orderData['totalAmount'] ?? 0.0)
                    .toDouble();
              }
            }
            totalRewardPoints.value = calculatedPoints;
            totalPurchasedAmount.value = calculatedAmount;
          } catch (e) {
            debugPrint('Error calculating order stats: $e');
            // Fallback to stored values if query fails
            totalRewardPoints.value = data['totalRewardPoints'] ?? 0;
            totalPurchasedAmount.value = (data['totalPurchasedAmount'] ?? 0.0)
                .toDouble();
          }

          String? refCode = data['referralCode'] as String?;
          if (refCode == null || refCode.trim().isEmpty) {
            // Generate and save referral code
            refCode = _generateReferralCode(currentMobile);
            await _firestore.collection('users').doc(currentMobile).update({
              'referralCode': refCode,
            });
          }
          referralCode.value = refCode;
        }
      } else {
        // If doc doesn't exist, initialize with auth controller data
        name.value = _authController.currentUserName.value;
        mobile.value = currentMobile;
        email.value = '';
        profilePicture.value = '';
        totalRewardPoints.value = 0;
        totalPurchasedAmount.value = 0.0;
        referralCode.value = _generateReferralCode(currentMobile);
      }
    } catch (e) {
      debugPrint('Error fetching admin profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Generate a random, unique 6 digit referral code
  String _generateReferralCode(String mobileNumber) {
    return (100000 + Random().nextInt(900000)).toString();
  }

  // Copy referral code to clipboard
  void copyReferralCode() {
    if (referralCode.value.isNotEmpty && referralCode.value != 'N/A') {
      Clipboard.setData(ClipboardData(text: referralCode.value));
      Get.snackbar(
        'সফল',
        'বিজনেজ কোড ক্লিপবোর্ডে কপি করা হয়েছে',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF08B3AC).withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(15),
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Update profile information in Firestore
  Future<bool> updateProfile({
    required String newName,
    required String newEmail,
  }) async {
    final String currentMobile = _authController.currentUserMobile.value;
    if (currentMobile.isEmpty) return false;

    try {
      isLoading.value = true;

      await _firestore.collection('users').doc(currentMobile).update({
        'name': newName,
        'email': newEmail,
      });

      // Update local reactive states
      name.value = newName;
      email.value = newEmail;

      // Update AuthController
      _authController.currentUserName.value = newName;

      // Persist locally in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', newName);

      Get.snackbar(
        'সফল',
        'প্রোফাইল তথ্য সফলভাবে আপডেট করা হয়েছে',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(15),
      );

      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      Get.snackbar(
        'ব্যর্থতা',
        'প্রোফাইল আপডেট করা যায়নি: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(15),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Pick and upload profile picture
  Future<void> pickAndUploadProfilePicture() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 400,
        maxHeight: 400,
      );

      if (image != null) {
        isLoading.value = true;
        final String currentMobile = _authController.currentUserMobile.value;
        if (currentMobile.isNotEmpty) {
          final r2Service = R2StorageService();
          final Uint8List bytes = await image.readAsBytes();
          final String extension = image.name.split('.').last.toLowerCase();
          final String destination =
              'profiles/${currentMobile}_${DateTime.now().millisecondsSinceEpoch}.$extension';

          final String? imageUrl = await r2Service.uploadBytes(
            bytes: bytes,
            destinationPath: destination,
            contentType: 'image/$extension',
          );

          if (imageUrl != null) {
            await _firestore.collection('users').doc(currentMobile).update({
              'profilePicture': imageUrl,
            });
            profilePicture.value = imageUrl;
            Get.snackbar(
              'সফল',
              'প্রোফাইল ছবি সফলভাবে আপডেট করা হয়েছে',
              backgroundColor: Colors.green.withValues(alpha: 0.9),
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(15),
            );
          } else {
            throw Exception('R2 upload returned null URL');
          }
        }
      }
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      Get.snackbar(
        'ব্যর্থতা',
        'প্রোফাইল ছবি আপডেট করা যায়নি',
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(15),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update address
  Future<bool> updateAddress(String newAddress) async {
    final String currentMobile = _authController.currentUserMobile.value;
    if (currentMobile.isEmpty) return false;

    try {
      isLoading.value = true;
      await _firestore.collection('users').doc(currentMobile).update({
        'address': newAddress,
      });

      address.value = newAddress;
      
      Get.snackbar(
        'সফল',
        'আপনার ঠিকানা সফলভাবে আপডেট করা হয়েছে',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(15),
      );
      return true;
    } catch (e) {
      debugPrint('Error updating address: $e');
      Get.snackbar(
        'ত্রুটি',
        'ঠিকানা আপডেট করতে সমস্যা হয়েছে',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(15),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Change password in Firestore
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final String currentMobile = _authController.currentUserMobile.value;
    if (currentMobile.isEmpty) return false;

    try {
      isLoading.value = true;
      final doc = await _firestore.collection('users').doc(currentMobile).get();
      if (doc.exists) {
        final currentPasswordInDb = doc.data()?['password'] ?? '';
        if (currentPasswordInDb != oldPassword) {
          Get.snackbar(
            'ভুল',
            'পুরাতন পাসওয়ার্ড মিলেনি',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
            colorText: Colors.white,
            margin: const EdgeInsets.all(15),
          );
          return false;
        }

        // Update to new password
        await _firestore.collection('users').doc(currentMobile).update({
          'password': newPassword,
        });

        Get.snackbar(
          'সফল',
          'পাসওয়ার্ড সফলভাবে পরিবর্তন করা হয়েছে',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white,
          margin: const EdgeInsets.all(15),
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error changing password: $e');
      Get.snackbar(
        'ব্যর্থতা',
        'পাসওয়ার্ড পরিবর্তন করা যায়নি: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(15),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
