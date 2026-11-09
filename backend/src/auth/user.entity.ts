import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('Users')
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 50 })
  first_name: string;

  @Column({ length: 50 })
  last_name: string;

  @Column({ length: 100, unique: true })
  email: string;

  @Column({ length: 20, unique: true, nullable: true })
  phone: string;

  @Column({ length: 255 })
  password_hash: string;

  @CreateDateColumn()
  created_at: Date;
}
