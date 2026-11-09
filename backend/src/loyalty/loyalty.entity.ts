import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('LoyaltyAccounts')
export class LoyaltyAccount {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  user_id: number;

  @Column({ default: 0 })
  total_points: number;

  @Column({ default: 0 })
  current_stamps: number;

  @UpdateDateColumn()
  updated_at: Date;
}

@Entity('LoyaltyTransactions')
export class LoyaltyTransaction {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  loyalty_account_id: number;

  @Column({ nullable: true })
  order_id: number;

  @Column({ length: 30 })
  transaction_type: string; // 'EARN' | 'REDEEM' | 'REVERSAL'

  @Column({ default: 0 })
  points_changed: number;

  @Column({ default: 0 })
  stamps_changed: number;

  @CreateDateColumn()
  created_at: Date;
}

@Entity('RewardQRs')
export class RewardQR {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  user_id: number;

  @Column({ length: 50 })
  reward_type: string; // Örn: 'FREE_COFFEE'

  @Column({ length: 100, unique: true })
  qr_code_token: string;

  @Column({ default: false })
  is_used: boolean;

  @Column({ type: 'timestamp' })
  expires_at: Date;

  @CreateDateColumn()
  created_at: Date;
}
