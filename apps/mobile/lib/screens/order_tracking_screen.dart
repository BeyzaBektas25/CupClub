import 'package:flutter/material.dart';

import '../services/socket_service.dart';

class OrderTrackingScreen extends StatefulWidget {
  final int orderId;
  final String initialStatus;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    required this.initialStatus,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final SocketService _socketService = SocketService();

  late String _status;

  final List<String> _steps = ['Pending', 'Preparing', 'Ready', 'Completed'];

  final Map<String, String> _statusLabels = {
    'Pending': 'Sipariş alındı',
    'Preparing': 'Hazırlanıyor',
    'Ready': 'Siparişiniz hazır!',
    'Completed': 'Sipariş tamamlandı',
    'Cancelled': 'Sipariş iptal edildi',
  };

  @override
  void initState() {
    super.initState();

    _status = widget.initialStatus;

    _socketService.connectToOrder(
      orderId: widget.orderId,
      onStatusChanged: (newStatus) {
        if (!mounted) return;

        setState(() {
          _status = newStatus;
        });
      },
    );
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }

  int get _currentStep {
    final index = _steps.indexOf(_status);
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    const coffeeBrown = Color(0xFF79543A);
    const lightBrown = Color(0xFFD8C6B5);
    const backgroundColor = Color(0xFFFAF6F1);

    final isCancelled = _status == 'Cancelled';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Sipariş Takibi'),
        backgroundColor: backgroundColor,
        foregroundColor: coffeeBrown,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.coffee_rounded, size: 65, color: coffeeBrown),
              const SizedBox(height: 20),

              Text(
                'Sipariş #${widget.orderId}',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: coffeeBrown,
                ),
              ),

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withValues(alpha: 0.06),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      _statusLabels[_status] ?? _status,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: coffeeBrown,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      isCancelled
                          ? 'Bu sipariş iptal edilmiştir.'
                          : 'Siparişinizin durumunu buradan '
                                'anlık olarak takip edebilirsiniz.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.brown),
                    ),

                    const SizedBox(height: 42),

                    if (isCancelled)
                      const Icon(
                        Icons.cancel_outlined,
                        size: 55,
                        color: Colors.redAccent,
                      )
                    else
                      _buildProgress(coffeeBrown, lightBrown),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgress(Color coffeeBrown, Color lightBrown) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final itemWidth = width / 4;

            return SizedBox(
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: itemWidth / 2,
                    right: itemWidth / 2,
                    top: 22,
                    child: Row(
                      children: List.generate(3, (index) {
                        return Expanded(
                          child: Container(
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: _currentStep > index
                                  ? coffeeBrown
                                  : lightBrown,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  Row(
                    children: List.generate(4, (index) {
                      final isCompleted = index < _currentStep;
                      final isActive = index == _currentStep;

                      return SizedBox(
                        width: itemWidth,
                        child: Center(
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isActive || isCompleted
                                  ? const Color(0xFFF3E8DC)
                                  : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isActive || isCompleted
                                    ? coffeeBrown
                                    : lightBrown,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              isCompleted
                                  ? Icons.check
                                  : isActive
                                  ? Icons.coffee_rounded
                                  : Icons.circle_outlined,
                              color: isActive || isCompleted
                                  ? coffeeBrown
                                  : lightBrown,
                              size: isActive ? 25 : 21,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 14),

        Row(
          children: List.generate(4, (index) {
            final isReached = index <= _currentStep;

            return Expanded(
              child: Text(
                ['Alındı', 'Hazırlanıyor', 'Hazır', 'Tamamlandı'][index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isReached ? FontWeight.bold : FontWeight.normal,
                  color: isReached ? coffeeBrown : Colors.grey,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
