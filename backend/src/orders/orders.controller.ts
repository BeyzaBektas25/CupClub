import { Controller, Post, Get, Patch, Body, Param, ParseIntPipe } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBody } from '@nestjs/swagger';
import { OrdersService } from './orders.service';

@ApiTags('Orders (Sipariş Yönetimi)')
@Controller()
export class OrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @Post('orders')
  @ApiOperation({ summary: 'Müşteri sepetinden sunucu fiyat kontrolüyle sipariş oluşturur' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        userId: { type: 'number', example: 1 },
        branchId: { type: 'number', example: 1 },
        items: {
          type: 'array',
          example: [{ productId: 1, quantity: 2 }],
        },
      },
    },
  })
  createOrder(@Body() body: { userId: number; branchId: number; items: { productId: number; quantity: number }[] }) {
    return this.ordersService.createOrder(body);
  }

  @Get('branches/:branchId/orders')
  @ApiOperation({ summary: 'Şube personelinin ekranı için şubeye gelen siparişleri listeler' })
  getBranchOrders(@Param('branchId', ParseIntPipe) branchId: number) {
    return this.ordersService.getBranchOrders(branchId);
  }

  @Patch('orders/:orderId/status')
  @ApiOperation({ summary: 'Sipariş durumunu günceller (Accepted, Preparing, Ready, Delivered)' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: { status: { type: 'string', example: 'Preparing' } },
    },
  })
  updateStatus(@Param('orderId', ParseIntPipe) orderId: number, @Body('status') status: string) {
    return this.ordersService.updateStatus(orderId, status);
  }
}
