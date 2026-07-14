import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/product_model.dart';

class EcommerceController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reactive states
  final RxBool isLoading = false.obs;
  final RxList<Product> products = <Product>[].obs;
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> brands = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> productTypes = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> units = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProductTypes();
    fetchUnits();
    fetchCategories();
    fetchBrands();
    fetchProducts();
  }

  // --- Product Types ---
  void fetchProductTypes() {
    _firestore.collection('product_types').orderBy('name').snapshots().listen(
      (snapshot) {
        productTypes.value = snapshot.docs.map((doc) => {
          'id': doc.id,
          'name': doc.data()['name'] ?? '',
          'image': doc.data()['image'] ?? '',
          'status': doc.data()['status'] ?? 'public',
        }).toList();
      },
      onError: (e) => debugPrint('Error fetching product types: $e'),
    );
  }

  Future<bool> addProductType(String name, {String image = '', String status = 'public'}) async {
    if (name.trim().isEmpty) return false;
    try {
      isLoading.value = true;
      final existing = await _firestore.collection('product_types').where('name', isEqualTo: name.trim()).get();
      if (existing.docs.isNotEmpty) {
        Get.snackbar(
  'ত্রুটি',
  'এই প্রোডাক্ট টাইপ ইতিমধ্যে বিদ্যমান রয়েছে',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
        return false;
      }
      await _firestore.collection('product_types').add({
        'name': name.trim(),
        'image': image,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error adding product type: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProductType(String id, String name, {String image = '', String status = 'public'}) async {
    if (name.trim().isEmpty) return false;
    try {
      isLoading.value = true;
      await _firestore.collection('product_types').doc(id).update({
        'name': name.trim(),
        'image': image,
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error updating product type: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProductType(String id) async {
    try {
      await _firestore.collection('product_types').doc(id).delete();
      Get.snackbar(
  'সফল',
  'প্রোডাক্ট টাইপ মুছে ফেলা হয়েছে',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
    } catch (e) {
      debugPrint('Error deleting product type: $e');
      Get.snackbar(
  'ত্রুটি',
  'প্রোডাক্ট টাইপ মুছতে ব্যর্থ হয়েছে: $e',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
    }
  }

  // --- Units ---
  void fetchUnits() {
    _firestore.collection('units').orderBy('name').snapshots().listen(
      (snapshot) {
        units.value = snapshot.docs.map((doc) => {
          'id': doc.id,
          'name': doc.data()['name'] ?? '',
          'status': doc.data()['status'] ?? 'public',
        }).toList();
      },
      onError: (e) => debugPrint('Error fetching units: $e'),
    );
  }

  Future<bool> addUnit(String name, {String status = 'public'}) async {
    if (name.trim().isEmpty) return false;
    try {
      isLoading.value = true;
      final existing = await _firestore.collection('units').where('name', isEqualTo: name.trim()).get();
      if (existing.docs.isNotEmpty) {
        Get.snackbar(
  'ত্রুটি',
  'এই ইউনিট ইতিমধ্যে বিদ্যমান রয়েছে',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
        return false;
      }
      await _firestore.collection('units').add({
        'name': name.trim(),
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error adding unit: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateUnit(String id, String name, {String status = 'public'}) async {
    if (name.trim().isEmpty) return false;
    try {
      isLoading.value = true;
      await _firestore.collection('units').doc(id).update({
        'name': name.trim(),
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error updating unit: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteUnit(String id) async {
    try {
      await _firestore.collection('units').doc(id).delete();
      Get.snackbar(
  'সফল',
  'ইউনিট মুছে ফেলা হয়েছে',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
    } catch (e) {
      debugPrint('Error deleting unit: $e');
      Get.snackbar(
  'ত্রুটি',
  'ইউনিট মুছতে ব্যর্থ হয়েছে: $e',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
    }
  }

  // --- Categories ---
  void fetchCategories() {
    _firestore.collection('categories').orderBy('name').snapshots().listen(
      (snapshot) {
        categories.value = snapshot.docs.map((doc) => {
          'id': doc.id,
          'name': doc.data()['name'] ?? '',
          'image': doc.data()['image'] ?? '',
          'productTypeId': doc.data()['productTypeId'] ?? '',
          'status': doc.data()['status'] ?? 'public',
        }).toList();
      },
      onError: (e) => debugPrint('Error fetching categories: $e'),
    );
  }

  Future<bool> addCategory(String name, {String image = '', required String productTypeId, String status = 'public'}) async {
    if (name.trim().isEmpty || productTypeId.isEmpty) return false;
    try {
      isLoading.value = true;
      
      final existing = await _firestore.collection('categories').where('name', isEqualTo: name.trim()).get();
      if (existing.docs.isNotEmpty) {
        Get.snackbar(
  'ত্রুটি',
  'এই ক্যাটাগরি ইতিমধ্যে বিদ্যমান রয়েছে',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
        return false;
      }

      await _firestore.collection('categories').add({
        'name': name.trim(),
        'image': image,
        'productTypeId': productTypeId,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error adding category: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateCategory(String id, String name, {String image = '', required String productTypeId, String status = 'public'}) async {
    if (name.trim().isEmpty || productTypeId.isEmpty) return false;
    try {
      isLoading.value = true;
      await _firestore.collection('categories').doc(id).update({
        'name': name.trim(),
        'image': image,
        'productTypeId': productTypeId,
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error updating category: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _firestore.collection('categories').doc(id).delete();
      Get.snackbar(
  'সফল',
  'ক্যাটাগরি মুছে ফেলা হয়েছে',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
    } catch (e) {
      debugPrint('Error deleting category: $e');
      Get.snackbar(
  'ত্রুটি',
  'ক্যাটাগরি মুছতে ব্যর্থ হয়েছে: $e',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
    }
  }

  // --- Brands ---
  void fetchBrands() {
    _firestore.collection('brands').orderBy('name').snapshots().listen(
      (snapshot) {
        brands.value = snapshot.docs.map((doc) => {
          'id': doc.id,
          'name': doc.data()['name'] ?? '',
          'image': doc.data()['image'] ?? '',
          'productTypeId': doc.data()['productTypeId'] ?? '',
          'status': doc.data()['status'] ?? 'public',
        }).toList();
      },
      onError: (e) => debugPrint('Error fetching brands: $e'),
    );
  }

  Future<bool> addBrand(String name, {String image = '', required String productTypeId, String status = 'public'}) async {
    if (name.trim().isEmpty || productTypeId.isEmpty) return false;
    try {
      isLoading.value = true;
      
      final existing = await _firestore.collection('brands').where('name', isEqualTo: name.trim()).get();
      if (existing.docs.isNotEmpty) {
        Get.snackbar(
  'ত্রুটি',
  'এই ব্র্যান্ড ইতিমধ্যে বিদ্যমান রয়েছে',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
        return false;
      }

      await _firestore.collection('brands').add({
        'name': name.trim(),
        'image': image,
        'productTypeId': productTypeId,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error adding brand: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateBrand(String id, String name, {String image = '', required String productTypeId, String status = 'public'}) async {
    if (name.trim().isEmpty || productTypeId.isEmpty) return false;
    try {
      isLoading.value = true;
      await _firestore.collection('brands').doc(id).update({
        'name': name.trim(),
        'image': image,
        'productTypeId': productTypeId,
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error updating brand: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteBrand(String id) async {
    try {
      await _firestore.collection('brands').doc(id).delete();
      Get.snackbar(
  'সফল',
  'ব্র্যান্ড মুছে ফেলা হয়েছে',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
    } catch (e) {
      debugPrint('Error deleting brand: $e');
      Get.snackbar(
  'ত্রুটি',
  'ব্র্যান্ড মুছতে ব্যর্থ হয়েছে: $e',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
    }
  }

  // Stream products from Firestore
  void fetchProducts() {
    isLoading.value = true;
    _firestore.collection('products').orderBy('createdAt', descending: true).snapshots().listen(
      (snapshot) {
        products.value = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
        isLoading.value = false;
      },
      onError: (e) {
        debugPrint('Error fetching products: $e');
        isLoading.value = false;
      },
    );
  }

  // Add a new Product
  Future<bool> addProduct(Product product) async {
    try {
      isLoading.value = true;
      await _firestore.collection('products').add(product.toFirestore());
      Get.snackbar(
  'সফল',
  'পণ্যটি সফলভাবে যুক্ত করা হয়েছে',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
      return true;
    } catch (e) {
      debugPrint('Error adding product: $e');
      Get.snackbar(
  'ব্যর্থতা',
  'পণ্য যুক্ত করা যায়নি: $e',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Update an existing Product
  Future<bool> updateProduct(String productId, Product product) async {
    try {
      isLoading.value = true;
      await _firestore.collection('products').doc(productId).update(product.toFirestore());
      Get.snackbar(
  'সফল',
  'পণ্যটির তথ্য সফলভাবে আপডেট করা হয়েছে',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
      return true;
    } catch (e) {
      debugPrint('Error updating product: $e');
      Get.snackbar(
  'ব্যর্থতা',
  'পণ্য আপডেট করা যায়নি: $e',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Delete Product
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      Get.snackbar(
  'সফল',
  'পণ্যটি সফলভাবে মুছে ফেলা হয়েছে',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
    } catch (e) {
      debugPrint('Error deleting product: $e');
      Get.snackbar(
  'ত্রুটি',
  'পণ্যটি মোছা যায়নি: $e',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
    }
  }

}
