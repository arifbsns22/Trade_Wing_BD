import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import 'package:trade_wign_bd/uitls/constants/assets_path/images_path.dart';
import 'logo_picker_stub.dart'
    if (dart.library.html) 'logo_picker_web.dart'
    as picker_impl;
import 'package:trade_wign_bd/features/common/services/r2_storage_service.dart';

class AdminSettingsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reactive states
  final RxBool isLoading = false.obs;
  final RxString appName = 'Trade Wign BD'.obs;
  final RxString appEmail = ''.obs;
  final RxString appMobile = ''.obs;
  final RxString appAddress = ''.obs;
  final RxString appCopyright = ''.obs;
  final RxBool isMaintenanceMode = false.obs;

  // Payment states
  final RxBool isCodActive = true.obs;
  final RxString codName = 'Cash On Delivery'.obs;
  final RxString codAmount = '0'.obs;

  final RxBool isDigitalPaymentActive = false.obs;
  final RxString digitalPaymentName = 'Digital Payment'.obs;
  final RxString digitalPaymentAmount = '0'.obs;

  final RxBool isOfflinePaymentActive = false.obs;
  final RxString offlinePaymentName = 'Offline Payment'.obs;
  final RxString offlinePaymentAmount = '0'.obs;

  // Offline Payment Gateways
  final RxString bkashAccountName = ''.obs;
  final RxString bkashAccountNumber = ''.obs;
  final RxString bkashPaymentOption = 'Send Money'.obs;
  final RxString bkashAccountType = 'Personal'.obs;

  final RxString nagadAccountName = ''.obs;
  final RxString nagadAccountNumber = ''.obs;
  final RxString nagadPaymentOption = 'Send Money'.obs;
  final RxString nagadAccountType = 'Personal'.obs;

  // Active modules map
  final RxMap<String, bool> activeModules = {
    'dashboard': true,
    'users': true,
    'ecommerce': true,
    'drive': true,
    'reselling': true,
    'vendor': true,
    'b2b': true,
    'parcel': true,
    'training': true,
    'business_club': true,
    'payment': true,
    'reports': true,
    'support': true,
  }.obs;

  // Local/Custom Logo paths (for runtime rendering preview)
  final RxString customLightLogoPath = ''.obs;
  final RxString customDarkLogoPath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  // Load settings from SharedPreferences and Firestore
  Future<void> loadSettings() async {
    isLoading.value = true;
    try {
      // 1. Load from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      appName.value = prefs.getString('settings_app_name') ?? 'Trade Wign BD';
      appEmail.value = prefs.getString('settings_app_email') ?? '';
      appMobile.value = prefs.getString('settings_app_mobile') ?? '';
      appAddress.value = prefs.getString('settings_app_address') ?? '';
      appCopyright.value = prefs.getString('settings_app_copyright') ?? '';
      isMaintenanceMode.value =
          prefs.getBool('settings_maintenance_mode') ?? false;
      customLightLogoPath.value =
          prefs.getString('settings_custom_light_logo') ?? '';
      customDarkLogoPath.value =
          prefs.getString('settings_custom_dark_logo') ?? '';

      isCodActive.value = prefs.getBool('settings_payment_cod_active') ?? true;
      codName.value =
          prefs.getString('settings_payment_cod_name') ?? 'Cash On Delivery';
      codAmount.value = prefs.getString('settings_payment_cod_amount') ?? '0';

      isDigitalPaymentActive.value =
          prefs.getBool('settings_payment_digital_active') ?? false;
      digitalPaymentName.value =
          prefs.getString('settings_payment_digital_name') ?? 'Digital Payment';
      digitalPaymentAmount.value =
          prefs.getString('settings_payment_digital_amount') ?? '0';

      isOfflinePaymentActive.value =
          prefs.getBool('settings_payment_offline_active') ?? false;
      offlinePaymentName.value =
          prefs.getString('settings_payment_offline_name') ?? 'Offline Payment';
      offlinePaymentAmount.value =
          prefs.getString('settings_payment_offline_amount') ?? '0';

      bkashAccountName.value =
          prefs.getString('settings_payment_bkash_name') ?? '';
      bkashAccountNumber.value =
          prefs.getString('settings_payment_bkash_number') ?? '';
      bkashPaymentOption.value =
          prefs.getString('settings_payment_bkash_option') ?? 'Send Money';
      bkashAccountType.value =
          prefs.getString('settings_payment_bkash_type') ?? 'Personal';

      nagadAccountName.value =
          prefs.getString('settings_payment_nagad_name') ?? '';
      nagadAccountNumber.value =
          prefs.getString('settings_payment_nagad_number') ?? '';
      nagadPaymentOption.value =
          prefs.getString('settings_payment_nagad_option') ?? 'Send Money';
      nagadAccountType.value =
          prefs.getString('settings_payment_nagad_type') ?? 'Personal';

      // Override runtime in-memory ImagePath values if we have cached custom logo paths
      if (customLightLogoPath.value.isNotEmpty) {
        ImagePath.lightLogoPng = customLightLogoPath.value;
      }
      if (customDarkLogoPath.value.isNotEmpty) {
        ImagePath.darkLogoPng = customDarkLogoPath.value;
      }

      // Load active modules
      for (var key in activeModules.keys) {
        activeModules[key] = prefs.getBool('module_active_$key') ?? true;
      }

      // 2. Fetch from Firestore for real-time backup
      final doc = await _firestore
          .collection('app_settings')
          .doc('global')
          .get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          appName.value = data['appName'] ?? appName.value;
          appEmail.value = data['appEmail'] ?? appEmail.value;
          appMobile.value = data['appMobile'] ?? appMobile.value;
          appAddress.value = data['appAddress'] ?? appAddress.value;
          appCopyright.value = data['appCopyright'] ?? appCopyright.value;
          isMaintenanceMode.value =
              data['isMaintenanceMode'] ?? isMaintenanceMode.value;

          isCodActive.value = data['isCodActive'] ?? isCodActive.value;
          codName.value = data['codName'] ?? codName.value;
          codAmount.value = data['codAmount'] ?? codAmount.value;

          isDigitalPaymentActive.value =
              data['isDigitalPaymentActive'] ?? isDigitalPaymentActive.value;
          digitalPaymentName.value =
              data['digitalPaymentName'] ?? digitalPaymentName.value;
          digitalPaymentAmount.value =
              data['digitalPaymentAmount'] ?? digitalPaymentAmount.value;

          isOfflinePaymentActive.value =
              data['isOfflinePaymentActive'] ?? isOfflinePaymentActive.value;
          offlinePaymentName.value =
              data['offlinePaymentName'] ?? offlinePaymentName.value;
          offlinePaymentAmount.value =
              data['offlinePaymentAmount'] ?? offlinePaymentAmount.value;

          bkashAccountName.value =
              data['bkashAccountName'] ?? bkashAccountName.value;
          bkashAccountNumber.value =
              data['bkashAccountNumber'] ?? bkashAccountNumber.value;
          bkashPaymentOption.value =
              data['bkashPaymentOption'] ?? bkashPaymentOption.value;
          bkashAccountType.value =
              data['bkashAccountType'] ?? bkashAccountType.value;

          nagadAccountName.value =
              data['nagadAccountName'] ?? nagadAccountName.value;
          nagadAccountNumber.value =
              data['nagadAccountNumber'] ?? nagadAccountNumber.value;
          nagadPaymentOption.value =
              data['nagadPaymentOption'] ?? nagadPaymentOption.value;
          nagadAccountType.value =
              data['nagadAccountType'] ?? nagadAccountType.value;

          if (data['lightLogo'] != null && customLightLogoPath.value.isEmpty) {
            customLightLogoPath.value = data['lightLogo'];
            ImagePath.lightLogoPng = data['lightLogo'];
          }
          if (data['darkLogo'] != null && customDarkLogoPath.value.isEmpty) {
            customDarkLogoPath.value = data['darkLogo'];
            ImagePath.darkLogoPng = data['darkLogo'];
          }

          final Map<String, dynamic>? dbModules =
              data['modules'] as Map<String, dynamic>?;
          if (dbModules != null) {
            dbModules.forEach((key, value) {
              if (activeModules.containsKey(key)) {
                activeModules[key] = value as bool;
              }
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Save Settings to SharedPreferences and Firestore
  Future<void> saveSettings() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('settings_app_name', appName.value);
      await prefs.setString('settings_app_email', appEmail.value);
      await prefs.setString('settings_app_mobile', appMobile.value);
      await prefs.setString('settings_app_address', appAddress.value);
      await prefs.setString('settings_app_copyright', appCopyright.value);
      await prefs.setBool('settings_maintenance_mode', isMaintenanceMode.value);

      await prefs.setBool('settings_payment_cod_active', isCodActive.value);
      await prefs.setString('settings_payment_cod_name', codName.value);
      await prefs.setString('settings_payment_cod_amount', codAmount.value);

      await prefs.setBool(
        'settings_payment_digital_active',
        isDigitalPaymentActive.value,
      );
      await prefs.setString(
        'settings_payment_digital_name',
        digitalPaymentName.value,
      );
      await prefs.setString(
        'settings_payment_digital_amount',
        digitalPaymentAmount.value,
      );

      await prefs.setBool(
        'settings_payment_offline_active',
        isOfflinePaymentActive.value,
      );
      await prefs.setString(
        'settings_payment_offline_name',
        offlinePaymentName.value,
      );
      await prefs.setString(
        'settings_payment_offline_amount',
        offlinePaymentAmount.value,
      );

      await prefs.setString(
        'settings_payment_bkash_name',
        bkashAccountName.value,
      );
      await prefs.setString(
        'settings_payment_bkash_number',
        bkashAccountNumber.value,
      );
      await prefs.setString(
        'settings_payment_bkash_option',
        bkashPaymentOption.value,
      );
      await prefs.setString(
        'settings_payment_bkash_type',
        bkashAccountType.value,
      );

      await prefs.setString(
        'settings_payment_nagad_name',
        nagadAccountName.value,
      );
      await prefs.setString(
        'settings_payment_nagad_number',
        nagadAccountNumber.value,
      );
      await prefs.setString(
        'settings_payment_nagad_option',
        nagadPaymentOption.value,
      );
      await prefs.setString(
        'settings_payment_nagad_type',
        nagadAccountType.value,
      );

      // Save modules state
      activeModules.forEach((key, value) async {
        await prefs.setBool('module_active_$key', value);
      });

      // Save to Firestore
      await _firestore.collection('app_settings').doc('global').set({
        'appName': appName.value,
        'appEmail': appEmail.value,
        'appMobile': appMobile.value,
        'appAddress': appAddress.value,
        'appCopyright': appCopyright.value,
        'isMaintenanceMode': isMaintenanceMode.value,
        'lightLogo': customLightLogoPath.value,
        'darkLogo': customDarkLogoPath.value,
        'modules': Map<String, bool>.from(activeModules),
        'isCodActive': isCodActive.value,
        'codName': codName.value,
        'codAmount': codAmount.value,
        'isDigitalPaymentActive': isDigitalPaymentActive.value,
        'digitalPaymentName': digitalPaymentName.value,
        'digitalPaymentAmount': digitalPaymentAmount.value,
        'isOfflinePaymentActive': isOfflinePaymentActive.value,
        'offlinePaymentName': offlinePaymentName.value,
        'offlinePaymentAmount': offlinePaymentAmount.value,
        'bkashAccountName': bkashAccountName.value,
        'bkashAccountNumber': bkashAccountNumber.value,
        'bkashPaymentOption': bkashPaymentOption.value,
        'bkashAccountType': bkashAccountType.value,
        'nagadAccountName': nagadAccountName.value,
        'nagadAccountNumber': nagadAccountNumber.value,
        'nagadPaymentOption': nagadPaymentOption.value,
        'nagadAccountType': nagadAccountType.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'সফল',
        'অ্যাপ্লিকেশন সেটিংস সফলভাবে সংরক্ষণ করা হয়েছে',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: AppColors.primaryColor.withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      debugPrint('Error saving settings: $e');
      Get.snackbar(
        'ব্যর্থতা',
        'সেটিংস সংরক্ষণ করা যায়নি: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle single module state
  void toggleModule(String moduleKey) {
    if (activeModules.containsKey(moduleKey)) {
      activeModules[moduleKey] = !(activeModules[moduleKey] ?? true);
    }
  }

  // Pick and configure Logo image
  Future<void> pickLogo(String mode) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? result = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (result != null) {
        isLoading.value = true;

        final String newFileName = mode == 'light' ? 'app_logo.png' : 'app_logo_dark.png';
        final String assetPath = 'assets/logos/$newFileName';
        
        final r2Service = R2StorageService();
        final Uint8List bytes = await result.readAsBytes();
        final String destination = 'logos/$newFileName';

        final String? imageUrl = await r2Service.uploadBytes(
          bytes: bytes,
          destinationPath: destination,
          contentType: 'image/png',
        );

        if (imageUrl == null) {
          throw Exception('R2 upload returned null URL');
        }

        if (!kIsWeb && result.path.isNotEmpty) {
          final String localPickedPath = result.path;
          final File pickedFile = File(localPickedPath);

          // 1. Copy logo to assets folder
          await _copyLogoToAssets(pickedFile, newFileName);
        }

        // 2. Update dynamic local application states
        final prefs = await SharedPreferences.getInstance();
        if (mode == 'light') {
          customLightLogoPath.value = imageUrl;
          ImagePath.lightLogoPng = imageUrl;
          await prefs.setString('settings_custom_light_logo', imageUrl);
        } else {
          customDarkLogoPath.value = imageUrl;
          ImagePath.darkLogoPng = imageUrl;
          await prefs.setString('settings_custom_dark_logo', imageUrl);
        }

        // 3. Save automatically to Firestore config
        await _firestore.collection('app_settings').doc('global').update({
          mode == 'light' ? 'lightLogo' : 'darkLogo': imageUrl,
        });
        await _firestore.collection('app_settings').doc(mode == 'light' ? 'logo_light' : 'logo_dark').set({
          'url': imageUrl,
        });

        Get.snackbar(
          'সফল',
          '${mode == 'light' ? 'লাইট মোড' : 'ডার্ক মোড'} লোগো পরিবর্তন করা হয়েছে',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      debugPrint('Error picking logo: $e');
      Get.snackbar(
        'ব্যর্থতা',
        'লোগো আপলোড করা যায়নি: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Copy logo file to the local development workspace assets folder
  Future<void> _copyLogoToAssets(File sourceFile, String targetFileName) async {
    if (kIsWeb) return;
    try {
      final String projectPath =
          'c:\\Users\\mohos\\OneDrive\\Desktop\\trade_wign_bd';
      final Directory targetDir = Directory('$projectPath\\assets\\logos');
      if (targetDir.existsSync()) {
        final File targetFile = File('${targetDir.path}\\$targetFileName');
        await sourceFile.copy(targetFile.path);
        debugPrint(
          'Successfully copied logo to host project workspace assets directory',
        );
      }
    } catch (e) {
      debugPrint('Could not copy file to workspace assets directory: $e');
    }
  }


}
