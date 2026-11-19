import 'package:flutter/foundation.dart';

import '../models/branch_product.dart';
import '../models/cart_item.dart';

enum CartAddResult { added, outOfStock, differentBranch }

class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];

  int? _branchId;

  // Sepetteki ürünleri dışarıdan görüntülemek için
  List<CartItem> get items => List.unmodifiable(_items);

  // Sepetin hangi şubeye ait olduğunu gösterir
  int? get branchId => _branchId;

  // Sepetteki toplam ürün adedi
  int get totalQuantity {
    return _items.fold(0, (total, item) => total + item.quantity);
  }

  // Sepetin toplam fiyatı
  double get totalPrice {
    return _items.fold(0, (total, item) => total + item.subtotal);
  }

  // Şube değiştirme
  void setBranch(int newBranchId) {
    if (_branchId != newBranchId) {
      _items.clear();
      _branchId = newBranchId;
      notifyListeners();
    }
  }

  // Sepete ürün ekleme
  CartAddResult addItem(BranchProduct product) {
    // Ürün stokta değilse ekleme
    if (!product.isInStock) {
      return CartAddResult.outOfStock;
    }

    // Farklı şubeden ürün eklenmesini engelle
    if (_branchId != null && _branchId != product.branchId) {
      return CartAddResult.differentBranch;
    }

    // Henüz şube seçilmemişse ürünün şubesini belirle
    _branchId ??= product.branchId;

    // Ürün daha önce sepete eklenmiş mi?
    final existingIndex = _items.indexWhere(
      (item) => item.productId == product.productId,
    );

    if (existingIndex != -1) {
      // Varsa adedini artır
      _items[existingIndex].quantity++;
    } else {
      // Yoksa yeni ürün oluştur
      _items.add(CartItem(branchProduct: product));
    }

    notifyListeners();

    return CartAddResult.added;
  }

  // Ürün adedini artırma
  void increaseQuantity(int productId) {
    final index = _items.indexWhere((item) => item.productId == productId);

    if (index != -1 && _items[index].branchProduct.isInStock) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  // Ürün adedini azaltma
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

  // Ürünü tamamen sepetten çıkarma
  void removeItem(int productId) {
    _items.removeWhere((item) => item.productId == productId);

    notifyListeners();
  }

  // Sepeti temizleme
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
