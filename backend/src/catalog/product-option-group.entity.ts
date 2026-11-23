import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';

import { Product } from './product.entity';
import { ProductOption } from './product-option.entity';

@Entity('ProductOptionGroups')
export class ProductOptionGroup {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  product_id: number;

  @Column({ length: 50 })
  name: string;

  @Column({ default: false })
  is_required: boolean;

  @Column({ default: 1 })
  min_selectable: number;

  @Column({ default: 1 })
  max_selectable: number;

  @ManyToOne(() => Product, (product) => product.optionGroups)
  @JoinColumn({ name: 'product_id' })
  product: Product;

  @OneToMany(() => ProductOption, (option) => option.group)
  options: ProductOption[];
}