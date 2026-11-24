import {
  Controller,
  Post,
  Get,
  Patch,
  Body,
  Param,
  ParseIntPipe,
  UseGuards,
  Req,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBody,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { OrdersService } from './orders.service';
import { BranchAccessGuard } from '../auth/branch-access.guard';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@ApiTags('Orders (Sipariş Yönetimi)')
@Controller()
export class OrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @Post('orders')
  @ApiOperation({
    summary: 'Müşteri sepetinden sunucu fiyat kontrolüyle sipariş oluşturur',
  })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        userId: { type: 'number', example: 1 },
        branchId: { type: 'number', example: 1 },
        items: {
          type: 'array',
          items: {
            type: 'object',
            properties: {
              productId: { type: 'number', example: 1 },
              quantity: { type: 'number', example: 2 },
              optionIds: {
                type: 'array',
                items: { type: 'number' },
                example: [1, 3],
              },
            },
            required: ['productId', 'quantity'],
          },
        },
      },
      required: ['userId', 'branchId', 'items'],
    },
  })
  createOrder(
    @Body()
    body: {
      userId: number;
      branchId: number;
      items: {
  productId: number;
  quantity: number;
  optionIds?: number[];
}[];
    },
  ) {
    return this.ordersService.createOrder(body);
  }

  @Get('branches/:branchId/orders')
  @UseGuards(JwtAuthGuard, BranchAccessGuard)
  @ApiBearerAuth()
  @ApiOperation({
    summary: 'Yetkili olduğu şubenin siparişlerini listeler',
  })
  getBranchOrders(
    @Param('branchId', ParseIntPipe) branchId: number,
  ) {
    return this.ordersService.getBranchOrders(branchId);
  }

  @Patch('orders/:orderId/status')
  @UseGuards(JwtAuthGuard, BranchAccessGuard)
  @ApiBearerAuth()
  @ApiOperation({
    summary: 'Sipariş durumunu günceller (Accepted, Preparing, Ready, Delivered)',
  })
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
  @Req() request: any,
) {
  return this.ordersService.updateStatus(
    orderId,
    body.status,
    request.user,
  );
}
}
