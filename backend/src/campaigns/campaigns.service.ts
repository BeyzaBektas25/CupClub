import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThanOrEqual, MoreThanOrEqual } from 'typeorm';
import { Campaign, Coupon } from './campaign.entity';
import { CampaignStrategyFactory, CampaignContext } from './campaign.strategies';

@Injectable()
export class CampaignsService {
  constructor(
    @InjectRepository(Campaign) private campaignRepo: Repository<Campaign>,
    @InjectRepository(Coupon) private couponRepo: Repository<Coupon>,
  ) {}

  getActiveCampaigns() {
    const now = new Date();
    return this.campaignRepo.find({
      where: {
        is_active: true,
        start_date: LessThanOrEqual(now),
        end_date: MoreThanOrEqual(now),
      },
      relations: { rules: true },
      order: { priority: 'DESC' },
    });
  }

  async evaluateCart(
    cartTotal: number,
    couponCode?: string,
    extraContext?: Omit<CampaignContext, 'cartTotal'>,
  ) {
    const activeCampaigns = await this.getActiveCampaigns();
    let selectedCampaign: Campaign | null = null;

    if (couponCode) {
      const coupon = await this.couponRepo.findOne({
        where: { coupon_code: couponCode, is_active: true },
        relations: { campaign: { rules: true } },
      });
      if (!coupon || coupon.used_count >= coupon.usage_limit) {
        throw new BadRequestException('Geçersiz veya kullanım limiti dolmuş kupon kodu.');
      }
      selectedCampaign = coupon.campaign;
    } else {
      // Çakışma kontrolü: En yüksek öncelikli (priority DESC) uygun kampanyayı seç
      selectedCampaign =
        activeCampaigns.find((c) => Number(cartTotal) >= Number(c.min_cart_amount)) || null;
    }

    if (!selectedCampaign || Number(cartTotal) < Number(selectedCampaign.min_cart_amount)) {
      return { appliedCampaign: null, discountAmount: 0, finalAmount: cartTotal };
    }

    const rule = selectedCampaign.rules?.[0];
    const strategy = CampaignStrategyFactory.getStrategy(rule?.rule_type);

    const discountAmount = strategy
      ? strategy.calculateDiscount(Number(rule.rule_value), {
          cartTotal,
          ...extraContext,
        })
      : 0;

    const finalAmount = Math.max(0, cartTotal - discountAmount);
    return {
      appliedCampaign: selectedCampaign.title,
      strategyUsed: rule?.rule_type ?? 'NONE',
      priority: selectedCampaign.priority,
      canCombine: selectedCampaign.can_combine,
      discountAmount,
      finalAmount,
    };
  }
}
