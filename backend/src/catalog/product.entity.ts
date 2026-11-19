import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';

import { Category } from './category.entity';
import { ProductOptionGroup } from './product-option-group.entity';

@Entity('Products')
export class Product {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  category_id: number;

  @ManyToOne(() => Category)
  @JoinColumn({ name: 'category_id' })
  category: Category;

  @Column({ length: 100 })
  name: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ length: 255, nullable: true })
  image_url: string;

  @Column({ type: 'text', nullable: true })
  allergens: string;

  @Column({ default: true })
  is_active: boolean;

  @OneToMany(
    () => ProductOptionGroup,
    (group) => group.product,
  )
  optionGroups: ProductOptionGroup[];
}