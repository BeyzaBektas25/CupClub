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
  bool _isCheckingCoupon = false;

  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  final TextEditingController _couponController = TextEditingController();

  bool _couponApplied = false;
  double _discountAmount = 0;
  double? _couponCartTotal;
  String? _couponMessage;

  bool get _isCouponValidForCurrentCart {
    if (!_couponApplied || _couponCartTotal == null) {
      return false;
    }

    return (widget.cartService.totalPrice - _couponCartTotal!).abs() < 0.005;
  }

  double get _finalTotal {
    if (_isCouponValidForCurrentCart) {
      return (widget.cartService.totalPrice - _discountAmount)
          .clamp(0, double.infinity)
          .toDouble();
    }

    return widget.cartService.totalPrice;
  }

  void _onCouponChanged(String value) {
    setState(() {
      _couponMessage = null;

      if (_couponApplied) {
        _couponApplied = false;
        _discountAmount = 0;
        _couponCartTotal = null;
      }
    });
  }

  Future<void> _applyCoupon() async {
    final couponCode = _couponController.text.trim();

    if (couponCode.isEmpty) {
      setState(() {
        _couponMessage = 'Lütfen bir kupon kodu girin.';
        _couponApplied = false;
      });
      return;
    }

    if (_isCheckingCoupon || widget.cartService.items.isEmpty) {
      return;
    }

    setState(() {
      _isCheckingCoupon = true;
      _couponMessage = null;
      _couponApplied = false;
      _discountAmount = 0;
      _couponCartTotal = null;
    });

    try {
      final cartTotal = widget.cartService.totalPrice;

      final result = await _apiService.evaluateCoupon(
        cartTotal: cartTotal,
        couponCode: couponCode,
      );

      final campaign = result['appliedCampaign'];

      if (campaign == null) {
        throw Exception('Bu kupon mevcut sepetiniz için uygulanamıyor.');
      }

      final discount =
          double.tryParse(result['discountAmount']?.toString() ?? '') ?? 0;

      if (!mounted) return;

      setState(() {
        _couponApplied = true;
        _discountAmount = discount;
        _couponCartTotal = cartTotal;
        _couponMessage = 'Kupon başarıyla uygulandı.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _couponApplied = false;
        _discountAmount = 0;
        _couponCartTotal = null;
        _couponMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingCoupon = false;
        });
      }
    }
  }

  void _removeCoupon() {
    setState(() {
      _couponApplied = false;
      _discountAmount = 0;
      _couponCartTotal = null;
      _couponMessage = 'Kupon kaldırıldı.';
      _couponController.clear();
    });
  }

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
        couponCode: _isCouponValidForCurrentCart
            ? _couponController.text.trim()
            : null,
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
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sepetim')),
      body: ListenableBuilder(
        listenable: widget.cartService,
        builder: (context, child) {
          final items = widget.cartService.items;
          final cartTotal = widget.cartService.totalPrice;
          final couponIsCurrent = _isCouponValidForCurrentCart;

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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Divider(),
                      const Text(
                        'Kupon Kodu',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _couponController,
                              textCapitalization: TextCapitalization.characters,
                              enabled: !_isCheckingCoupon && !_isSubmitting,
                              decoration: const InputDecoration(
                                hintText: 'Kupon kodunuzu girin',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                              ),
                              onChanged: _onCouponChanged,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed:
                                _isCheckingCoupon ||
                                    _isSubmitting ||
                                    _couponController.text.trim().isEmpty
                                ? null
                                : _applyCoupon,
                            child: _isCheckingCoupon
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Uygula'),
                          ),
                        ],
                      ),
                      if (_couponMessage != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _couponMessage!,
                                style: TextStyle(
                                  color: _couponApplied && couponIsCurrent
                                      ? Colors.green
                                      : Colors.redAccent,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            if (_couponApplied)
                              TextButton(
                                onPressed: _isSubmitting ? null : _removeCoupon,
                                child: const Text('Kaldır'),
                              ),
                          ],
                        ),
                      ],
                      if (_couponApplied && !couponIsCurrent)
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Text(
                            'Sepet tutarı değişti. Kuponu yeniden uygulayın.',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Ara Toplam'),
                          Text('${cartTotal.toStringAsFixed(2)} TL'),
                        ],
                      ),
                      if (couponIsCurrent) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Kupon İndirimi',
                              style: TextStyle(color: Colors.green),
                            ),
                            Text(
                              '-${_discountAmount.toStringAsFixed(2)} TL',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const Divider(height: 20),
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
                            '${_finalTotal.toStringAsFixed(2)} TL',
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
