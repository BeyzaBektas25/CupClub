import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';
import 'order_tracking_screen.dart';

class CartScreen extends StatefulWidget {
  final CartService cartService;
  final int branchId;

  const CartScreen({
    super.key,
    required this.cartService,
    required this.branchId,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isSubmitting = false;

  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  Future<void> _completeOrder() async {
    if (_isSubmitting || widget.cartService.items.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userId = await _authService.getCurrentUserId();

      final orderItems = widget.cartService.items.map((item) {
        return {
          'productId': item.productId,
          'quantity': item.quantity,
          'optionIds': item.selectedOptions.map((option) => option.id).toList(),
        };
      }).toList();

      final order = await _apiService.createOrder(
        userId: userId,
        branchId: widget.branchId,
        items: orderItems,
      );

      final orderId = int.parse(order['id'].toString());
      final initialStatus = order['status']?.toString() ?? 'Pending';

      widget.cartService.clearCart();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderTrackingScreen(
            orderId: orderId,
            initialStatus: initialStatus,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Sipariş oluşturulamadı: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sepetim')),
      body: ListenableBuilder(
        listenable: widget.cartService,
        builder: (context, child) {
          final items = widget.cartService.items;

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

                    return _CartItemCard(
                      item: item,
                      cartService: widget.cartService,
                    );
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
                            '${widget.cartService.totalPrice.toStringAsFixed(2)} TL',
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
                          onPressed: _isSubmitting ? null : _completeOrder,
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Siparişi Tamamla'),
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
