import {
  Entity,
  PrimaryColumn,
  Column,
  ManyToOne,
  JoinColumn,
} from 'typeorm';

import { ProductOption } from './product-option.entity';

@Entity('BranchOptionPrices')
export class BranchOptionPrice {
  @PrimaryColumn()
  branch_id: number;

  @PrimaryColumn()
  option_id: number;

  @Column({
    type: 'decimal',
    precision: 10,
    scale: 2,
    nullable: true,
  })
  additional_price: number;

  @ManyToOne(() => ProductOption)
  @JoinColumn({ name: 'option_id' })
  option: ProductOption;
}