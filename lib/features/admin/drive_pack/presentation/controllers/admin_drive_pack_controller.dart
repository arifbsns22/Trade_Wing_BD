import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trade_wign_bd/features/users/drive_pack/data/repositories/drive_pack_repository.dart';
import 'package:trade_wign_bd/features/users/drive_pack/domain/models/operator_model.dart';
import 'package:trade_wign_bd/features/users/drive_pack/domain/models/drive_package_model.dart';
import 'package:trade_wign_bd/features/common/services/r2_storage_service.dart';

class AdminDrivePackController extends GetxController {
  final DrivePackRepository _repository = DrivePackRepository();
  final R2StorageService _r2Storage = R2StorageService();

  final RxBool isLoading = false.obs;
  final RxList<OperatorModel> operators = <OperatorModel>[].obs;
  final RxList<DrivePackageModel> offers = <DrivePackageModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _bindOperators();
    _bindOffers();
  }

  void _bindOperators() {
    _repository.streamOperators().listen((data) {
      operators.value = data;
    }, onError: (e) {
      debugPrint('Error streaming operators: $e');
    });
  }

  void _bindOffers() {
    _repository.streamAllOffers().listen((data) {
      offers.value = data;
    }, onError: (e) {
      debugPrint('Error streaming offers: $e');
    });
  }

  // --- Operator Actions ---

  Future<bool> createOperator({required String name, required XFile imageFile}) async {
    try {
      isLoading.value = true;

      // 1. Upload operator logo to R2
      final bytes = await imageFile.readAsBytes();
      final extension = imageFile.name.split('.').last;
      final fileName = 'operator_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final String destinationPath = 'operators/$fileName';

      final String? logoUrl = await _r2Storage.uploadBytes(
        bytes: bytes,
        destinationPath: destinationPath,
        contentType: 'image/$extension',
      );

      if (logoUrl == null) {
        throw Exception('Cloudflare R2 image upload failed.');
      }

      // 2. Save in Firestore
      final operator = OperatorModel(
        id: '',
        name: name,
        logoUrl: logoUrl,
        status: true,
        createdAt: DateTime.now(),
      );

      await _repository.addOperator(operator);
      isLoading.value = false;
      return true;
    } catch (e) {
      debugPrint('Error creating operator: $e');
      isLoading.value = false;
      return false;
    }
  }

  Future<void> deleteOperator(String id) async {
    try {
      isLoading.value = true;
      await _repository.deleteOperator(id);
      isLoading.value = false;
      Get.snackbar(
        'সফল',
        'অপারেটর সফলভাবে মুছে ফেলা হয়েছে।',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      debugPrint('Error deleting operator: $e');
      isLoading.value = false;
    }
  }

  // --- Offer Actions ---

  Future<bool> createOffer({
    required String operatorId,
    required String operatorName,
    required String title,
    required String description,
    required String packageType,
    required double price,
    required double offerPrice,
    required List<String> targetRoles,
    required String validity,
    required bool status,
  }) async {
    try {
      isLoading.value = true;
      final offer = DrivePackageModel(
        id: '',
        operatorId: operatorId,
        operatorName: operatorName,
        title: title,
        description: description,
        packageType: packageType,
        price: price,
        offerPrice: offerPrice,
        targetRoles: targetRoles,
        status: status,
        validity: validity,
        createdAt: DateTime.now(),
      );

      await _repository.addOffer(offer);
      isLoading.value = false;
      return true;
    } catch (e) {
      debugPrint('Error creating offer: $e');
      isLoading.value = false;
      return false;
    }
  }

  Future<bool> editOffer({
    required String id,
    required String operatorId,
    required String operatorName,
    required String title,
    required String description,
    required String packageType,
    required double price,
    required double offerPrice,
    required List<String> targetRoles,
    required String validity,
    required bool status,
  }) async {
    try {
      isLoading.value = true;
      final offer = DrivePackageModel(
        id: id,
        operatorId: operatorId,
        operatorName: operatorName,
        title: title,
        description: description,
        packageType: packageType,
        price: price,
        offerPrice: offerPrice,
        targetRoles: targetRoles,
        status: status,
        validity: validity,
        createdAt: DateTime.now(),
      );

      await _repository.updateOffer(offer);
      isLoading.value = false;
      return true;
    } catch (e) {
      debugPrint('Error updating offer: $e');
      isLoading.value = false;
      return false;
    }
  }

  Future<void> deleteOffer(String id) async {
    try {
      isLoading.value = true;
      await _repository.deleteOffer(id);
      isLoading.value = false;
      Get.snackbar(
        'সফল',
        'অফারটি সফলভাবে মুছে ফেলা হয়েছে।',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      debugPrint('Error deleting offer: $e');
      isLoading.value = false;
    }
  }
}
