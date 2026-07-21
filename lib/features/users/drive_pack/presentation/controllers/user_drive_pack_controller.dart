import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/users/drive_pack/data/repositories/drive_pack_repository.dart';
import 'package:trade_wign_bd/features/users/drive_pack/domain/models/operator_model.dart';
import 'package:trade_wign_bd/features/users/drive_pack/domain/models/drive_package_model.dart';

class UserDrivePackController extends GetxController {
  final DrivePackRepository _repository = DrivePackRepository();

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  
  final RxList<OperatorModel> operators = <OperatorModel>[].obs;
  final RxList<DrivePackageModel> allOffers = <DrivePackageModel>[].obs;
  
  final RxString selectedOperatorId = ''.obs;
  final RxString selectedCategory = 'All'.obs; // 'All', 'Combo', 'Internet', 'Minutes'

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      // Listen to operators
      _repository.streamOperators().listen((operatorList) {
        operators.value = operatorList;
        if (selectedOperatorId.value.isEmpty && operatorList.isNotEmpty) {
          selectedOperatorId.value = operatorList.first.id;
        }
      }, onError: (e) {
        debugPrint('Error streaming user operators: $e');
        hasError.value = true;
      });

      // Listen to all offers
      _repository.streamAllOffers().listen((offerList) {
        allOffers.value = offerList;
        isLoading.value = false;
      }, onError: (e) {
        debugPrint('Error streaming user offers: $e');
        hasError.value = true;
        isLoading.value = false;
      });
    } catch (e) {
      debugPrint('Error in fetchInitialData: $e');
      hasError.value = true;
      isLoading.value = false;
    }
  }

  /// Get currently active operator logo/name details
  OperatorModel? get selectedOperator {
    return operators.firstWhereOrNull((o) => o.id == selectedOperatorId.value);
  }

  /// Filter offers by operator and/or category
  List<DrivePackageModel> get filteredOffers {
    return allOffers.where((offer) {
      final matchesOperator = selectedOperatorId.value.isEmpty || offer.operatorId == selectedOperatorId.value;
      final matchesCategory = selectedCategory.value == 'All' || offer.packageType == selectedCategory.value;
      return matchesOperator && matchesCategory && offer.status;
    }).toList();
  }

  /// Get the 8 most recently added packages for dashboard preview (max 8)
  List<DrivePackageModel> get recentOffers {
    final activeOffers = allOffers.where((offer) => offer.status).toList();
    // Already sorted by createdAt descending in stream
    return activeOffers.take(8).toList();
  }
}
