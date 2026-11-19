import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../services/cart_service.dart';

class CartScreen extends StatelessWidget {
  final CartService cartService;

  const CartScreen({super.key, required this.cartService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sepetim')),
      body: ListenableBuilder(
        listenable: cartService,
        builder: (context, child) {
          final items = cartService.items;

          if (items.isEmpty) {
            return const Center(child: Text('Sepetiniz henüz boş.'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    return _CartItemCard(item: item, cartService: cartService);
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Toplam',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '${cartService.totalPrice.toStringAsFixed(2)} TL',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: null,
                          child: const Text('Siparişi Tamamla'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final CartService cartService;

  const _CartItemCard({required this.item, required this.cartService});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => cartService.removeCartItem(item),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            if (item.selectedOptions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  item.optionsDescription,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            Row(
              children: [
                IconButton(
                  onPressed: () => cartService.decreaseCartItem(item),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('${item.quantity}'),
                IconButton(
                  onPressed: () => cartService.increaseCartItem(item),
                  icon: const Icon(Icons.add_circle_outline),
                ),
                const Spacer(),
                Text(
                  '${item.subtotal.toStringAsFixed(2)} TL',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
