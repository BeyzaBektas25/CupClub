import { Controller, Get, Post, Body, Param, ParseIntPipe } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBody } from '@nestjs/swagger';
import { LoyaltyService } from './loyalty.service';

@ApiTags('Loyalty (Sadakat ve QR Ödül Sistemi)')
@Controller('loyalty')
export class LoyaltyController {
  constructor(private readonly loyaltyService: LoyaltyService) {}

  @Get(':userId')
  @ApiOperation({ summary: 'Müşterinin puan, damga bakiyesini ve hareket geçmişini getirir' })
  getAccount(@Param('userId', ParseIntPipe) userId: number) {
    return this.loyaltyService.getOrCreateAccount(userId);
  }

  @Post('earn')
  @ApiOperation({ summary: 'Sipariş tutarına göre puan ve damga ekler' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        userId: { type: 'number', example: 1 },
        orderId: { type: 'number', example: 1 },
        orderAmount: { type: 'number', example: 220 },
      },
    },
  })
  earn(@Body() body: { userId: number; orderId: number; orderAmount: number }) {
    return this.loyaltyService.earnFromOrder(body.userId, body.orderId, body.orderAmount);
  }

  @Post('reverse')
  @ApiOperation({ summary: 'İptal edilen siparişin puanını ters hareketle geri alır' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        userId: { type: 'number', example: 1 },
        orderId: { type: 'number', example: 1 },
      },
    },
  })
  reverse(@Body() body: { userId: number; orderId: number }) {
    return this.loyaltyService.reverseOrder(body.userId, body.orderId);
  }

  @Post('qr/generate/:userId')
  @ApiOperation({ summary: 'Müşteri için tek kullanımlık QR ödül kodu üretir' })
  generateQR(@Param('userId', ParseIntPipe) userId: number) {
    return this.loyaltyService.generateRewardQR(userId);
  }

  @Post('qr/consume')
  @ApiOperation({ summary: 'Şube personelinin QR kodu okutup tüketmesini sağlar' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: { qrToken: { type: 'string', example: 'QR-1-170000000' } },
    },
  })
  consumeQR(@Body('qrToken') qrToken: string) {
    return this.loyaltyService.consumeRewardQR(qrToken);
  }
}
