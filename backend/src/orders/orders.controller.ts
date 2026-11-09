import { Controller, Post, Get, Patch, Body, Param, ParseIntPipe, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBody, ApiHeader } from '@nestjs/swagger';
import { OrdersService } from './orders.service';
import { BranchAccessGuard } from '../auth/branch-access.guard';

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
  @UseGuards(BranchAccessGuard)
  @ApiOperation({ summary: 'Şube personelinin ekranı için sadece yetkili olduğu şubenin siparişlerini listeler' })
  @ApiHeader({ name: 'x-user-role', description: 'Kullanıcı Rolü (BRANCH_STAFF veya ADMIN)', example: 'BRANCH_STAFF' })
  @ApiHeader({ name: 'x-branch-id', description: 'Personelin Yetkili Olduğu Şube ID', example: '1' })
  getBranchOrders(@Param('branchId', ParseIntPipe) branchId: number) {
    return this.ordersService.getBranchOrders(branchId);
  }

  @Patch('orders/:orderId/status')
  @UseGuards(BranchAccessGuard)
  @ApiOperation({ summary: 'Sipariş durumunu günceller (Accepted, Preparing, Ready, Delivered)' })
  @ApiHeader({ name: 'x-user-role', description: 'Kullanıcı Rolü (BRANCH_STAFF veya ADMIN)', example: 'BRANCH_STAFF' })
  @ApiHeader({ name: 'x-branch-id', description: 'Personelin Yetkili Olduğu Şube ID', example: '1' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        branchId: { type: 'number', example: 1 },
        status: { type: 'string', example: 'Preparing' },
      },
    },
  })
  updateStatus(
    @Param('orderId', ParseIntPipe) orderId: number,
    @Body() body: { branchId: number; status: string },
  ) {
    return this.ordersService.updateStatus(orderId, body.status);
  }
}
