import { Controller, Get, Post, Body } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBody } from '@nestjs/swagger';
import { CampaignsService } from './campaigns.service';

@ApiTags('Campaigns (Kampanya ve Kupon Motoru)')
@Controller('campaigns')
export class CampaignsController {
  constructor(private readonly campaignsService: CampaignsService) {}

  @Get()
  @ApiOperation({ summary: 'Aktif kampanyaları öncelik sırasına göre listeler' })
  getActiveCampaigns() {
    return this.campaignsService.getActiveCampaigns();
  }

  @Post('evaluate')
  @ApiOperation({ summary: 'Sepet tutarına göre çakışma kurallarını işletip indirimi hesaplar' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        cartTotal: { type: 'number', example: 250 },
        couponCode: { type: 'string', example: 'WELCOME20' },
      },
    },
  })
  evaluateCart(@Body() body: { cartTotal: number; couponCode?: string }) {
    return this.campaignsService.evaluateCart(body.cartTotal, body.couponCode);
  }
}
