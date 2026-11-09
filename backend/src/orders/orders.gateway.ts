import { WebSocketGateway, WebSocketServer } from '@nestjs/websockets';
import { Server } from 'socket.io';

@WebSocketGateway({ cors: { origin: '*' } })
export class OrdersGateway {
  @WebSocketServer()
  server: Server;

  // Sipariş durumu değiştiğinde hem şube paneline hem müşteriye anlık haber verir
  notifyOrderStatusChanged(orderId: number, branchId: number, status: string) {
    this.server.emit(`order-status-${orderId}`, { orderId, status });
    this.server.emit(`branch-orders-${branchId}`, { orderId, status });
  }
}
