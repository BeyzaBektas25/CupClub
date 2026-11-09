import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity('Branches')
export class Branch {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 100 })
  name: string;

  @Column({ type: 'text', nullable: true })
  address: string;

  @Column({ type: 'decimal', precision: 10, scale: 8, nullable: true })
  latitude: number;

  @Column({ type: 'decimal', precision: 11, scale: 8, nullable: true })
  longitude: number;

  @Column({ length: 100, nullable: true })
  working_hours: string;

  @Column({ default: true })
  is_active: boolean;
}
