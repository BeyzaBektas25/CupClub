
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  Index,
} from 'typeorm';

@Entity('CouponRedemptions')
@Index(
  'idx_unique_coupon_user',
  ['coupon_id', 'user_id'],
  { unique: true },
)
export class CouponRedemption {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  coupon_id: number;

  @Column()
  order_id: number;

  @Column()
  user_id: number;

  @Column({
    type: 'timestamp',
    default: () => 'CURRENT_TIMESTAMP',
  })
  redeemed_at: Date;
}
