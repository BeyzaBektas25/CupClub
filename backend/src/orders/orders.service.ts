import {
  Injectable,
  BadRequestException,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Order } from './order.entity';
import { OrderItem } from './order-item.entity';
import { OrderItemOption } from './order-item-option.entity';

import { BranchProduct } from '../catalog/branch-product.entity';
import { ProductOptionGroup } from '../catalog/product-option-group.entity';
import { BranchOptionPrice } from '../catalog/branch-option-price.entity';

import { OrdersGateway } from './orders.gateway';

interface OrderItemInput {
  productId: number;
  quantity: number;
  optionIds?: number[];
}

interface CreateOrderInput {
  userId: number;
  branchId: number;
  items: OrderItemInput[];
}

@Injectable()
export class OrdersService {
  constructor(
    @InjectRepository(Order)
    private orderRepo: Repository<Order>,

    @InjectRepository(OrderItem)
    private orderItemRepo: Repository<OrderItem>,

    @InjectRepository(OrderItemOption)
    private orderItemOptionRepo: Repository<OrderItemOption>,

    @InjectRepository(BranchProduct)
    private branchProductRepo: Repository<BranchProduct>,

    @InjectRepository(ProductOptionGroup)
    private optionGroupRepo: Repository<ProductOptionGroup>,

    @InjectRepository(BranchOptionPrice)
    private branchOptionPriceRepo: Repository<BranchOptionPrice>,

    private ordersGateway: OrdersGateway,
  ) {}

  async createOrder(data: CreateOrderInput) {
    if (
      !Number.isInteger(data.userId) ||
      data.userId <= 0 ||
      !Number.isInteger(data.branchId) ||
      data.branchId <= 0
    ) {
      throw new BadRequestException('Geçersiz kullanıcı veya şube bilgisi.');
    }

    if (!Array.isArray(data.items) || data.items.length === 0) {
      throw new BadRequestException('Sipariş sepeti boş olamaz.');
    }

    let totalAmount = 0;
    const orderItems: OrderItem[] = [];
    const optionsToSave: {
      itemIndex: number;
      options: OrderItemOption[];
    }[] = [];

    for (const item of data.items) {
      if (
        !Number.isInteger(item.productId) ||
        item.productId <= 0 ||
        !Number.isInteger(item.quantity) ||
        item.quantity <= 0
      ) {
        throw new BadRequestException('Geçersiz ürün veya adet bilgisi.');
      }

      const selectedOptionIds = item.optionIds ?? [];

      if (
        !Array.isArray(selectedOptionIds) ||
        selectedOptionIds.some(
          (id) => !Number.isInteger(id) || id <= 0,
        ) ||
        new Set(selectedOptionIds).size !== selectedOptionIds.length
      ) {
        throw new BadRequestException('Geçersiz ürün seçenekleri.');
      }

      const branchProduct = await this.branchProductRepo.findOne({
        where: {
          branch_id: data.branchId,
          product_id: item.productId,
        },
      });

      if (!branchProduct || !branchProduct.is_in_stock) {
        throw new BadRequestException(
          `Ürün (ID: ${item.productId}) bu şubede mevcut değil veya stokta yok.`,
        );
      }

      const groups = await this.optionGroupRepo.find({
        where: { product_id: item.productId },
        relations: { options: true },
      });

      const availableOptions = groups.flatMap(
        (group) => group.options ?? [],
      );

      const selectedOptions = selectedOptionIds.map((optionId) => {
        const option = availableOptions.find(
          (availableOption) => availableOption.id === optionId,
        );

        if (!option) {
          throw new BadRequestException(
            `Seçenek (ID: ${optionId}) bu ürüne ait değil.`,
          );
        }

        return option;
      });

      for (const group of groups) {
        const selectedCount = selectedOptions.filter(
          (option) => option.group_id === group.id,
        ).length;

        if (
          selectedCount < group.min_selectable ||
          selectedCount > group.max_selectable
        ) {
          throw new BadRequestException(
            `${group.name} grubu için seçim sayısı geçersiz.`,
          );
        }
      }

      let optionsTotal = 0;
      const orderItemOptions: OrderItemOption[] = [];

      for (const option of selectedOptions) {
        const branchOptionPrice =
          await this.branchOptionPriceRepo.findOne({
            where: {
              branch_id: data.branchId,
              option_id: option.id,
            },
          });

        const additionalPrice =
          branchOptionPrice?.additional_price != null
            ? Number(branchOptionPrice.additional_price)
            : Number(option.base_additional_price);

        optionsTotal += additionalPrice;

        const orderItemOption = new OrderItemOption();
        orderItemOption.option_id = option.id;
        orderItemOption.additional_price = additionalPrice;

        orderItemOptions.push(orderItemOption);
      }

      const basePrice = Number(branchProduct.price);
      const unitPrice = basePrice + optionsTotal;

      const orderItem = new OrderItem();
      orderItem.product_id = item.productId;
      orderItem.quantity = item.quantity;
      orderItem.unit_price = unitPrice;

      orderItems.push(orderItem);

      if (orderItemOptions.length > 0) {
        optionsToSave.push({
          itemIndex: orderItems.length - 1,
          options: orderItemOptions,
        });
      }

      totalAmount += unitPrice * item.quantity;
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

    // Önce sipariş ve ürün satırlarını kaydet.
    const savedOrder = await this.orderRepo.save(order);

    // Sonra seçenekleri ürün satırlarının ID'leriyle kaydet.
    for (const entry of optionsToSave) {
      const savedItem = savedOrder.items[entry.itemIndex];

      if (!savedItem?.id) {
        throw new Error('Sipariş ürün satırı kaydedilemedi.');
      }

      for (const option of entry.options) {
        option.order_item_id = savedItem.id;
      }

      await this.orderItemOptionRepo.save(entry.options);
    }

    return this.orderRepo.findOne({
      where: { id: savedOrder.id },
      relations: {
        items: {
          options: true,
          product: true,
        },
      },
    });
  }

  getBranchOrders(branchId: number) {
  return this.orderRepo.find({
    where: { branch_id: branchId },
    relations: {
      items: {
        options: true,
        product: true,
      },
    },
    order: { created_at: 'DESC' },
  });
}

  async updateStatus(
    orderId: number,
    status: string,
    user: { roles: string[]; branchId: number | null },
  ) {
    const order = await this.orderRepo.findOne({
      where: { id: orderId },
    });

    if (!order) {
      throw new NotFoundException('Sipariş bulunamadı.');
    }

    const isCentralAdmin = user.roles.includes('CENTRAL_ADMIN');
    const isBranchStaff = user.roles.includes('BRANCH_STAFF');

    if (
      !isCentralAdmin &&
      (!isBranchStaff ||
        !user.branchId ||
        Number(user.branchId) !== Number(order.branch_id))
    ) {
      throw new ForbiddenException(
        'Bu sipariş üzerinde işlem yapma yetkiniz bulunmuyor.',
      );
    }

    order.status = status;

    const saved = await this.orderRepo.save(order);

    this.ordersGateway.notifyOrderStatusChanged(
      saved.id,
      saved.branch_id,
      saved.status,
    );

    return saved;
  }
}
