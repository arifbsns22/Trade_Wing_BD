import 'package:get/get.dart';
import 'package:trade_wign_bd/features/admin/ecommerce/domain/models/product_model.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';

class CartController extends GetxController {
  // Map of productId -> quantity
  final RxMap<String, int> _cartItems = <String, int>{}.obs;

  // Map of productId -> Product (to store full product details)
  final RxMap<String, Product> _cartProducts = <String, Product>{}.obs;

  /// Total number of individual items in the cart (sum of all quantities)
  int get totalItemsCount {
    int total = 0;
    for (final qty in _cartItems.values) {
      total += qty;
    }
    return total;
  }

  /// All products currently in cart as a list
  List<Product> get cartProductList => _cartProducts.values.toList();

  /// Compute total price based on user's role
  double totalPrice() {
    try {
      final authController = Get.find<AuthController>();
      final role = authController.currentUserRole.value;
      double total = 0.0;
      for (final entry in _cartItems.entries) {
        final product = _cartProducts[entry.key];
        if (product != null) {
          final price = product.rolePrices[role] ??
              product.rolePrices['Customer'] ??
              product.rolePrices['Guest Customer'] ??
              0.0;
          total += price * entry.value;
        }
      }
      return total;
    } catch (_) {
      return 0.0;
    }
  }

  /// Get current quantity for a specific product (0 if not in cart)
  int getProductQuantity(String productId) {
    return _cartItems[productId] ?? 0;
  }

  /// Add a full product object to cart (preferred method)
  void addProductToCart(Product product) {
    final id = product.id ?? product.name;
    _cartProducts[id] = product;
    addToCart(id);
  }

  /// Add 1 unit of a product to the cart by ID
  void addToCart(String productId) {
    final current = _cartItems[productId] ?? 0;
    _cartItems[productId] = current + 1;
  }

  /// Decrease quantity by 1; remove from cart if quantity reaches 0
  void decreaseQuantity(String productId) {
    final current = _cartItems[productId] ?? 0;
    if (current <= 1) {
      _cartItems.remove(productId);
      _cartProducts.remove(productId);
    } else {
      _cartItems[productId] = current - 1;
    }
  }

  /// Set quantity directly for a product
  void setQuantity(String productId, int qty) {
    if (qty <= 0) {
      _cartItems.remove(productId);
      _cartProducts.remove(productId);
    } else {
      _cartItems[productId] = qty;
    }
  }

  /// Remove a product entirely from the cart
  void removeFromCart(String productId) {
    _cartItems.remove(productId);
    _cartProducts.remove(productId);
  }

  /// Clear the entire cart
  void clearCart() {
    _cartItems.clear();
    _cartProducts.clear();
  }

  /// Returns the reactive map for listening
  RxMap<String, int> get cartItems => _cartItems;
}
