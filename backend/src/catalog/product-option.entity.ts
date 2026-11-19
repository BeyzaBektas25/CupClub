import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
} from 'typeorm';

import { ProductOptionGroup } from './product-option-group.entity';

@Entity('ProductOptions')
export class ProductOption {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  group_id: number;

  @Column({ length: 50 })
  name: string;

  @Column({
    type: 'decimal',
    precision: 10,
    scale: 2,
    default: 0,
  })
  base_additional_price: number;

  @ManyToOne(() => ProductOptionGroup, (group) => group.options)
  @JoinColumn({ name: 'group_id' })
  group: ProductOptionGroup;
}