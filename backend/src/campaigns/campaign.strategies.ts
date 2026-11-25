export interface CampaignContext {
  cartTotal: number;
  isFirstOrder?: boolean;
  itemCount?: number;
  cheapestItemPrice?: number;
}

export interface CampaignStrategy {
  readonly type: string;
  calculateDiscount(ruleValue: number, context: CampaignContext): number;
}

// 1. Yüzdesel İndirim Stratejisi (Örn: %20 indirim)
export class PercentageDiscountStrategy implements CampaignStrategy {
  readonly type = 'DISCOUNT_PERCENT';
  calculateDiscount(ruleValue: number, context: CampaignContext): number {
    return (context.cartTotal * ruleValue) / 100;
  }
}

// 2. Sabit Tutar İndirim Stratejisi (Örn: 40 TL indirim)
export class FixedAmountStrategy implements CampaignStrategy {
  readonly type = 'DISCOUNT_FIXED';
  calculateDiscount(ruleValue: number, context: CampaignContext): number {
    return Math.min(context.cartTotal, ruleValue);
  }
}

// 3. Kombin (Çoklu Ürün) İndirim Stratejisi (Örn: En az 2 üründe sabit indirim)
export class ComboDiscountStrategy implements CampaignStrategy {
  readonly type = 'COMBO_DISCOUNT';
  calculateDiscount(ruleValue: number, context: CampaignContext): number {
    if ((context.itemCount ?? 1) < 2) return 0;
    return Math.min(context.cartTotal, ruleValue);
  }
}

// 4. Hediye Ürün Stratejisi (Örn: Sepetteki en ucuz ürünü ücretsiz yapar)
export class FreeItemStrategy implements CampaignStrategy {
  readonly type = 'FREE_ITEM';
  calculateDiscount(ruleValue: number, context: CampaignContext): number {
    if ((context.itemCount ?? 1) < 2) return 0;
    return context.cheapestItemPrice ?? ruleValue;
  }
}

// 5. İlk Sipariş İndirim Stratejisi
export class FirstOrderStrategy implements CampaignStrategy {
  readonly type = 'FIRST_ORDER';
  calculateDiscount(ruleValue: number, context: CampaignContext): number {
    if (!context.isFirstOrder) return 0;
    return (context.cartTotal * ruleValue) / 100;
  }
}

// Strategy Kayıt Defteri (Yeni strateji eklendiğinde Open/Closed prensibine uyar)
export class CampaignStrategyFactory {
  private static readonly strategies: Record<string, CampaignStrategy> = {
    DISCOUNT_PERCENT: new PercentageDiscountStrategy(),
    DISCOUNT_FIXED: new FixedAmountStrategy(),
    COMBO_DISCOUNT: new ComboDiscountStrategy(),
    FREE_ITEM: new FreeItemStrategy(),
    FIRST_ORDER: new FirstOrderStrategy(),
  };

  static getStrategy(ruleType?: string): CampaignStrategy | null {
    if (!ruleType) return null;
    return this.strategies[ruleType] ?? null;
  }
}
