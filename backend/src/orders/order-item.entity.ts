import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';

import { Order } from './order.entity';
import { OrderItemOption } from './order-item-option.entity';

@Entity('OrderItems')
export class OrderItem {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  order_id: number;

  @ManyToOne(() => Order, (order) => order.items)
  @JoinColumn({ name: 'order_id' })
  order: Order;

  @Column()
  product_id: number;

  @Column()
  quantity: number;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  unit_price: number;

  @OneToMany(
    () => OrderItemOption,
    (option) => option.orderItem,
    { cascade: true },
  )
  options: OrderItemOption[];
}