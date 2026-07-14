import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/controllers/product_review_controller.dart';

class ReviewDialogWidget extends StatefulWidget {
  final String productId;
  final ProductReviewController reviewController;

  const ReviewDialogWidget({
    super.key,
    required this.productId,
    required this.reviewController,
  });

  @override
  State<ReviewDialogWidget> createState() => _ReviewDialogWidgetState();
}

class _ReviewDialogWidgetState extends State<ReviewDialogWidget> {
  double _rating = 5.0;
  final TextEditingController _commentCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    try {
      final auth = Get.find<AuthController>();
      _nameCtrl.text = auth.currentUserName.value;
    } catch (_) {}
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Write a Review',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF034F4B),
              ),
            ),
            const SizedBox(height: 20),

            // Star Rating
            const Text('Your Rating',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (i) {
                return GestureDetector(
                  onTap: () => setState(() => _rating = (i + 1).toDouble()),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(
                      i < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: const Color(0xFFF59E0B),
                      size: 34,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Name field
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: 'Your Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF034F4B)),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),

            // Comment field
            TextField(
              controller: _commentCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Comment (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF034F4B)),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),

            // Submit
            Obx(() {
              final isSubmitting = widget.reviewController.isSubmitting.value;
              return SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBEF264),
                    foregroundColor: const Color(0xFF034F4B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF034F4B),
                          ),
                        )
                      : const Text(
                          'Submit Review',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) {
      Get.snackbar(
  'Error',
  'Please enter your name.',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
      return;
    }

    String userId = '';
    String userName = _nameCtrl.text.trim();
    try {
      final auth = Get.find<AuthController>();
      userId = auth.currentUserMobile.value;
      if (userName.isEmpty) userName = auth.currentUserName.value;
    } catch (_) {}

    final success = await widget.reviewController.submitReview(
      productId: widget.productId,
      userId: userId,
      userName: _nameCtrl.text.trim(),
      comment: _commentCtrl.text.trim(),
      rating: _rating,
    );

    if (success) {
      Get.back();
      Get.snackbar(
  'Thank you!',
  'Your review has been submitted.',
  backgroundColor: Colors.white.withValues(alpha: 0.9),
  colorText: Colors.black87,
  borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
  borderWidth: 1,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(16),
);
    } else {
      Get.snackbar(
  'Error',
  'Failed to submit review. Please try again.',
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
