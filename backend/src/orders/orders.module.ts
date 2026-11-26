
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Order } from './order.entity';
import { OrderItem } from './order-item.entity';
import { OrderItemOption } from './order-item-option.entity';
import { CouponRedemption } from './coupon-redemption.entity';

import { BranchProduct } from '../catalog/branch-product.entity';
import { ProductOptionGroup } from '../catalog/product-option-group.entity';
import { BranchOptionPrice } from '../catalog/branch-option-price.entity';

import { Campaign, CampaignRule, Coupon } from '../campaigns/campaign.entity';
import { LoyaltyModule } from '../loyalty/loyalty.module';

import { OrdersService } from './orders.service';
import { OrdersController } from './orders.controller';
import { OrdersGateway } from './orders.gateway';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Order,
      OrderItem,
      OrderItemOption,
      CouponRedemption,
      BranchProduct,
      ProductOptionGroup,
      BranchOptionPrice,
      Campaign,
      CampaignRule,
      Coupon,
    ]),
    LoyaltyModule,
  ],
  controllers: [OrdersController],
  providers: [OrdersService, OrdersGateway],
})
export class OrdersModule {}
