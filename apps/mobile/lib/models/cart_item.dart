import 'branch_product.dart';
import 'product_option.dart';

class CartItem {
  final BranchProduct branchProduct;
  final List<ProductOption> selectedOptions;
  int quantity;

  CartItem({
    required this.branchProduct,
    this.selectedOptions = const [],
    this.quantity = 1,
  });

  String get productName => branchProduct.product.name;

  double get unitPrice {
    final optionsPrice = selectedOptions.fold<double>(
      0,
      (total, option) => total + option.additionalPrice,
    );

    return branchProduct.price + optionsPrice;
  }

  double get subtotal => unitPrice * quantity;

  int get productId => branchProduct.productId;

  String get optionsDescription {
    return selectedOptions.map((option) => option.name).join(', ');
  }

  bool hasSameOptions(List<ProductOption> options) {
    if (selectedOptions.length != options.length) return false;

    final currentIds = selectedOptions.map((option) => option.id).toSet();
    final newIds = options.map((option) => option.id).toSet();

    return currentIds.length == newIds.length && currentIds.containsAll(newIds);
  }
}
