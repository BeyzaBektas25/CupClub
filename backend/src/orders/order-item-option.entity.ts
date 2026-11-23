import {
  Entity,
  PrimaryColumn,
  Column,
  ManyToOne,
  JoinColumn,
} from 'typeorm';

import { OrderItem } from './order-item.entity';

@Entity('OrderItemOptions')
export class OrderItemOption {
  @PrimaryColumn()
  order_item_id: number;

  @PrimaryColumn()
  option_id: number;

  @Column({
    type: 'decimal',
    precision: 10,
    scale: 2,
    nullable: true,
  })
  additional_price: number;

  @ManyToOne(
    () => OrderItem,
    (orderItem) => orderItem.options,
    { onDelete: 'CASCADE' },
  )
  @JoinColumn({ name: 'order_item_id' })
  orderItem: OrderItem;
}