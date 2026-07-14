import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trade_wign_bd/features/common/services/r2_storage_service.dart';
import '../../domain/models/banner_model.dart';

class BannerController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final R2StorageService _r2Service = R2StorageService();
  final String collectionPath = 'marketing_banners';

  final RxBool isLoading = false.obs;
  final RxList<BannerModel> banners = <BannerModel>[].obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
  }

  void fetchBanners() {
    isLoading.value = true;
    _firestore
        .collection(collectionPath)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        banners.value = snapshot.docs
            .map((doc) => BannerModel.fromFirestore(doc))
            .toList();
        isLoading.value = false;
      },
      onError: (e) {
        debugPrint('Error fetching banners: $e');
        isLoading.value = false;
      },
    );
  }

  List<BannerModel> get filteredBanners {
    if (searchQuery.value.isEmpty) {
      return banners;
    }
    return banners
        .where((b) => b.title.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  Future<bool> addBanner({
    required String title,
    required String bannerType,
    required List<String> targetRoles,
    required XFile imageFile,
  }) async {
    try {
      isLoading.value = true;

      // Upload Image
      final bytes = await imageFile.readAsBytes();
      final extension = imageFile.name.split('.').last;
      final fileName = 'banner_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final String destination = 'banners/$fileName';

      final String? imageUrl = await _r2Service.uploadBytes(
        bytes: bytes,
        destinationPath: destination,
        contentType: 'image/$extension',
      );

      if (imageUrl == null) {
        throw Exception('Failed to upload banner image to R2.');
      }

      final newBanner = BannerModel(
        id: '', // Firestore auto ID
        title: title,
        bannerType: bannerType,
        targetRoles: targetRoles,
        imageUrl: imageUrl,
        isFeatured: false,
        status: true,
        createdAt: Timestamp.now(),
      );

      await _firestore.collection(collectionPath).add(newBanner.toFirestore());

      Get.snackbar(
        'সফল',
        'ব্যানার সফলভাবে যুক্ত করা হয়েছে',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      debugPrint('Error adding banner: $e');
      Get.snackbar(
        'ত্রুটি',
        'ব্যানার যুক্ত করা যায়নি: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFeatured(String id, bool currentValue) async {
    try {
      await _firestore.collection(collectionPath).doc(id).update({
        'isFeatured': !currentValue,
      });
    } catch (e) {
      debugPrint('Error toggling featured status: $e');
    }
  }

  Future<void> toggleStatus(String id, bool currentValue) async {
    try {
      await _firestore.collection(collectionPath).doc(id).update({
        'status': !currentValue,
      });
    } catch (e) {
      debugPrint('Error toggling status: $e');
    }
  }

  Future<void> deleteBanner(String id) async {
    try {
      await _firestore.collection(collectionPath).doc(id).delete();
      Get.snackbar('সফল', 'ব্যানার মুছে ফেলা হয়েছে');
    } catch (e) {
      debugPrint('Error deleting banner: $e');
      Get.snackbar('ত্রুটি', 'ব্যানার মোছা যায়নি: $e');
    }
  }
}
