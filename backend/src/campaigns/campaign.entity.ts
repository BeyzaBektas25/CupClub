import { Entity, PrimaryGeneratedColumn, Column, OneToMany, ManyToOne, JoinColumn } from 'typeorm';

@Entity('Campaigns')
export class Campaign {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 150 })
  title: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ length: 50 })
  campaign_type: string; // 'PERCENTAGE' | 'FIXED_AMOUNT' | 'BUNDLE' | 'FREE_PRODUCT' | 'FIRST_ORDER'

  @Column({ default: 0 })
  priority: number;

  @Column({ default: false })
  can_combine: boolean;

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  min_cart_amount: number;

  @Column({ type: 'timestamp' })
  start_date: Date;

  @Column({ type: 'timestamp' })
  end_date: Date;

  @Column({ default: true })
  is_active: boolean;

  @OneToMany(() => CampaignRule, (rule) => rule.campaign)
  rules: CampaignRule[];
}

@Entity('CampaignRules')
export class CampaignRule {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  campaign_id: number;

  @ManyToOne(() => Campaign, (campaign) => campaign.rules)
  @JoinColumn({ name: 'campaign_id' })
  campaign: Campaign;

  @Column({ length: 50 })
  rule_type: string;

  @Column({ length: 255 })
  rule_value: string;
}

@Entity('Coupons')
export class Coupon {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  campaign_id: number;

  @ManyToOne(() => Campaign)
  @JoinColumn({ name: 'campaign_id' })
  campaign: Campaign;

  @Column({ length: 20, unique: true })
  coupon_code: string;

  @Column({ default: 1 })
  usage_limit: number;

  @Column({ default: 0 })
  used_count: number;

  @Column({ default: true })
  is_active: boolean;
}
