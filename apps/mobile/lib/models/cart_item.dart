import 'branch_product.dart';

class CartItem {
  final BranchProduct branchProduct;
  int quantity;

  CartItem({required this.branchProduct, this.quantity = 1});

  // Ürün adı
  String get productName => branchProduct.product.name;

  // Birim fiyat
  double get unitPrice => branchProduct.price;

  // Ürün adedi ile birim fiyatın çarpımı
  double get subtotal => unitPrice * quantity;

  // Ürün ID'si
  int get productId => branchProduct.productId;
}
