
import {
  Controller,
  Post,
  Get,
  Patch,
  Body,
  Param,
  ParseIntPipe,
  UseGuards,
} from '@nestjs/common';

import {
  ApiTags,
  ApiOperation,
  ApiBody,
  ApiBearerAuth,
} from '@nestjs/swagger';

import { OrdersService } from './orders.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { BranchAccessGuard } from '../auth/branch-access.guard';

@ApiTags('Orders (Sipariş Yönetimi)')
@Controller()
export class OrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @Post('orders')
  @ApiOperation({
    summary: 'Müşteri sepetinden sipariş oluşturur',
  })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        userId: { type: 'number', example: 1 },
        branchId: { type: 'number', example: 1 },
        couponCode: { type: 'string', example: 'WELCOME20' },
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
      couponCode?: string;
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
    summary: 'Yetkili şubenin siparişlerini listeler',
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
    summary: 'Sipariş durumunu günceller',
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
  ) {
    return this.ordersService.updateStatus(orderId, body.status);
  }
}
