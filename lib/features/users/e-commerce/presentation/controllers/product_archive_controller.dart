import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trade_wign_bd/features/admin/ecommerce/domain/models/product_model.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/widgets/user_home_products.dart';

/// Strongly typed configuration object for passing arguments to ProductArchiveScreen
class ProductArchiveArguments {
  final String archiveTitle;
  final ProductTypeFilter filterType;
  final String? filterId;

  ProductArchiveArguments({
    required this.archiveTitle,
    required this.filterType,
    this.filterId,
  });
}

class ProductArchiveController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // State Management Variables
  final RxBool isLoading = true.obs;
  final RxBool isFetchingMore = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasMoreData = true.obs;
  final RxList<Product> productsList = <Product>[].obs;

  // Sorting / Filtering state
  final RxString currentSort = 'default'.obs; // default, price_low_high, price_high_low

  // Pagination parameters
  final int _batchSize = 20;
  DocumentSnapshot? _lastDocument;

  // Route Arguments
  final ProductArchiveArguments args;

  ProductArchiveController(this.args);

  @override
  void onInit() {
    super.onInit();
    // Initial fetch
    _fetchProducts(isInitial: true);
  }

  /// Fetches a batch of products from Firestore
  Future<void> _fetchProducts({bool isInitial = false}) async {
    if (!hasMoreData.value && !isInitial) return;
    
    if (isInitial) {
      isLoading.value = true;
      hasError.value = false;
      productsList.clear();
      _lastDocument = null;
      hasMoreData.value = true;
    } else {
      isFetchingMore.value = true;
    }

    try {
      // Base Query: only fetch public products
      Query query = _firestore.collection('products').where('status', isEqualTo: 'public');

      // Apply dynamic filtering based on arguments
      switch (args.filterType) {
        case ProductTypeFilter.category:
          if (args.filterId != null) {
            query = query.where('category', isEqualTo: args.filterId);
          }
          break;
        case ProductTypeFilter.brand:
          if (args.filterId != null) {
            query = query.where('brand', isEqualTo: args.filterId);
          }
          break;
        case ProductTypeFilter.productType:
          if (args.filterId != null) {
            query = query.where('type', isEqualTo: args.filterId);
          }
          break;
        case ProductTypeFilter.recent:
          query = query.orderBy('createdAt', descending: true);
          break;
      }

      // We cannot easily order by nested rolePrices map directly in Firestore without composite indexes,
      // so if the user wants to sort by price we might have to do it client side or ensure the data structure 
      // has a flat `basePrice` field. For now, we will just fetch the batch.
      
      // If we are not filtering by recent, it's good practice to add a predictable order for pagination.
      // E.g., orderBy createdAt descending if no other ordering applies.
      if (args.filterType != ProductTypeFilter.recent) {
        // We order by document ID to guarantee stable pagination, or by createdAt if available on all docs
         query = query.orderBy(FieldPath.documentId);
      }

      // Add pagination cursors
      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      query = query.limit(_batchSize);

      // Simulate offline-first by relying on Firestore's built-in offline persistence (which acts like Hive/Isar)
      // Since Get.isLoggable is true, Firestore will serve from cache instantly if offline.
      final QuerySnapshot snapshot = await query.get(const GetOptions(source: Source.serverAndCache));

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        
        final List<Product> fetchedBatch = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
        
        // Client-side sorting if needed
        if (currentSort.value == 'price_low_high') {
          fetchedBatch.sort((a, b) => (a.rolePrices['Customer'] ?? 0).compareTo(b.rolePrices['Customer'] ?? 0));
        } else if (currentSort.value == 'price_high_low') {
          fetchedBatch.sort((a, b) => (b.rolePrices['Customer'] ?? 0).compareTo(a.rolePrices['Customer'] ?? 0));
        }

        productsList.addAll(fetchedBatch);

        // If we fetched fewer items than the batch size, we've reached the end
        if (snapshot.docs.length < _batchSize) {
          hasMoreData.value = false;
        }
      } else {
        hasMoreData.value = false;
      }

    } catch (e) {
      debugPrint('Error fetching archive products: $e');
      hasError.value = true;
      errorMessage.value = 'Failed to load products. Please check your connection.';
    } finally {
      isLoading.value = false;
      isFetchingMore.value = false;
    }
  }

  /// Called by the UI when the user scrolls near the bottom
  void fetchNextPage() {
    if (!isLoading.value && !isFetchingMore.value && hasMoreData.value) {
      _fetchProducts();
    }
  }

  /// Update sorting order and re-fetch from scratch
  void updateSort(String sortOrder) {
    if (currentSort.value != sortOrder) {
      currentSort.value = sortOrder;
      _fetchProducts(isInitial: true);
    }
  }
}
