import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/models/product.dart';
import 'package:mobile/models/branch_product.dart';
import 'package:mobile/services/cart_service.dart';

void main() {
  late CartService cartService;

  setUp(() {
    cartService = CartService();
  });

  tearDown(() {
    cartService.dispose();
  });

  BranchProduct createProduct({
    int id = 1,
    int branchId = 1,
    double price = 40,
    bool isInStock = true,
  }) {
    return BranchProduct(
      id: id,
      branchId: branchId,
      productId: id,
      product: Product(id: id, name: 'Test Ürünü', isActive: true),
      isInStock: isInStock,
      price: price,
    );
  }

  test('Ürün sepete eklenebilmeli', () {
    final product = createProduct();

    final result = cartService.addItem(product);

    expect(result, CartAddResult.added);
    expect(cartService.totalQuantity, 1);
    expect(cartService.totalPrice, 40);
  });

  test('Aynı ürün tekrar eklenince adedi artmalı', () {
    final product = createProduct();

    cartService.addItem(product);
    cartService.addItem(product);

    expect(cartService.totalQuantity, 2);
    expect(cartService.totalPrice, 80);
  });

  test('Stokta olmayan ürün sepete eklenmemeli', () {
    final product = createProduct(isInStock: false);

    final result = cartService.addItem(product);

    expect(result, CartAddResult.outOfStock);
    expect(cartService.totalQuantity, 0);
  });

  test('Farklı şubeden ürün eklenememeli', () {
    final firstProduct = createProduct(id: 1, branchId: 1);

    final secondProduct = createProduct(id: 2, branchId: 2);

    cartService.addItem(firstProduct);

    final result = cartService.addItem(secondProduct);

    expect(result, CartAddResult.differentBranch);
    expect(cartService.totalQuantity, 1);
  });

  test('Ürün adedi artırılıp azaltılabilmeli', () {
    final product = createProduct();

    cartService.addItem(product);
    cartService.increaseQuantity(product.productId);
    cartService.decreaseQuantity(product.productId);

    expect(cartService.totalQuantity, 1);
    expect(cartService.totalPrice, 40);
  });

  test('Adet sıfıra düşünce ürün silinmeli', () {
    final product = createProduct();

    cartService.addItem(product);
    cartService.decreaseQuantity(product.productId);

    expect(cartService.totalQuantity, 0);
    expect(cartService.totalPrice, 0);
  });

  test('Sepet temizlenebilmeli', () {
    cartService.addItem(createProduct());

    cartService.clearCart();

    expect(cartService.totalQuantity, 0);
    expect(cartService.totalPrice, 0);
  });

  test('Şube değişince sepet temizlenmeli', () {
    cartService.addItem(createProduct());

    cartService.setBranch(2);

    expect(cartService.totalQuantity, 0);
    expect(cartService.branchId, 2);
  });
}
