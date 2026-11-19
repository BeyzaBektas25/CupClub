import 'product.dart';

class BranchProduct {
  final int id;
  final int branchId;
  final int productId;
  final Product product;
  final bool isInStock;
  final double price;

  BranchProduct({
    required this.id,
    required this.branchId,
    required this.productId,
    required this.product,
    required this.isInStock,
    required this.price,
  });

  factory BranchProduct.fromJson(Map<String, dynamic> json) {
    return BranchProduct(
      id: json['id'],
      branchId: json['branch_id'],
      productId: json['product_id'],
      product: Product.fromJson(json['product']),
      isInStock: json['is_in_stock'],
      price: double.parse(json['price'].toString()),
    );
  }
}
