
import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';

import { DataSource } from 'typeorm';

import { Order } from './order.entity';
import { OrderItem } from './order-item.entity';
import { OrderItemOption } from './order-item-option.entity';
import { CouponRedemption } from './coupon-redemption.entity';

import { BranchProduct } from '../catalog/branch-product.entity';
import { ProductOptionGroup } from '../catalog/product-option-group.entity';
import { BranchOptionPrice } from '../catalog/branch-option-price.entity';

import { Coupon } from '../campaigns/campaign.entity';
import { LoyaltyService } from '../loyalty/loyalty.service';

import { OrdersGateway } from './orders.gateway';

interface OrderItemInput {
  productId: number;
  quantity: number;
  optionIds?: number[];
}

interface CreateOrderInput {
  userId: number;
  branchId: number;
  couponCode?: string;
  items: OrderItemInput[];
}

@Injectable()
export class OrdersService {
  constructor(
    private readonly dataSource: DataSource,
    private readonly ordersGateway: OrdersGateway,
    private readonly loyaltyService: LoyaltyService,
  ) {}

  async createOrder(data: CreateOrderInput) {
    if (
      !Number.isInteger(data.userId) ||
      data.userId <= 0 ||
      !Number.isInteger(data.branchId) ||
      data.branchId <= 0
    ) {
      throw new BadRequestException(
        'Geçersiz kullanıcı veya şube bilgisi.',
      );
    }

    if (!Array.isArray(data.items) || data.items.length === 0) {
      throw new BadRequestException('Sipariş sepeti boş olamaz.');
    }

    return this.dataSource.transaction(async (manager) => {
      const orderRepo = manager.getRepository(Order);
      const orderItemOptionRepo =
        manager.getRepository(OrderItemOption);
      const branchProductRepo =
        manager.getRepository(BranchProduct);
      const optionGroupRepo =
        manager.getRepository(ProductOptionGroup);
      const branchOptionPriceRepo =
        manager.getRepository(BranchOptionPrice);
      const couponRepo = manager.getRepository(Coupon);
      const couponRedemptionRepo =
        manager.getRepository(CouponRedemption);

      let totalAmount = 0;

      const orderItems: OrderItem[] = [];

      const optionsToSave: {
        itemIndex: number;
        options: OrderItemOption[];
      }[] = [];

      // Ürün ve seçenek fiyatlarını backend üzerinden hesapla.
      for (const item of data.items) {
        if (
          !Number.isInteger(item.productId) ||
          item.productId <= 0 ||
          !Number.isInteger(item.quantity) ||
          item.quantity <= 0
        ) {
          throw new BadRequestException(
            'Geçersiz ürün veya adet bilgisi.',
          );
        }

        const selectedOptionIds = item.optionIds ?? [];

        if (
          !Array.isArray(selectedOptionIds) ||
          selectedOptionIds.some(
            (id) => !Number.isInteger(id) || id <= 0,
          ) ||
          new Set(selectedOptionIds).size !==
            selectedOptionIds.length
        ) {
          throw new BadRequestException(
            'Geçersiz ürün seçenekleri.',
          );
        }

        const branchProduct = await branchProductRepo.findOne({
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

        const groups = await optionGroupRepo.find({
          where: { product_id: item.productId },
          relations: { options: true },
        });

        const availableOptions = groups.flatMap(
          (group) => group.options ?? [],
        );

        const selectedOptions = selectedOptionIds.map(
          (optionId) => {
            const option = availableOptions.find(
              (availableOption) =>
                availableOption.id === optionId,
            );

            if (!option) {
              throw new BadRequestException(
                `Seçenek (ID: ${optionId}) bu ürüne ait değil.`,
              );
            }

            return option;
          },
        );

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
            await branchOptionPriceRepo.findOne({
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

      totalAmount = this.roundMoney(totalAmount);

      // Kupon varsa veritabanında kilitleyerek yeniden doğrula.
      let discountAmount = 0;
      let selectedCoupon: Coupon | null = null;

      const normalizedCouponCode =
        data.couponCode?.trim().toUpperCase();

      if (normalizedCouponCode) {
        selectedCoupon = await couponRepo
          .createQueryBuilder('coupon')
          .setLock('pessimistic_write', undefined, ['coupon'])
          .leftJoinAndSelect('coupon.campaign', 'campaign')
          .leftJoinAndSelect('campaign.rules', 'rules')
          .where(
            'LOWER(coupon.coupon_code) = LOWER(:couponCode)',
            { couponCode: normalizedCouponCode },
          )
          .getOne();

        if (
          !selectedCoupon ||
          !selectedCoupon.is_active ||
          selectedCoupon.used_count >=
            selectedCoupon.usage_limit
        ) {
          throw new BadRequestException(
            'Geçersiz veya kullanım limiti dolmuş kupon kodu.',
          );
        }

        // Aynı kullanıcı aynı kuponu tekrar kullanamaz.
        const existingRedemption =
          await couponRedemptionRepo.findOne({
            where: {
              coupon_id: selectedCoupon.id,
              user_id: data.userId,
            },
          });

        if (existingRedemption) {
          throw new BadRequestException(
            'Bu kuponu daha önce kullandınız.',
          );
        }

        const campaign = selectedCoupon.campaign;
        const now = new Date();

        if (
          !campaign ||
          !campaign.is_active ||
          now < new Date(campaign.start_date) ||
          now > new Date(campaign.end_date)
        ) {
          throw new BadRequestException(
            'Bu kuponun bağlı olduğu kampanya aktif değil.',
          );
        }

        if (
          totalAmount < Number(campaign.min_cart_amount)
        ) {
          throw new BadRequestException(
            `Bu kuponu kullanmak için sepet tutarı en az ${Number(campaign.min_cart_amount)} TL olmalıdır.`,
          );
        }

        const rule = campaign.rules?.[0];

        if (!rule) {
          throw new BadRequestException(
            'Kupon kampanyasının indirim kuralı tanımlanmamış.',
          );
        }

        const ruleValue = Number(rule.rule_value);

        if (!Number.isFinite(ruleValue) || ruleValue < 0) {
          throw new BadRequestException(
            'Kampanya indirim kuralı geçersiz.',
          );
        }

        if (rule.rule_type === 'DISCOUNT_PERCENT') {
          if (ruleValue > 100) {
            throw new BadRequestException(
              'Yüzdelik indirim 100 değerinden büyük olamaz.',
            );
          }

          discountAmount =
            (totalAmount * ruleValue) / 100;
        } else if (rule.rule_type === 'DISCOUNT_FIXED') {
          discountAmount = ruleValue;
        } else {
          throw new BadRequestException(
            'Bu kampanya türü sipariş kuponu olarak desteklenmiyor.',
          );
        }

        discountAmount = this.roundMoney(
          Math.min(discountAmount, totalAmount),
        );
      }

      const finalAmount = this.roundMoney(
        Math.max(0, totalAmount - discountAmount),
      );

      const order = orderRepo.create({
        order_number:
          'CC-' + Date.now().toString().slice(-6),
        user_id: data.userId,
        branch_id: data.branchId,
        total_amount: totalAmount,
        discount_amount: discountAmount,
        final_amount: finalAmount,
        status: 'Pending',
        items: orderItems,
      });

      // Sipariş ve ürün satırlarını aynı transaction içinde kaydet.
      const savedOrder = await orderRepo.save(order);

      // Ürün seçeneklerini kaydedilen ürün satırlarına bağla.
      for (const entry of optionsToSave) {
        const savedItem = savedOrder.items[entry.itemIndex];

        if (!savedItem?.id) {
          throw new Error(
            'Sipariş ürün satırı kaydedilemedi.',
          );
        }

        for (const option of entry.options) {
          option.order_item_id = savedItem.id;
        }

        await orderItemOptionRepo.save(entry.options);
      }

      // Kupon kullanımını ve sipariş bağlantısını kaydet.
      if (selectedCoupon) {
        const redemption = couponRedemptionRepo.create({
          coupon_id: selectedCoupon.id,
          order_id: savedOrder.id,
          user_id: data.userId,
        });

        await couponRedemptionRepo.save(redemption);

        selectedCoupon.used_count += 1;
        await couponRepo.save(selectedCoupon);
      }

      const completeOrder = await orderRepo.findOne({
        where: { id: savedOrder.id },
        relations: {
          items: {
            options: true,
          },
        },
      });

      if (!completeOrder) {
        throw new Error(
          'Oluşturulan sipariş tekrar okunamadı.',
        );
      }

      return completeOrder;
    });
  }

  private roundMoney(amount: number): number {
    return Number(amount.toFixed(2));
  }

  getBranchOrders(branchId: number) {
    return this.dataSource.getRepository(Order).find({
      where: { branch_id: branchId },
      relations: {
        items: {
          options: true,
        },
      },
      order: { created_at: 'DESC' },
    });
  }

  async updateStatus(orderId: number, status: string) {
    const orderRepo = this.dataSource.getRepository(Order);

    const order = await orderRepo.findOne({
      where: { id: orderId },
    });

    if (!order) {
      throw new NotFoundException('Sipariş bulunamadı.');
    }

    const previousStatus = order.status;

    order.status = status;

    const saved = await orderRepo.save(order);

    // Completed ve Delivered siparişin tamamlandığı durumlar olarak kabul edilir.
    // Bu durumlardan ilkine geçildiğinde yalnızca bir kez puan kazandırılır.
    const completedStatuses = ['Completed', 'Delivered'];

    const isNowCompleted = completedStatuses.includes(status);
    const wasAlreadyCompleted =
      completedStatuses.includes(previousStatus);

    if (isNowCompleted && !wasAlreadyCompleted) {
      await this.loyaltyService.earnFromOrder(
        saved.user_id,
        saved.id,
        Number(saved.final_amount),
      );
    }

    // Mevcut canlı sipariş bildirimi korunur.
    this.ordersGateway.notifyOrderStatusChanged(
      saved.id,
      saved.branch_id,
      saved.status,
    );

    return saved;
  }
}
