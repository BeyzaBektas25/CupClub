import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, OneToMany } from 'typeorm';
import { OrderItem } from './order-item.entity';

@Entity('Orders')
export class Order {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 20, unique: true })
  order_number: string;

  @Column()
  user_id: number;

  @Column()
  branch_id: number;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  total_amount: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  discount_amount: number;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  final_amount: number;

  @Column({ length: 30, default: 'Pending' })
  status: string;

  @CreateDateColumn()
  created_at: Date;

  @OneToMany(() => OrderItem, (item) => item.order, { cascade: true })
  items: OrderItem[];
}
