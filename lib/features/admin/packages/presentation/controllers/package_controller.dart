import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/package_model.dart';

class PackageController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxBool isLoading = false.obs;
  final RxList<SubscriptionPackage> packages = <SubscriptionPackage>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPackages();
  }

  void fetchPackages() {
    isLoading.value = true;
    _firestore
        .collection('packages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        packages.value = snapshot.docs
            .map((doc) => SubscriptionPackage.fromFirestore(doc))
            .toList();
        isLoading.value = false;
      },
      onError: (e) {
        debugPrint('Error fetching packages: $e');
        isLoading.value = false;
      },
    );
  }

  Future<bool> addPackage(SubscriptionPackage package) async {
    try {
      isLoading.value = true;
      await _firestore.collection('packages').add(package.toFirestore());
      Get.snackbar(
        'সফল',
        'প্যাকেজটি সফলভাবে যুক্ত করা হয়েছে',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF08B3AC),
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      debugPrint('Error adding package: $e');
      Get.snackbar(
        'ব্যর্থতা',
        'প্যাকেজ যুক্ত করা যায়নি: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updatePackage(String id, SubscriptionPackage package) async {
    try {
      isLoading.value = true;
      await _firestore
          .collection('packages')
          .doc(id)
          .update(package.toFirestore());
      Get.snackbar(
        'সফল',
        'প্যাকেজটি আপডেট করা হয়েছে',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF08B3AC),
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      debugPrint('Error updating package: $e');
      Get.snackbar(
        'ব্যর্থতা',
        'প্যাকেজ আপডেট করা যায়নি: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePackage(String id) async {
    try {
      await _firestore.collection('packages').doc(id).delete();
      Get.snackbar('সফল', 'প্যাকেজটি মুছে ফেলা হয়েছে');
    } catch (e) {
      debugPrint('Error deleting package: $e');
      Get.snackbar('ত্রুটি', 'প্যাকেজ মোছা যায়নি: $e');
    }
  }
}
