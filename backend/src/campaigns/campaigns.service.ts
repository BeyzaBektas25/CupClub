import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThanOrEqual, MoreThanOrEqual } from 'typeorm';
import { Campaign, Coupon } from './campaign.entity';

@Injectable()
export class CampaignsService {
  constructor(
    @InjectRepository(Campaign) private campaignRepo: Repository<Campaign>,
    @InjectRepository(Coupon) private couponRepo: Repository<Coupon>,
  ) {}

  // Aktif kampanyaları öncelik sırasına göre getirir
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

  // Sepet tutarına ve kupona göre uygulanacak en yüksek öncelikli kampanyayı hesaplar
  async evaluateCart(cartTotal: number, couponCode?: string) {
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
      // Çakışma kontrolü: En yüksek öncelikli uygun kampanyayı seç
      selectedCampaign = activeCampaigns.find((c) => Number(cartTotal) >= Number(c.min_cart_amount)) || null;
    }

    if (!selectedCampaign || Number(cartTotal) < Number(selectedCampaign.min_cart_amount)) {
      return { appliedCampaign: null, discountAmount: 0, finalAmount: cartTotal };
    }

    let discountAmount = 0;
    const rule = selectedCampaign.rules?.[0];

    if (rule?.rule_type === 'DISCOUNT_PERCENT') {
      discountAmount = (cartTotal * Number(rule.rule_value)) / 100;
    } else if (rule?.rule_type === 'DISCOUNT_FIXED') {
      discountAmount = Number(rule.rule_value);
    }

    const finalAmount = Math.max(0, cartTotal - discountAmount);
    return {
      appliedCampaign: selectedCampaign.title,
      priority: selectedCampaign.priority,
      canCombine: selectedCampaign.can_combine,
      discountAmount,
      finalAmount,
    };
  }
}
