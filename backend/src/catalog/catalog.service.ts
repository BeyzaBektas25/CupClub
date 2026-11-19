import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Category } from './category.entity';
import { BranchProduct } from './branch-product.entity';
import { ProductOptionGroup } from './product-option-group.entity';
import { BranchOptionPrice } from './branch-option-price.entity';

@Injectable()
export class CatalogService {
  constructor(
    @InjectRepository(Category)
    private categoryRepo: Repository<Category>,

    @InjectRepository(BranchProduct)
    private branchProductRepo: Repository<BranchProduct>,

    @InjectRepository(ProductOptionGroup)
    private optionGroupRepo: Repository<ProductOptionGroup>,

    @InjectRepository(BranchOptionPrice)
    private branchOptionPriceRepo: Repository<BranchOptionPrice>,
  ) {}

  getCategories() {
    return this.categoryRepo.find({
      order: { display_order: 'ASC' },
    });
  }

  getBranchMenu(branchId: number) {
    return this.branchProductRepo.find({
      where: { branch_id: branchId },
      relations: {
        product: {
          category: true,
        },
      },
    });
  }

  async getProductOptions(branchId: number, productId: number) {
    const groups = await this.optionGroupRepo.find({
      where: { product_id: productId },
      relations: {
        options: true,
      },
    });

    const branchPrices = await this.branchOptionPriceRepo.find({
      where: { branch_id: branchId },
    });

    const branchPriceMap = new Map(
      branchPrices.map((price) => [
        price.option_id,
        price.additional_price,
      ]),
    );

    return groups.map((group) => ({
      id: group.id,
      name: group.name,
      is_required: group.is_required,
      min_selectable: group.min_selectable,
      max_selectable: group.max_selectable,

      options: group.options.map((option) => ({
        id: option.id,
        name: option.name,
        additional_price: Number(
          branchPriceMap.get(option.id) ??
            option.base_additional_price ??
            0,
        ),
      })),
    }));
  }
}