import 'package:flutter/foundation.dart';

import '../models/branch_product.dart';
import '../models/cart_item.dart';
import '../models/product_option.dart';

enum CartAddResult { added, outOfStock, differentBranch }

class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];

  int? _branchId;

  List<CartItem> get items => List.unmodifiable(_items);

  int? get branchId => _branchId;

  int get totalQuantity {
    return _items.fold(0, (total, item) => total + item.quantity);
  }

  double get totalPrice {
    return _items.fold(0, (total, item) => total + item.subtotal);
  }

  void setBranch(int newBranchId) {
    if (_branchId != newBranchId) {
      _items.clear();
      _branchId = newBranchId;
      notifyListeners();
    }
  }

  CartAddResult addItem(
    BranchProduct product, {
    List<ProductOption> selectedOptions = const [],
    int quantity = 1,
  }) {
    if (!product.isInStock) {
      return CartAddResult.outOfStock;
    }

    if (_branchId != null && _branchId != product.branchId) {
      return CartAddResult.differentBranch;
    }

    if (quantity < 1) {
      return CartAddResult.outOfStock;
    }

    _branchId ??= product.branchId;

    final existingIndex = _items.indexWhere(
      (item) =>
          item.productId == product.productId &&
          item.hasSameOptions(selectedOptions),
    );

    if (existingIndex != -1) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(
        CartItem(
          branchProduct: product,
          selectedOptions: List.unmodifiable(selectedOptions),
          quantity: quantity,
        ),
      );
    }

    notifyListeners();
    return CartAddResult.added;
  }

  void increaseCartItem(CartItem cartItem) {
    final index = _items.indexOf(cartItem);

    if (index != -1 && _items[index].branchProduct.isInStock) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decreaseCartItem(CartItem cartItem) {
    final index = _items.indexOf(cartItem);

    if (index == -1) return;

    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }

    notifyListeners();
  }

  void removeCartItem(CartItem cartItem) {
    _items.remove(cartItem);
    notifyListeners();
  }

  // Eski productId tabanlı metotlar korunmuştur.
  void increaseQuantity(int productId) {
    final index = _items.indexWhere((item) => item.productId == productId);

    if (index != -1 && _items[index].branchProduct.isInStock) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decreaseQuantity(int productId) {
    final index = _items.indexWhere((item) => item.productId == productId);

    if (index == -1) return;

    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }

    notifyListeners();
  }

  void removeItem(int productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
