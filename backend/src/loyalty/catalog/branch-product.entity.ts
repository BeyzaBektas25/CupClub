import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm';
import { Product } from './product.entity';

@Entity('BranchProducts')
export class BranchProduct {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  branch_id: number;

  @Column()
  product_id: number;

  @ManyToOne(() => Product)
  @JoinColumn({ name: 'product_id' })
  product: Product;

  @Column({ default: true })
  is_in_stock: boolean;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  price: number;
}
