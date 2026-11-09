import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Order } from '../orders/order.entity';

@Injectable()
export class ReportsService {
  constructor(
    @InjectRepository(Order) private orderRepo: Repository<Order>,
  ) {}

  async getBranchSalesSummary() {
    return this.orderRepo
      .createQueryBuilder('order')
      .select('order.branch_id', 'branchId')
      .addSelect('COUNT(order.id)', 'totalOrders')
      .addSelect('COALESCE(SUM(order.final_amount), 0)', 'totalRevenue')
      .groupBy('order.branch_id')
      .getRawMany();
  }
}
