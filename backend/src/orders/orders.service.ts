import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Order } from './order.entity';
import { OrderItem } from './order-item.entity';
import { BranchProduct } from '../catalog/branch-product.entity';
import { OrdersGateway } from './orders.gateway';

@Injectable()
export class OrdersService {
  constructor(
    @InjectRepository(Order) private orderRepo: Repository<Order>,
    @InjectRepository(BranchProduct) private branchProductRepo: Repository<BranchProduct>,
    private ordersGateway: OrdersGateway,
  ) {}

  async createOrder(data: { userId: number; branchId: number; items: { productId: number; quantity: number }[] }) {
    let totalAmount = 0;
    const orderItems: OrderItem[] = [];

    for (const item of data.items) {
      const bp = await this.branchProductRepo.findOne({
        where: { branch_id: data.branchId, product_id: item.productId },
      });

      if (!bp || !bp.is_in_stock) {
        throw new BadRequestException(`Ürün (ID: ${item.productId}) bu şubede mevcut değil veya stokta yok.`);
      }

      const unitPrice = Number(bp.price);
      totalAmount += unitPrice * item.quantity;

      const orderItem = new OrderItem();
      orderItem.product_id = item.productId;
      orderItem.quantity = item.quantity;
      orderItem.unit_price = unitPrice;
      orderItems.push(orderItem);
    }

    const order = this.orderRepo.create({
      order_number: 'CC-' + Date.now().toString().slice(-6),
      user_id: data.userId,
      branch_id: data.branchId,
      total_amount: totalAmount,
      discount_amount: 0,
      final_amount: totalAmount,
      status: 'Pending',
      items: orderItems,
    });

    return this.orderRepo.save(order);
  }

  getBranchOrders(branchId: number) {
    return this.orderRepo.find({
      where: { branch_id: branchId },
      relations: { items: true },
      order: { created_at: 'DESC' },
    });
  }

  async updateStatus(orderId: number, status: string) {
    const order = await this.orderRepo.findOne({ where: { id: orderId } });
    if (!order) throw new NotFoundException('Sipariş bulunamadı.');
    order.status = status;
    const saved = await this.orderRepo.save(order);
    this.ordersGateway.notifyOrderStatusChanged(saved.id, saved.branch_id, saved.status);
    return saved;
  }
}
