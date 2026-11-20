import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../core/config/api_config.dart';

class SocketService {
  io.Socket? _socket;

  void connectToOrder({
    required int orderId,
    required Function(String status) onStatusChanged,
  }) {
    disconnect();

    _socket = io.io(
      ApiConfig.baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('Socket.IO bağlantısı kuruldu.');
    });

    _socket!.onConnectError((error) {
      debugPrint('Socket.IO bağlantı hatası: $error');
    });

    _socket!.on('order-status-$orderId', (data) {
      if (data is Map && data['status'] != null) {
        onStatusChanged(data['status'].toString());
      }
    });

    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
