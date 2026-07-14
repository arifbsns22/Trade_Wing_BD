import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/users/e-commerce/domain/models/product_review_model.dart';

class ProductReviewController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // reviews keyed by productId
  final RxMap<String, List<ProductReview>> _reviews =
      <String, List<ProductReview>>{}.obs;

  final RxBool isSubmitting = false.obs;

  /// Fetch reviews for a specific product (cached)
  Future<void> fetchReviews(String productId) async {
    if (_reviews.containsKey(productId)) return; // already loaded

    try {
      final snap = await _db
          .collection('product_reviews')
          .where('productId', isEqualTo: productId)
          .get();

      final fetchedReviews =
          snap.docs.map((d) => ProductReview.fromFirestore(d)).toList();
      
      // Sort locally to avoid needing a Firestore composite index
      fetchedReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      _reviews[productId] = fetchedReviews;
    } catch (e) {
      print('Error fetching reviews: $e');
      _reviews[productId] = [];
    }
  }

  /// Get reviews for a product
  List<ProductReview> getReviews(String productId) {
    return _reviews[productId] ?? [];
  }

  /// Compute average rating for a product (0.0 if no reviews)
  double getAverageRating(String productId) {
    final reviews = _reviews[productId];
    if (reviews == null || reviews.isEmpty) return 0.0;
    final total = reviews.fold<double>(0.0, (sum, r) => sum + r.rating);
    return total / reviews.length;
  }

  /// Submit a new review for a product
  Future<bool> submitReview({
    required String productId,
    required String userId,
    required String userName,
    required String comment,
    required double rating,
  }) async {
    isSubmitting.value = true;
    try {
      final review = ProductReview(
        productId: productId,
        userId: userId,
        userName: userName,
        comment: comment,
        rating: rating,
        createdAt: DateTime.now(),
      );

      await _db.collection('product_reviews').add(review.toFirestore());

      // Invalidate cache and refetch
      _reviews.remove(productId);
      await fetchReviews(productId);

      return true;
    } catch (e) {
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Force refresh reviews for a product
  Future<void> refreshReviews(String productId) async {
    _reviews.remove(productId);
    await fetchReviews(productId);
  }
}
